variable "resource_map" {
  description = "Map of resources with configuration for each VNI."
  type        = map(object({
    name                    = string
    subnet_id               = string
    allow_ip_spoofing       = bool
    use_vsi_security_group  = bool
    primary_reserved_ip     = optional(string)
    secondary_reserved_ips  = optional(map(string))
    additional_ip_count     = number
  }))
}

variable "create_security_group" {
  description = "Indicates whether to create a security group."
  type        = bool
}

variable "security_group" {
  description = "Security group details."
  type        = object({
    name = string
  })
}

variable "security_groups" {
  description = "List of security groups for VNIs."
  type        = list(object({
    interface_name  = string
    security_group_id = string
  }))
}

variable "manage_reserved_ips" {
  description = "Whether to manage reserved IPs."
  type        = bool
}
