output "bare_metal_server_id" {
  description = "The ID of the created bare metal server."
  value       = ibm_is_bare_metal_server.bms[*].id
}

output "bare_metal_server_name" {
  description = "The name of the created bare metal server."
  value       = ibm_is_bare_metal_server.bms[*].name
}
