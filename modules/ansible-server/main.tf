# IP Público
resource "azurerm_public_ip" "ansible" {
  name                = "pip-ansible-server"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                = "Standard"
  tags               = var.tags
}

# Interface de Rede
resource "azurerm_network_interface" "ansible" {
  name                = "nic-ansible-server"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags               = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.ansible.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "ansible" {
  name                = "vm-ansible-server"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags               = var.tags

  disable_password_authentication = false
  admin_password                  = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.ansible.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server-gen1"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/user-data.sh", {
    semaphore_admin_user  = var.semaphore_admin_user
    semaphore_admin_pass  = var.semaphore_admin_pass
    semaphore_admin_email = var.semaphore_admin_email
  }))
}
