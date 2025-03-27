########################################################################################################################
# Outputs
########################################################################################################################

output "baremetal_servers" {
  value = {
    for servers, key in module.baremetal :
    servers => {
      id   = key.baremetal_server_id
      name = key.baremetal_server_name
      ip   = key.baremetal_server_vni
    }
  }
  description = "IDs and names of the provisioned bare metal servers"
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
