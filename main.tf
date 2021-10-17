##################################################
# locals for tagging
##################################################

locals {
  common_tags = {
    Owner       = var.owner
    Environment = var.environment
    Cost_center = var.cost_center
    Application = var.app_name
  }
}

##################################################
# Azure resource group
##################################################

resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${var.app_name}-rg"
  location = var.location
  tags     = local.common_tags
}

###################################################
# Azure Vnet
###################################################

resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${var.environment}-${var.app_name}-vnet"
  location            = azurerm_resource_group.rg.location
  address_space       = [var.vnet_address_spaces]
  tags                = local.common_tags
}

###################################################
# Azure Subnet
###################################################

resource "azurerm_subnet" "subnet" {
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "${var.environment}-${var.app_name}-subnet"
  address_prefixes     = [var.subnet_address_spaces]
  virtual_network_name = azurerm_virtual_network.vnet.name
  depends_on           = [azurerm_resource_group.rg]
}

##################################################
# Network security group
##################################################

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.environment}-${var.app_name}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.common_tags
}

##################################################
# NSG Rule
##################################################

resource "azurerm_network_security_rule" "rules_inbound" {
  name                        = "${var.environment}-${var.app_name}-nsg-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

##################################################
# NSG adding to Subnet
##################################################

resource "azurerm_subnet_network_security_group_association" "nsg_subnet" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

##################################################
# Azure Random id
##################################################

/* resource "random_id" "name" {
   byte_length = 5
   prefix      = "ansible"
 } */

##################################################
# Azure KeyVault
##################################################

resource "azurerm_key_vault" "kv" {
  depends_on = [azurerm_resource_group.rg]
  #name                        = random_id.name.hex
  name                        = "${var.environment}${var.app_name}devopscafekv"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get", "backup", "delete", "list", "purge", "recover", "restore", "set",
    ]

    storage_permissions = [
      "get",
    ]
  }
  tags = local.common_tags
}

##################################################
# Azure Random Password
##################################################

resource "random_password" "password" {
  length  = 20
  special = true
}

##################################################
# Azure Keyvault Secret
##################################################

resource "azurerm_key_vault_secret" "secret" {
  name         = "${var.environment}-${var.app_name}-secret"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

##################################################
# Azure PIP - Ansible Server
##################################################

resource "azurerm_public_ip" "server_pip" {
  name                = "${var.environment}-${var.app_name}-server-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

##################################################
# Azure PIP - Ansible Workers
##################################################

resource "azurerm_public_ip" "worker_pip" {
  count               = var.workers_count
  name                = "${var.environment}-${var.app_name}-workers-pip-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}


##################################################
# Azure NIC - Ansible Server
##################################################

resource "azurerm_network_interface" "server_nic" {
  name                 = "${var.environment}-${var.app_name}-server-nic"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  enable_ip_forwarding = false
  ip_configuration {
    name                          = var.server_ipconf_name
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet.id
    public_ip_address_id          = azurerm_public_ip.server_pip.id
  }
  tags = local.common_tags
}

##################################################
# Azure NIC - Ansible Workers
##################################################

resource "azurerm_network_interface" "worker_nic" {
  count                = var.workers_count
  name                 = "${var.environment}-${var.app_name}-worker-nic-${count.index}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  enable_ip_forwarding = false
  ip_configuration {
    name                          = var.worker_ipconf_name
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet.id
    public_ip_address_id          = element(azurerm_public_ip.worker_pip.*.id, count.index)
  }
  tags = local.common_tags
}

##################################################
# Create an SSH key
##################################################

resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.sshkey.private_key_pem
  filename        = "key.pem"
  file_permission = "0600"
}

##############################################
# AZURE VIRTUAL Machine - Ansible Server
##############################################

resource "azurerm_linux_virtual_machine" "ansible_server" {
  name                            = "${var.environment}-${var.app_name}-server"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  size                            = var.os_type
  admin_username                  = var.username
  admin_password                  = azurerm_key_vault_secret.secret.value
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.server_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.range
  }

  admin_ssh_key {
    username = var.username
    # public_key = file("~/.ssh/id_rsa.pub")
    public_key = tls_private_key.sshkey.public_key_openssh
  }
  tags = local.common_tags
}

##############################################
# AZURE VIRTUAL Machine - Ansible Workers
##############################################

resource "azurerm_linux_virtual_machine" "ansible_workers" {
  count               = var.workers_count
  name                = "${var.environment}-${var.app_name}-workers-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.os_type
  admin_username      = var.username
  #admin_password = admin_password = azurerm_key_vault_secret.secret.value
  disable_password_authentication = true
  network_interface_ids = [
    element(azurerm_network_interface.worker_nic.*.id, count.index)
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.range
  }

  admin_ssh_key {
    username   = var.username
    public_key = tls_private_key.sshkey.public_key_openssh
  }

  tags = local.common_tags
}

##############################################
# AZURE VIRTUAL Machine Extension
##############################################

resource "azurerm_virtual_machine_extension" "extsn" {
  name                 = "${var.environment}-${var.app_name}-extsn"
  virtual_machine_id   = azurerm_linux_virtual_machine.ansible_server.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "script": "${filebase64("./files/ansible/ansiblesetup.sh")}"
    }
  SETTINGS
}