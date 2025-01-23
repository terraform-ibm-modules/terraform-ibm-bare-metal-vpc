output "primary_ips" {
  description = "Map of primary reserved IPs"
  value       = {
    for key, ip in ibm_is_subnet_reserved_ip.primary_ips :
    key => ip.reserved_ip
  }
}

output "secondary_ips" {
  description = "Map of secondary reserved IPs"
  value       = {
    for key, ip in ibm_is_subnet_reserved_ip.secondary_ips :
    key => ip.reserved_ip
  }
}