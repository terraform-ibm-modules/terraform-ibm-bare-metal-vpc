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
