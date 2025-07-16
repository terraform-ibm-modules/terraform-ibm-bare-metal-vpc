########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key required for authentication and provisioning resources. This is sensitive information and should be kept secure."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where all resources will be deployed. Example values: 'us-south', 'eu-gb', 'au-syd'."
}

variable "zone" {
  type        = string
  description = "The IBM Cloud region zone where all resources will be deployed. Example values: 'us-south-1', 'eu-gb-1', 'au-syd-1'."
}

variable "resource_group" {
  type        = string
  description = "The name of an existing IBM Cloud resource group to use for this deployment. If left unset, a new resource group will be created automatically."
  default     = null
}

variable "prefix" {
  description = "A prefix to be appended to all resource names for easy identification and organization."
  type        = string
  default     = "slz-bms"
}

variable "resource_tags" {
  description = "A list of tags to associate with the created resources for better categorization and management."
  type        = list(string)
  default     = null
}

variable "vpc_name" {
  type        = string
  description = "The name of the IBM Cloud Virtual Private Cloud (VPC) where the servers will be deployed."
  default     = "vpc"
}

variable "ssh_key" {
  description = "The name of an existing SSH key to be used for secure access to the servers. If left null, a new SSH key will be created automatically."
  type        = string
  default     = null
}

variable "profile" {
  description = "The hardware profile defining the CPU, memory, and storage configuration of the bare metal server."
  type        = string
  default     = "bx2d-metal-96x384"
}
