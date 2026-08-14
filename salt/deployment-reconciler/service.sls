/etc/systemd/system/deployment-reconcile.path:
  file.managed:
    - source: salt://deployment-reconciler/files/deployment-reconcile.path
    - user: root
    - group: root
    - mode: '0644'

/etc/systemd/system/deployment-reconcile.service:
  file.managed:
    - source: salt://deployment-reconciler/files/deployment-reconcile.service
    - user: root
    - group: root
    - mode: '0644'

reload-systemd-for-deployment-reconciler:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/deployment-reconcile.path
      - file: /etc/systemd/system/deployment-reconcile.service

deployment-reconcile.path:
  service.running:
    - enable: true
    - require:
      - file: /var/lib/deployment-reconciler
      - file: /usr/local/libexec/reconcile-deployments
      - cmd: reload-systemd-for-deployment-reconciler
