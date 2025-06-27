## Baremetal Module

### Usage

Creates a single Bare Metal server on the provided subnet.

```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "X.Y.Z"  # Lock into a provider version that satisfies the module constraints
    }
  }
}

locals {
    region = "eu-gb"
}

provider "ibm" {
  ibmcloud_api_key = ""  # replace with apikey value
  region           = local.region
}

module "slz_baremetal" {
  source                       = "terraform-ibm-modules/bare-metal-vpc/ibm//modules/baremetal"
  version                      = "X.X.X" # Replace "X.X.X" with a release version to lock
  prefix                       = "slz-bms"
  profile                      = "cx2d-metal-96x192"
  image_id                     = "r022-a327ec71-6f38-4bdc-99c8-33e723786a91"
  subnet_ids                   = ["r022-d72dc796-b08a-4f8e-a5aa-6c523284173d","r092-d72ddcds96-b0sa-4f8e-a5aa-6c523284s173d"]
  ssh_key_ids                  = ["r022-89b37a2e-e78d-46b8-8989-5f8d00cd44d2"]
  bandwidth                    = 100000
  allowed_vlans_ids            = ["100", "102"]
  user_data                    = "service httpd start"
  enable_secure_boot           = true
  tpm_mode                     = "tpm_2"
  secondary_vni_enabled        = true
  secondary_subnet_id          = "r022-d75gh796-b08a-4hje-a5aa-76hju84173d"
  secondary_security_group_ids = ["r098-c76b3522-77aa-41ea-bbbf-76ct5416fbad"]
  secondary_allowed_vlan_ids   = ["100", "102"]
  access_tags                  = null
  resource_group_id            = "xxxxxxxxxxxxxxxxx"
}
```

 <!-- The following content is automatically populated by the pre-commit hook -->
 <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.75.2, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_bare_metal_server.bms](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_bare_metal_server) | resource |
| [ibm_is_virtual_network_interface.bms](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_virtual_network_interface) | resource |
| [ibm_is_virtual_network_interface.bms_secondary](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_virtual_network_interface) | resource |
| [ibm_is_subnet.subnet](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_subnet) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access management tags to be attached to the bare metal server for categorization and policy enforcement. | `list(string)` | `[]` | no |
| <a name="input_allowed_vlan_ids"></a> [allowed\_vlan\_ids](#input\_allowed\_vlan\_ids) | A list of VLAN IDs that are permitted for the bare metal server, ensuring network isolation and control. Example: [100, 102] | `list(number)` | `[]` | no |
| <a name="input_bandwidth"></a> [bandwidth](#input\_bandwidth) | The allocated bandwidth (in Mbps) for the bare metal server to manage network traffic. If unset, default values apply. | `number` | `null` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | Timeout for creating the bare metal server | `string` | `"60m"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | Timeout for deleting the bare metal server | `string` | `"60m"` | no |
| <a name="input_enable_secure_boot"></a> [enable\_secure\_boot](#input\_enable\_secure\_boot) | Indicates whether secure boot is enabled. If enabled, the image must support secure boot or the server will fail to boot. | `bool` | `false` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | The unique identifier of the operating system image to be installed on the bare metal server. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The base name for the bare metal servers and its resources. | `string` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | The hardware profile defining the CPU, memory, and storage configuration of the bare metal server. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of the resource group where you want to create the service. | `string` | `null` | no |
| <a name="input_secondary_allowed_vlan_ids"></a> [secondary\_allowed\_vlan\_ids](#input\_secondary\_allowed\_vlan\_ids) | List of allowed VLAN IDs for the secondary VNI | `list(number)` | `null` | no |
| <a name="input_secondary_security_group_ids"></a> [secondary\_security\_group\_ids](#input\_secondary\_security\_group\_ids) | List of security group IDs for the secondary VNI | `list(string)` | `null` | no |
| <a name="input_secondary_subnet_id"></a> [secondary\_subnet\_id](#input\_secondary\_subnet\_id) | The ID of the secondary subnet | `string` | `""` | no |
| <a name="input_secondary_vni_enabled"></a> [secondary\_vni\_enabled](#input\_secondary\_vni\_enabled) | Whether to enable a secondary virtual network interface | `bool` | `false` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | IDs of additional security groups to be added to BMS deployment primary interface. A BMS interface can have a maximum of 5 security groups. | `list(string)` | `[]` | no |
| <a name="input_ssh_key_ids"></a> [ssh\_key\_ids](#input\_ssh\_key\_ids) | A list of SSH key IDs that will be used for secure access to the bare metal server. | `list(string)` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | A list of subnet IDs where the bare metal server will be deployed, ensuring proper network segmentation. | `string` | n/a | yes |
| <a name="input_tpm_mode"></a> [tpm\_mode](#input\_tpm\_mode) | Trusted platform module (TPM) configuration for the bare metal server. For more details see [Secure Boot and TPM documentation](https://cloud.ibm.com/docs/vpc?topic=vpc-secure-boot-tpm) | `string` | `"disabled"` | no |
| <a name="input_update_timeout"></a> [update\_timeout](#input\_update\_timeout) | Timeout for updating the bare metal server | `string` | `"60m"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data to initialize BMS deployment | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_baremetal_server_id"></a> [baremetal\_server\_id](#output\_baremetal\_server\_id) | Output for baremetal servers ID. |
| <a name="output_baremetal_server_name"></a> [baremetal\_server\_name](#output\_baremetal\_server\_name) | Output for baremetal servers name. |
| <a name="output_baremetal_server_primary_ip"></a> [baremetal\_server\_primary\_ip](#output\_baremetal\_server\_primary\_ip) | Output for baremetal Primary IP address. |
| <a name="output_baremetal_server_primary_vni_id"></a> [baremetal\_server\_primary\_vni\_id](#output\_baremetal\_server\_primary\_vni\_id) | Output for primary virtual network interface ID. |
| <a name="output_baremetal_server_secondary_ip"></a> [baremetal\_server\_secondary\_ip](#output\_baremetal\_server\_secondary\_ip) | Output for baremetal Secondary IP address. |
| <a name="output_baremetal_server_secondary_vni_id"></a> [baremetal\_server\_secondary\_vni\_id](#output\_baremetal\_server\_secondary\_vni\_id) | Output for secondary virtual network interface ID. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
