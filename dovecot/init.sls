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

{% set ddf = datamap.config.defaults_file %}
dovecot_defaults_file:
  file:
    - managed
    - name: {{ ddf.path }}
    - source: {{ ddf.template_path|default('salt://dovecot/files/defaults_file.' ~ salt['grains.get']('oscodename')) }}
    - mode: {{ ddf.mode|default(640) }}
    - user: {{ ddf.user|default('root') }}
    - group: {{ ddf.group|default('dovecot') }}
    - template: jinja
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
