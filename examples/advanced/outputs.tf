########################################################################################################################
# Outputs for BareMetal Servers
########################################################################################################################

output "bare_metal_server_ids" {
  description = "The IDs of the deployed bare metal servers."
  value = {
    for name, server in module.slz_bms.bare_metal_servers : name => server.id
  }
}

output "bare_metal_server_names" {
  description = "The names of the deployed bare metal servers."
  value = {
    for name, server in module.slz_bms.bare_metal_servers : name => server.name
  }
}

output "bare_metal_server_private_ips" {
  description = "The private IP addresses of the deployed bare metal servers."
  value = {
    for name, server in module.slz_bms.bare_metal_servers : name => server.private_ip
  }
}

output "bare_metal_server_zones" {
  description = "The zones of the deployed bare metal servers."
  value = {
    for name, server in module.slz_bms.bare_metal_servers : name => server.zone
  }
}

output "bare_metal_server_primary_subnets" {
  description = "The primary subnets assigned to the bare metal servers."
  value = {
    for name, server in module.slz_bms.bare_metal_servers : name => server.primary_subnet
  }
}
