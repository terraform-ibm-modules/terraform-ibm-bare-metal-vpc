output "reserved_ips" {
  description = "Reserved IPs created by the module."
  value       = {
    bms_ips         = ibm_is_subnet_reserved_ip.bms_ip
    secondary_bms_ips = ibm_is_subnet_reserved_ip.secondary_bms_ip
    secondary_vni_ips = ibm_is_subnet_reserved_ip.secondary_vni_ip
  }
}

output "vni_ids" {
  description = "Virtual Network Interface IDs created by the module."
  value = {
    primary_vnis   = ibm_is_virtual_network_interface.primary_vni
    secondary_vnis = ibm_is_virtual_network_interface.secondary_vni
  }
}

output "secondary_vni" {
  value = {
    for key, vni in ibm_is_virtual_network_interface.secondary_vni : key => {
      id    = vni.id
      zone  = vni.zone
      name  = vni.name
    }
  }
}