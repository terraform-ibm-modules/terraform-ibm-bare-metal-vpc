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
  primary_vni                  = module.virtual_network_interfaces.primary_vnis[local.bms_name]
  secondary_vnis               = module.virtual_network_interfaces.secondary_vnis
  bms_name                     = var.bms_name
  primary_legacy_interface     = var.primary_legacy_interface
  legacy_additional_interfaces = var.legacy_additional_interfaces

  create_security_group           = var.create_security_group
  secondary_security_groups       = var.secondary_security_groups
  default_security_group          = var.default_security_group
  manage_reserved_ips             = var.manage_reserved_ips
  primary_reserved_ips             = module.reserved_ips.primary_ips
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
        type        = "primary"
      } if var.manage_reserved_ips
    },
    {
      for key, value in local.secondary_reserved_ips_map :
      key => {
        name        = "${var.prefix}-${substr(md5(value.name), -4, 4)}-ip"
        subnet_id   = value.subnet_id
        auto_delete = false
        type        = "secondary"
      } if var.primary_vni_additional_ip_count > 0 && !var.use_legacy_network_interface
    },
    {
      for key, value in local.secondary_vni_map :
      key => {
        name        = "${var.prefix}-${substr(md5(value.name), -4, 4)}-secondary-vni-ip"
        subnet_id   = value.subnet_id
        auto_delete = false
        type        = "secondary"
      } if !var.use_legacy_network_interface && var.manage_reserved_ips
    }
  )


  prefix = var.prefix
}


module "virtual_network_interfaces" {
  source = "./modules/vni"

  resource_map = merge(
    {
      for bms_key, bms_value in local.bms_map :
      bms_key => {
        name                   = "${bms_value.bms_name}-vni"
        subnet_id              = bms_value.subnet_id
        allow_ip_spoofing      = var.allow_ip_spoofing
        use_bms_security_group = var.create_security_group
        primary_reserved_ip    = var.manage_reserved_ips ? module.reserved_ips.primary_ips[bms_value.name] : null
        secondary_reserved_ips = var.manage_reserved_ips ? {
          for count in range(var.primary_vni_additional_ip_count) :
          count => module.reserved_ips.secondary_ips["${bms_value.name}-${count}"]
        } : null
        additional_ip_count    = var.primary_vni_additional_ip_count
      } if !var.use_legacy_network_interface
    },
    {
      for key, value in local.secondary_vni_map :
      key => {
        name                   = value.name
        subnet_id              = value.subnet_id
        allow_ip_spoofing      = var.secondary_allow_ip_spoofing
        use_bms_security_group = var.secondary_use_bms_security_group
        primary_reserved_ip    = var.manage_reserved_ips ? module.reserved_ips.primary_ips[key] : null
        secondary_reserved_ips = {}
        additional_ip_count    = 0
      } if !var.use_legacy_network_interface
    }
  )

  create_security_group = var.create_security_group
  security_group        = var.security_group
  security_groups       = var.secondary_security_groups
  manage_reserved_ips   = var.manage_reserved_ips
}

module "floating_ips" {
  source = "./modules/fip"

  floating_ip_map = merge(
    // Primary BMS Floating IPs
    {
      for key, bms in module.bare_metal_server :
      key => {
        name           = "${bms.name}-fip"
        target         = var.use_legacy_network_interface ? bms.primary_network_interface[0].id : bms.primary_network_attachment[0].virtual_network_interface[0].id
        tags           = var.tags
        access_tags    = var.access_tags
        resource_group = var.resource_group_id
      } if var.enable_floating_ip
    },

    // Legacy Secondary Floating IPs
    var.use_legacy_network_interface && length(var.secondary_floating_ips) > 0 ? {
      for interface in local.legacy_secondary_fip_list :
      interface.name => {
        name           = interface.name
        target         = interface.target
        tags           = var.tags
        access_tags    = var.access_tags
        resource_group = var.resource_group_id
      }
    } : {},

    // VNI Secondary Floating IPs
    {
      for key, value in local.secondary_fip_map :
      key => {
        name           = key
        target         = value.vni_id
        tags           = var.tags
        access_tags    = var.access_tags
        resource_group = var.resource_group_id
      }
    }
  )
}
