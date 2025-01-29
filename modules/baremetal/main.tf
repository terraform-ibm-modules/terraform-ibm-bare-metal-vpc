#############################################
###     Subnet Mapping Details Block      ###
#############################################

locals {
  # Distribute BMS instances across subnets in a round-robin fashion
  bms_list = [
    for i in range(var.bms_count) : {
      name        = "${var.prefix}-${i}"
      bms_name    = "${var.prefix}-${substr(var.subnets[i % length(var.subnets)].id, -4, 4)}-${format("%03d", i + 1)}"
      subnet_id   = var.subnets[i % length(var.subnets)].id
      zone        = var.subnets[i % length(var.subnets)].zone
      subnet_name = var.subnets[i % length(var.subnets)].name
    }
  ]

  # Create a map of BMS instances
  bms_map = { for server in local.bms_list : server.name => server }
}

data "ibm_is_vpc" "vpc" {
  identifier = var.vpc_id
}

resource "ibm_is_subnet_reserved_ip" "bms_ip" {
  for_each    = { for bms_key, bms_value in local.bms_map : bms_key => bms_value if var.manage_reserved_ips }
  name        = "${each.value.name}-ip"
  subnet      = each.value.subnet_id
  auto_delete = false
}

#############################################
###     BareMetal Server Resource Block   ###
#############################################

resource "ibm_is_bare_metal_server" "bms" {
  for_each       = local.bms_map
  name           = each.value.bms_name
  profile        = var.profile
  image          = var.image
  zone           = each.value.zone
  keys           = var.keys
  vpc            = var.vpc_id
  tags           = var.tags
  access_tags    = var.access_tags
  resource_group = var.resource_group_id

  dynamic "primary_network_interface" {
    for_each = [1]
    content {
      subnet = each.value.subnet_id
      security_groups = flatten([
        (var.create_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
        var.security_group_ids,
        (var.create_security_group == false && length(var.security_group_ids) == 0 ? [data.ibm_is_vpc.vpc.default_security_group] : []),
      ])
      allow_ip_spoofing = var.allow_ip_spoofing
      dynamic "primary_ip" {
        for_each = var.manage_reserved_ips ? [1] : []
        content {
          reserved_ip = ibm_is_subnet_reserved_ip.bms_ip[each.value.name].reserved_ip
        }
      }
    }
  }
}

#############################################
###     BareMetal NIC Block               ###
#############################################

resource "ibm_is_bare_metal_server_network_interface" "bms_nic" {
  for_each          = local.bms_map
  bare_metal_server = ibm_is_bare_metal_server.bms[each.key].id
  subnet            = each.value.subnet_id
  name              = "${var.prefix}-eth"
  allow_ip_spoofing = var.allow_ip_spoofing
}
