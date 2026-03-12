# Crea un Key Vault para almacenar secretos de forma segura
resource "azurerm_key_vault" "secureincident_vault" {
  name                        = "kv-secureincident"
  location                    = azurerm_resource_group.secureincident_rg.location
  resource_group_name         = azurerm_resource_group.secureincident_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id  # Tenant de Azure
  sku_name                    = "standard"  # Plan estándar

  purge_protection_enabled    = false  # No protege contra purga (para desarrollo)

  # Política de acceso para el usuario actual (el que ejecuta Terraform)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id  # Mi usuario

    secret_permissions = [
      "Get",   # Puede leer secretos
      "Set",   # Puede crear secretos
      "Delete" # Puede eliminar secretos
    ]
  }
}

# Guarda la contraseña de la BD como un secreto en Key Vault
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password  # Valor pasado por variable (sensitive)
  key_vault_id = azurerm_key_vault.secureincident_vault.id
}

# Política de acceso para la VM (mediante su identidad gestionada)
resource "azurerm_key_vault_access_policy" "vm_policy" {
  key_vault_id = azurerm_key_vault.secureincident_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.vm_identity.principal_id  # ID de la identidad de la VM

  secret_permissions = [
    "Get"  # La VM solo puede LEER secretos (mínimo privilegio)
  ]
}