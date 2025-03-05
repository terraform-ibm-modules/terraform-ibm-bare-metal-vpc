output "debug_baremetal_servers" {
  description = "Debug output for baremetal servers."
  value       = ibm_is_bare_metal_server.bms
}

output "debug_virtual_network_interfaces" {
  description = "Debug output for virtual network interfaces."
  value       = ibm_is_virtual_network_interface.bms
}
