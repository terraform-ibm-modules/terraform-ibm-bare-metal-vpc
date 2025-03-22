output "baremetal_servers_ids" {
  description = "Output for baremetal servers."
  value       = ibm_is_bare_metal_server.bms.id
}

output "baremetal_servers_name" {
  description = "Output for virtual network interfaces."
  value       = ibm_is_bare_metal_server.bms.name
}
