# Configuración principal de Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Proveedor de Azure
provider "azurerm" {
  features {}
}

# Grupo de recursos principal
resource "azurerm_resource_group" "secureincident_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Datos del cliente actual (para Key Vault)
data "azurerm_client_config" "current" {}