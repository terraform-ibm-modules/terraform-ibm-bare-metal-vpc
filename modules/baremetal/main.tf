resource "ibm_is_bare_metal_server" "bms" {
  profile     = var.profile
  name        = var.prefix
  image       = var.image
  zone        = var.zone
  keys        = var.ssh_key_id
  vpc         = var.vpc_id
  bandwidth   = var.bandwidth
  access_tags = var.access_tags

  # Use primary_network_interface if no VLANs are needed
  dynamic "primary_network_interface" {
    for_each = length(var.allowed_vlans) == 0 ? [1] : []
    content {
      subnet = var.subnet_id
    }
  }

  # Use primary_network_attachment if VLANs are required
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

resource "ibm_is_virtual_network_interface" "bms" {
  count  = length(var.subnet_id) # Create one VNI per subnet
  name   = "vni-${var.prefix}-${count.index}"
  subnet = var.subnet_id[count.index] # Assign subnet dynamically
}
