#!jinja|yaml

{% from 'dovecot/defaults.yaml' import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('dovecot:lookup')) %}

#TODO do we need postfix?

dovecot:
  pkg:
    - installed
    - pkgs: {{ datamap.pkgs }}
  service:
    - {{ datamap.service.ensure|default('running') }}
    - name: {{ datamap.service.name|default('dovecot') }}
    - enable: {{ datamap.service.enable|default(True) }}

dovecot_defaults_file:
  file:
    - managed
    - name: {{ datamap.config.defaults_file.path }}
    - source: {{ f.template_path|default('salt://dovecot/files/defaults_file.' ~ salt['grains.get']('oscodename')) }}
    - mode: {{ f.mode|default(640) }}
    - user: {{ f.user|default('root') }}
    - group: {{ f.group)|default('dovecot') }}
    - watch_in:
      - service: dovecot

{% for i in datamap.config.manage|default([]) %}
  {% set f = datamap.config[i] %}
dovecot_file_{{ i }}:
  file:
    - managed
    - name: {{ f.path }}
    - source: {{ f.template_path|default('salt://dovecot/files/' ~ i) }}
    - mode: {{ f.mode|default(640) }}
    - user: {{ f.user|default('root') }}
    - group: {{ f.group)|default('dovecot') }}
    - watch_in:
      - service: dovecot
{% endfor %}
