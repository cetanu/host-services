/etc/systemd/system/deployment-webhook.service:
  file.managed:
    - source: salt://deployment-webhook/files/deployment-webhook.service
    - user: root
    - group: root
    - mode: '0644'

reload-systemd-for-deployment-webhook:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/deployment-webhook.service

deployment-webhook.service:
  service.running:
    - enable: true
    - require:
      - user: deployment-webhook
      - file: /usr/local/libexec/deployment-webhook
      - cmd: set-deployment-webhook-config-permissions
      - cmd: validate-deployment-webhook-config
      - cmd: reload-systemd-for-deployment-webhook
