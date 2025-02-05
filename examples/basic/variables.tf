########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example."
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "prefix" {
  description = "The prefix that you would like to append to your resources"
  type        = string
  default     = "slz-vsi"
}

variable "resource_tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

variable "server_count" {
  description = "Number of bare metal servers to provision"
  type        = number
  default     = 1
}

variable "profile" {
  description = "Bare metal server profile (e.g., mx2d-metal-32x192)"
  type        = string
}

variable "image" {
  description = "Image ID for the Bare Metal Server"
  type        = string
}

variable "zone" {
  description = "IBM Cloud Zone where the server will be deployed"
  type        = string
}

variable "vpc_name" {
  type        = string
  description = "Name for VPC"
  default     = "vpc"
}

variable "vpc_id" {
  description = "VPC ID where the Bare Metal Server should be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the Bare Metal Server should be attached"
  type        = string
  default = null
}

variable "ssh_key" {
  description = "SSH Key name (if existing) or null to create a new one"
  type        = string
  default     = null
}

variable "reservation_pool_id" {
  description = "Reservation Pool ID for Bare Metal Server"
  type        = string
  default     = null
}

variable "bandwidth" {
  description = "Bandwidth for the Bare Metal Server (in Mbps)"
  type        = number
  default     = null
}

variable "primary_ip" {
  description = "Primary reserved IP for the server"
  type        = string
  default     = null
}

variable "allowed_vlans" {
  description = "List of VLANs allowed for the server"
  type        = list(number)
  default     = []
}

variable "access_tags" {
  description = "Access tags for resource management"
  type        = list(string)
  default     = []
}
