# main.tf

resource "ibm_is_bare_metal_server" "bms" {
  profile        = var.bare_metal_profile
  name           = var.bare_metal_name
  image          = var.image_id
  zone           = var.zone
  keys           = [var.ssh_key_id]
  resource_group = var.resource_group_id
  vpc            = var.vpc_id

  # Primary Virtual Network Interface
  dynamic "primary_network_attachment" {
    for_each = var.use_legacy_network_interface ? [] : [var.primary_vni]
    content {
      name = each.key.name
      virtual_network_interface {
        id = each.key.id
      }
    }
  }

  # Additional Virtual Network Interface
  dynamic "network_attachments" {
    for_each = { for index, id in each.value.secondary_vnis : index => id if !var.use_legacy_network_interface }
    content {
      name = "${each.value.vsi_name}-secondary-vni-${network_attachments.key}"
      virtual_network_interface {
        id = network_attachments.value
      }
    }
  }

  # Legacy Network Interface
  dynamic "primary_network_interface" {
    for_each = var.use_legacy_network_interface ? [1] : []
    content {
      subnet = each.value.subnet_id
      security_groups = flatten([
        (var.create_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
        var.security_group_ids,
        (var.create_security_group == false && length(var.security_group_ids) == 0 ? [var.default_security_group] : []),
      ])
      allow_ip_spoofing = var.allow_ip_spoofing
      dynamic "primary_ip" {
        for_each = var.manage_reserved_ips ? [1] : []
        content {
          reserved_ip = var.primary_reserved_ips[each.value.name].reserved_ip
        }
      }
    }
  } 
  # Legacy additional Network Interface
  dynamic "network_interfaces" {
    for_each = {
      for k in var.secondary_subnets : k.zone => k
      if k.zone == each.value.zone && var.use_legacy_network_interface
    }
    content {
      name = "legacy-secondary-${network_interfaces.value.name}" # Add a name for legacy additional network interface
      subnet = network_interfaces.value.id
      security_groups = length(flatten([
        (var.create_security_group && var.secondary_use_vsi_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
        [
          for group in var.secondary_security_groups :
          group.security_group_id if group.interface_name == network_interfaces.value.name
        ]
        ])) == 0 ? [var.default_security_group] : flatten([
        (var.create_security_group && var.secondary_use_vsi_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
        [
          for group in var.secondary_security_groups :
          group.security_group_id if group.interface_name == network_interfaces.value.name
        ]
      ])
      allow_ip_spoofing = var.secondary_allow_ip_spoofing
    }
  }

}
