locals {

  # Create list of BMS using subnets and BMS per subnet
  bms_list = flatten([
    # For each number in a range from 0 to BMS per subnet
    for count in range(var.bms_per_subnet) : [
      # For each subnet
      for subnet in range(length(var.subnets)) :
      {
        name           = "${var.subnets[subnet].name}-${count}"
        bms_name       = "${var.prefix}-${substr(var.subnets[subnet].id, -4, 4)}-${format("%03d", count + 1)}"
        subnet_id      = var.subnets[subnet].id
        zone           = var.subnets[subnet].zone
        subnet_name    = var.subnets[subnet].name
        secondary_vnis = [for index, vni in module.network.secondary_vni : vni.id if(vni.zone == var.subnets[subnet].zone) && (tonumber(substr(index, -1, -1)) == count)]
      }
    ]
  ])

  secondary_vni_list = flatten([
    # For each number in a range from 0 to BMS per subnet
    for count in range(var.bms_per_subnet) : [
      # For each subnet
      for subnet in range(length(var.secondary_subnets)) :
      {
        name        = "${var.secondary_subnets[subnet].name}-${count}"
        subnet_id   = var.secondary_subnets[subnet].id
        zone        = var.secondary_subnets[subnet].zone
        subnet_name = var.secondary_subnets[subnet].name
      }
    ]
  ])

  secondary_vni_map = {
    for vni in local.secondary_vni_list :
    vni.name => vni
  }

  # Create map of BMS from list
  bms_map = {
    for server in local.bms_list :
    server.name => server
  }

  # List of additional private IP addresses to bind to the primary virtual network interface.
  secondary_reserved_ips_list = flatten([
    for count in range(var.primary_vni_additional_ip_count) : [
      for bms_key, bms_value in local.bms_map :
      {
        name      = "${bms_key}-${count}"
        subnet_id = bms_value.subnet_id
      }
    ]
  ])

  secondary_reserved_ips_map = {
    for ip in local.secondary_reserved_ips_list :
    ip.name => ip
  }

  # Old approach to create floating IPs for the secondary network interface.
  legacy_secondary_fip_list = var.use_legacy_network_interface ? flatten([
    # For each interface in list of floating ips
    for interface in var.secondary_floating_ips :
    [
      # For each virtual server
      for server in module.baremetal :
      {
        # fip name
        name = "${server.name}-${interface}-fip"
        # target interface at the same index as subnet name
        target = server.network_interfaces[index(var.secondary_subnets[*].name, interface)].id
      }
    ]
  ]) : []

  # List of secondary Virtual network interface for which floating IPs needs to be added.
  secondary_fip_list = !var.use_legacy_network_interface && length(var.secondary_floating_ips) != 0 ? flatten([
    for subnet in var.secondary_floating_ips :
    [
      for key, value in local.secondary_vni_map :
      {
        subnet_index = key
        vni_name     = module.network.secondary_vni[key].name
        vni_id       = module.network.secondary_vni[key].id
      } if strcontains(key, subnet)
    ]
  ]) : []

  secondary_fip_map = {
    for vni in local.secondary_fip_list :
    vni.subnet_index => vni
  }
}

locals {
  # Flatten secondary subnets for legacy network interfaces if needed.
  secondary_subnets_flattened = flatten([
    for subnet in var.secondary_subnets :
    {
      id   = subnet.id
      name = subnet.name
      zone = subnet.zone
    }
  ])
}

##############################################################################
# Security Group
##############################################################################

locals {
  bms_security_group = [var.create_security_group ? var.security_group : null]
  # Create list of all security groups including the ones for load balancers
  security_groups = flatten([
    [
      for group in local.bms_security_group :
      group if group != null
    ],
  ])

  # Convert list to map
  security_group_map = {
    for group in local.security_groups :
    (group.name) => group
  }

  # input variable validation
  # tflint-ignore: terraform_unused_declarations
  validate_security_group = var.create_security_group == false && var.security_group != null ? tobool("var.security_group should be null when var.create_security_group is false. Use var.security_group_ids to add security groups to BMS deployment primary interface.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_security_group_2 = var.create_security_group == true && var.security_group == null ? tobool("var.security_group cannot be null when var.create_security_group is true.") : true
}

##############################################################################
# Change Security Group (Optional)
##############################################################################

locals {
  # Create list of all sg rules to create adding the name
  security_group_rule_list = flatten([
    for group in local.security_groups :
    [
      for rule in group.rules :
      merge({
        sg_name = group.name
      }, rule)
    ]
  ])

  # Convert list to map
  security_group_rules = {
    for rule in local.security_group_rule_list :
    ("${rule.sg_name}-${rule.name}") => rule
  }
}
