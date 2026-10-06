/usr/local/libexec/deployment-webhook:
  file.managed:
    - source: salt://deployment-webhook/files/deployment-webhook.py
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: /usr/local/libexec

set-deployment-webhook-config-permissions:
  file.managed:
    - name: /etc/deployment-webhook.json
    - user: root
    - group: deployment-webhook
    - mode: '0640'
    - create: false
    - require:
      - user: deployment-webhook

validate-deployment-webhook-config:
  cmd.run:
    - name: test -s /etc/deployment-webhook.json
    - stateful: true
    - require:
      - file: set-deployment-webhook-config-permissions
