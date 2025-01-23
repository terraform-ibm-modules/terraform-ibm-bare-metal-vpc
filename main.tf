# main.tf

module "bare_metal_server" {
  source = "./modules/bare_metal_server"

  bare_metal_profile = var.bare_metal_profile
  bare_metal_name    = var.bare_metal_name
  image_id           = var.image_id
  zone               = var.zone
  ssh_key_id         = var.ssh_key_id
  resource_group_id  = var.resource_group_id
  vpc_id             = var.vpc_id

  use_legacy_network_interface = var.use_legacy_network_interface
  primary_vni                  = var.primary_vni
  secondary_vnis               = var.secondary_vnis
  bms_name                     = var.bms_name
  primary_legacy_interface     = var.primary_legacy_interface
  legacy_additional_interfaces = var.legacy_additional_interfaces

  create_security_group           = var.create_security_group
  secondary_security_groups       = var.secondary_security_groups
  default_security_group          = var.default_security_group
  manage_reserved_ips             = var.manage_reserved_ips
  secondary_use_bms_security_group = var.secondary_use_bms_security_group
}

module "reserved_ips" {
  source = "./modules/reserved_ip"

  reserved_ips_map = merge(
    {
      for bms_key, bms_value in local.bms_map :
      bms_key => {
        name        = "${bms_value.name}-ip"
        subnet_id   = bms_value.subnet_id
        auto_delete = false
      } if var.manage_reserved_ips
    },
    {
      for key, value in local.secondary_reserved_ips_map :
      key => {
        name        = "${var.prefix}-${substr(md5(value.name), -4, 4)}-ip"
        subnet_id   = value.subnet_id
        auto_delete = false
      } if var.primary_vni_additional_ip_count > 0 && !var.use_legacy_network_interface
    },
    {
      for key, value in local.secondary_vni_map :
      key => {
        name        = "${var.prefix}-${substr(md5(value.name), -4, 4)}-secondary-vni-ip"
        subnet_id   = value.subnet_id
        auto_delete = false
      } if !var.use_legacy_network_interface && var.manage_reserved_ips
    }
  )

  prefix = var.prefix
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
