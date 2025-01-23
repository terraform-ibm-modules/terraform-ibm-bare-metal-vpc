variable "reserved_ips_map" {
  description = "Map of reserved IP configurations."
  type        = map(object({
    name        = string
    subnet_id   = string
    auto_delete = optional(bool, false)
  }))
}

variable "prefix" {
  description = "Prefix for naming reserved IPs."
  type        = string
  default     = ""
}