##############################################################################
# Locals
##############################################################################

locals {
  ssh_key_id = var.ssh_key != null ? data.ibm_is_ssh_key.existing_ssh_key[0].id : resource.ibm_is_ssh_key.ssh_key[0].id
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create new SSH key
##############################################################################

resource "tls_private_key" "tls_key" {
  count     = var.ssh_key != null ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "ssh_key" {
  count      = var.ssh_key != null ? 0 : 1
  name       = "${var.prefix}-ssh-key"
  public_key = resource.tls_private_key.tls_key[0].public_key_openssh
}

data "ibm_is_ssh_key" "existing_ssh_key" {
  count = var.ssh_key != null ? 1 : 0
  name  = var.ssh_key
}

#############################################################################
# Provision VPC
#############################################################################

module "slz_vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "7.19.1"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  tags              = var.resource_tags
  name              = var.vpc_name
}

#############################################################################
# Provision VSI
#############################################################################
data "ibm_is_image" "slz_vsi_image" {
  name = "ibm-centos-stream-9-amd64-8"
}

module "slz_baremetal" {
  source                = "../.."
  server_count          = 2
  prefix                = var.prefix
  profile               = var.profile
  image_id              = data.ibm_is_image.slz_vsi_image.id
  subnet_ids            = [for subnet in module.slz_vpc.subnet_zone_list : subnet.id if subnet.zone == "${var.region}-1"]
  ssh_key_ids           = [local.ssh_key_id]
  bandwidth             = 100000
  allowed_vlan_ids      = ["100", "102"]
  create_security_group = true
  security_group_ids    = []
  user_data             = <<-EOF
    #!/bin/bash
    echo "Provisioning BareMetal Server at $(date)"
    echo "Hello from user_data!"
  EOF
  security_group_rules = [
    # TCP Rule Example
    {
      name      = "allow-http"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 80
        port_max = 80
      }
    },

    # UDP Rule Example
    {
      name      = "allow-dns"
      direction = "outbound"
      remote    = "161.26.0.0/16"
      udp = {
        port_min = 53
        port_max = 53
      }
    },

    # ICMP Rule Example (ping)
    {
      name      = "allow-ping"
      direction = "inbound"
      remote    = "10.0.0.0/8"
      icmp = {
        type = 8
      }
    },

    # Minimal Rule (defaults to inbound)
    {
      name   = "default-rule"
      remote = "192.168.1.1/32"
      tcp = {
        port_min = 22
      }
    }
  ]

  # Secondary VNI configuration Enabled for Basic Example
  secondary_vni_enabled        = true
  secondary_subnet_ids         = var.secondary_vni_enabled && var.secondary_subnet_ids != null ? var.secondary_subnet_ids : [for subnet in module.slz_vpc.subnet_zone_list : subnet.id if subnet.zone == "${var.region}-1"]
  secondary_security_group_ids = var.secondary_vni_enabled ? var.secondary_security_group_ids : []
  secondary_allowed_vlan_ids   = var.secondary_vni_enabled ? var.secondary_allowed_vlan_ids : []

  access_tags       = null
  resource_group_id = module.resource_group.resource_group_id
}
