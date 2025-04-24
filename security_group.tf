##############################################################################
# Subnet Data Block
##############################################################################

data "ibm_is_subnet" "subnet" {
  for_each   = local.bms_server_map
  identifier = each.value.subnet_id
}

##############################################################################
# ibm_is_security_group - Create if requested with auto-generated name
##############################################################################

locals {
  security_group_name = "bms-sg-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
}

resource "ibm_is_security_group" "security_group" {
  count = var.create_security_group ? 1 : 0

  name           = local.security_group_name
  resource_group = var.resource_group_id
  vpc            = values(data.ibm_is_subnet.subnet)[0].vpc
  tags           = var.tags
  access_tags    = var.access_tags

  lifecycle {
    ignore_changes = [name]
  }
}

##############################################################################
# Security Group Rules - Create if new SG is being created
##############################################################################

resource "ibm_is_security_group_rule" "security_group_rules" {
  for_each = var.create_security_group ? {
    for rule in var.security_group_rules : rule.name => rule
  } : {}

  group     = ibm_is_security_group.security_group[0].id
  direction = each.value.direction
  remote    = each.value.source

  dynamic "icmp" {
    for_each = each.value.icmp != null ? [each.value.icmp] : []
    content {
      type = icmp.value.type
      code = icmp.value.code
    }
  }

  dynamic "tcp" {
    for_each = each.value.tcp != null ? [each.value.tcp] : []
    content {
      port_min = tcp.value.port_min
      port_max = tcp.value.port_max
    }
  }

  dynamic "udp" {
    for_each = each.value.udp != null ? [each.value.udp] : []
    content {
      port_min = udp.value.port_min
      port_max = udp.value.port_max
    }
  }
}

##############################################################################
# VPC Data for default security group
##############################################################################

data "ibm_is_vpc" "vpc" {
  identifier = values(data.ibm_is_subnet.subnet)[0].vpc
}

##############################################################################
# Final Security Group IDs to use
##############################################################################

locals {
  security_group_ids = distinct(compact(concat(
    var.create_security_group ? [ibm_is_security_group.security_group[0].id] : [],
    var.security_group_ids,
    (!var.create_security_group && length(var.security_group_ids) == 0) ? [data.ibm_is_vpc.vpc.default_security_group] : []
  )))
}
