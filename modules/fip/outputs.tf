output "fip_ids" {
  value = { for k, v in ibm_is_floating_ip.fip : k => v.id }
}
