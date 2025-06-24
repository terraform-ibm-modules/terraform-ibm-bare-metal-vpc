locals {
  # Map subnets with stable keys
  subnet_map = {
    for idx, subnet_id in var.subnet_ids :
    "subnet-${idx}" => subnet_id
  }

  # Map secondary subnets if provided, otherwise use primary subnets
  secondary_subnet_map = length(var.secondary_subnet_ids) > 0 ? {
    for idx, subnet_id in var.secondary_subnet_ids :
    "subnet-${idx}" => subnet_id
  } : local.subnet_map

  # Generate server keys with stable subnet association
  bms_servers = [
    for idx in range(var.server_count) : {
      key                 = "server-${idx}"
      prefix              = "${var.prefix}-${idx}"
      subnet_key          = "subnet-${idx % length(var.subnet_ids)}"
      subnet_id           = local.subnet_map["subnet-${idx % length(var.subnet_ids)}"]
      secondary_subnet_id = try(local.secondary_subnet_map["subnet-${idx % length(local.secondary_subnet_map)}"], null)
    }
  ]

  # Create a map for stable keys
  bms_server_map = {
    for server in local.bms_servers :
    server.key => {
      prefix              = server.prefix
      subnet_key          = server.subnet_key
      subnet_id           = server.subnet_id
      secondary_subnet_id = server.secondary_subnet_id
    } if contains(keys(local.subnet_map), server.subnet_key)
  }
}

# Fetch subnet details dynamically
data "ibm_is_subnet" "selected" {
  for_each   = local.subnet_map
  identifier = each.value
}

# Fetch secondary subnet details if they exist
data "ibm_is_subnet" "secondary_selected" {
  for_each   = local.secondary_subnet_map
  identifier = each.value
}

# Create baremetal instances
module "baremetal" {
  source   = "./modules/baremetal"
  for_each = local.bms_server_map

  name               = each.value.prefix
  profile            = var.profile
  image_id           = var.image_id
  subnet_id          = each.value.subnet_id
  ssh_key_ids        = var.ssh_key_ids
  security_group_ids = local.security_group_ids
  bandwidth          = var.bandwidth
  allowed_vlan_ids   = var.allowed_vlan_ids

  # Secondary VNI parameters
  secondary_vni_enabled        = var.secondary_vni_enabled
  secondary_subnet_id          = each.value.secondary_subnet_id
  secondary_security_group_ids = var.secondary_security_group_ids
  secondary_allowed_vlan_ids   = var.secondary_allowed_vlan_ids

  user_data         = var.user_data
  access_tags       = var.access_tags
  resource_group_id = var.resource_group_id
}
