{% set envoy = salt['pillar.get']('envoy_proxy', {}) %}
{% if envoy.get('enabled', False) %}

/etc/envoy/envoy.yaml:
  file.managed:
    - contents_pillar: envoy_proxy:config
    - user: root
    - group: envoy
    - mode: '0640'
    - show_changes: false

validate-envoy-config:
  cmd.run:
    - name: /usr/local/bin/envoy --mode validate --config-path /etc/envoy/envoy.yaml
    - env:
        ENVOY_DYNAMIC_MODULES_SEARCH_PATH: /usr/local/lib/envoy/modules
    - require:
      - file: /etc/envoy/envoy.yaml
      - file: /usr/local/bin/envoy
      - file: /usr/local/lib/envoy/modules/libenvoy_acme_dynmod-envoy-{{ envoy.get('envoy_version', '1.39.0') }}.so

{% endif %}

