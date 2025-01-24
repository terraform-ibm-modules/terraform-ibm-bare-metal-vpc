variable "profile" {
  description = "Bare metal server profile to specify the configuration of the server."
  type        = string
}

variable "name" {
  description = "Name of the bare metal server."
  type        = string
}

variable "image" {
  description = "Image ID to be used for the bare metal server."
  type        = string
}

variable "zone" {
  description = "Zone where the bare metal server will be deployed."
  type        = string
}

variable "keys" {
  description = "List of SSH keys to be used for the server."
  type        = list(string)
}

variable "vpc" {
  description = "VPC ID where the bare metal server will be deployed."
  type        = string
}

variable "use_legacy_network_interface" {
  description = "Toggle to enable or disable legacy network interface configuration."
  type        = bool
  default     = false
}

variable "primary_vni" {
  description = "Primary virtual network interface ID for the non-legacy configuration."
  type        = string
  default     = null
}

variable "primary_reserved_ip" {
  description = "Reserved IP ID for the primary virtual network interface."
  type        = string
  default     = null
}

variable "primary_subnet_id" {
  description = "Subnet ID for the primary network interface in legacy configuration."
  type        = string
  default     = null
}

variable "secondary_vnis" {
  description = "Map of secondary virtual network interface IDs for additional interfaces in non-legacy configuration."
  type        = map(string)
  default     = {}
}

variable "secondary_subnets" {
  description = "List of secondary subnets to be used for legacy additional network interfaces."
  type        = list(object({
    id   = string
    name = string
    zone = string
  }))
  default = []
}

variable "allow_ip_spoofing" {
  description = "Boolean to enable or disable IP spoofing for the primary network interface."
  type        = bool
  default     = false
}

variable "secondary_allow_ip_spoofing" {
  description = "Boolean to enable or disable IP spoofing for the secondary network interfaces."
  type        = bool
  default     = false
}

variable "create_security_group" {
  description = "Boolean to specify whether to create a security group."
  type        = bool
  default     = false
}

variable "secondary_use_vsi_security_group" {
  description = "Boolean to specify whether to use the VSI's security group for secondary interfaces."
  type        = bool
  default     = false
}

variable "security_group" {
  description = "Object specifying the security group name for the server."
  type        = object({
    name = string
  })
  default = null
}

variable "security_group_ids" {
  description = "List of additional security group IDs for primary and secondary interfaces."
  type        = list(string)
  default     = []
}

variable "secondary_security_groups" {
  description = "List of objects mapping secondary network interfaces to their respective security group IDs."
  type        = list(object({
    interface_name    = string
    security_group_id = string
  }))
  default = []
}
