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

## Configuration

### Inventory Setup

Edit `inventory.ini` to specify your target host:
```ini
[appdynamics]
198.18.134.23 ansible_user=root ansible_ssh_pass={{ ssh_password }}
```

### Variables

The following variables need to be configured in the playbook or through environment variables:

- `controller_url`: AppDynamics Controller URL
- `controller_account`: AppDynamics account name
- `controller_username`: Controller username
- `controller_password`: Controller password (recommended to use vault)
- `controller_access_key`: Controller access key (recommended to use vault)
- `app_name`: Name of your application
- `namespace_to_monitor`: Regex pattern for namespaces to monitor
- `namespace_to_instrument`: Regex pattern for namespaces to instrument

## Usage

1. Configure your inventory and variables
2. Run the playbook:
   ```bash
   ansible-playbook -i inventory.ini cluster-agent-install.yaml --ask-pass
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

- Passwords and access keys should be stored securely using Ansible Vault
- SSH passwords are prompted during playbook execution
- Consider using SSH keys instead of passwords for production environments

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



