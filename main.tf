# main.tf

module "baremetal_server" {
  source = "./modules/baremetal_server"

  bare_metal_profile = var.bare_metal_profile
  bare_metal_name    = var.prefix
  image_id           = var.image_id
  zone               = var.zone
  ssh_key_id         = var.ssh_key_ids
  resource_group_id  = var.resource_group_id
  vpc_id             = var.vpc_id
  use_legacy_network_interface = var.use_legacy_network_interface
  primary_vni                  = module.virtual_network_interfaces.primary_vnis[local.bms_name]
  create_security_group            = var.create_security_group
  secondary_security_groups        = var.secondary_security_groups
  default_security_group           = data.ibm_is_vpc.vpc.default_security_group
  manage_reserved_ips              = var.manage_reserved_ips
  primary_reserved_ips             = module.reserved_ips.primary_ips
}

module "reserved_ips" {
  source = "./modules/reserved_ip"

  reserved_ips_map = local.reserved_ips_map
  prefix = var.prefix
}


module "virtual_network_interfaces" {
  source = "./modules/vni"

  resource_map         = local.resource_map
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
