variable "prefix" {
  description = "Name of the bare metal server. If multiple instances are created, an index will be appended."
  type        = string
}

variable "profile" {
  description = "The profile to use for the bare metal server."
  type        = string
}

variable "image" {
  description = "The ID of the image to use for the bare metal server."
  type        = string
}

variable "zone" {
  description = "The zone where the bare metal server will be provisioned."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the bare metal server will be provisioned."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the bare metal server will be provisioned."
  type        = list(string)
}

variable "ssh_key_id" {
  description = "The ID of the SSH key to use for the bare metal server."
  type        = list(string)
}

variable "bandwidth" {
  description = "The bandwidth for the bare metal server."
  type        = number
  default     = null
}

variable "allowed_vlans" {
  description = "List of allowed VLANs for the bare metal server."
  type        = list(number)
  default     = []
}

variable "access_tags" {
  description = "List of access management tags to attach to the bare metal server."
  type        = list(string)
  default     = []
}
