resource "ibm_is_subnet_reserved_ip" "primary_ips" {
  for_each = { for key, value in var.reserved_ips_map : key => value if value.type == "primary" }
  name     = each.value.name
  subnet   = each.value.subnet_id
  auto_delete = each.value.auto_delete
}

resource "ibm_is_subnet_reserved_ip" "secondary_ips" {
  for_each = { for key, value in var.reserved_ips_map : key => value if value.type == "secondary" }
  name     = each.value.name
  subnet   = each.value.subnet_id
  auto_delete = each.value.auto_delete
}
