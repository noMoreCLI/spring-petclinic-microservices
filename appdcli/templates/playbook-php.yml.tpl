---
- name: {{ .Agent }} Agent Test
  hosts: {{ .Hosts }}
  tasks:
    - ansible.builtin.include_role:
        name: appdynamics.agents.{{ .Agent }}
      vars:
        # Define Agent Type and Version
        agent_version: {{ .Version }}
        agent_type: {{ .Agent }}
        agent_action: {{ .Operation }}
        log_directory: "/opt/appdynamics/php-agent/appd_logs"
        zts_support: false
        
        {{ if .InstallDir }}
        linux_custom_agent_install_path: {{ .InstallDir }}
        windows_custom_agent_install_path: {{ .InstallDir }}
        {{ end }}

        {{ if .InstallArtifactFrom }}
        download_uri: {{ .InstallArtifactFrom }}
        {{ end }}

        {{ if .AppName }}
        application_name: {{ .AppName }}
        {{ end }}

        {{ if .NodeName }}
        node_name: {{ .NodeName }}
        {{ end }}

        {{ if .TierName }}
        tier_name: {{ .TierName }}
        {{ end }}
        
        {{- range $key, $value := .ProfileVars }}
        {{ $key }}: {{ $value }}
        {{- end}}
