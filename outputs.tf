########################################################################################################################
# Outputs
########################################################################################################################

output "baremetal_servers" {
  value = {
    for servers, key in module.baremetal :
    servers => {
      bms_server_id                        = key.baremetal_server_id
      bms_server_name                      = key.baremetal_server_name
      bms_server_primary_ip                = key.baremetal_server_primary_ip
      bms_primary_vni_id                   = key.baremetal_server_primary_vni_id
      bms_server_secondary_ip              = key.baremetal_server_secondary_ip
      bms_secondary_vni_id                 = key.baremetal_server_secondary_vni_id
      baremetal_server_primary_reserved_ip = key.baremetal_server_primary_reserved_ip
    }
  }
  description = "IDs and names of the provisioned bare metal servers"
}

output "subnet_details" {
  description = "The details of the subnets selected for the baremetal servers."
  value       = data.ibm_is_subnet.selected
}

output "secondary_subnet_details" {
  description = "The details of the subnets selected for the baremetal servers."
  value       = var.secondary_vni_enabled ? data.ibm_is_subnet.secondary_selected : null
}

output "server_count" {
  description = "The number of servers to be created."
  value       = var.server_count
}

output "subnet_ids" {
  description = "The list of subnet IDs passed to the root module."
  value       = var.subnet_ids
}
