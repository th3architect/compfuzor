---
# postfix
# expects: configset - configuration file for a set of zones to load
- hosts: all
  tags:
  - packages
  - root
  gather_facts: False
  vars:
    TYPE: postfix
    INSTANCE: main 
    ETC_DIRS:
    - ssl
    TEMPLATES:
    - aliases
    - main.cf
    POSTMAP:
    - aliases
  vars_files:
  - vars/common.vars
  - vars/srv.vars
  - files/postfix/defaults.vars
  - [ "private/postfix/$configset.vars" ]
  handlers:
  - include: handlers.yml
  tasks:
  - include: tasks/cfvar_includes.tasks
  - apt: state=${APT_INSTALL} pkg=postfix
  - template: src=files/postfix/${item} dest=${ETC.stdout}/${item}
    with_items: $TEMPLATES
    notify: restart service
  - shell: chdir=${ETC.stdout} postmap ${item}
    with_items: $POSTMAP
  - file: src=/etc/postfix/master.cf dest=${ETC.stdout}/master.cf state=link