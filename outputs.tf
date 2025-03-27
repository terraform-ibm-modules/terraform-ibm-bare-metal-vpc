########################################################################################################################
# Outputs
########################################################################################################################

output "baremetal_servers" {
  value = {
    for servers, key in module.baremetal :
    servers => {
      bms_server_id   = key.baremetal_server_id
      bms_server_name = key.baremetal_server_name
      bms_server_ip   = key.baremetal_server_ip
      bms_vni_id      = key.baremetal_server_vni_id
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
