resource "ibm_is_bare_metal_server" "bms" {
  profile        = var.profile
  name           = var.prefix
  image          = var.image
  zone           = var.zone
  keys           = var.ssh_key_ids
  vpc            = var.vpc_id
  bandwidth      = var.bandwidth
  access_tags    = var.access_tags
  resource_group = var.resource_group_id

  # Attach subnet if VLANs are **not** provided
  dynamic "primary_network_interface" {
    for_each = length(var.allowed_vlans) == 0 ? [1] : []
    content {
      subnet = var.subnet_id
    }
  }

  # Attach VLANs if they are provided
  dynamic "primary_network_attachment" {
    for_each = length(var.allowed_vlans) > 0 ? [1] : []
    content {
      name = "${var.prefix}-vni"
      virtual_network_interface {
        id = ibm_is_virtual_network_interface.bms[0].id
      }
      allowed_vlans = var.allowed_vlans
    }
  }
}

# Create Virtual Network Interface (VNI) only if VLANs are provided
resource "ibm_is_virtual_network_interface" "bms" {
  count  = length(var.allowed_vlans) > 0 ? 1 : 0 # Only create when VLANs exist
  name   = "vni-${var.prefix}"
  subnet = var.subnet_id
}
