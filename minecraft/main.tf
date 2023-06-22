terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  required_version = "~>1.4.5"
}

provider "azurerm" {
  features {}
}

resource "random_password" "minecraft_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.scope}-resources"
  location = "Central India"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.scope}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "minecraft_public_ipv4" {
  name                = "${var.scope}-ipv4"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.scope}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ip-configuration"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_version    = "IPv4"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.69"
    public_ip_address_id          = azurerm_public_ip.minecraft_public_ipv4.id
  }
}

resource "azurerm_virtual_machine" "minecraft_server" {
  name                             = "${var.scope}-vm"
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  network_interface_ids            = [azurerm_network_interface.main.id]
  vm_size                          = "Standard_B1ms"
  delete_os_disk_on_termination    = false
  delete_data_disks_on_termination = false

  storage_os_disk {
    name              = "${var.scope}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "20.04.202306180"
  }

  os_profile {
    computer_name  = "${var.scope}-server"
    admin_username = var.scope
    admin_password = random_password.minecraft_password.result
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.scope}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }


}
