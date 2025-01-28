########################################################################################################################
# Baremetal Server Outputs
########################################################################################################################

output "bare_metal_servers" {
  description = "Details of the provisioned bare metal servers"
  value = {
    for server_key, server_value in module.bare_metal_servers :
    server_key => {
      id         = server_value.id
      name       = server_value.name
      zone       = server_value.zone
      primary_ip = server_value.primary_ip
    }
  }
}
