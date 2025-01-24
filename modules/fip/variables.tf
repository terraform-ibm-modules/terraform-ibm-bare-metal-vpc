variable "floating_ip_map" {
  description = "A map defining the floating IP resources to create. Each entry should include name, target, tags, access_tags, and resource_group."
  type = map(object({
    name           = string
    target         = string
    tags           = optional(list(string), [])
    access_tags    = optional(list(string), [])
    resource_group = string
  }))
}
