output "bare_metal_server_id" {
  description = "The ID of the bare metal server."
  value       = ibm_is_bare_metal_server.bms.id
}