variable "disks" {
  type = list(object({
    name              = string
    bare_metal_server = string
  }))
}
