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
        
        install_env: default # [default - (main python path taken automatically), virtualenv - (virtualenv path need to be provided)]
        virtualenv_path: /home/ansible/venv # if environment is virtualenv then path else None
        install_agent_from: pypi # [pypi - (using pip), appd-portal - (using whl file)]
  
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

        {{ if .InstallArtifactFrom }}
        download_uri: {{ .InstallArtifactFrom }}
        {{ end }}
        
        {{- range $key, $value := .ProfileVars }}
        {{ $key }}: {{ $value }}
        {{- end}}
