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

variable "vpc_name" {
  type        = string
  description = "Name for VPC"
  default     = "vpc"
}

variable "ssh_key" {
  description = "SSH Key name (if existing) or null to create a new one"
  type        = string
  default     = null
}
