module "network" {
  source = "../network"

  manage_reserved_ips               = var.manage_reserved_ips
  primary_vni_additional_ip_count   = var.primary_vni_additional_ip_count
  use_legacy_network_interface      = var.use_legacy_network_interface
  allow_ip_spoofing                 = var.allow_ip_spoofing
  secondary_allow_ip_spoofing       = var.secondary_allow_ip_spoofing
  create_security_group             = var.create_security_group
  security_group_ids                = var.security_group_ids
  secondary_security_groups         = var.secondary_security_groups
  prefix                            = var.prefix
  vsi_map                           = local.vsi_map
  secondary_vni_map                 = local.secondary_vni_map
  secondary_reserved_ips_map        = local.secondary_reserved_ips_map
  secondary_use_bms_security_group  = var.secondary_use_bms_security_group
}


/*module "disk" {
  source = "./modules/disk"
  disks = [
    {
      name              = "disk1"
      bare_metal_server = module.baremetal.bare_metal_id
    }
  ]
}*/

module "fip" {
  source = "./modules/fip"
  floating_ip_map = {
    fip1 = {
      name    = "floating-ip-1"
      target  = module.vni.vni_ids["primary_vni"]
      zone    = var.zone
    }
  }
}

module "baremetal" {
  source = "./modules/baremetal"
  profile             = var.bare_metal_profile
  name                = var.bare_metal_name
  image               = var.image_id
  zone                = var.zone
  keys                = var.ssh_keys
  primary_vni         = module.vni.vni_ids["primary_vni"]
  primary_reserved_ip = module.reserved_ips.reserved_ips["primary_ip"]
  vpc                 = var.vpc_id
  secondary_vnis            = var.secondary_vnis
  secondary_subnets         = var.secondary_subnets
  use_legacy_network_interface = var.use_legacy_network_interface
  allow_ip_spoofing         = var.allow_ip_spoofing
  secondary_allow_ip_spoofing = var.secondary_allow_ip_spoofing
  create_security_group     = var.create_security_group
  security_group            = var.security_group
  security_group_ids        = var.security_group_ids
  secondary_security_groups = var.secondary_security_groups
}

