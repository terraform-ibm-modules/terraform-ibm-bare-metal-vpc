resource "ibm_is_bare_metal_server" "bms" {
  profile             = var.profile
  name                = var.name
  image               = var.image
  zone                = var.zone
  keys                = var.keys
  vpc = var.vpc

  # Primary Network Interface (Dynamic Configuration)
  dynamic "primary_network_interface" {
    for_each = var.use_legacy_network_interface ? [1] : []
    content {
      subnet = var.primary_vni
      primary_ip {
        address = var.primary_reserved_ip
      }
      allow_ip_spoofing = var.allow_ip_spoofing
    }
  }

  # Legacy Primary Network Interface
  dynamic "primary_network_interface" {
    for_each = var.use_legacy_network_interface ? [] : [1]
    content {
      subnet = var.primary_subnet_id
      allow_ip_spoofing = var.allow_ip_spoofing
      primary_ip {
        address = var.primary_reserved_ip
      }
    }
  }

  # Additional Network Interfaces (Non-Legacy)
  dynamic "network_attachments" {
    for_each = var.use_legacy_network_interface ? [] : { for index, id in var.secondary_vnis : index => id }
    content {
      name = "${var.name}-secondary-vni-${network_attachments.key}"
      virtual_network_interface {
        id = network_attachments.value
      }
    }
  }

  # Legacy Additional Network Interfaces
  dynamic "network_interfaces" {
    for_each = var.use_legacy_network_interface ? { for k in var.secondary_subnets : k.zone => k if k.zone == var.zone } : []
    content {
      name = "secondary_vni"
      subnet = network_interfaces.value.id
      allow_ip_spoofing = var.secondary_allow_ip_spoofing

      security_groups = length(flatten([
        (var.create_security_group && var.secondary_use_bms_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
        [
          for group in var.secondary_security_groups :
          group.security_group_id if group.interface_name == network_interfaces.value.name
        ]
        ])) == 0 ? [data.ibm_is_vpc.vpc.default_security_group] : flatten([
        (var.create_security_group && var.secondary_use_bms_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
        [
          for group in var.secondary_security_groups :
          group.security_group_id if group.interface_name == network_interfaces.value.name
        ]
      ])
    }
  }
}
