# Copy the envoy_proxy mapping into the host's private pillar data and set
# enabled to true only when the Envoy listener configuration is ready.
envoy_proxy:
  enabled: false
  envoy_version: '1.39.0'
  envoy_url: https://github.com/envoyproxy/envoy/releases/download/v1.39.0/envoy-1.39.0-linux-x86_64
  module_url: https://github.com/cetanu/envoy-acme-dynmod/releases/latest/download/libenvoy_acme_dynmod-envoy-1.39.0.so
  # Prefer sha256:<digest> values for both downloaded artifacts.
  # envoy_source_hash: sha256:<digest>
  # module_source_hash: sha256:<digest>
  config: |
    # See envoy-acme-dynmod/README.md for the dynamic filter and SDS wiring.
    # This example is intentionally incomplete and must be replaced.

