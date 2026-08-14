ddns-packages:
  pkg.installed:
    - pkgs:
      - curl

/var/lib/host-services:
  file.directory:
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: true

