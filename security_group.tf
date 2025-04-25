##############################################################################
# Subnet Data Block
##############################################################################

data "ibm_is_subnet" "subnet" {
  for_each   = local.bms_server_map
  identifier = each.value.subnet_id
}

##############################################################################
# Security Group Implementation using IBM Module
##############################################################################

locals {

  # Determine if we need to create a new security group
  create_security_group = var.create_security_group

  # Final security group IDs
  security_group_ids = distinct(compact(concat(
    local.create_security_group ? [module.sg_group[0].security_group_id] : [],
    var.security_group_ids,
    (!local.create_security_group && length(var.security_group_ids) == 0) ? [data.ibm_is_vpc.vpc.default_security_group] : []
  )))
}

##############################################################################
# IBM Security Group Module
##############################################################################

module "sg_group" {
  count   = local.create_security_group ? 1 : 0
  source  = "terraform-ibm-modules/security-group/ibm"
  version = "2.6.2"

  add_ibm_cloud_internal_rules = true
  resource_group               = var.resource_group_id
  security_group_name          = "${var.prefix}-sg"
  vpc_id                       = values(data.ibm_is_subnet.subnet)[0].vpc
  tags                         = var.tags
}

##############################################################################
# VPC Data for default security group
##############################################################################

data "ibm_is_vpc" "vpc" {
  identifier = values(data.ibm_is_subnet.subnet)[0].vpc
}
