import hashlib
import hmac
import http.client
import importlib.util
import json
import os
import tempfile
import threading
import unittest
from pathlib import Path


class WebhookTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary = tempfile.TemporaryDirectory()
        root = Path(cls.temporary.name)
        config_path = root / "config.json"
        config_path.write_text(
            json.dumps(
                {
                    "secret": "test-secret",
                    "repositoryIds": [12345],
                    "event": "release",
                    "action": "published",
                    "path": "/hooks/github",
                    "listenAddress": "127.0.0.1",
                    "listenPort": 0,
                }
            ),
            encoding="utf-8",
        )
        os.environ["DEPLOYMENT_WEBHOOK_CONFIG"] = str(config_path)
        os.environ["DEPLOYMENT_RECONCILER_STATE"] = str(root / "state")
        module_path = (
            Path(__file__).parents[1]
            / "salt"
            / "deployment-webhook"
            / "files"
            / "deployment-webhook.py"
        )
        spec = importlib.util.spec_from_file_location("deployment_webhook", module_path)
        cls.webhook = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.webhook)
        cls.server = cls.webhook.HTTPServer(
            ("127.0.0.1", 0), cls.webhook.WebhookHandler
        )
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()
        cls.temporary.cleanup()

    def setUp(self):
        for marker in (self.webhook.PENDING_PATH, self.webhook.PROCESSING_PATH):
            marker.unlink(missing_ok=True)

    def request(self, payload, event="release", valid_signature=True):
        body = json.dumps(payload).encode()
        signature = "sha256=" + hmac.new(
            b"test-secret", body, hashlib.sha256
        ).hexdigest()
        if not valid_signature:
            signature = "sha256=" + "0" * 64
        connection = http.client.HTTPConnection(*self.server.server_address)
        connection.request(
            "POST",
            "/hooks/github",
            body=body,
            headers={
                "Content-Type": "application/json",
                "X-GitHub-Event": event,
                "X-Hub-Signature-256": signature,
            },
        )
        response = connection.getresponse()
        response.read()
        connection.close()
        return response.status

    def test_valid_release_queues_reconciliation(self):
        status = self.request(
            {"action": "published", "repository": {"id": 12345}}
        )
        self.assertEqual(status, 202)
        self.assertTrue(self.webhook.PENDING_PATH.exists())

    def test_invalid_signature_is_rejected(self):
        status = self.request(
            {"action": "published", "repository": {"id": 12345}},
            valid_signature=False,
        )
        self.assertEqual(status, 401)
        self.assertFalse(self.webhook.PENDING_PATH.exists())

    def test_wrong_repository_is_rejected(self):
        status = self.request(
            {"action": "published", "repository": {"id": 99999}}
        )
        self.assertEqual(status, 403)
        self.assertFalse(self.webhook.PENDING_PATH.exists())

    def test_signed_ping_does_not_reconcile(self):
        status = self.request({}, event="ping")
        self.assertEqual(status, 204)
        self.assertFalse(self.webhook.PENDING_PATH.exists())


if __name__ == "__main__":
    unittest.main()
