# Key Vault para guardar secretos
resource "azurerm_key_vault" "secureincident_vault" {
  name                        = "kv-secureincident2"
  location                    = azurerm_resource_group.secureincident_rg.location
  resource_group_name         = azurerm_resource_group.secureincident_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
}

# Política de acceso para tu usuario actual (para crear secretos)
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.secureincident_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "Set", "Delete", "List"
  ]
}

# Política de acceso para la Managed Identity (GitHub Actions)
resource "azurerm_key_vault_access_policy" "managed_identity" {
  key_vault_id = azurerm_key_vault.secureincident_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = "74e071e1-2b4a-49a4-aa08-9eb853d2823b"   # clientId de la Managed Identity

  secret_permissions = [
    "Get"
  ]
}

# Secreto con la contraseña de PostgreSQL
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password2026"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.secureincident_vault.id

  depends_on = [
    azurerm_key_vault_access_policy.current_user
  ]
}