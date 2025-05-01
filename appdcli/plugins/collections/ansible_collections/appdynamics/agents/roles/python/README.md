# AppDynamics role to install the Python agent

This role features:

- Python Agent installation for Linux (Debian, Alpine and RedHat)

Install python agent and take backup if already installed

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
        name: appdynamics.agents.python
      vars:
        agent_version: 22.10.0.5500.0
        # possible value:
        #          - latest: Latest version 
        #          - 22.10.0.5500.0: Any Specific version number
        agent_type: python
        agent_action: upgrade
        # possible value:
        #          - upgrade: upgrade currently installed agent to agent_version 
        #          - install: install agent_version
        #          - rollback: rollback to previous backup if any
        #          - uninstall: uninstall agent
        # Python specific Args
        install_env: default # [default - (main python path taken automatically), virtualenv - (virtualenv path need to be provided)]
        # possible value:
        #          - default: install agent in global python
        #          - virtualenv: install agent  to specific virtualenv
        virtualenv_path: /home/ansible/venv
        # possible value:
        #          - /home/ansible/venv: virtualenv path
        #          - None
        install_agent_from: appd-portal
        # possible value:
        #          - pypi: Downlaod agent from PYPI
        #          - appd-portal: Download agent from AppD portal
        
```

### Starting a Sample Flask app with Python Agent
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
        name: appdynamics.agents.python
    
    - name: Start Sample Python app
      shell: "nohup pyagent run -c /opt/appdynamics/python-agent/appd.cfg python3 /home/ubuntu/app.py &"
      async: 100
      poll: 0
      register: status
      failed_when: "'FAILED' in status.stdout"

Config path and the application path has to be changed accordingly. 

```

### Python Agent Ansible variables

|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`agent_version` | Version of the Python Agent to use for a given action | [latest, X.X.X.X]; where X.X.X.X is a version, e.g. 22.10.0.5500.0 | N | latest
|`agent_action` | Defines action for agent | [`install`<sup>\*</sup>, `upgrade`, `rollback`<sup>\*\*</sup>, `uninstall`] | N | install
|`download_uri` | In case install is done using whl files other than default Appdynamics Download Portal then specify tar.bz2 file url | url | N | https://download.appdynamics.com/download
|`download_protocol` | Defines how the Python Agent should be downloaded from download_uri | [http, local, nfs] | N | http
|`keep_backup` | Flag to Keep backup folder in case of an uninstall | [true, false] | N | false
|`max_agent_backup_count` | Counter to provide the number of backups to be retained  | Number | N | 1
|`agent_config_path` | In case you want to use the previous config file data (which was created manually). User should provide the absolute file path including the file name | file_path | N | agent_destination_directory


<sup>\*</sup>usually install is performed on a fresh machine however if the `agent_action`=`install` is executed and there is a Python Agent installed on the machine the role will imply the upgrade

<sup>\*\*</sup>`agent_action`=`rollback` will honor the previous agent configuration (taken from backup) and will ignore any agent configuration settings defined in the role

### How is Configuration file Generated and Maintained

* Case 1: System already has an agent installed manually. If you want to use the same config in the newer upgrade use `agent_config_path` it will take the data from this file for the current upgraded agent. (This is treated as an upgrade, so make sure you set `agent_action` to upgrade)

* Case 2: No Existing installation is found and the new installation is done using ansible. This will generate a new config file based on the Vars provided by the user for the roles else default values will be used.

#### Config Diff Merge Priority (High to Low)

Data passed to the role vars >>> Data found on Config file on the system >>> Default Values

### Python Agent specific Ansible variables

|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`install_env` | Python Environment where to install Appdynamics Agent (global or vitualenv) | [default, virtualenv] | N | default
|`virtualenv_path` | Path to virtualenv. Only required if `install_env` set to virtualenv | [None, `venv_path`]|Y if `install_env` == virtualenv, N if `install_env` == default | None
|`install_agent_from`<sup>\*</sup> | Install Agent from PYPI or Appdynamics Download Portal | [pypi, appd-portal] | N | pypi 
|`pypi_index_url` | Change the pypi index url to any internal artifactory | url | N | https://pypi.org/simple 

<sup>\*</sup>Once install_agent_from is selected it will remain same throughout the lifecycle of the agent. If changed it might cause error during next upgrade or rollback as pypi and virtualenv has different strategies to handle backup and other actions
### Python Agent Config specific  Ansible variables

#### [agent]
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`agent_dir` | Base directory for files related to the AppDynamics agent | directory | N | /tmp/appd/
|`node_reuse` | Reuse Node Name	 |[true, false] | N | 
|`node_reuse_prefix` | Reuse Node Name Prefix | | N |  
|`unique_host_id` | Unique host id for the app agents | | N |

#### [wsgi]
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`wsgi_script` | Path to WSGI script file | | N | 
|`wsgi_callable` | Name of WSGI callable in script/module | | N | application
|`wsgi_module` | Fully-qualified name of app module | | N |  

#### [log]
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`log_level` | The directory to write proxy and agent logs to	 | [warning, debug, info] | N | warning
|`log_debugging` | The level to log at one of: warning, info, or debug	 | [off, on] | N | off
|`log_dir` | On to write DEBUG level logs to stderr and log files	 | | N |  /tmp/appd/logs

#### [eum]
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`eum_disable_cookie` | If set, the agent does not add EUM correlation data to WSGI response headers.	 | [on, off] | N | off
|`eum_user_agent_allowlist` | If specified overwrites the default allowlist for user agent added as EUM correlation data headers Use this setting to specify alternate user agents as a comma separated list. Use '*' to allow all user agents.| | N | 'Mozilla, Opera, WebKit, Nokia'

#### [services:snapshot]
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`snapshot_exit_call_details_length` | Specifies the number of characters in the details string describing exit calls in transaction snapshots. | | N | 100


#### [services:transaction-monitor]
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`transaction_monitor_bt_max_duration_ms` | Maximum duration of a business transaction in milliseconds. | | N | 120000


#### [services:analytics]
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`analytics_host` | Analytics Agent host	|| N | localhost
|`analytics_port` |Analytics Agent port  || N | 9090
|`analytics_ssl` | Set it on to enable SSL communication with the Analytics Agent	 | | N |  off
|`analytics_ca_file` | Certificate of the CA authority that signed the certificate of Analytics Agent.| | N | 

#### [controller:http-proxy]
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`proxy_host` | HTTP proxy host	|proxy.example.org| N | None
|`proxy_port` | HTTP proxy port | 8090 | N | 80
|`proxy_user` | HTTP proxy user	 | proxyuser | N |  None
|`proxy_password_file` | CHTTP proxy password file| /etc/http-proxy.passwd | N | None

#### [proxy]
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`max_heap_size` | Max heap size for proxy	|450| N | 300
|`min_heap_size` | Min heap size for proxy	|100| N | 50
|`max_perm_size` | Max permanent generation size	|150| N | 120
|`proxy_debug_port` | Port number to which to attach the JAVA debugger	|8092| N | None
|`start_suspended` | Specifies whether to debug proxy startup with a JAVA debugger.	|om| N | off
|`debug_opt` | Specifies the debug opt for debugging	|agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8090| N | None
|`proxy_agent` | Specifies the Agent type (Eg PYTHON_APP_AGENT, NODEJS_APP_AGENT etc)	|NODEJS_APP_AGENT| N | PYTHON_AGENT
|`tcp_comm_host` | Host over which the agent-proxy TCP communication takes place	|127.0.0.1| N | None
|`tcp_comm_port` | 	Port over which initial communication requests between the agent and proxy occurs	|8080| N | None
|`tcp_reporting_port` | Port for reporting transport (Agent only property)	|10010| N | None
|`tcp_request_port` | Port for request and config transport (Agent only property)	|10011| N | None
|`tcp_port_range` | Port range to allocate request and report port for agents (Proxy only property)	|10000-10100| N | None


## Molecule Tests

Tests are written using [molecule](https://github.com/ansible-community/molecule).

### Install optional dependencies

``` sh
pip install molecule
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.windows
```

### Running all the tests

``` sh
molecule test --all
```

### Running individual tests

```sh
molecule test -s <scenario name>
```



## CURRENT LIMITATIONS

1. Agent Upgrade do not retain previous Agent configuration and always honor the configuration properties provided in the role. If no property is provided then a default minimal configuration will be used. This is also the case when a previous installation was not managed by this role, the Agent configuration will be overridden according to the role settings. Please make sure to backup all important configuration before running this role
1. Python Agent Rollback is not supported in the following situations:
   - if Agent was never installed on the machine or the previous Agent installation was not managed by this role
   - if the rollback is already performed; only rollback to one previous version is supported
