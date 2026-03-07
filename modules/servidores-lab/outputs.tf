output "vm_private_ips" {
  description = "IPs privados das VMs"
  value = {
    redhat               = azurerm_network_interface.vms["redhat"].private_ip_address
#    suse                 = azurerm_network_interface.vms["suse"].private_ip_address
    ubuntu               = azurerm_network_interface.vms["ubuntu"].private_ip_address
  }
}

output "vm_public_ips" {
  description = "IPs públicos das VMs"
  value = {
    redhat               = azurerm_public_ip.vms["redhat"].ip_address
#    suse                 = azurerm_public_ip.vms["suse"].ip_address
    ubuntu               = azurerm_public_ip.vms["ubuntu"].ip_address
  }
}

output "nic_ids" {
  description = "IDs das interfaces de rede"
  value = {
    for k, v in azurerm_network_interface.vms : k => v.id
  }
}