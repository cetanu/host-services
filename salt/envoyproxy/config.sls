{% set envoy = salt['pillar.get']('envoy_proxy', {}) %}

/etc/envoy/envoy.yaml:
  file.managed:
    - source: salt://envoyproxy/files/envoy.yaml.jinja
    - template: jinja
    - user: root
    - group: envoy
    - mode: '0640'
    - show_changes: false
    - require:
      - user: envoy

validate-envoy-config:
  cmd.run:
    - name: test -s /etc/envoy/envoy.yaml && /usr/local/bin/envoy --mode validate --config-path /etc/envoy/envoy.yaml
    - env:
        ENVOY_DYNAMIC_MODULES_SEARCH_PATH: /usr/local/lib/envoy/modules
    - require:
      - file: /etc/envoy/envoy.yaml
      - file: /usr/local/bin/envoy
      - file: /usr/local/lib/envoy/modules/libenvoy_acme_dynmod.so
