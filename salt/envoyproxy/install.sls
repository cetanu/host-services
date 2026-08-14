{% set envoy = salt['pillar.get']('envoy_proxy', {}) %}
{% if envoy.get('enabled', False) %}
{% set version = envoy.get('envoy_version', '1.39.0') %}
{% set envoy_url = envoy.get('envoy_url', 'https://github.com/envoyproxy/envoy/releases/download/v' ~ version ~ '/envoy-' ~ version ~ '-linux-x86_64') %}
{% set module_url = envoy.get('module_url', 'https://github.com/cetanu/envoy-acme-dynmod/releases/latest/download/libenvoy_acme_dynmod-envoy-' ~ version ~ '.so') %}

envoyproxy-packages:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl

envoy:
  user.present:
    - system: true
    - home: /var/lib/envoy
    - createhome: true
    - shell: /usr/sbin/nologin

/etc/envoy:
  file.directory:
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: true

/usr/local/lib/envoy/modules:
  file.directory:
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: true

/var/lib/envoy-acme:
  file.directory:
    - user: envoy
    - group: envoy
    - mode: '0700'
    - makedirs: true

/usr/local/bin/envoy:
  file.managed:
    - source: {{ envoy_url }}
    - user: root
    - group: root
    - mode: '0755'
{% if envoy.get('envoy_source_hash') %}
    - source_hash: {{ envoy['envoy_source_hash'] }}
{% endif %}
    - require:
      - pkg: envoyproxy-packages

/usr/local/lib/envoy/modules/libenvoy_acme_dynmod-envoy-{{ version }}.so:
  file.managed:
    - source: {{ module_url }}
    - user: root
    - group: root
    - mode: '0755'
{% if envoy.get('module_source_hash') %}
    - source_hash: {{ envoy['module_source_hash'] }}
{% endif %}
    - require:
      - file: /usr/local/lib/envoy/modules

{% endif %}

