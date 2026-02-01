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
  version = "1.4.7"
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
  version           = "8.13.2"
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
  server_count          = 1
  prefix                = var.prefix
  profile               = var.profile
  image_id              = data.ibm_is_image.slz_vsi_image.id
  subnet_ids            = [for subnet in module.slz_vpc.subnet_zone_list : subnet.id if subnet.zone == "${var.region}-${var.zone}"]
  ssh_key_ids           = [local.ssh_key_id]
  manage_reserved_ips   = false
  bandwidth             = 100000
  create_security_group = false
  security_group_ids    = []
  user_data             = null
  allowed_vlan_ids      = ["100", "102"]
  access_tags           = null
  resource_group_id     = module.resource_group.resource_group_id
}
