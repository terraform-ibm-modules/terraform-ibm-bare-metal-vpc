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
  value       = length(var.allowed_vlan_ids) > 0 ? ibm_is_bare_metal_server.bms.primary_network_attachment[0].virtual_network_interface[0].primary_ip[0].address : ibm_is_bare_metal_server.bms.primary_network_interface[0].primary_ip[0].address
}

output "baremetal_server_primary_vni_id" {
  description = "Output for primary virtual network interface ID."
  value       = one(ibm_is_virtual_network_interface.bms[*].id)
}

output "baremetal_server_secondary_ip" {
  description = "Output for baremetal Secondary IP address."
  value       = var.secondary_vni_enabled ? ibm_is_bare_metal_server.bms.network_attachments[0].virtual_network_interface[0].primary_ip[0].address : null
}

output "baremetal_server_secondary_vni_id" {
  description = "Output for secondary virtual network interface ID."
  value       = one(ibm_is_virtual_network_interface.bms_secondary[*].id)
}

output "baremetal_server_primary_reserved_ip" {
  description = "Output for baremetal Primary Reserved IP."
  value       = ibm_is_bare_metal_server.bms.primary_network_interface[0].primary_ip[0].reserved_ip
}