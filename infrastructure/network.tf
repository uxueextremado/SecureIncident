# Red Virtual (VNet)
resource "azurerm_virtual_network" "secureincident_vnet" {
  name                = "vnet-secureincident"
  location            = azurerm_resource_group.secureincident_rg.location
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  address_space       = var.vnet_address_space
}

# Subred privada para PostgreSQL (sin acceso público)
resource "azurerm_subnet" "secureincident_subnet_private" {
  name                 = "subnet-private"
  resource_group_name  = azurerm_resource_group.secureincident_rg.name
  virtual_network_name = azurerm_virtual_network.secureincident_vnet.name
  address_prefixes     = [var.subnet_private_prefix]

  # Delegación para PostgreSQL Flexible Server
  delegation {
    name = "postgres-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Subred para la integración de App Service (VNet Integration)
resource "azurerm_subnet" "app_integration_subnet" {
  name                 = "subnet-app-integration"
  resource_group_name  = azurerm_resource_group.secureincident_rg.name
  virtual_network_name = azurerm_virtual_network.secureincident_vnet.name
  address_prefixes     = [var.subnet_integration_prefix]

  # Delegación para App Service
  delegation {
    name = "app-delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}