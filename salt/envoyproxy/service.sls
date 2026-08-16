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
      - file: /usr/local/lib/envoy/modules/libenvoy_acme_dynmod.so
    - require:
      - user: envoy
      - cmd: validate-envoy-config
      - cmd: run-initial-ddns-update
      - cmd: reload-systemd-for-envoyproxy
