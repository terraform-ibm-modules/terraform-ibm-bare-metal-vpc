########################################################################################################################
# Input Variables
########################################################################################################################
variable "resource_group_id" {
  type        = string
  description = "ID of the resource group where you want to create the service."
  default     = null
}

variable "server_count" {
  description = "The number of bare metal server instances to create. If set to more than one, multiple instances will be provisioned."
  type        = number
  default     = 1
}

variable "prefix" {
  description = "The base name for the bare metal server. If multiple instances are created, an index will be appended for uniqueness."
  type        = string
  default     = "demo-bms"
}

variable "profile" {
  description = "The hardware profile defining the CPU, memory, and storage configuration of the bare metal server."
  type        = string
  default     = "bx3-metal-48x256"
}

variable "image" {
  description = "The unique identifier of the operating system image to be installed on the bare metal server."
  type        = string
  default     = "r010-7aef85f6-5f06-49e4-a7b4-361baf4e9b88"
}

variable "bandwidth" {
  description = "The allocated bandwidth (in Mbps) for the bare metal server to manage network traffic. If unset, default values apply."
  type        = number
  default     = null
}

variable "allowed_vlans" {
  description = "A list of VLAN IDs that are permitted for the bare metal server, ensuring network isolation and control."
  type        = list(number)
  default     = []
}

variable "access_tags" {
  description = "A list of access management tags to be attached to the bare metal server for categorization and policy enforcement."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "The unique identifier of the IBM Cloud Virtual Private Cloud (VPC) where the bare metal server will be provisioned."
  type        = string
}

variable "ssh_key_ids" {
  description = "A list of SSH key IDs that will be used for secure access to the bare metal server."
  type        = list(string)
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the bare metal server will be deployed, ensuring proper network segmentation."
  type        = list(string)
}
