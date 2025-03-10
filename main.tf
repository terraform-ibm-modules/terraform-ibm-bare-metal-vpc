# Data block to retrieve subnet details
data "ibm_is_subnet" "selected" {
  count      = length(var.subnet_ids)
  identifier = var.subnet_ids[count.index]
}

locals {
  baremetal_server_map = {
    for idx in range(var.server_count) :
    md5("${var.prefix}-${idx}") => {
      prefix    = var.server_count == 1 ? var.prefix : "${var.prefix}-${idx}"
      subnet_id = var.subnet_ids[idx % length(var.subnet_ids)]
      zone      = data.ibm_is_subnet.selected[idx % length(data.ibm_is_subnet.selected)].zone
      vpc       = data.ibm_is_subnet.selected[idx % length(data.ibm_is_subnet.selected)].vpc
    }
  }
}

# BareMetal module
module "baremetal" {
  source   = "./modules/baremetal"
  for_each = local.baremetal_server_map

  name              = each.value.prefix
  profile           = var.profile
  image_id          = var.image_id
  subnet_id         = each.value.subnet_id
  zone              = each.value.zone
  vpc_id            = each.value.vpc
  ssh_key_ids       = var.ssh_key_ids
  bandwidth         = var.bandwidth
  allowed_vlan_ids  = var.allowed_vlan_ids
  access_tags       = var.access_tags
  resource_group_id = var.resource_group_id
}
