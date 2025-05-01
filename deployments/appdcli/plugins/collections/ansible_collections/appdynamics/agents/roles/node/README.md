# AppDynamics role to install the node.js agent

```yml
---
- hosts: linux
  tasks:
    - include_role:
        name: appdynamics.agents.node
      vars:
        agent_version: latest # [latest or provide the specific agent version]
        agent_type: node
        agent_action: upgrade # can be upgrade/install/rollback, default upgrade when unspecified
        controller_account_access_key: "123key" # Please add this to your Vault
        controller_host_name: "fieldlab.saas.appdynamics.com" # Your AppDynamics controller
        controller_account_name: "customer1" # Please add this to your Vault
        enable_ssl: "false"
        controller_port: "8090"

```
