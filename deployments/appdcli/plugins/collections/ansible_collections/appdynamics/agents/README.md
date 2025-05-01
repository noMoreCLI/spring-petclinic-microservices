
# AppDynamics Ansible Collection

The AppDynamics Ansible Collection installs and configures AppDynamics agents. All supported agents are downloaded from the download portal or supported repositories. This makes it easy to acquire and upgrade agents declaratively.

## Documentation

Refer to the [official documentation](https://docs.appdynamics.com/appd/23.x/latest/en/application-monitoring/install-app-server-agents/agent-management/standalone-host-platforms/ansible) for details.


## Demo

<i> Pro Tip: Right-Click the GIF and "Open in new Tab" or view on <a href="https://terminalizer.com/view/405023a64449">terminalizer</a> </i>

![DEMO](https://github.com/Appdynamics/appdynamics-ansible/blob/master/docs/ansible.gif?raw=true)

## Installation

Install the <a href="https://galaxy.ansible.com/appdynamics"> AppDynamics Collection </a> from Ansible Galaxy on your Ansible control node:

```shell
ansible-galaxy collection install --pre --force appdynamics.agents
```

### Enable status report plugin
Status report plugin will print summarized agent installation status to a file. Enable it by configuring ansible.cfg.
```yaml
[defaults]
callbacks_enabled=  appdynamics.agents.appd_agent_status
```

## Supported Agents

The agent binaries and the installation process for the Machine and DB agent depend on the OS type –– Windows or Linux.

This AppDynamics collection abstracts the OS differences so you should only have to provide `agent_type`, without necessarily specifying your OS type.

| Agent type  | Description |
|--|--|
|`sun-java7`   or     `java7`   | Agent to monitor Java applications running on JRE version 1.7 and less |
|`sun-java`   or     `java`   | Agent to monitor Java applications running on JRE version 1.8 and above |
|`ibm-java` | Agent to monitor Java applications running on IBM JRE |
|`dotnet_msi` | Machine global Agent to monitor .Net and .Net Framework applications on Windows |
|`machine` | 64 Bit Machine agent ZIP bundle with JRE. Windows and Linux |
|`python` | Agent to Monitor Python applications on Linux|
| `php`|  Agent to Monitor Php applications on Linux or Redhat based System|
| `node` | Agent to Monitor NodeJS application on Linux |