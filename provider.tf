##################################################
# Providers
##################################################
provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

data "azurerm_client_config" "current" {}