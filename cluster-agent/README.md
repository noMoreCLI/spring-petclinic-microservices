# AppDynamics Cluster Agent Installation

This Ansible project automates the installation and configuration of the AppDynamics Cluster Agent with Java auto-instrumentation capabilities.

## Project Structure

```
.
├── cluster-agent-install.yaml    # Main playbook
├── inventory.ini                 # Inventory file
├── README.md                    # This documentation
├── templates/
│   └── cluster-agent-values.yaml.j2  # Template for Helm values
└── vars/
    └── appd-cluster-agent.yaml  # Variables file
```

## Prerequisites

- Ansible 2.9 or later
- Access to a Kubernetes cluster
- Helm 3.x installed on the target host
- kubectl configured on the target host
- SSH access to the target host
- AppDynamics Controller credentials

### Variables

Set these variables in the local Ansible Vault file described below:

- `controller_url`: AppDynamics Controller URL
- `controller_account`: AppDynamics account name
- `controller_access_key`: Controller account access key; keep it in Ansible Vault only
- `app_name`: Name of your application
- `namespace_to_monitor`: Regex pattern for namespaces to monitor
- `namespace_to_instrument`: Regex pattern for namespaces to instrument

## Usage

1. Copy the example variables file and populate it locally:
   ```bash
   cp vars/secrets.example.yaml vars/secrets.yaml
   ansible-vault encrypt vars/secrets.yaml
   ```
   The local `vars/secrets.yaml` file is ignored by Git.
2. Run the playbook from the `cluster-agent` directory. Use `--ask-vault-pass` for the encrypted variables file; add `--ask-pass --ask-become-pass` only if your SSH setup requires password authentication:
   ```bash
   ansible-playbook -i inventory.ini cluster-agent-install.yaml --ask-vault-pass
   ```

The playbook will:
1. Verify Kubernetes cluster access
2. Check Helm installation
3. Add AppDynamics Helm repository
4. Create necessary namespace
5. Deploy Cluster Agent
6. Configure auto-instrumentation
7. Verify deployment status

## Verification

After installation, verify the deployment:
```bash
kubectl get pods -n appdynamics
kubectl logs -n appdynamics -l app=cluster-agent
```

## Security Notes

- Never commit `vars/secrets.yaml`; it is ignored by Git and should be encrypted with Ansible Vault.
- Do not print rendered values files or credentials in Ansible logs.
- Prefer SSH keys; if password authentication is required, use Ansible's interactive prompts rather than storing the password in inventory.

## Troubleshooting

Common issues and solutions:

1. **Helm Repository Access**
   - Verify network connectivity to AppDynamics repository
   - Check Helm version compatibility

2. **Kubernetes Access**
   - Ensure kubectl is properly configured
   - Verify cluster permissions

3. **Deployment Issues**
   - Check cluster resources
   - Verify namespace permissions
   - Review deployment logs

## Support

For issues or questions, please:
1. Check the AppDynamics documentation
2. Review deployment logs
3. Contact your AppDynamics representative



