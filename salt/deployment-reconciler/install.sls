reconciler-packages:
  pkg.installed:
    - pkgs:
      - salt-minion

/var/lib/deployment-reconciler:
  file.directory:
    - user: deployment-webhook
    - group: deployment-webhook
    - mode: '0750'
    - makedirs: true
    - require:
      - user: deployment-webhook

