resource "ibm_is_floating_ip" "fip" {
  for_each = var.floating_ip_map
  name     = each.value.name
  target   = each.value.target
  zone     = each.value.zone
}
