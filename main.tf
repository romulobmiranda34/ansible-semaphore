# Configuração do Resource Group
resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Módulo de Rede
module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.lab.name
  location           = azurerm_resource_group.lab.location
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnet_prefixes    = var.subnet_prefixes
  tags              = var.tags
}

module "servidores_lab" {
  source = "./modules/servidores-lab"
  
  resource_group_name = azurerm_resource_group.lab.name
  location           = azurerm_resource_group.lab.location
  subnet_id          = module.network.ansible_subnet_id
  admin_username     = var.admin_username
  admin_password     = var.admin_password
  vm_size_linux      = var.vm_size_linux
  vm_size_windows    = var.vm_size_windows
  tags               = var.tags
}


# Módulo do Servidor Ansible com Semaphore
module "ansible_server" {
  source = "./modules/ansible-server"

  resource_group_name  = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  subnet_id           = module.network.ansible_subnet_id
  vm_size             = var.ansible_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  semaphore_admin_user = var.semaphore_admin_user
  semaphore_admin_pass = var.semaphore_admin_pass
  semaphore_admin_email = var.semaphore_admin_email
  tags                = var.tags
}