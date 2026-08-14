/etc/systemd/system/caddy.service:
  file.managed:
    - source: salt://caddy/files/caddy.service
    - user: root
    - group: root
    - mode: '0644'

reload-systemd-for-caddy:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/caddy.service

caddy.service:
  service.running:
    - enable: true
    - reload: true
    - require:
      - user: caddy
      - cmd: install-caddy
      - file: /etc/caddy/apps/empty.caddy
      - cmd: validate-caddy-runtime-config
      - cmd: run-initial-ddns-update
      - cmd: reload-systemd-for-caddy
