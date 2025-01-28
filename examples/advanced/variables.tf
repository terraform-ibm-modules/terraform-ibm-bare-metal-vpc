variable "ibmcloud_api_key" {
  description = "APIkey that's associated with the account to provision resources to"
  type        = string
  sensitive   = true
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "region" {
  description = "The region to which to deploy the VPC"
  type        = string
  default     = "us-south"
}

variable "ssh_key" {
  type        = string
  description = "An existing ssh key name to use for this example, if unset a new ssh key will be created"
  default     = null
}

variable "prefix" {
  description = "The prefix that you would like to append to your resources"
  type        = string
  default     = "slz-bms"
}

variable "resource_tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

variable "vpc_name" {
  type        = string
  description = "Name for VPC"
  default     = "vpc"
}
