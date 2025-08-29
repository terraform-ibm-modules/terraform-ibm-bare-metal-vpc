variable "name" {
  description = "The base name for the bare metal servers and its resources."
  type        = string
}

variable "resource_group_id" {
  type        = string
  description = "ID of the resource group where you want to create the service."
  default     = null
}

variable "profile" {
  description = "The hardware profile defining the CPU, memory, and storage configuration of the bare metal server."
  type        = string
}

variable "image_id" {
  description = "The unique identifier of the operating system image to be installed on the bare metal server."
  type        = string
}

variable "subnet_id" {
  description = "A list of subnet IDs where the bare metal server will be deployed, ensuring proper network segmentation."
  type        = string
}

variable "ssh_key_ids" {
  description = "A list of SSH key IDs that will be used for secure access to the bare metal server."
  type        = list(string)
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
  nullable    = false
}

variable "access_tags" {
  description = "A list of access management tags to be attached to the bare metal server for categorization and policy enforcement."
  type        = list(string)
  default     = []
}

####### Timeout configurations ########

variable "create_timeout" {
  description = "Timeout for creating the bare metal server"
  type        = string
  default     = "60m"
}

variable "update_timeout" {
  description = "Timeout for updating the bare metal server"
  type        = string
  default     = "60m"
}

variable "delete_timeout" {
  description = "Timeout for deleting the bare metal server"
  type        = string
  default     = "60m"
}

variable "user_data" {
  description = "User data to initialize BMS deployment"
  type        = string
}

variable "security_group_ids" {
  description = "IDs of additional security groups to be added to BMS deployment primary interface. A BMS interface can have a maximum of 5 security groups."
  type        = list(string)
  default     = []
}

##############################################################################
# Reserved IP's Variables
##############################################################################

variable "manage_reserved_ips" {
  description = "Set to `true` if you want this terraform module to manage the reserved IP addresses that are assigned to BMS instances. If this option is enabled, when any BMS is recreated it should retain its original IP."
  type        = bool
  default     = false
}

########################################################################################################################
# Secondary VNI Variables
########################################################################################################################

variable "secondary_vni_enabled" {
  description = "Whether to enable a secondary virtual network interface"
  type        = bool
  default     = false
}

variable "secondary_subnet_id" {
  description = "The ID of the secondary subnet"
  type        = string
  default     = ""
  nullable    = false
}

variable "secondary_security_group_ids" {
  description = "List of security group IDs for the secondary VNI"
  type        = list(string)
  default     = null
}

variable "secondary_allowed_vlan_ids" {
  description = "List of allowed VLAN IDs for the secondary VNI"
  type        = list(number)
  default     = null
}

variable "enable_secure_boot" {
  description = "Indicates whether secure boot is enabled. If enabled, the image must support secure boot or the server will fail to boot."
  type        = bool
  default     = false
}

variable "tpm_mode" {
  default     = "disabled"
  description = "Trusted platform module (TPM) configuration for the bare metal server. For more details see [Secure Boot and TPM documentation](https://cloud.ibm.com/docs/vpc?topic=vpc-secure-boot-tpm)"
  type        = string
  nullable    = false

  validation {
    condition     = contains(["disabled", "tpm_2"], var.tpm_mode)
    error_message = "TPM mode must be either 'disabled' or 'tpm_2'."
  }
}
