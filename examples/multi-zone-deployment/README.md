# Multi-zone example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=bare-metal-vpc-multi-zone-deployment-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-bare-metal-vpc/tree/main/examples/multi-zone-deployment"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


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
- Deploys 3 baremetal servers on a round-robin method.
- Two subnets are selected on different zones.
- Deploys first server on first subnet.
- Deploys second server on second subnet.
- The third baremetal server will be deployed on first subnet again.
- Ensures proper connectivity with SSH keys, bandwidth allocation, and VLAN configurations.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
