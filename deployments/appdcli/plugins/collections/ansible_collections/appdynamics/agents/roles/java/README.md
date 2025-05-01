# AppDynamics role to install the Java agent

This role features:

- java-agent installation for Windows/Linux

Example 1: Install java-agent without any apps instrumentation.

```yml
---
- hosts: all
  tasks:
    - name: Include variables for the controller settings
      # Include all yaml files under the vars directory
      include_vars:
        dir: vars
        extensions:
          - 'yaml'
          - 'yml'
    - include_role:
        name: appdynamics.agents.java
      vars:
        agent_version: 21.1.0
        agent_type: java
        agent_action: upgrade # can be upgrade/install/rollback/uninstall, defaults to upgrade when unspecified
        application_name: "IoT_API" # agent default application
        tier_name: "java_tier" # agent default tier
        java_agent_install_args:
          #customise Java Agent installation path for Linux/Windows.
          LINUX_INSTALL_PATH: /opt/appdynamics/java
          WINDOWS_INSTALL_PATH: C:\appdynamics\java_agent
```

Java agent specific variables:

| Variable                            | Description                                                                                                   | Default |
|-------------------------------------|---------------------------------------------------------------------------------------------------------------|---------|
| java_agent_is_simple_hostname       | Truncate the hostname to remove the domain name                                                               | False   |
| java_agent_encrypted_creds          | Use Encrypted Credentials                                                                                     | ""      |
| java_agent_credential_store_file    | Full qualified path name for the SCS-KeyStore                                                                 | ""      |
| java_agent_credential_store_pass    | Password for the 'Secure Credential Store'                                                                    | ""      |
| java_agent_credential_store_format  | File Format for the 'Secure Credential Store' (SCS)                                                           | ""      |
| java_agent_ssl_client_auth          | Enable agent-side mutual authentication with the Controller                                                   | ""      |
| java_agent_assymetric_keystore_name | Asymmetric keystore filename                                                                                  | ""      |
| java_agent_assymetric_keystore_pass | Asymmetric keystore password                                                                                  | ""      |
| java_agent_assymetric_key_pass      | Asymmetric key password - If SCS is enabled, use the encrypted password.                                      | ""      |
| java_agent_assymetric_key_alias     | Asymmetric key alias - Only set this alias if the keystore has multiple keys for deterministic key selection. | ""      |
| java_agent_force_registration       | Use when Node moved to different Tier/App                                                                     | False   |
| java_agent_auto_naming              | Use when Node moved to different Tier/App                                                                     | False   |
| java_agent_runtime_dir              | The runtime directory for all runtime files                                                                   | False   |
| java_agent_enable_orchestration     | Enable features required for AppDynamics Orchestration.                                                       | False   |
