resource "azurerm_network_security_group" "secureincident_nsg" {
  name                = "nsg-secureincident"
  location            = azurerm_resource_group.secureincident_rg.location
  resource_group_name = azurerm_resource_group.secureincident_rg.name
}