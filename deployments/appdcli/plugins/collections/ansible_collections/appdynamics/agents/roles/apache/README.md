# AppDynamics role to install the Apache agent

This role features:

- apache installation for Linux (Debian and  RedHat)

Install apache agent and take backup if already installed

```yml
---
- hosts: all
  tasks:
    - name: Include variables for the controller settings
      include_vars:
          # Include all yaml files under the vars directory
          dir: vars
          extensions:
          - 'yaml'
          - 'yml'

    - ansible.builtin.include_role:
        name: appdynamics.agents.apache
      vars:
        agent_version: 22.12.1
        # possible value:
        #          - latest: Latest version
        #          - 22.12.1: Any Specific version number
        agent_type: apache
        agent_action: upgrade
        # possible value:
        #          - upgrade: upgrade currently installed agent to agent_version
        #          - install: install agent_version
        #          - rollback: rollback to previous backup if any
        # Apache specific Args
        #apache_conf_path:
        # possible value:
        #          - /etc/httpd/conf/httpd.conf #default path in case of RedHat
        #          - /etc/apache2/apache2.conf  #Default path in case of Debian
        #          - #any custom path where the conf file is located.
        #
        #The following variables are applicable for appdynamics_agent.conf file and the details can be referred from [Apache Agent Documentation](https://docs.appdynamics.com/appd/23.x/latest/en/application-monitoring/install-app-server-agents/apache-web-server-agent/install-the-apache-agent)
        # The naming convention
        # appdynamics_enabled: ON | OFF  #Default value is ON
        # appdynamics_proxy_host: <proxy host> # Default is empty string
        # appdynamics_proxy_port: <proxy port> # Default is empty string
        # appdynamics_launch_proxy: ON | OFF #Default is ON
        # appdynamics_resolve_backends: ON | OFF #Default is ON
        # appdynamics_trace_as_error: ON | OFF   # Default is OFF
        # appdynamics_report_all_instrumented_modules: ON | OFF # Default is OFF
        # appdynamics_backend_name_segments: 0 # Default is O
        # appdynamics_proxy_comm_dir: <path> #Default is set to installation folder
        # appdynamics_request_cache_cleanup_interval: 60000  # Default is 60000
        # appdynamics_mask_cookie: OFF | ON # Default is OFF
        # appdynamics_mask_cookie_pattern: <pattern>
        # appdynamics_mask_sm_user: OFF | ON #Default is OFF
        # appdynamics_delimiter: <delimiter>
        # appdynamics_segment: <segment>
        # appdynamics_match_filter: <filter>
        # appdynamics_match_pattern: <pattern>

```