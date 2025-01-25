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
    (var.create_security_group == false && length(var.security_group_ids) == 0 ? [var.vpc_id.default_security_group] : []),
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
  ])) == 0 ? [var.vpc_id.default_security_group] : flatten([
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

resource "ibm_is_security_group" "security_group" {
  for_each       = var.security_group_map
  name           = each.value.name
  resource_group = var.resource_group_id
  vpc            = var.vpc_id
  tags           = var.tags
  access_tags    = var.access_tags
}

resource "ibm_is_security_group_rule" "security_group_rules" {
  for_each  = var.security_group_rules
  group     = ibm_is_security_group.security_group[each.value.sg_name].id
  direction = each.value.direction
  remote    = each.value.source


  ##############################################################################
  # Dynamicaly create ICMP Block
  ##############################################################################

  dynamic "icmp" {

    # Runs a for each loop, if the rule block contains icmp, it looks through the block
    # Otherwise the list will be empty

    for_each = (
      # Only allow creation of icmp rules if all of the keys are not null.
      # This allows the use of the optional variable in landing zone patterns
      # to convert to a single typed list by adding `null` as the value.
      each.value.icmp == null
      ? []
      : length([
        for value in ["type", "code"] :
        true if lookup(each.value["icmp"], value, null) == null
      ]) == 2
      ? [] # if all values null empty array
      : [each.value]
    )
    # Conditianally add content if sg has icmp
    content {
      type = lookup(
        each.value["icmp"],
        "type",
        null
      )
      code = lookup(
        each.value["icmp"],
        "code",
        null
      )
    }
  }

  ##############################################################################

  ##############################################################################
  # Dynamically create TCP Block
  ##############################################################################

  dynamic "tcp" {

    # Runs a for each loop, if the rule block contains tcp, it looks through the block
    # Otherwise the list will be empty

    for_each = (
      # Only allow creation of tcp rules if all of the keys are not null.
      # This allows the use of the optional variable in landing zone patterns
      # to convert to a single typed list by adding `null` as the value.
      # the default behavior will be to set `null` `port_min` values to 1 if null
      # and `port_max` to 65535 if null
      each.value.tcp == null
      ? []
      : length([
        for value in ["port_min", "port_max"] :
        true if lookup(each.value["tcp"], value, null) == null
      ]) == 2
      ? [] # if all values null empty array
      : [each.value]
    )

    # Conditionally adds content if sg has tcp
    content {
      port_min = lookup(
        each.value["tcp"],
        "port_min",
        null
      )

      port_max = lookup(
        each.value["tcp"],
        "port_max",
        null
      )
    }
  }

  ##############################################################################

  ##############################################################################
  # Dynamically create UDP Block
  ##############################################################################

  dynamic "udp" {

    # Runs a for each loop, if the rule block contains udp, it looks through the block
    # Otherwise the list will be empty

    for_each = (
      # Only allow creation of udp rules if all of the keys are not null.
      # This allows the use of the optional variable in landing zone patterns
      # to convert to a single typed list by adding `null` as the value.
      # the default behavior will be to set `null` `port_min` values to 1 if null
      # and `port_max` to 65535 if null
      each.value.udp == null
      ? []
      : length([
        for value in ["port_min", "port_max"] :
        true if lookup(each.value["udp"], value, null) == null
      ]) == 2
      ? [] # if all values null empty array
      : [each.value]
    )

    # Conditionally adds content if sg has udp
    content {
      port_min = lookup(
        each.value["udp"],
        "port_min",
        null
      )
      port_max = lookup(
        each.value["udp"],
        "port_max",
        null
      )
    }
  }

  ##############################################################################

}
