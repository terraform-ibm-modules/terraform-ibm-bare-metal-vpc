##############################################################################
# VSI Outputs
##############################################################################

output "ids" {
  description = "The IDs of the VSI"
  value = [
    for bms in module.baremetal_server :
    bms.id
  ]
}

output "vsi_security_group" {
  description = "Security group for the VSI"
  value       = var.security_group != null && var.create_security_group == true ? ibm_is_security_group.security_group[var.security_group.name] : null
}

output "list" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address"
  value = [
    for vsi_key, baremetal_server in module.baremetal_server :
    {
      name                   = baremetal_server.name
      id                     = baremetal_server.id
      zone                   = baremetal_server.zone
      ipv4_address           = baremetal_server.primary_network_interface[0].primary_ipv4_address
      secondary_ipv4_address = length(baremetal_server.network_interfaces) == 0 ? null : baremetal_server.network_interfaces[0].primary_ipv4_address
      floating_ip            = var.enable_floating_ip ? ibm_is_floating_ip.vsi_fip[vsi_key].address : null
      floating_ip_id         = var.enable_floating_ip ? ibm_is_floating_ip.vsi_fip[vsi_key].id : null
      floating_ip_crn        = var.enable_floating_ip ? ibm_is_floating_ip.vsi_fip[vsi_key].crn : null
      vpc_id                 = var.vpc_id
      snapshot_id            = one(baremetal_server.boot_volume[*].snapshot)
    }
  ]
}

output "fip_list" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, and floating IP. This list only contains instances with a floating IP attached."
  value = [
    for vsi_key, baremetal_server in module.baremetal_server :
    {
      name                   = baremetal_server.name
      id                     = baremetal_server.id
      zone                   = baremetal_server.zone
      ipv4_address           = baremetal_server.primary_network_interface[0].primary_ipv4_address
      secondary_ipv4_address = length(baremetal_server.network_interfaces) == 0 ? null : baremetal_server.network_interfaces[0].primary_ipv4_address
      floating_ip            = var.enable_floating_ip ? ibm_is_floating_ip.vsi_fip[vsi_key].address : null
      floating_ip_id         = var.enable_floating_ip ? ibm_is_floating_ip.vsi_fip[vsi_key].id : null
      floating_ip_crn        = var.enable_floating_ip ? ibm_is_floating_ip.vsi_fip[vsi_key].crn : null
      vpc_id                 = var.vpc_id
    } if var.enable_floating_ip == true
  ]
}
