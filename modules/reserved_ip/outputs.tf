output "reserved_ip_ids" {
  description = "Map of reserved IP IDs."
  value = { for key, ip in ibm_is_subnet_reserved_ip.reserved_ip : key => ip.id }
}

output "reserved_ip_names" {
  description = "Map of reserved IP Names."
  value = { for key, ip in ibm_is_subnet_reserved_ip.reserved_ip : key => ip.name }
}
