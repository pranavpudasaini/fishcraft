resource "random_password" "minecraft_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_string" "random_prefix" {
  length  = 6
  lower   = true
  numeric = true
  special = false
  upper   = false
}

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

resource "azurerm_storage_account" "main" {
  name                     = "fishstorage${random_string.random_prefix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_service_plan" "plan" {
  name                = "service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function" {
  name                = "on-demand-fish-function"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  site_config {}
}

resource "azurerm_automation_account" "automation_account" {
  name                = "automation-account-fish"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name = "Basic"
}

resource "azurerm_automation_runbook" "runbook" {
  name                    = "paisa_bachau_runbook"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  automation_account_name = azurerm_automation_account.automation_account.name
  log_verbose             = true
  log_progress            = true
  description             = "Paisa Bachau Abhiyan For Fishcraft Server"
  runbook_type            = "PowerShellWorkflow"

  # publish_content_link {
  #   uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  # }
  content = file("./scripts/paisa_bachau_runbook.ps1")
}

resource "azurerm_automation_webhook" "paisa_bachau" {
  name                    = "paisa-bachau-fish"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation_account.name
  expiry_time             = "2023-06-23T00:00:00Z"
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.runbook.name
  parameters = {
  }
}
