module "baremetal" {
  source              = "./modules/baremetal"
  for_each            = { for idx in range(var.server_count) : idx => idx }
  prefix              = var.server_count == 1 ? var.prefix : "${var.prefix}-${each.key}"
  profile             = var.profile
  image               = var.image
  zone                = var.zone
  vpc_id              = var.vpc_id
  subnet_id           = var.subnet_id
  ssh_key_id          = var.ssh_key_id
  reservation_pool_id = var.reservation_pool_id
  bandwidth           = var.bandwidth
  allowed_vlans       = var.allowed_vlans
  access_tags         = var.access_tags
}
