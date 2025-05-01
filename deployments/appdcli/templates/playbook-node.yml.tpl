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

        {{ if .InstallDir }}
        linux_custom_agent_install_path: {{ .InstallDir }}
        windows_custom_agent_install_path: {{ .InstallDir }}
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

        keep_backup: {{ .Backup }}
        
        install_agent_from: "https://registry.npmjs.org"
        {{- range $key, $value := .ProfileVars }}
        {{ $key }}: {{ $value }}
        {{- end}}
