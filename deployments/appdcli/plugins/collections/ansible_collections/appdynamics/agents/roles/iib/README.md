# IIB agent

This role features:

- iib-agent installation for AIX or Redhat based System

Example 1: Install iib agent in linux or redhat playbook

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

    - include_role:
        name: appdynamics.agents.iib
      vars:
        agent_version: latest
        # possible value:
        #          - latest: Latest version 
        #          - 22.10.0.5500.0: Any Specific version number
        agent_type: iib
        agent_action: upgrade
        # possible value:
        #          - upgrade: upgrade currently installed agent to  agent_version 
        #          - install: install agent_version
        #          - rollback: rollback to previous backup if any
        #    For config reefer https://docs.appdynamics.com/appd/22.x/22.5/en/application-monitoring/install-app-server-agents/ibm-integration-bus-agent/install-the-iib-agent
        #Specify the settings for the agent-controller communication. In the controller-info.xml file, set these properties:
        controller_account_name: ecommerce #Account name of the controller login.
        controller_account_access_key: "123-xyz-ade-lop" #Access key. This key is used for verification with the controller.
        application_name: "default" #Name of the application that the IIB server belongs to.
        controller_host_name: "controller.ecommerce.com" #Hostname of the controller.
        controller_port: 8090 #Port number of the controller.
        controller_proxy_host: "ecommerce.proxy.com" #Host name or IP address of any proxy required for the agent to connect to the controller.
        controller_proxy_port: 8090 #Port number of any proxy required for the agent to connect to the controller.
        controller_proxy_username: ecom #Username for authenticating with the proxy.
        controller_proxy_password: temp #Password for authenticating with the proxy user.
        controller_proxy_passwordfile: /etc/ecommerce/passwd #Full path name of a file containing the password for authenticating with the proxy user.
        ssl_enabled: "True" #SSL login. Set true to enable, 
        iib_controller_cert_file: /etc/controller/iib.pem  #Full path to the PEM format X509 certificate for SSL.See, Enable SSL for the C/C++ SDK for more information on obtaining the file.
        iib_log_dir: /opt/appd/logs/ #Path to the directory containing the IIB agent log files. The default path is /tmp/appd. Logs that are written before this configuration are logged in this path. 
        agent_log_level: info #Level of the logs. Set this property to trace|debug|info|warning|error. Error is the highest priority and trace is the lowest priority.
        tier_name: ecommere_tier_1 #Name of the tier representing the broker.
        iib_user_exit: ecom_t1 #Exit name of the user. This must be in the alphanumeric format, as provided to the mqsichangebroker command.
        iib_flow_level_visibility_enabled: 1   Flow level visibility option. Set 1 to enable, 0 to disable. The default value is 0. See IIB Agent Flow Level Visibility.
        iib_node_reuse: false #Set this property to reuse the node names of historical VMs for new VMs. It prevents the rapid increase of differently named nodes. See Enable the Node Name Reuse.
        iib_node_reuse_prefix: ecom #Use this property when node-reuse is set to true. If you do not set this property, the IIB agent generates node names as per the internal node name standards of IBM. See Enable the Node Name Reuse.
        linux_custom_agent_install_path: "/home/ubuntu/ecommerce_agent/" #this path should contain the appdynamics folder 
```

### IIB agent specific variables and configuration

|Variable<img width="200"/>     | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`iib_log_dir` | Path to the directory containing the IIB agent log files. The default path is /tmp/appd. Logs that are written before this configuration are logged in this path. | path-to-log-directory| optional |  /tmp/appd |
|`iib_user_exit` | Exit name of the user. This must be in the alphanumeric format, as provided to the mqsichangebroker command. | ecom | optional |  None |
|`iib_flow_level_visibility_enabled` | Flow level visibility option. Set 1 to enable, 0 to disable. The default value is 0. See IIB Agent Flow Level Visibility | 1 | optional |  0 |
|`iib_node_reuse` | Flow level visibility option. Set `true` to enable, `false` to disable. The default value is false. See IIB Agent Flow Level Visibility | `true` or `false` | optional |  `false` |
|`iib_node_reuse_prefix` | Use this property when node-reuse is set to true. If you do not set this property, the IIB agent generates node names as per the internal node name standards of IBM. See Enable the Node Name Reuse. | ecom | optional |  None |
|`config_file_path`|  Use this property to set path for node or server conf files to update UserExist (provide multiple path by using comma)| `/opt/node1.conf.yaml,/opt/node2.conf.yaml`| optional | None|

### IIB agent proxy specific variables and configuration

|Variable<img width="200"/>     | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`controller_proxy_host` | Host name or IP address of any proxy required for the agent to connect to the controller. | ecommerce.proxy.com | optional |  None |
|`controller_proxy_port` | Port number of any proxy required for the agent to connect to the controller. | 8090 | optional |  None |
|`controller_proxy_username` | Username for authenticating with the proxy. | ecom | optional |  None |
|`controller_proxy_password` | assword for authenticating with the proxy user. | temp | optional |  None |
|`controller_proxy_passwordfile` | Full path name of a file containing the password for authenticating with the proxy user. | /etc/ecommerce/passwd | optional |  None |

