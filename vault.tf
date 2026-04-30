# Key Vault para guardar secretos
resource "azurerm_key_vault" "secureincident_vault" {
  name                        = "kv-secureincident2"   # ← Nombre nuevo
  location                    = azurerm_resource_group.secureincident_rg.location
  resource_group_name         = azurerm_resource_group.secureincident_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
}

# Política de acceso para el usuario actual (para crear secretos)
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.secureincident_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "Set", "Delete", "List"
  ]
}

# Secreto con la contraseña de PostgreSQL (nombre nuevo)
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password2026"   # ← Nombre nuevo
  value        = var.db_password
  key_vault_id = azurerm_key_vault.secureincident_vault.id

  depends_on = [
    azurerm_key_vault_access_policy.current_user
  ]
}