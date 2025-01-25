variable "resource_group_id" {
  description = "ID of resource group to create VSI and block storage volumes. If you wish to create the block storage volumes in a different resource group, you can optionally set that directly in the 'block_storage_volumes' variable."
  type        = string
}

variable "manage_reserved_ips" {
  description = "Flag to determine whether reserved IPs should be managed."
  type        = bool
}

variable "primary_vni_additional_ip_count" {
  description = "Number of additional primary VNI IPs."
  type        = number
  default     = 0
}

variable "use_legacy_network_interface" {
  description = "Flag to use legacy network interfaces."
  type        = bool
}

variable "allow_ip_spoofing" {
  description = "Flag to allow IP spoofing on VNIs."
  type        = bool
}

variable "secondary_allow_ip_spoofing" {
  description = "Flag to allow IP spoofing on secondary VNIs."
  type        = bool
}

variable "create_security_group" {
  description = "Flag to create a security group."
  type        = bool
}

variable "security_group_ids" {
  description = "List of security group IDs for primary VNIs."
  type        = list(string)
}

variable "secondary_security_groups" {
  description = "List of security groups for secondary VNIs."
  type        = list(object({
    security_group_id = string
    interface_name    = string
  }))
}

variable "prefix" {
  description = "Prefix to use for naming resources."
  type        = string
}

variable "bms_map" {
  description = "Map of BMS configurations."
  type        = map(object({
    name      = string
    subnet_id = string
    bms_name  = string
  }))
}

variable "secondary_vni_map" {
  description = "Map of secondary VNI configurations."
  type        = map(object({
    name      = string
    subnet_id = string
  }))
}

variable "secondary_reserved_ips_map" {
  description = "Map of secondary reserved IP configurations."
  type        = map(object({
    name      = string
    subnet_id = string
  }))
}

variable "secondary_use_bms_security_group" {
  description = "Use the security group created by this module in the secondary interface"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "security_group_map" {
  description = "A map of security groups where the key is the group name and the value is the group object."
  type = map(object({
    name = string
  }))
}

variable "tags" {
  description = "List of tags to apply to resources created by this module."
  type        = list(string)
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the VSI resources created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

variable "security_group" {
  description = "Security group created for VSI"
  type = object({
    name = string
    rules = list(
      object({
        name      = string
        direction = string
        source    = string
        tcp = optional(
          object({
            port_max = number
            port_min = number
          })
        )
        udp = optional(
          object({
            port_max = number
            port_min = number
          })
        )
        icmp = optional(
          object({
            type = number
            code = number
          })
        )
      })
    )
  })

  validation {
    error_message = "Each security group rule must have a unique name."
    condition = (
      var.security_group == null
      ? true
      : length(distinct(var.security_group.rules[*].name)) == length(var.security_group.rules[*].name)
    )
  }

  validation {
    error_message = "Security group rule direction can only be `inbound` or `outbound`."
    condition = var.security_group == null ? true : length(
      distinct(
        flatten([
          for rule in var.security_group.rules :
          false if !contains(["inbound", "outbound"], rule.direction)
        ])
      )
    ) == 0
  }
  default = null
}

variable "security_group_rules" {
  description = "A map of security group rules keyed by a combination of security group name and rule name."
  type = map(object({
    protocol   = string        
    port_range = string        
    direction  = string        
    source     = string
  }))
  default = {}
}

