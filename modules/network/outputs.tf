output "vnet_id" {
  description = "ID da Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "ansible_subnet_id" {
  description = "ID da subnet do Ansible"
  value       = azurerm_subnet.ansible.id
}

output "database_subnet_id" {
  description = "ID da subnet do Database"
  value       = azurerm_subnet.database.id
}
