resource "ibm_is_virtual_network_interface" "vni" {
  for_each = var.resource_map
  name     = each.value.name
  subnet   = each.value.subnet_id

  security_groups = length(flatten([
    (var.create_security_group && each.value.use_bms_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
    [
      for group in var.security_groups :
      group.security_group_id if group.interface_name == each.value.name
    ]
  ])) == 0 ? [data.ibm_is_vpc.vpc.default_security_group] : flatten([
    (var.create_security_group && each.value.use_bms_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
    [
      for group in var.security_groups :
      group.security_group_id if group.interface_name == each.value.name
    ]
  ])

  allow_ip_spoofing         = each.value.allow_ip_spoofing
  auto_delete               = false
  enable_infrastructure_nat = true

  dynamic "primary_ip" {
    for_each = var.manage_reserved_ips ? [1] : []
    content {
      reserved_ip = each.value.primary_reserved_ip
    }
  }

  dynamic "ips" {
    for_each = each.value.additional_ip_count > 0 ? { for count in range(each.value.additional_ip_count) : count => count } : {}
    content {
      reserved_ip = each.value.secondary_reserved_ips[ips.key]
    }
  }
}
