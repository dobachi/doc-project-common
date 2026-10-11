nodejs
=========

Installs Node.js JavaScript runtime

Requirements
------------

- Ansible 2.9 or higher
- Supported operating systems: Linux

Role Variables
--------------

This role has no configurable variables.

Dependencies
------------

None

Example Playbook
----------------

```yaml
- hosts: servers
  become: yes
  roles:
    - nodejs
```

Tags
----

- `nodejs`: Apply this tag to run only this role

License
-------

Apache-2.0（リポジトリ直下の LICENSE）

Author Information
------------------

dobachi
