caddy-packages:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl

caddy:
  user.present:
    - system: true
    - home: /var/lib/caddy
    - createhome: true
    - shell: /usr/sbin/nologin

/etc/caddy/apps:
  file.directory:
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: true

install-caddy:
  cmd.run:
    - name: curl -fsSL --retry 3 'https://caddyserver.com/api/download?os=linux&arch=amd64' -o /usr/local/bin/caddy && chmod 0755 /usr/local/bin/caddy
    - unless: test -x /usr/local/bin/caddy
    - require:
      - pkg: caddy-packages

