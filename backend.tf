terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "stterraformsecure"
    container_name       = "tfstate"
    key                  = "secureincident.tfstate"
  }
}