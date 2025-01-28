output "bare_metal_server_ids" {
  description = "The IDs of the deployed bare metal servers."
  value = {
    for key, server in ibm_is_bare_metal_server.bms : key => server.id
  }
}

output "bare_metal_server_names" {
  description = "The names of the deployed bare metal servers."
  value = {
    for key, server in ibm_is_bare_metal_server.bms : key => server.name
  }
}

output "bare_metal_server_zones" {
  description = "The zones of the deployed bare metal servers."
  value = {
    for key, server in ibm_is_bare_metal_server.bms : key => server.zone
  }
}

output "bare_metal_server_vpcs" {
  description = "The VPC IDs of the deployed bare metal servers."
  value = {
    for key, server in ibm_is_bare_metal_server.bms : key => server.vpc
  }
}

output "bare_metal_server_primary_subnets" {
  description = "The primary subnets assigned to the bare metal servers."
  value = {
    for key, server in ibm_is_bare_metal_server.bms : key => server.primary_network_interface[0].subnet
  }
}

output "bare_metal_server_primary_ips" {
  description = "The primary IP addresses assigned to the bare metal servers."
  value = {
    for key, server in ibm_is_bare_metal_server.bms : key => server.primary_network_interface[0].primary_ip
  }
}

output "bare_metal_server_ip_spoofing" {
  description = "The allow_ip_spoofing setting for the primary network interfaces of the bare metal servers."
  value = {
    for key, server in ibm_is_bare_metal_server.bms : key => server.primary_network_interface[0].allow_ip_spoofing
  }
}
