variable "floating_ip_map" {
  type = map(object({
    name   = string
    target = string
    zone   = string
  }))
}
