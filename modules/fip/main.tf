resource "ibm_is_floating_ip" "fips" {
  for_each = var.floating_ip_map
  name     = each.value.name
  target   = each.value.target
  tags     = each.value.tags
  access_tags = each.value.access_tags
  resource_group = each.value.resource_group
}