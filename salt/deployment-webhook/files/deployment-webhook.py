#!/usr/bin/env python3
"""Receive authenticated GitHub webhooks and queue one reconciliation."""

import hashlib
import hmac
import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

CONFIG_PATH = Path(os.environ.get("DEPLOYMENT_WEBHOOK_CONFIG", "/etc/deployment-webhook.json"))
STATE_DIRECTORY = Path(
    os.environ.get("DEPLOYMENT_RECONCILER_STATE", "/var/lib/deployment-reconciler")
)
PENDING_PATH = STATE_DIRECTORY / "pending"
PROCESSING_PATH = STATE_DIRECTORY / "processing"
MAX_BODY_BYTES = 1024 * 1024


def load_config():
    with CONFIG_PATH.open("r", encoding="utf-8") as config_file:
        return json.load(config_file)


CONFIG = load_config()


def signature_is_valid(body, supplied_signature):
    expected = "sha256=" + hmac.new(
        CONFIG["secret"].encode("utf-8"), body, hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, supplied_signature or "")


def queue_reconciliation():
    STATE_DIRECTORY.mkdir(mode=0o750, parents=True, exist_ok=True)
    descriptor = os.open(PENDING_PATH, os.O_WRONLY | os.O_CREAT, 0o640)
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)
    directory = os.open(STATE_DIRECTORY, os.O_RDONLY)
    try:
        os.fsync(directory)
    finally:
        os.close(directory)


def recover_interrupted_reconciliation():
    if PROCESSING_PATH.exists() and not PENDING_PATH.exists():
        PROCESSING_PATH.replace(PENDING_PATH)


class WebhookHandler(BaseHTTPRequestHandler):
    server_version = "deployment-webhook/1"

    def do_POST(self):
        if self.path != CONFIG["path"]:
            self.send_error(404)
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            self.send_error(400, "invalid content length")
            return
        if length <= 0 or length > MAX_BODY_BYTES:
            self.send_error(413, "invalid payload size")
            return

        body = self.rfile.read(length)
        if not signature_is_valid(body, self.headers.get("X-Hub-Signature-256")):
            self.send_error(401, "invalid signature")
            return

        try:
            payload = json.loads(body)
        except (UnicodeDecodeError, json.JSONDecodeError):
            self.send_error(400, "invalid JSON")
            return

        event = self.headers.get("X-GitHub-Event", "")
        if event == "ping":
            self.send_response(204)
            self.end_headers()
            return

        repository = payload.get("repository") or {}
        if (
            event != CONFIG["event"]
            or payload.get("action") != CONFIG["action"]
            or repository.get("id") not in CONFIG["repositoryIds"]
        ):
            self.send_error(403, "event is not an allowed deployment trigger")
            return

        queue_reconciliation()
        self.send_response(202)
        self.end_headers()

    def do_GET(self):
        if self.path == "/healthz":
            self.send_response(204)
            self.end_headers()
            return
        self.send_error(404)

    def log_message(self, message, *args):
        print("%s - %s" % (self.address_string(), message % args), flush=True)


def main():
    recover_interrupted_reconciliation()
    server = HTTPServer(
        (CONFIG["listenAddress"], CONFIG["listenPort"]), WebhookHandler
    )
    server.serve_forever()


if __name__ == "__main__":
    main()

