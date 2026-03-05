resource "azurerm_postgresql_flexible_server" "secureincident_db" {
  name                   = "postgres-secureincident"
  resource_group_name    = azurerm_resource_group.secureincident_rg.name
  location               = azurerm_resource_group.secureincident_rg.location
  administrator_login    = "dbadmin"
  administrator_password = "SecurePassword123!"

  sku_name = "B_Standard_B1ms"
  version  = "13"
}