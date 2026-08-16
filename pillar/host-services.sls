envoy_proxy:
  envoy_version: '1.39.0'
  envoy_url: https://github.com/envoyproxy/envoy/releases/download/v1.39.0/envoy-1.39.0-linux-x86_64
  envoy_source_hash: sha256:4409dadc87931d8f8676314cbd83071cb65125fb4feac3f6335800580dfa9218
  module_url: https://github.com/cetanu/envoy-acme-dynmod/releases/download/v0.2.0/libenvoy_acme_dynmod-envoy-1.39.0.so
  module_source_hash: sha256:2f4a73066a6a0c16a31905d77f85457eb28dd01bff41376a209e8cfc78b210af
  acme_contact_email: syrakis@pm.me
  routes:
    - name: rtmp-manager
      domain: rtmp.vsyrakis.dev
      port: 3000
    - name: socketything
      domain: presence.vsyrakis.dev
      port: 4000
    - name: deployment-webhook
      domain: deploy.vsyrakis.dev
      port: 9100
      path: /hooks/github
