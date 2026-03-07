# Servidores Linux e Windows - RedHat, SUSE, Ubuntu, Windows 11, Windows Server 2019

locals {
  vms = {
    redhat = {
      name           = "vm-redhat-lab"
      publisher      = "RedHat"
      offer          = "RHEL"
      sku            = "9_7"
      version        = "latest"
      vm_size        = var.vm_size_linux
      os_type        = "Linux"
    }
#    suse = {
#      name           = "vm-suse-lab"
#      publisher      = "SUSE"
#      offer          = "sles-15-sp5"
#      sku            = "gen2"
#      version        = "latest"
#      vm_size        = var.vm_size_linux
#      os_type        = "Linux"
#    }

#    ubuntu = {
#      name           = "vm-ubuntu-lab"
#      publisher      = "Canonical"
#      offer          = "ubuntu-24_04-lts"
#      sku            = "server-gen1"
#      version        = "latest"
#      vm_size        = var.vm_size_linux
#      os_type        = "Linux"
#    }
  }
}

# Interfaces de Rede
resource "azurerm_network_interface" "vms" {
  for_each = local.vms

  name                = "nic-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags               = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.vms[each.key].id
  }
}

# IPs Públicos
resource "azurerm_public_ip" "vms" {
  for_each = local.vms

  name                = "pip-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                = "Standard"
  tags               = var.tags
}

# Virtual Machines Linux
resource "azurerm_linux_virtual_machine" "vms_linux" {
  for_each = {
    for k, v in local.vms : k => v if v.os_type == "Linux"
  }

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = each.value.vm_size
  admin_username      = var.admin_username
  tags               = merge(var.tags, { OS = each.value.name })

  disable_password_authentication = false
  admin_password                  = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.vms[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }
}