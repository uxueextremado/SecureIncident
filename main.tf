terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "secureincident_rg" {
  name     = "rg-secureincident"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}