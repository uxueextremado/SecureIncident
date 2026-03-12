# Configuración principal de Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"  # Usa AzureRM versión 3.x
    }
  }
}

# Configura el proveedor de Azure
provider "azurerm" {
  features {}  # Habilita todas las features del proveedor
}

# Crea el grupo de recursos que contendrá todos los servicios
resource "azurerm_resource_group" "secureincident_rg" {
  name     = "rg-secureincident"
  location = "spaincentral"  # Región de España
}

# Obtiene información del cliente actual (tenant, subscription, object_id)
data "azurerm_client_config" "current" {}  # Útil para Key Vault y accesos