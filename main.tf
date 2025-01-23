# main.tf

module "baremetal_server" {
  for_each        = local.bms_map
  source = "./modules/baremetal_server"
  bare_metal_profile = var.bare_metal_profile
  bare_metal_name    = var.bare_metal_name
  image_id           = var.image_id
  zone            = each.value.zone
  ssh_key_id         = var.ssh_key_ids
  resource_group_id  = var.resource_group_id
  subnet_id          = var.subnet_id
  vpc_id             = var.vpc_id
  user_data       = var.user_data
  tags            = var.tags
  access_tags     = var.access_tags
}

module "virtual_network_interfaces" {
  source = "./modules/vni"

  resource_map = merge(
    { for bms_key, bms_value in local.bms_map : bms_key => {
        name                   = "${bms_value.bms_name}-vni"
        subnet_id              = bms_value.subnet_id
        allow_ip_spoofing      = var.allow_ip_spoofing
        use_bms_security_group = var.create_security_group
        primary_reserved_ip    = var.manage_reserved_ips ? ibm_is_subnet_reserved_ip.bms_ip[bms_value.name].reserved_ip : null
        secondary_reserved_ips = var.manage_reserved_ips ? { for count in range(var.primary_vni_additional_ip_count) : count => ibm_is_subnet_reserved_ip.secondary_bms_ip["${bms_value.name}-${count}"].reserved_ip } : null
        additional_ip_count    = var.primary_vni_additional_ip_count
      } if !var.use_legacy_network_interface },
    { for key, value in local.secondary_vni_map : key => {
        name                   = value.name
        subnet_id              = value.subnet_id
        allow_ip_spoofing      = var.secondary_allow_ip_spoofing
        use_bms_security_group = var.secondary_use_bms_security_group
        primary_reserved_ip    = var.manage_reserved_ips ? ibm_is_subnet_reserved_ip.secondary_vni_ip[key].reserved_ip : null
        secondary_reserved_ips = {}
        additional_ip_count    = 0
      } if !var.use_legacy_network_interface }
  )

  create_security_group = var.create_security_group
  security_group        = var.security_group
  security_groups       = var.secondary_security_groups
  manage_reserved_ips   = var.manage_reserved_ips
}
