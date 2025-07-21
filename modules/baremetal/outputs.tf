output "baremetal_server_id" {
  description = "Output for baremetal servers ID."
  value       = ibm_is_bare_metal_server.bms.id
}

output "baremetal_server_name" {
  description = "Output for baremetal servers name."
  value       = ibm_is_bare_metal_server.bms.name
}

output "baremetal_server_primary_ip" {
  description = "Output for baremetal Primary IP address."
  value       = one(ibm_is_virtual_network_interface.bms[*].primary_ip[*].address)
}

output "baremetal_server_primary_vni_id" {
  description = "Output for primary virtual network interface ID."
  value       = one(ibm_is_virtual_network_interface.bms[*].id)
}

output "baremetal_server_secondary_ip" {
  description = "Output for baremetal Secondary IP address."
  value       = one(ibm_is_virtual_network_interface.bms_secondary[*].primary_ip[*].address)
}

output "baremetal_server_secondary_vni_id" {
  description = "Output for secondary virtual network interface ID."
  value       = one(ibm_is_virtual_network_interface.bms_secondary[*].id)
}
