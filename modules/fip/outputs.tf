output "floating_ips" {
  description = "Map of created Floating IPs"
  value = {
    for key, fip in ibm_is_floating_ip.fips :
    key => {
      id       = fip.id
      name     = fip.name
      target   = fip.target
      address  = fip.address
    }
  }
}