#########################################################
######            BareMetal Server Module          ######
#########################################################

module "bare_metal_servers" {
  for_each = var.bare_metal_servers

  source = "./modules/baremetal"

  profile               = each.value.profile
  prefix                = each.value.prefix
  image                 = each.value.image
  keys                  = each.value.keys
  vpc_id                = var.vpc_id
  subnets               = var.subnets
  bms_per_subnet        = var.bms_per_subnet
  allow_ip_spoofing     = var.allow_ip_spoofing
  resource_group_id     = var.resource_group_id
  tags                  = var.tags
  access_tags           = var.access_tags
  create_security_group = var.create_security_group
}
