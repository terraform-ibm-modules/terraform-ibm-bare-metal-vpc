########################################################################################################################
# Outputs
########################################################################################################################

/*output "bare_metal_server_ids" {
  description = "List of Bare Metal Server IDs"
  value       = module.slz_baremetal.bare_metal_server_ids
}

output "bare_metal_server_names" {
  description = "Names of the Bare Metal Servers"
  value       = module.slz_baremetal.bare_metal_server_names
}
*/

output "mz" {
  value = module.slz_vpc.subnet_zone_list
}