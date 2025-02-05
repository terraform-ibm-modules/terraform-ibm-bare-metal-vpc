########################################################################################################################
# Input Variables
########################################################################################################################

variable "server_count" {
  description = "Number of bare metal server instances to create."
  type        = number
  default     = 1
}

variable "prefix" {
  description = "Name of the bare metal server. If multiple instances are created, an index will be appended."
  type        = string
  default     = "example-bms"
}

variable "profile" {
  description = "The profile to use for the bare metal server."
  type        = string
  default     = "mx2d-metal-32x192"
}

variable "image" {
  description = "The ID of the image to use for the bare metal server."
  type        = string
  default     = "r134-31c8ca90-2623-48d7-8cf7-737be6fc4c3e"
}

variable "zone" {
  description = "The zone where the bare metal server will be provisioned."
  type        = string
  default     = "us-south-3"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet."
  type        = string
  default     = "10.240.129.0/24"
}

variable "reservation_pool_id" {
  description = "The ID of the reservation pool to use for the bare metal server."
  type        = string
  default     = null
}

variable "bandwidth" {
  description = "The bandwidth for the bare metal server."
  type        = number
  default     = null
}

variable "primary_ip" {
  description = "The primary IP configuration for the bare metal server."
  type = object({
    auto_delete = bool
    name        = string
    address     = string
  })
  default = null
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

variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "ssh_key_id" {
  description = "List of SSH key IDs for authentication"
  type        = list(string)
}

variable "subnet_id" {
  description = "List of Subnet IDs to associate with the Bare Metal Server(s)"
  type        = list(string)
}
