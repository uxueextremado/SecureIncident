# Private DNS Zone para que la VM resuelva el nombre del servidor PostgreSQL
resource "azurerm_private_dns_zone" "postgres_dns" {
  name                = "secureincident.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
}

# Vincula la DNS Zone privada con la VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_link" {
  name                  = "dns-link-secureincident"
  resource_group_name   = azurerm_resource_group.secureincident_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns.name
  virtual_network_id    = azurerm_virtual_network.secureincident_vnet.id
}

resource "azurerm_postgresql_flexible_server" "secureincident_db" {
  name                   = "postgres-secureincident"
  resource_group_name    = azurerm_resource_group.secureincident_rg.name
  location               = azurerm_resource_group.secureincident_rg.location

  administrator_login    = "dbadmin"
  administrator_password = azurerm_key_vault_secret.db_password.value

  sku_name = "B_Standard_B1ms"
  version  = "13"
  zone     = "1"

  storage_mb            = 32768
  backup_retention_days = 7

  # Integración con la subred privada mediante VNet injection
  delegated_subnet_id = azurerm_subnet.secureincident_subnet_private.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres_dns.id

  public_network_access_enabled = false

  depends_on = [
    azurerm_key_vault_secret.db_password,
    azurerm_private_dns_zone_virtual_network_link.postgres_dns_link
  ]
}
