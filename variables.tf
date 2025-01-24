variable "bare_metal_profile" {
  description = "The profile to use for the bare metal server."
  type        = string
}

variable "bare_metal_name" {
  description = "The name of the bare metal server."
  type        = string
}

variable "image_id" {
  description = "The image ID to use for the bare metal server."
  type        = string
}

variable "zone" {
  description = "The zone where resources will be deployed."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to attach the bare metal server."
  type        = string
}

variable "primary_subnet_id" {
  description = "The subnet ID for the primary VNI."
  type        = string
}

variable "secondary_subnet_id" {
  description = "The subnet ID for the secondary VNI."
  type        = string
}

variable "ssh_keys" {
  description = "List of SSH key IDs to be added to the bare metal server."
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the resources."
  type        = map(string)
  default     = {}
}

variable "bms_per_subnet" {
  description = "Number of BMS servers for each subnet"
  type        = number
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

variable "prefix" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
  type        = string

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "secondary_subnets" {
  description = "List of secondary network interfaces to add to bms secondary subnets must be in the same zone as BMS. This is only recommended for use with a deployment of 1 BMS."
  type = list(
    object({
      name = string
      id   = string
      zone = string
      cidr = optional(string)
    })
  )
  default = []
}

variable "primary_vni_additional_ip_count" {
  description = "The number of secondary reversed IPs to attach to a Virtual Network Interface (VNI). Additional IPs are created only if `manage_reserved_ips` is set to true."
  type        = number
  nullable    = false
  default     = 0
}

variable "enable_floating_ip" {
  description = "Create a floating IP for each virtual server created"
  type        = bool
  default     = false
}

variable "allow_ip_spoofing" {
  description = "Allow IP spoofing on the primary network interface"
  type        = bool
  default     = false
}

variable "create_security_group" {
  description = "Create security group for BMS. If this is passed as false, the default will be used"
  type        = bool
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

##############################################################################

variable "use_legacy_network_interface" {
  description = "Set this to true to use legacy network interface for the created servers."
  type        = bool
  nullable    = false
  default     = false
}

variable "secondary_floating_ips" {
  description = "List of secondary interfaces to add floating ips"
  type        = list(string)
  default     = []

  validation {
    error_message = "Secondary floating IPs must contain a unique list of interfaces."
    condition     = length(var.secondary_floating_ips) == length(distinct(var.secondary_floating_ips))
  }
}

variable "secondary_use_bms_security_group" {
  description = "Use the security group created by this module in the secondary interface"
  type        = bool
  default     = false
}