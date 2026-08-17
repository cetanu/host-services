envoy_proxy:
  envoy_version: '1.39.0'
  envoy_url: https://github.com/envoyproxy/envoy/releases/download/v1.39.0/envoy-1.39.0-linux-x86_64
  envoy_source_hash: sha256=4409dadc87931d8f8676314cbd83071cb65125fb4feac3f6335800580dfa9218
  module_url: https://github.com/cetanu/envoy-acme-dynmod/releases/download/v0.2.1/libenvoy_acme_dynmod-envoy-1.39.0-ubuntu-22.04-glibc-2.35.so
  module_source_hash: sha256=484130752ba1ead56d7255e74459f20e105016b0d580bd73d91cffd0d397ae15
  acme_contact_email: syrakis@pm.me
  routes:
    - name: rtmp-manager
      domain: rtmp.vsyrakis.dev
      port: 3000
    - name: socketything
      domain: presence.vsyrakis.dev
      port: 4000
      upgrade_configs:
        - upgrade_type: websocket
    - name: deployment-webhook
      domain: deploy.vsyrakis.dev
      port: 9100
      path: /hooks/github
