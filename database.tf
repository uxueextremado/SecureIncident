# Zona DNS privada para PostgreSQL
resource "azurerm_private_dns_zone" "postgres_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
}

# Vincula la zona DNS privada con la VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_link" {
  name                  = "dns-link-secureincident"
  resource_group_name   = azurerm_resource_group.secureincident_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns.name
  virtual_network_id    = azurerm_virtual_network.secureincident_vnet.id
}
# Servidor PostgreSQL Flexible Server (dentro de la subred privada)
resource "azurerm_postgresql_flexible_server" "secureincident_db" {
  name                   = var.postgresql_server_name
  resource_group_name    = azurerm_resource_group.secureincident_rg.name
  location               = azurerm_resource_group.secureincident_rg.location

  administrator_login    = var.postgresql_admin_login
  administrator_password = azurerm_key_vault_secret.db_password.value

  sku_name   = "B_Standard_B1ms"
  version    = "14"
  # zone       = null  # <--- CAMBIO CLAVE: Se elimina la zona fija

  storage_mb            = 32768
  backup_retention_days = 7

  delegated_subnet_id = azurerm_subnet.secureincident_subnet_private.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres_dns.id

  public_network_access_enabled = false

  depends_on = [
    azurerm_key_vault_secret.db_password,
    azurerm_private_dns_zone_virtual_network_link.postgres_dns_link
  ]
}

# Base de datos dentro del servidor
resource "azurerm_postgresql_flexible_server_database" "secureincident_db" {
  name      = var.postgresql_database_name
  server_id = azurerm_postgresql_flexible_server.secureincident_db.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
