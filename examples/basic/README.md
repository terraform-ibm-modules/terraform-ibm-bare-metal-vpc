# Basic example

This Terraform configuration provisions IBM Cloud infrastructure, including a resource group, SSH key management, VPC, and Bare Metal Servers (BMS). It automates the setup, ensuring resources are dynamically created or reused based on input variables.

SSH Key Management:
- Uses an existing SSH key (var.ssh_key) if provided
- If no key is specified, it generates a new RSA 4096-bit SSH key using Terraform's TLS provider.

Resource Group Provisioning:
- Creates a new IBM Cloud Resource Group if var.resource_group is null.
- Otherwise, it attaches to an existing resource group.

VPC Deployment:
- Provisions a VPC using the terraform-ibm-modules/landing-zone-vpc module.
- The VPC is assigned to the resource group and tagged for easy management.

Bare Metal Server Provisioning:
- Deploys one or more Bare Metal Servers based on var.server_count.
- Dynamically selects subnets specifically using zone-1 for quota availability.
- Ensures proper connectivity with SSH keys, bandwidth allocation, and VLAN configurations.
