resource "azurerm_user_assigned_identity" "vm_identity" {
  name                = "identity-secureincident"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  location            = azurerm_resource_group.secureincident_rg.location
}