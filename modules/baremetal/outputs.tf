output "baremetal_server_id" {
  description = "Output for baremetal servers ID."
  value       = ibm_is_bare_metal_server.bms.id
}

output "baremetal_server_name" {
  description = "Output for baremetal servers name."
  value       = ibm_is_bare_metal_server.bms.name
}

output "baremetal_server_vni" {
  description = "Output for virtual network interfaces."
  value       = ibm_is_virtual_network_interface.bms[*].primary_ip
}
