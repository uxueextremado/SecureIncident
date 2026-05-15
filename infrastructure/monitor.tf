# Grupo de acción para alertas de monitorización
# Cuando ocurran alertas (CPU alta, login fallidos...), este grupo define quién recibe notificaciones
resource "azurerm_monitor_action_group" "secureincident_ag" {
  name                = "ag-secureincident"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  short_name          = "secureag"  # Nombre corto (máx 12 caracteres)
  # Aquí se pueden añadir emails, SMS, webhooks, etc. (pendiente de configurar)
}