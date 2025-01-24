resource "ibm_is_subnet_reserved_ip" "bms_ip" {
  for_each    = { for bms_key, bms_value in var.bms_map : bms_key => bms_value if var.manage_reserved_ips }
  name        = "${each.value.name}-ip"
  subnet      = each.value.subnet_id
  auto_delete = false
}

resource "ibm_is_subnet_reserved_ip" "secondary_bms_ip" {
  for_each    = { for key, value in var.secondary_reserved_ips_map : key => value if var.primary_vni_additional_ip_count > 0 && !var.use_legacy_network_interface }
  name        = "${var.prefix}-${substr(md5(each.value.name), -4, 4)}-ip"
  subnet      = each.value.subnet_id
  auto_delete = false
}

resource "ibm_is_subnet_reserved_ip" "secondary_vni_ip" {
  for_each    = { for key, value in var.secondary_vni_map : key => value if !var.use_legacy_network_interface && var.manage_reserved_ips }
  name        = "${var.prefix}-${substr(md5(each.value.name), -4, 4)}-secondary-vni-ip"
  subnet      = each.value.subnet_id
  auto_delete = false
}

resource "ibm_is_virtual_network_interface" "primary_vni" {
  for_each = { for bms_key, bms_value in var.bms_map : bms_key => bms_value if !var.use_legacy_network_interface }
  name     = "${each.value.bms_name}-vni"
  subnet   = each.value.subnet_id
  security_groups = flatten([
    (var.create_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
    var.security_group_ids,
    (var.create_security_group == false && length(var.security_group_ids) == 0 ? [data.ibm_is_vpc.vpc.default_security_group] : []),
  ])
  allow_ip_spoofing         = var.allow_ip_spoofing
  auto_delete               = false
  enable_infrastructure_nat = true
  dynamic "primary_ip" {
    for_each = var.manage_reserved_ips ? [1] : []
    content {
      reserved_ip = ibm_is_subnet_reserved_ip.bms_ip[each.value.name].reserved_ip
    }
  }
  dynamic "ips" {
    for_each = var.primary_vni_additional_ip_count > 0 ? { for count in range(var.primary_vni_additional_ip_count) : count => count } : {}
    content {
      reserved_ip = ibm_is_subnet_reserved_ip.secondary_bms_ip["${each.value.name}-${ips.key}"].reserved_ip
    }
  }
}

resource "ibm_is_virtual_network_interface" "secondary_vni" {
  for_each = { for key, value in var.secondary_vni_map : key => value if !var.use_legacy_network_interface }
  name     = each.value.name
  subnet   = each.value.subnet_id
  allow_ip_spoofing = var.secondary_allow_ip_spoofing
  security_groups = length(flatten([
    (var.create_security_group && var.secondary_use_bms_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
    [
      for group in var.secondary_security_groups :
      group.security_group_id if group.interface_name == each.value.name
    ]
  ])) == 0 ? [data.ibm_is_vpc.vpc.default_security_group] : flatten([
    (var.create_security_group && var.secondary_use_bms_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
    [
      for group in var.secondary_security_groups :
      group.security_group_id if group.interface_name == each.value.name
    ]
  ])
  auto_delete               = false
  enable_infrastructure_nat = true
  dynamic "primary_ip" {
    for_each = var.manage_reserved_ips ? [1] : []
    content {
      reserved_ip = ibm_is_subnet_reserved_ip.secondary_vni_ip[each.key].reserved_ip
    }
  }
}
