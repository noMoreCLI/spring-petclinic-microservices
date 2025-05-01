# Php agent

This role features:

- php-agent installation for Linux or Redhat based System

Example 1: Install php-agent without any apps instrumentation.

```yml
---
- hosts: all
  tasks:
    - include_role:
        name: appdynamics.agents.php
      vars:
        agent_version: latest
        agent_type: php
        agent_action: upgrade 
        application_name: e-commerce 
        controller_account_access_key: "123key" 
        controller_host_name: "fieldlab.saas.appdynamics.com" 
        controller_account_name: "customer1"
        enable_ssl: false
        controller_port: 8090
        tier_name: tier1 
        node_name: node1 
        log_directory: "/opt/appdynamics/php-agent/ecommerce_logs" 
        zts_support: false 
        
        # proxy configs
        proxy_host: master.ecommerce-proxy.com 
        proxy_port: 8080
        proxy_user: ecommerce-user 
        proxy_password_file: /etc/ecommerce/passwd
        proxy_ctrl_dir: /ecommerce/proxy_dir/
```

Example 2: Upgrading php-agent on an absolute path where agent in already manually installed

```yml
---
- hosts: all
  tasks:
    - include_role:
        name: appdynamics.agents.php
      vars:
        agent_version: latest
        agent_type: php
        agent_action: upgrade 
        application_name: e-commerce 
        controller_account_access_key: "123key" 
        controller_host_name: "fieldlab.saas.appdynamics.com" 
        controller_account_name: "customer1"
        enable_ssl: false
        controller_port: 8090
        tier_name: tier1 
        node_name: node1 
        log_directory: "/opt/appdynamics/php-agent/ecommerce_logs" 
        zts_support: false 
        linux_custom_agent_install_path: "/home/ubuntu/ecommerce_agent/" #this path should contain the agent files (eg: install.sh ,php etc)
        custom_agent_ini_file: "/etc/php/7.4/cli/conf.d/appdynamics_agent.ini" #this file should contain your agent controller details
        
       
```


### Php agent specific variables and configuration

|Variable<img width="200"/>     | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`zts_support` | By Default `false`. If you want to install PHP ZTS agent set it to `true` | `true` or `false`| optional | `false`|
|`log_directory`| By default `logs` folder is created inside agent directory. But you specify your log directory | `<agent-directory>/logs` | optional | `<agent-directory>/logs`  |
|`php_executable_path`| By default it take the php path installed in System , but you can specify the path for php PHP binary | `/usr/bin/php` | optional | `global php path set`  |
|`php_ini_dir`| ini directory for the appdynamics_agent.ini file. Needed on Ubuntu as well as when the default PHP CLI binary cannot be determined. | `/etc/php/` | optional | `global php ini path set` |
|`php_extension_dir`| Extensions directory for the appdynamics_agent.so file. Needed on Ubuntu as well as when the default PHP CLI binary cannot be determined. | `/etc/php/extensions/` | optional | `global php extension path set` |
|`php_version`| Version of PHP that you are instrumenting. Valid formats are version numbers to one or two decimal positions, for example, 7.4 and 7.4.29. Needed only when the default PHP CLI binary cannot be determined or there is no PHP CLI binary. | `7.4.29` | optional | `global php verdsion set` |
|`enable_cli`| Set `true` if you want to enable agent for CLI mode | `true` or `false` | optional | `None` |
|`enable_cli_long_running`| Set to true to defend PHP in long-running CLI applications. Defaults to false. See [Long-Running CLI Applications with the Suhosin Patch.](https://docs.appdynamics.com/appd/4.5.x/en/application-monitoring/install-app-server-agents/php-agent/install-the-php-agent/configure-the-agent-for-php-cli-applications#ConfiguretheAgentforPHPCLIApplicatins-LongRunningCLIPatch) | `true` or `false` | optional | `None` |
|`ignore_permissions`| Set to `true` if you want to ignore file and directory permission issues | `true` or `false` | optional | `None` |
|`custom_agent_ini_file`| Set the absolute path of `appdynamics_agent.ini` file of your custom path agent  | For default it takes the default ini path set in your php settings | required( if `linux_custom_agent_install_path` is defined) | `None` 

**Note:**
1. To  get the `appdynamics_agent.ini` path use the command `php -i|grep appdynamics_agent.ini` and set the `custom_agent_ini_file` with the absolute file path if your agent in not installed in default location ie if you are using `linux_custom_agent_install_path`
2. If you want to install agent in different php version which is not set globally please keep in mind that `php_executable_path`,  `php_ini_dir`,  `php_extension_dir`,  `php_version` are required parameters otherwise agent installation will fail. These parameters are required for all `agent_action` so if you installing in some other php version try to keep these required attributes all time in the playbook.


### Custom Proxy Configuration

|Variable<img width="200"/>     | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`proxy_host`| proxy host to route data to the controller through a proxy server. By default none optional parameter | `master.ecommerce-proxy.com` | optional | `None` |
|`proxy_port`| proxy port to route data to the controller through a proxy server. By default none optional parameter | `8090` | optional | `None` |
|`proxy_user`| proxy user to login in proxy server host. By default none optional parameter | `ecommere-user` | optional | `None` |
|`proxy_password_file`| proxy password file to login in proxy server host. By default none optional parameter | `/etc/ecommerce/passwd` | optional | `None` |
|`proxy_ctrl_dir`| The proxy control directory If not specified, the installer creates a temporary directory. | `/ecommerce/proxy_dir/` | optional | `None` |

