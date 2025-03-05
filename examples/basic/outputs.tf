output "vpc_id" {
  description = "The ID of the VPC created by the slz_vpc module."
  value       = module.slz_vpc.vpc_id
}

output "subnet_ids" {
  description = "The list of subnet IDs created in the specified zone."
  value       = [for subnet in module.slz_vpc.subnet_zone_list : subnet.id if subnet.zone == "${var.region}-1"]
}

output "region" {
  description = "The region where the resources are being created."
  value       = var.region
}
