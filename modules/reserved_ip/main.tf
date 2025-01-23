resource "ibm_is_subnet_reserved_ip" "reserved_ip" {
  for_each    = var.reserved_ips_map
  name        = "${var.prefix}${each.value.name}"
  subnet      = each.value.subnet_id
  auto_delete = each.value.auto_delete
}