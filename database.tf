resource "azurerm_postgresql_flexible_server" "secureincident_db" {
  name                   = "postgres-secureincident"
  resource_group_name    = azurerm_resource_group.secureincident_rg.name
  location               = azurerm_resource_group.secureincident_rg.location

  administrator_login    = "dbadmin"
  administrator_password = azurerm_key_vault_secret.db_password.value

  sku_name = "B_Standard_B1ms"
  version  = "13"

  public_network_access_enabled = false
}