#!jinja|yaml

{% from 'dovecot/defaults.yaml' import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('dovecot:lookup')) %}

include: {{ datamap.sls_include|default([]) }}
extend: {{ datamap.sls_extend|default({}) }}

dovecot:
  pkg:
    - installed
    - pkgs: {{ datamap.pkgs }}
  service:
    - {{ datamap.service.ensure|default('running') }}
    - name: {{ datamap.service.name|default('dovecot') }}
    - enable: {{ datamap.service.enable|default(True) }}

{% set f = datamap.config.defaults_file|default({}) %}
dovecot_defaults_file:
  file:
    - managed
    - name: {{ f.path }}
    - source: {{ f.template_path|default('salt://dovecot/files/defaults_file.' ~ salt['grains.get']('oscodename')) }}
    - mode: {{ f.mode|default(640) }}
    - user: {{ f.user|default('root') }}
    - group: {{ f.group|default('dovecot') }}
    - template: jinja
    - watch_in:
      - service: dovecot

{% set f = datamap.config.dsync_backup_dir|default({}) %}
dovecot_dsync_backup_dir:
  file:
    - directory
    - name: {{ f.path|default('/var/backups/dsync') }}
    - mode: {{ f.mode|default(700) }}
    - user: {{ f.user|default('mail') }}
    - group: {{ f.group|default('mail') }}

{% set f = datamap.config.sieve_global_dir|default({}) %}
dovecot_sieve_global_dir:
  file:
    - recurse
    - name: {{ f.path }}
    - source: {{ f.source|default('salt://dovecot/files/sieve_global') }}
    - file_mode: {{ f.file_mode|default(644) }}
    - dir_mode: {{ f.dir_mode|default(755) }}
    - user: {{ f.user|default('root') }}
    - group: {{ f.group|default('root') }}

dovecot_sieve_global_compile:
  cmd:
    - wait
    - name: sievec {{ datamap.config.sieve_global_dir.path }}
    - cwd: /var/tmp
    - user: root
    - watch:
      - file: dovecot_sieve_global_dir
    - watch_in:
      - service: dovecot

{% for i in datamap.config.manage|default([]) %}
  {% set f = datamap.config[i] %}
dovecot_file_{{ i }}:
  file:
    - managed
    - name: {{ f.path }}
    - source: {{ f.template_path|default('salt://dovecot/files/generic') }}
    - mode: {{ f.mode|default(640) }}
    - user: {{ f.user|default('root') }}
    - group: {{ f.group|default('dovecot') }}
    - template: jinja
    - context:
      comp: {{ i }}
    - watch_in:
      - service: dovecot
{% endfor %}

dovecot_passwd:
  file:
    - managed
    - name: /etc/dovecot/passwd
    - mode: 600
    - user: dovecot
    - group: root
