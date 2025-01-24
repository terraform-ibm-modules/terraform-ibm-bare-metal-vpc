output "bare_metal_server_id" {
  description = "The ID of the bare metal server."
  value       = module.baremetal.bare_metal_id
}

output "disk_ids" {
  description = "The IDs of the attached disks."
  value       = module.disk.disk_ids
}

output "floating_ip_ids" {
  description = "The IDs of the floating IPs."
  value       = module.fip.fip_ids
}

output "reserved_ips" {
  description = "Reserved IPs created by the network module."
  value = module.network.reserved_ips
}

output "vni_ids" {
  description = "Virtual Network Interface IDs created by the network module."
  value = module.network.vni_ids
}

output "bms_id" {
  description = "ID of the bare metal server."
  value       = module.bms.bms_id
}

output "primary_network_interface" {
  description = "Primary network interface of the bare metal server."
  value       = module.bms.primary_network_interface
}

output "secondary_network_interfaces" {
  description = "List of secondary network interfaces of the bare metal server."
  value       = module.bms.secondary_network_interfaces
}
