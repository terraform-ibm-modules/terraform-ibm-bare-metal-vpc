output "primary_vnis" {
  description = "List of primary VNI IDs and their zones."
  value = [
    for key, vni in ibm_is_virtual_network_interface.vni :
    {
      id   = vni.id
      name = vni.name
      zone = vni.zone
    }
    if contains(keys(var.resource_map), key) && var.resource_map[key].additional_ip_count > 0
  ]
}

output "secondary_vnis" {
  description = "List of secondary VNI IDs and their zones."
  value = [
    for key, vni in ibm_is_virtual_network_interface.vni :
    {
      id   = vni.id
      name = vni.name
      zone = vni.zone
    }
    if contains(keys(var.resource_map), key) && var.resource_map[key].additional_ip_count == 0
  ]
}
