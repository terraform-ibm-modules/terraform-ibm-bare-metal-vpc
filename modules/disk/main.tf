resource "ibm_is_bare_metal_server_disk" "disk" {
  for_each = toset(var.disks)
  bare_metal_server = each.value.bare_metal_server
  name              = each.value.name
}
