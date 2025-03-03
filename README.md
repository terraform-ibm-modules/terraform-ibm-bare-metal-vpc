#  Bare Metal Server for VPC module

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-bare-metal-vpc?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-bare-metal-vpc/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)


The IBM Cloud Bare Metal Server Deployment Module provisions IBM Cloud Bare Metal Servers for VPC in a flexible and scalable manner. It supports deploying single or multiple servers, dynamically distributing them across one or more subnets while ensuring each instance is uniquely named.

- Automates complex bare metal deployments in IBM Cloud.
- Ensures high availability with intelligent subnet selection.
- Handles Terraform plan-time issues gracefully.

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-bare-metal-vpc](#terraform-ibm-bare-metal-vpc)
* [Submodules](./modules)
* [Examples](./examples)
    * [Basic example](./examples/advanced)
    * [Basic example](./examples/basic)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and link to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-bare-metal-vpc

### Usage

```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.75.2, < 2.0.0"
    }
  }
}

locals {
    region = "eu-gb"
}

provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"  # replace with apikey value
  region           = local.region
}

module "slz_baremetal" {
  source        = "../.."
  for_each      = { for idx in range(var.server_count) : idx => idx }
  server_count  = 1
  prefix        = "slz-bms"
  profile       = "cx2d-metal-96x192"
  image         = "r018-d1e5615e-6fc8-47f9-bc0e-9b92a6572ed1"
  vpc_id        = var.vpc_id
  subnet_ids    = ["subnet-1.id","subnet-2.id"]
  ssh_key_ids   = ["ssh_key.id"]
  bandwidth     = 100000
  allowed_vlans = ["100", "102"]
  access_tags   = null
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **IBM Cloud Activity Tracker** service
        - `Editor` platform access
        - `Manager` service access
    - **IBM Cloud Monitoring** service
        - `Editor` platform access
        - `Manager` service access
    - **IBM Cloud Object Storage** service
        - `Editor` platform access
        - `Manager` service access

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.75.2, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_baremetal"></a> [baremetal](#module\_baremetal) | ./modules/baremetal | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_is_subnet.selected](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_subnet) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access management tags to be attached to the bare metal server for categorization and policy enforcement. | `list(string)` | `[]` | no |
| <a name="input_allowed_vlans"></a> [allowed\_vlans](#input\_allowed\_vlans) | A list of VLAN IDs that are permitted for the bare metal server, ensuring network isolation and control. | `list(number)` | `[]` | no |
| <a name="input_bandwidth"></a> [bandwidth](#input\_bandwidth) | The allocated bandwidth (in Mbps) for the bare metal server to manage network traffic. If unset, default values apply. | `number` | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | The unique identifier of the operating system image to be installed on the bare metal server. | `string` | `"r010-7aef85f6-5f06-49e4-a7b4-361baf4e9b88"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The base name for the bare metal server. If multiple instances are created, an index will be appended for uniqueness. | `string` | `"demo-bms"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | The hardware profile defining the CPU, memory, and storage configuration of the bare metal server. | `string` | `"bx3-metal-48x256"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of the resource group where you want to create the service. | `string` | `null` | no |
| <a name="input_server_count"></a> [server\_count](#input\_server\_count) | The number of bare metal server instances to create. If set to more than one, multiple instances will be provisioned. | `number` | `1` | no |
| <a name="input_ssh_key_ids"></a> [ssh\_key\_ids](#input\_ssh\_key\_ids) | A list of SSH key IDs that will be used for secure access to the bare metal server. | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs where the bare metal server will be deployed, ensuring proper network segmentation. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The unique identifier of the IBM Cloud Virtual Private Cloud (VPC) where the bare metal server will be provisioned. | `string` | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
