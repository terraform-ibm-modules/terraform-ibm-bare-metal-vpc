########################################################################################################################
# Input Variables
########################################################################################################################
variable "resource_group_id" {
  type        = string
  description = "ID of the resource group where you want to create the service."
  default     = null
}

variable "server_count" {
  description = "Specifies the number of bare metal server instances to provision. If greater than one, multiple instances will be created and distributed across the available subnets in a round-robin manner. For example, if the server count is 3 and there are 2 subnets, Server 1 and Server 3 will be deployed on Subnet 1, while Server 2 will be deployed on Subnet 2."
  type        = number
  default     = 1
}

variable "prefix" {
  description = "The base name for the bare metal server. If multiple instances are created, an index will be appended for uniqueness."
  type        = string
}

variable "profile" {
  description = "The hardware profile defining the CPU, memory, and storage configuration of the bare metal server."
  type        = string
}

variable "image_id" {
  description = "The unique identifier of the operating system image to be installed on the bare metal server."
  type        = string
}

variable "bandwidth" {
  description = "The allocated bandwidth (in Mbps) for the bare metal server to manage network traffic. If unset, default values apply."
  type        = number
  default     = null
}

variable "allowed_vlan_ids" {
  description = "A list of VLAN IDs that are permitted for the bare metal server, ensuring network isolation and control. Example: [100, 102]"
  type        = list(number)
  default     = []
}

variable "access_tags" {
  description = "A list of access management tags to be attached to the bare metal server for categorization and policy enforcement."
  type        = list(string)
  default     = []
}

variable "ssh_key_ids" {
  description = "A list of SSH key IDs that will be used for secure access to the bare metal server."
  type        = list(string)
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the bare metal server will be deployed, ensuring proper network segmentation."
  type        = list(string)
  nullable    = false

}

variable "tags" {
  description = "List of tags to apply to resources created by this module."
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Setting to true will be create a new security group"
  type        = bool
  default     = false
  nullable    = false
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

##############################################################################
# Rule Variables
##############################################################################

variable "security_group_rules" {
  description = "A list of security group rules to be added to the default vpc security group"
  type = list(
    object({
      name      = string
      direction = optional(string, "inbound")
      remote    = string
      tcp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      udp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      icmp = optional(
        object({
          type = optional(number)
          code = optional(number)
        })
      )
    })
  )
  default = []

  validation {
    error_message = "Security group rule direction can only be `inbound` or `outbound`."
    condition = (var.security_group_rules == null || length(var.security_group_rules) == 0) ? true : length(distinct(
      flatten([
        # Check through rules
        for rule in var.security_group_rules :
        # Return false if direction is not valid
        false if !contains(["inbound", "outbound"], rule.direction)
      ])
    )) == 0
  }

  validation {
    error_message = "Security group rule names must match the regex pattern ^([a-z]|[a-z][-a-z0-9_]*[a-z0-9])$."
    condition = (var.security_group_rules == null || length(var.security_group_rules) == 0) ? true : length(distinct(
      flatten([
        # Check through rules
        for rule in var.security_group_rules :
        # Return false if direction is not valid
        false if !can(regex("^([a-z]|[a-z][-a-z0-9_]*[a-z0-9])$", rule.name))
      ])
    )) == 0
  }

  validation {
    error_message = "Security group rules can only have one of `icmp`, `udp`, or `tcp`."
    condition = (var.security_group_rules == null || length(var.security_group_rules) == 0) ? true : length(distinct(
      # Get flat list of results
      flatten([
        # Check through rules
        for rule in var.security_group_rules :
        # Return true if there is more than one of `icmp`, `udp`, or `tcp`
        true if length(
          [
            for type in ["tcp", "udp", "icmp"] :
            true if rule[type] != null
          ]
        ) > 1
      ])
    )) == 0 # Checks for length. If all fields all correct, array will be empty
  }
}

##############################################################################

variable "user_data" {
  description = "User data to initialize BMS deployment"
  type        = string
  default     = null
}

variable "secondary_vni_enabled" {
  description = "Whether to enable secondary virtual network interfaces"
  type        = bool
  default     = false
}

variable "secondary_subnet_ids" {
  description = "List of secondary subnet IDs (if empty, will use primary subnets)"
  type        = list(string)
  default     = []
}

variable "secondary_security_group_ids" {
  description = "List of security group IDs for secondary VNIs"
  type        = list(string)
  default     = []
}

variable "secondary_allowed_vlan_ids" {
  description = "List of allowed VLAN IDs for secondary VNIs"
  type        = list(number)
  default     = []
}