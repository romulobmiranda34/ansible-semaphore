output "public_ip_address" {
  description = "Endereço IP público"
  value       = azurerm_public_ip.ansible.ip_address
}

output "private_ip_address" {
  description = "Endereço IP privado"
  value       = azurerm_network_interface.ansible.private_ip_address
}
