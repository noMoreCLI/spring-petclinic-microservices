---
- name: {{ .Agent }} Agent Test
  hosts: {{ .Hosts }}
  tasks:
    - ansible.builtin.include_role:
        name: appdynamics.agents.{{ .Agent }}
      vars:
        # Define Agent Type and Version
        agent_type: {{ .Agent }}
        agent_action: {{ .Operation }}

        {{ if ne .Version "latest" }}
        agent_version: {{ .Version }}
        {{ end }}

        {{ if .SmartagentDownloadURL }}
        download_uri: {{ .SmartagentDownloadURL }}
        {{ end }}

        {{ if .AttachConfigureFile }}
        auto_attach_config_file: {{ .AttachConfigureFile }}
        {{ end }}

        {{ if .InstallArtifactFrom }}
        linux_artifact_path: {{ .InstallArtifactFrom }}
        {{ end }}

        {{ if .InstallDir }}
        linux_custom_agent_install_path: {{ .InstallDir }}
        windows_custom_agent_install_path: {{ .InstallDir }}
        {{ end }}

        smartagent_auto_start: {{ .AutoStart }}

        {{- range $key, $value := .ProfileVars }}
        {{ $key }}: {{ $value }}
        {{- end}}

       
