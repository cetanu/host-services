/etc/systemd/system/update-ddns.service:
  file.managed:
    - source: salt://ddns/files/update-ddns.service
    - user: root
    - group: root
    - mode: '0644'

/etc/systemd/system/update-ddns.timer:
  file.managed:
    - source: salt://ddns/files/update-ddns.timer
    - user: root
    - group: root
    - mode: '0644'

reload-systemd-for-ddns:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/update-ddns.service
      - file: /etc/systemd/system/update-ddns.timer

run-initial-ddns-update:
  cmd.run:
    - name: systemctl start update-ddns.service && install -o root -g root -m 0644 /dev/null /var/lib/host-services/ddns-initialized
    - unless: test -e /var/lib/host-services/ddns-initialized
    - require:
      - file: /var/lib/host-services
      - file: /usr/local/libexec/update-ddns
      - cmd: reload-systemd-for-ddns
      - cmd: validate-ddns-runtime-config

update-ddns.timer:
  service.running:
    - enable: true
    - require:
      - cmd: reload-systemd-for-ddns
