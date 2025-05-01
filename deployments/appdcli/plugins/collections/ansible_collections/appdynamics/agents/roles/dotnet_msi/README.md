# AppDynamics role to install and configure .Net Agent MSI
This role features:

- .Net Agent MSI installation for Windows. This agent installs on the entire Windows machine and can monitor multiple applications.

Below are the properties supported by .Net Agent MSI role. Please refer to the examples on how the properties are used

## .Net Agent MSI Installation Ansible Variables

below are installation properties supported by .Net Agent MSI

### Common
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`agent_version` | Version of the .Net Agent MSI to install from the AppDynamics download portal | [`latest`, X.X.X]; where X.X.X is a version, e.g. `22.12.0` | N | `latest`
|`download_uri`| Path to .Net Agent MSI installer. Can be url or system path (local or network) depending on the `download_protocol` property. Takes priority over `agent_version` | [url, system path] | N | |
|`download_protocol`| Defines how the .Net Agent MSI should be downloaded from `download_uri` | [`http`, `local`, `nfs`] | N | `http` |
|`agent_action`| Defines action for agent installation/uninstallation | [`install`<sup>\*</sup>, `upgrade`, `rollback`<sup>\*\*</sup>, `uninstall`] | N | `upgrade` |

<sup>\*</sup>usually install is performed on a fresh machine however if the `agent_action`=`install` is executed and there is a .Net Agent MSI installed on the machine the role will imply the upgrade

<sup>\*\*</sup>`agent_action`=`rollback` will honor the previous agent configuration and will ignore any agent configuration settings defined in the role

### .Net Agent MSI Specific
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`custom_ad_setup_file`| Defines a local path to the custom Ad_Setup installation config file on the ansible controlling node; can be a static file or a dynamic jinja template (in which case the ansible properties below can be used) | system path | N | |
|`restart_app`| Defines whether to restart instrumented applications after agent install/upgrade/rollback or not; LIMITATION! Standalone application will only receive a printed notice | [`true`, `false`] | N | `false` |

## .Net Agent MSI Configuration Ansible variables

below are configuration properties supported by .Net Agent MSI

### Common
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`controller_host_name`| Controller host name | | Y | |
|`controller_port`| Controller port number | | Y | |
|`enable_ssl`| Enable Controller SSL connection | [`true`, `false`] | N | `false` |
|`account_name`| Controller Account name | | Y | |
|`account_access_key`| Controller Account Access Key | | Y | |
|`enable_proxy`| Enable Controller Proxy | [`true`, `false`] | N | `false` |
|`proxy_host`| Controller Proxy Host Name | | Y if `enable_proxy`=`true`; N otherwise | |
|`proxy_port`| Controller Proxy Port Number | | Y if `enable_proxy`=`true`; N otherwise | |
|`application_name`| Controller Application Name | | N | 'default' |

### .Net Agent MSI Specific
|Variable | Description | Possible Values | Required | Default |
|--|--|--|--|--|
|`enable_tls12`| Enable Controller SSL TLS1.2 connection | [`true`, `false`] | N | `false` |
|`monitor_all_IIS_apps`| Enable monitoring of all IIS applications | [`true`, `false`] | N | `true` |
|`iis_applications`| List of IIS applications to monitor; useful if `monitor_all_IIS_apps`=`false` or custom tier and node names are required for an application. Configuration mirrors properties described in the [Documentation](https://docs.appdynamics.com/display/latest/.NET+Agent+Configuration+Properties) | | N | |
|`iis_application.site`| Name of the IIS web site | | Y for each IIS application if `iis_applications` is defined | |
|`iis_application.path`| Path to the IIS web application relative to the IIS web site; path must begin with '/'. If the path is missing the default value '/' indicates that all applications under the web site are instrumented | | N | '/' |
|`iis_application.tier_name`| Controller Tier Name for IIS application | | N | `iis_application.site/iis_application.path` if path is defined; `iis_application.site` otherwise |
|`iis_application.node_name`| Controller Node Name for IIS application | | N | `hostname-iis_application.tier_name` |
|`standalone_applications`| List of .Net standalone applications to monitor; Configuration mirrors properties described in the [Documentation](https://docs.appdynamics.com/display/latest/.NET+Agent+Configuration+Properties) | | N | |
|`standalone_application.executable`| Name of the executable file for the standalone application (with or without extension) | | Y for each standalone application if `standalone_applications` is defined | |
|`standalone_application.command_line`| Command line arguments for executable to limit the monitoring to a specific execution of the application | | N | |
|`standalone_application.tier_name`| Controller Tier Name for standalone application | | N | `standalone_application.executable` |
|`standalone_application.node_name`| Controller Node Name for standalone application | | N | `hostname-standalone_application.tier_name` |
|`custom_config`| Defines a local path to the custom config.xml on ansible controlling node; static file only; take priority over other configuration settings above | system path | N | |

### Examples

**Example 1:** .Net Agent MSI with minimal configuration:
 - latest agent version
 - auto-generated Controller application name
 - instrument all IIS applications (IIS must be restarted)

In the playbook below, the parameters for communicating with controller included from `vars/args.yaml`

```yml
---
- name: .Net Agent MSI Minimal Configuration
  hosts: windows
  tasks:
    - name: Include variables for the controller settings
      # Include all yaml files under the vars directory
      ansible.builtin.include_vars:
        dir: vars
        extensions:
          - 'yaml'
          - 'yml'

    - ansible.builtin.include_role:
        name: appdynamics.agents.dotnet_msi
```

**Example 2:** .Net Agent MSI with extended configuration:
 - agent version: 22.12.0
 - specific Controller application name
 - instrument only certain IIS applications with an without default tier and node names (IIS must be restarted)
 - instrument standalone applications with an without default tier and node names (standalone applications must be restarted)

In the playbooks below, the parameters for communicating with controller are initialised directly in the yaml file rather than including them from `vars/args.yaml

```yml
---
- name: .Net Agent MSI Extended Configuration
  hosts: windows
  tasks:
    - ansible.builtin.include_role:
        name: appdynamics.agents.dotnet_msi
      vars:
        agent_version: '22.12.0'
        # Your controller details
        controller_host_name: 'something.saas.appdynamics.com'
        controller_port: '443'
        enable_ssl: 'true'
        controller_account_name: 'customer1'
        controller_account_access_key: '123456'
        application_name: 'DotNetAgent_Application'

        monitor_all_IIS_apps: 'false'

        iis_applications:
            # instrument a web application 'PaymentService' under a web site 'Default Web Site'
          - site: 'Default Web Site'
            path: '/PaymentService'
            # default tier: 'site/path'
            # default node: 'host-tier'

            # instrument an entire web site 'BillingWebSite'
          - site: 'BillingWebSite'
            tier_name: 'BillingWebSiteTier'
            node_name: 'BillingWebSiteNode'

        standalone_applications:
            # instrument any execution of a standalone aplication 'login.exe'
          - executable: 'login.exe'
            # default tier: 'executable'
            # default node: 'host-tier'

            # instrument a standalone aplication 'checker.exe' with a specific set of command line arguments
          - executable: 'checker.exe'
            command_line: '-arg1 value1 -flag1'
            tier_name: 'CheckerTier'
            node_name: 'CheckedNode'
```

### Restart Instrumented Applications

By default `restart_app`=`false` which means that the instrumented applications will not be restarted after applying the role. To make sure that the changes to the agent applies to all application please restart them after applying this role. Both added and removed from instrumentation applications must be restarted. 

`restart_app` can be set to `true` in which case the role will restart the IIS if it is installed on the system. However the role will not restart the standalone applications added or removed from instrumentation.

### Setting .Net Agent MSI Environment Variables

Setting .Net Agent MSI environment variables can be done using `ansible.windows.win_environment` ansible module. Please refer to the [Ansible Documentation](https://docs.ansible.com/ansible/2.9_ja/modules/win_environment_module.html) and refer to the example below that defines `APPDYNAMICS_AGENT_UNIQUE_HOST_ID` environment variable on the system where the Agent will be installed
```yml
---
- name: .Net Agent MSI Test Play
  hosts: windows
  tasks:
    - name: Include variables for the controller settings
      # Include all yaml files under the vars directory
      ansible.builtin.include_vars:
        dir: vars
        extensions:
          - 'yaml'
          - 'yml'

    - ansible.windows.win_environment:
        state: present
        name: 'APPDYNAMICS_AGENT_UNIQUE_HOST_ID'
        value: '{{ ansible_hostname }}' # can be jinja template like in this example or a static `value` if needed
        level: machine

    - ansible.builtin.include_role:
        name: appdynamics.agents.dotnet_msi
```

### Install and Upgrade .Net Agent MSI on a Certain Tier/Node

.Net Agent MSI is a global machine-wise installation so within one machine it is not possible to have different versions of the Agent. All applications on the same machine are instrumented by the same version of the Agent

To update the Agent on certain Windows machines please organaize the ansible inventory file and run the playbook on the desired hosts - [Ansible Inventory Documentation](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)
 ```yml
---
# updating agent version on certain windows machines only
- name: .Net Agent MSI Test Play
  hosts: windows_region_1 # a group 'windows_region_1' should be defined in ansible inventory and lisy all desired machines
  tasks:
    - ansible.builtin.include_role:
        name: appdynamics.agents.dotnet_msi
        vars:
          agent_version: '22.12.0' # or providing custom_config or any other changes to the configuration
```

To update the list of instrumented applications within a machine please add or remove desired application from the role configuration and rerun the playbook.

### LIMITATIONS

1. Agent Upgrade do not retain previous .Net Agent MSI configuration and always honor the configuration properties provided in the role. If no property is provided then a default minimal configuration will be used. This is also the case when a previous installation was not managed by this role, the Agent configuration will be overridden according to the role settings. Please make sure to backup all imprtant configuration before running this role
1. .Net Agent MSI Rollback is not supported in the following situations:
   - if .Net Agent MSI was never installed on the machine or the previous .Net Agent MSI installation was not managed by this role
   - if the rollback is already performed; only rollback to one previous version is supported
