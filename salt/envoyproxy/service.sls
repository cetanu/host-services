{% set envoy = salt['pillar.get']('envoy_proxy', {}) %}
{% if envoy.get('enabled', False) %}

/etc/systemd/system/envoy.service:
  file.managed:
    - source: salt://envoyproxy/files/envoy.service
    - user: root
    - group: root
    - mode: '0644'

reload-systemd-for-envoyproxy:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/envoy.service

envoy.service:
  service.running:
    - enable: true
    - watch:
      - file: /etc/envoy/envoy.yaml
      - file: /usr/local/bin/envoy
      - file: /usr/local/lib/envoy/modules/libenvoy_acme_dynmod-envoy-{{ envoy.get('envoy_version', '1.39.0') }}.so
    - require:
      - user: envoy
      - cmd: validate-envoy-config
      - cmd: reload-systemd-for-envoyproxy

{% endif %}
