output "baremetal_server_id" {
  description = "Output for baremetal servers ID."
  value       = ibm_is_bare_metal_server.bms.id
}

output "baremetal_server_name" {
  description = "Output for baremetal servers name."
  value       = ibm_is_bare_metal_server.bms.name
}

output "baremetal_server_ip" {
  description = "Output for baremetal IP address."
  value       = ibm_is_virtual_network_interface.bms[0].primary_ip
}

output "baremetal_server_vni_id" {
  description = "Output for virtual network interface ID."
  value       = ibm_is_virtual_network_interface.bms[0].id
}
