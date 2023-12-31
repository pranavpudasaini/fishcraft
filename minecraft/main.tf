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

resource "random_password" "chux_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
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

resource "azurerm_automation_account" "automation_account" {
  name                = "automation-account-fish"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name = "Basic"
}

# TODO: remove this lazy fix
# Runbook to Stop
resource "azurerm_automation_runbook" "runbook" {
  name                    = "stop-start-azurevm"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  automation_account_name = azurerm_automation_account.automation_account.name
  log_verbose             = true
  log_progress            = true
  description             = "paisa bachau abhiyan for fishcraft server"
  runbook_type            = "PowerShellWorkflow"

  # publish_content_link {
  #   uri = "https://raw.githubusercontent.com/azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/runbooks/get-azurevmtutorial.ps1"
  # }
  content = file("./scripts/paisa_bachau_runbook.ps1")
}

# Runbook to Start
resource "azurerm_automation_runbook" "kunbook" {
  name                    = "start-stop-azurevm"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  automation_account_name = azurerm_automation_account.automation_account.name
  log_verbose             = true
  log_progress            = true
  description             = "kahile kai ta khelera ni lyaunu paryo ni sir 🏃🎮"
  runbook_type            = "PowerShellWorkflow"

  # publish_content_link {
  #   uri = "https://raw.githubusercontent.com/azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/runbooks/get-azurevmtutorial.ps1"
  # }
  content = file("./scripts/on_hanera_lyau_gyaam.ps1")
}

# Webhook for Starting
resource "azurerm_automation_webhook" "paisa_bachaera_lyau" {
  name                    = "paisa_bachau_webhook"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation_account.name
  expiry_time             = "2024-06-23T00:00:00Z"
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.runbook.name
  parameters              = {}
}

# Webhook for Stopping
resource "azurerm_automation_webhook" "use_garaera_lyau" {
  name                    = "use_garau_webhook"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation_account.name
  expiry_time             = "2024-06-23T00:00:00Z"
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.kunbook.name
  parameters              = {}
}

resource "azurerm_automation_credential" "fish_creds" {
  name                    = "AzureCredential"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation_account.name
  username                = var.paisa_bachau_username
  password                = var.paisa_bachau_password
}

# https://778eeeda-1677-43be-8fcb-21d7ca799fd5.webhook.cid.azure-automation.net/webhooks?token=GiE5MYWYnonmY1VV0ythXEIScIAxWPoW1J3in5Sr45M%3d
