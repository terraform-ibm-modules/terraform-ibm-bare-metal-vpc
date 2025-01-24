variable "region" {
  description = "Region for the resources."
  type        = string
  default     = "us-south"
}

variable "vpc_id" {
  description = "Name of the VPC."
  type        = string
}

variable "zone" {
  description = "Zone for the resources."
  type        = string
}

variable "ipv4_cidr_block" {
  description = "IPv4 CIDR block for the subnet."
  type        = string
  default     = "10.240.129.0/24"
}

variable "ssh_key_id" {
  description = "Name of the SSH key."
  type        = string
}

variable "bare_metal_profile" {
  description = "Profile for the bare metal server."
  type        = string
  default     = "mx2d-metal-32x192"
}

variable "bare_metal_name" {
  description = "Name of the bare metal server."
  type        = string
}

variable "image_id" {
  description = "Image ID for the bare metal server."
  type        = string
}

variable "resource_group_id" {
  description = "Resource group ID for the bare metal server."
  type        = string
}

variable "use_legacy_network_interface" {
  description = "Set this to true to use legacy network interface for the created instances."
  type        = bool
  nullable    = false
  default     = false
}

variable "create_security_group" {
  description = "Create security group for VSI. If this is passed as false, the default will be used"
  type        = bool
}

variable "default_security_group" {
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
      : length(distinct(var.default_security_group.rules[*].name)) == length(var.default_security_group.rules[*].name)
    )
  }

  validation {
    error_message = "Security group rule direction can only be `inbound` or `outbound`."
    condition = var.default_security_group == null ? true : length(
      distinct(
        flatten([
          for rule in var.default_security_group.rules :
          false if !contains(["inbound", "outbound"], rule.direction)
        ])
      )
    ) == 0
  }
  default = null
}

variable "security_group_ids" {
  description = "IDs of additional security groups to be added to VSI deployment primary interface. A VSI interface can have a maximum of 5 security groups."
  type        = list(string)
  default     = []

  validation {
    error_message = "Security group IDs must be unique."
    condition     = length(var.security_group_ids) == length(distinct(var.security_group_ids))
  }

  validation {
    error_message = "No more than 5 security groups can be added to a VSI deployment."
    condition     = length(var.security_group_ids) <= 5
  }
}

variable "allow_ip_spoofing" {
  description = "Allow IP spoofing on the primary network interface"
  type        = bool
  default     = false
}

variable "manage_reserved_ips" {
  description = "Set to `true` if you want this terraform module to manage the reserved IP addresses that are assigned to VSI instances. If this option is enabled, when any VSI is recreated it should retain its original IP."
  type        = bool
  default     = false
}

variable "primary_reserved_ips" {
  description = "List of secondary interfaces to add floating ips"
  type        = list(string)
  default     = []
}  

variable "primary_vni" {
  description = "Primary Virtual Network Interface details (name and id)"
  type = map(object({
    name = string
    id   = string
  }))
}
##############################################################################
# Secondary Interface Variables
##############################################################################

variable "secondary_subnets" {
  description = "List of secondary network interfaces to add to vsi secondary subnets must be in the same zone as VSI. This is only recommended for use with a deployment of 1 VSI."
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

variable "secondary_use_vsi_security_group" {
  description = "Use the security group created by this module in the secondary interface"
  type        = bool
  default     = false
}

variable "secondary_security_groups" {
  description = "The security group IDs to add to the VSI deployment secondary interfaces (5 maximum). Use the same value for interface_name as for name in secondary_subnets to avoid applying the default VPC security group on the secondary network interface."
  type = list(
    object({
      security_group_id = string
      interface_name    = string
    })
  )
  default = []

  validation {
    error_message = "Security group IDs must be unique."
    condition     = length(var.secondary_security_groups) == length(distinct(var.secondary_security_groups))
  }

  validation {
    error_message = "No more than 5 security groups can be added to a VSI deployment."
    condition     = length(var.secondary_security_groups) <= 5
  }
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

variable "secondary_allow_ip_spoofing" {
  description = "Allow IP spoofing on additional network interfaces"
  type        = bool
  default     = false
}

