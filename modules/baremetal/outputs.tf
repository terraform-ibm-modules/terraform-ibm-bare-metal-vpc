##############################################################################
# Outputs
##############################################################################

output "bare_metal_servers" {
  description = "Details of the bare metal servers"
  value = {
    for server_name, server in ibm_is_bare_metal_server.bms : server_name => {
      id    = server.id
      name  = server.name
      zone  = server.zone
      image = server.image
      keys  = server.keys
      tags  = server.tags
    }
  }
}
