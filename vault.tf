resource "azurerm_key_vault" "secureincident_vault" {
  name                        = "kv-secureincident"
  location                    = azurerm_resource_group.secureincident_rg.location
  resource_group_name         = azurerm_resource_group.secureincident_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  purge_protection_enabled    = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "Set",
      "Delete"
    ]
  }
}