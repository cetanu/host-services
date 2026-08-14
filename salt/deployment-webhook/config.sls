/usr/local/libexec/deployment-webhook:
  file.managed:
    - source: salt://deployment-webhook/files/deployment-webhook.py
    - user: root
    - group: root
    - mode: '0755'

set-deployment-webhook-config-permissions:
  cmd.run:
    - name: chown root:deployment-webhook /etc/deployment-webhook.json && chmod 0640 /etc/deployment-webhook.json
    - onlyif: test -f /etc/deployment-webhook.json
    - require:
      - user: deployment-webhook

validate-deployment-webhook-config:
  cmd.run:
    - name: test -s /etc/deployment-webhook.json
