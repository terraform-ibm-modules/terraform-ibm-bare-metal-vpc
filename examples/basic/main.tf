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

module "slz_baremetal" {
  source        = "../.."
  for_each      = { for idx in range(var.server_count) : idx => idx }
  server_count  = 2
  prefix        = "slz-bms"
  profile       = "bx3-metal-48x256"
  image         = "r010-7aef85f6-5f06-49e4-a7b4-361baf4e9b88"
  zone          = "eu-de-2"
  vpc_id        = module.slz_vpc.vpc_id
  subnet_id     = [module.slz_vpc.subnet_zone_list[each.key % length(module.slz_vpc.subnet_zone_list)].id]
  ssh_key_id    = [local.ssh_key_id]
  bandwidth     = 100000
  allowed_vlans = ["100", "102"]
  access_tags   = null
}
