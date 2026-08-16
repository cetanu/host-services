/usr/local/libexec/reconcile-deployments:
  file.managed:
    - source: salt://deployment-reconciler/files/reconcile-deployments.sh
    - user: root
    - group: root
    - mode: '0755'
    - require:
      - file: /usr/local/libexec
