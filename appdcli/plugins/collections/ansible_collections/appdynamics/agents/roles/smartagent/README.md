# AppDynamics role to install the Smart Agent 


```yml
---
- hosts: linux
  tasks:
    - include_role:
        name: appdynamics.agents.smartagent
      vars:
        # Auto start smart agent after install
        smartagent_auto_start: true

```