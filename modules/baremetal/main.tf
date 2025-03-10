resource "ibm_is_bare_metal_server" "bms" {
  profile        = var.profile
  name           = var.name
  image          = var.image_id
  zone           = var.zone
  keys           = var.ssh_key_ids
  vpc            = var.vpc_id
  bandwidth      = var.bandwidth
  access_tags    = var.access_tags
  resource_group = var.resource_group_id

  # Attach subnet if VLANs are **not** provided
  dynamic "primary_network_interface" {
    for_each = length(var.allowed_vlan_ids) == 0 ? [1] : []
    content {
      subnet = var.subnet_id
    }
  }

  # Attach VLANs if they are provided
  dynamic "primary_network_attachment" {
    for_each = length(var.allowed_vlan_ids) > 0 ? [1] : []
    content {
      name = "${var.name}-vni"
      virtual_network_interface {
        id = ibm_is_virtual_network_interface.bms[0].id
      }
      allowed_vlans = var.allowed_vlan_ids
    }
  }

  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }
}

# Create Virtual Network Interface (VNI) only if VLANs are provided
resource "ibm_is_virtual_network_interface" "bms" {
  count          = length(var.allowed_vlan_ids) > 0 ? 1 : 0 # Only create when VLANs exist
  name           = "${var.name}-vni"
  subnet         = var.subnet_id
  resource_group = var.resource_group_id
}
