webhook-packages:
  pkg.installed:
    - pkgs:
      - python3

deployment-webhook:
  user.present:
    - system: true
    - home: /nonexistent
    - shell: /usr/sbin/nologin

