########################################################################################################################
# Outputs
########################################################################################################################

output "baremetal_servers" {
  description = "The map of baremetal servers with their respective subnets and zones."
  value       = local.baremetal_servers
}

output "subnet_details" {
  description = "The details of the subnets selected for the baremetal servers."
  value       = data.ibm_is_subnet.selected
}

output "server_count" {
  description = "The number of servers to be created."
  value       = var.server_count
}

output "subnet_ids" {
  description = "The list of subnet IDs passed to the root module."
  value       = var.subnet_ids
}
