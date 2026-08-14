/etc/caddy/apps/empty.caddy:
  file.managed:
    - contents: "# Application routes are managed by Salt.\n"
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: /etc/caddy/apps

validate-caddy-runtime-config:
  cmd.run:
    - name: test -s /etc/caddy/Caddyfile

