output "disk_ids" {
  value = { for k, v in ibm_is_bare_metal_server_disk.disk : k => v.id }
}
