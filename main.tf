data "ibm_is_subnet" "selected" {
  count     = length(var.subnet_ids) # Use count instead of for_each
  identifier = var.subnet_ids[count.index]
}

locals {
  baremetal_servers = { for idx in range(var.server_count) : idx => {
    prefix    = var.server_count == 1 ? var.prefix : "${var.prefix}-${idx}"
    subnet_id = var.subnet_ids[idx % length(var.subnet_ids)]
    zone      = data.ibm_is_subnet.selected[idx % length(var.subnet_ids)].zone
  } }
}

module "baremetal" {
  source   = "./modules/baremetal"
  for_each = local.baremetal_servers

  prefix            = each.value.prefix
  profile           = var.profile
  image             = var.image
  subnet_id         = each.value.subnet_id
  zone              = each.value.zone
  vpc_id            = var.vpc_id
  ssh_key_ids       = var.ssh_key_ids
  bandwidth         = var.bandwidth
  allowed_vlans     = var.allowed_vlans
  access_tags       = var.access_tags
  resource_group_id = var.resource_group_id
}
