variable "manage_reserved_ips" {
  description = "Flag to determine whether reserved IPs should be managed."
  type        = bool
}

variable "primary_vni_additional_ip_count" {
  description = "Number of additional primary VNI IPs."
  type        = number
  default     = 0
}

variable "use_legacy_network_interface" {
  description = "Flag to use legacy network interfaces."
  type        = bool
}

variable "allow_ip_spoofing" {
  description = "Flag to allow IP spoofing on VNIs."
  type        = bool
}

variable "secondary_allow_ip_spoofing" {
  description = "Flag to allow IP spoofing on secondary VNIs."
  type        = bool
}

variable "create_security_group" {
  description = "Flag to create a security group."
  type        = bool
}

variable "security_group_ids" {
  description = "List of security group IDs for primary VNIs."
  type        = list(string)
}

variable "secondary_security_groups" {
  description = "List of security groups for secondary VNIs."
  type        = list(object({
    security_group_id = string
    interface_name    = string
  }))
}

variable "prefix" {
  description = "Prefix to use for naming resources."
  type        = string
}

variable "bms_map" {
  description = "Map of VSI configurations."
  type        = map(object({
    name      = string
    subnet_id = string
    bms_name  = string
  }))
}

variable "secondary_vni_map" {
  description = "Map of secondary VNI configurations."
  type        = map(object({
    name      = string
    subnet_id = string
  }))
}

variable "secondary_reserved_ips_map" {
  description = "Map of secondary reserved IP configurations."
  type        = map(object({
    name      = string
    subnet_id = string
  }))
}

variable "secondary_use_bms_security_group" {
  description = "Use the security group created by this module in the secondary interface"
  type        = bool
  default     = false
}