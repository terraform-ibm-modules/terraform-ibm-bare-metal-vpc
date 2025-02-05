variable "prefix" {
  description = "The base name for the bare metal server. If multiple instances are created, an index will be appended for uniqueness."
  type        = string
}

variable "profile" {
  description = "The hardware profile defining the CPU, memory, and storage configuration of the bare metal server."
  type        = string
}

variable "image" {
  description = "The unique identifier of the operating system image to be installed on the bare metal server."
  type        = string
}

variable "zone" {
  description = "The IBM Cloud availability zone where the bare metal server will be deployed."
  type        = string
}

variable "vpc_id" {
  description = "The unique identifier of the IBM Cloud Virtual Private Cloud (VPC) where the bare metal server will be provisioned."
  type        = string
}

variable "subnet_id" {
  description = "A list of subnet IDs where the bare metal server will be deployed, ensuring proper network segmentation."
  type        = list(string)
}

variable "ssh_key_id" {
  description = "A list of SSH key IDs that will be used for secure access to the bare metal server."
  type        = list(string)
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
