variable "resource_group_id" {
  description = "ID of resource group to create BMS and block storage volumes. If you wish to create the block storage volumes in a different resource group, you can optionally set that directly in the 'block_storage_volumes' variable."
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

variable "profile" {
  type        = string
  description = "Specifies the hardware configuration for the bare metal server. Determines the CPU, memory, and resource allocations (e.g., bx2-4x16, mx2-32x128)."
}

variable "prefix" {
  type        = string
  description = "A string prefix added to resource names for easy identification and alignment with naming conventions (e.g., dev, staging, prod)."
}

variable "image" {
  type        = string
  description = "Defines the operating system or software image for the bare metal server (e.g., rhel, ubuntu, windows-server)."
}

variable "keys" {
  type        = list(string)
  description = "A list of SSH public keys used to access the bare metal server for secure management and configuration."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the IBM Cloud VPC where the bare metal server will be deployed."
}

variable "allow_ip_spoofing" {
  type        = string
  description = "Controls whether IP spoofing is allowed on the primary network interface. Typically set to 'true' or 'false'."
}

variable "subnets" {
  type = list(
    object({
      name = string
      id   = string
      zone = string
      cidr = optional(string)
    })
  )
  description = <<EOT
A list of subnets where the bare metal servers will be deployed. Each subnet object contains:
- name: The name of the subnet.
- id: The unique identifier for the subnet.
- zone: The availability zone of the subnet.
- cidr (optional): The CIDR block assigned to the subnet.
EOT
}

variable "manage_reserved_ips" {
  type        = bool
  description = "Set to true if the module should manage the reserved IPs assigned to bare metal servers. If enabled, servers retain their original IPs upon recreation."
  default     = false
}

variable "bms_count" {
  type        = number
  description = "The number of bare metal server instances to be deployed."
}

################ Security Group #################

variable "create_security_group" {
  description = "Create security group for BMS. If this is passed as false, the default will be used"
  type        = bool
}

variable "security_group" {
  description = "Security group created for BMS"
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

variable "security_group_ids" {
  description = "IDs of additional security groups to be added to BMS deployment primary interface. A BMS interface can have a maximum of 5 security groups."
  type        = list(string)
  default     = []

  validation {
    error_message = "Security group IDs must be unique."
    condition     = length(var.security_group_ids) == length(distinct(var.security_group_ids))
  }

  validation {
    error_message = "No more than 5 security groups can be added to a BMS deployment."
    condition     = length(var.security_group_ids) <= 5
  }
}
