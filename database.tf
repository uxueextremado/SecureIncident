# Crea una zona DNS privada para que la VM pueda resolver el nombre de la BD
resource "azurerm_private_dns_zone" "postgres_dns" {
  name                = "secureincident.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
}

# Vincula la zona DNS privada con nuestra VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_link" {
  name                  = "dns-link-secureincident"
  resource_group_name   = azurerm_resource_group.secureincident_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns.name
  virtual_network_id    = azurerm_virtual_network.secureincident_vnet.id
}

# Crea el servidor PostgreSQL Flexible Server en la subred privada
resource "azurerm_postgresql_flexible_server" "secureincident_db" {
  name                   = "postgres-secureincident"
  resource_group_name    = azurerm_resource_group.secureincident_rg.name
  location               = azurerm_resource_group.secureincident_rg.location

  # Credenciales de administrador (la contraseña viene de Key Vault)
  administrator_login    = "dbadmin"
  administrator_password = azurerm_key_vault_secret.db_password.value

  # Configuración básica: B1ms (1 vCPU, 2GB RAM), PostgreSQL 13
  sku_name = "B_Standard_B1ms"
  version  = "13"
  zone     = "1"

  # Almacenamiento: 32GB, backups por 7 días
  storage_mb            = 32768
  backup_retention_days = 7

  # Integración con la subred privada (sin IP pública)
  delegated_subnet_id = azurerm_subnet.secureincident_subnet_private.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres_dns.id

  # Deshabilita el acceso público (solo accesible desde la VNet)
  public_network_access_enabled = false

  # Espera a que existan la contraseña en Key Vault y el enlace DNS
  depends_on = [
    azurerm_key_vault_secret.db_password,
    azurerm_private_dns_zone_virtual_network_link.postgres_dns_link
  ]
}