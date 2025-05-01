# AppDynamics role to install the Machine Agent 

Use `machine-win` as `agent_type` parameter value for Windows OS. 

```yml
---
- hosts: linux
  tasks:
    - include_role:
        name: appdynamics.agents.machine
      vars:
        # Define Agent Type and Version
        agent_version: 22.6.0
        agent_type: machine
        # Your controller details 
        controller_account_access_key: "b0248ceb-c954-4a37-97b5-207e90418cb4" # Please add this to your Vault
        controller_global_analytics_account_name: 'customer1_e2f90621-ab21-4bf4-908c-872d213c7f64' # Please add this to your Vault
        controller_host_name: "ansible-20100nosshcont-bum4wzwa.appd-cx.com" # Your AppDynamics controller
        controller_account_name: "customer1" # Please add this to your Vault
        sim_enabled: "true"
        enable_ssl: "false"
        controller_port: "8090"
        analytics_event_endpoint: "http://ansible-20100nosshcont-bum4wzwa.appd-cx.com:7001"
        enable_analytics_agent: "true"
        machine_hierarchy: "AppName|Owners|Environment|" # Make sure it ends with a |
        # config properties docs - https://docs.appdynamics.com/display/latest/Machine+Agent+Configuration+Properties
        # Can be used to configure the proxy for the agent
        java_system_properties: "-Dappdynamics.http.proxyHost=10.0.4.2 -Dappdynamics.http.proxyPort=9090" # mind the space between each property
        # Analytics settings
        analytics_event_endpoint: "http://lncontroller20103-2010-o8evv8rp.appd-cx.com:9080"
        enable_analytics_agent: "true"
        # To install the machine agent with root permissions; Default value: "true"; Required: Yes
        # When true, will install and run the Machine Agent as a system service, this requires root user permissions
        # When false, will just install the Machine Agent with the given configurations
        autostart_agent: "true"

```