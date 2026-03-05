resource "azurerm_monitor_action_group" "secureincident_ag" {
  name                = "ag-secureincident"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  short_name          = "secureag"
}