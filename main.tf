locals {
  # Map subnets with stable keys
  subnet_map = {
    for idx, subnet_id in var.subnet_ids :
    "subnet-${idx}" => subnet_id
  }

  # Generate server keys with stable subnet association
  bms_servers = [
    for idx in range(var.server_count) : {
      key        = "server-${idx}" # Stable key based on server index
      prefix     = "${var.prefix}-${idx}"
      subnet_key = "subnet-${idx % length(var.subnet_ids)}" # Consistent subnet mapping
      subnet_id  = local.subnet_map["subnet-${idx % length(var.subnet_ids)}"]
    }
  ]

  # Create a map for stable keys
  bms_server_map = {
    for server in local.bms_servers :
    server.key => {
      prefix     = server.prefix
      subnet_key = server.subnet_key
      subnet_id  = server.subnet_id
    } if contains(keys(local.subnet_map), server.subnet_key)
  }
}

# Fetch subnet details dynamically
data "ibm_is_subnet" "selected" {
  for_each   = local.subnet_map
  identifier = each.value
}

# Create baremetal instances
module "baremetal" {
  source   = "./modules/baremetal"
  for_each = local.bms_server_map

  name              = each.value.prefix
  profile           = var.profile
  image_id          = var.image_id
  subnet_id         = each.value.subnet_id
  ssh_key_ids       = var.ssh_key_ids
  bandwidth         = var.bandwidth
  allowed_vlan_ids  = var.allowed_vlan_ids
  access_tags       = var.access_tags
  resource_group_id = var.resource_group_id
}
