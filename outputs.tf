##############################################################################
# Outputs
##############################################################################

output "bare_metal_servers" {
  description = "Details of the bare metal servers"
  value = {
    for server_name, server in module.bare_metal_servers : server_name => server.bare_metal_servers
  }
}
