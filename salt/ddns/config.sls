/usr/local/libexec/update-ddns:
  file.managed:
    - source: salt://ddns/files/update-ddns.sh
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: /usr/local/libexec

validate-ddns-runtime-config:
  cmd.run:
    - name: test -s /etc/default/update-ddns
