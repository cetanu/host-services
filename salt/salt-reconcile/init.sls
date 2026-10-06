salt-reconcile-packages:
  pkg.installed:
    - pkgs:
      - cron
      - salt-minion

cron:
  service.running:
    - enable: true
    - require:
      - pkg: salt-reconcile-packages

periodic-salt-reconcile:
  cron.present:
    - name: /usr/bin/salt-call --local --retcode-passthrough state.apply > /var/log/salt-reconcile.log 2>&1
    - user: root
    - minute: '*/5'
    - identifier: periodic-salt-reconcile
    - require:
      - service: cron
