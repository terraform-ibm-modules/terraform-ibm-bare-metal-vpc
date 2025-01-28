########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  description = "ID of resource group to create BMS."
  type        = string
}

variable "tags" {
  description = "List of tags to apply to resources created by this module."
  type        = list(string)
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the BMS resources created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "subnets" {
  description = "A list of subnet IDs where BMS will be deployed"
  type = list(
    object({
      name = string
      id   = string
      zone = string
      cidr = optional(string)
    })
  )
}

variable "allow_ip_spoofing" {
  description = "Whether to allow IP spoofing on the network interface"
  type        = string
}

variable "create_security_group" {
  description = "Create security group for BMS. If this is passed as false, the default will be used"
  type        = bool
}

variable "bare_metal_servers" {
  description = "Configuration for bare metal servers"
  type = map(object({
    profile = string
    prefix  = string
    image   = string
    zone    = string
    keys    = list(string)
  }))
}

variable "bms_per_subnet" {
  description = "Number Baremetal Servers for each subnet"
  type        = number
}
