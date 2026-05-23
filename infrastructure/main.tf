# Configuración principal de Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    use_oidc             = true
    use_azuread_auth     = true
    tenant_id            = "78f3a279-48c8-4670-9162-a63c451c9fae"
    client_id            = "74e071e1-2b4a-49a4-aa08-9eb853d2823b"
    storage_account_name = "stterraformsecure"
    container_name       = "tfstate"
    key                  = "secureincident.tfstate"
  }
}

# Proveedor de Azure
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Grupo de recursos principal
resource "azurerm_resource_group" "secureincident_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Datos del cliente actual (para Key Vault)
data "azurerm_client_config" "current" {}