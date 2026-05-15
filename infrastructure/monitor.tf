# 1. Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "secureincident" {
  name                = "law-secureincident"
  location            = azurerm_resource_group.secureincident_rg.location
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 2. Application Insights
resource "azurerm_application_insights" "secureincident" {
  name                = "ai-secureincident"
  location            = azurerm_resource_group.secureincident_rg.location
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  workspace_id        = azurerm_log_analytics_workspace.secureincident.id
  application_type    = "web"
}

# 3. Diagnostic Setting para App Service
resource "azurerm_monitor_diagnostic_setting" "app_service" {
  name                       = "diag-appservice"
  target_resource_id         = azurerm_linux_web_app.secureincident_app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.secureincident.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  enabled_log {
    category = "AppServiceConsoleLogs"
  }
  enabled_log {
    category = "AppServiceAppLogs"
  }
  enabled_log {
    category = "AppServiceAuditLogs"
  }
  metric {
    category = "AllMetrics"
  }
}

# 4. Diagnostic Setting para PostgreSQL
resource "azurerm_monitor_diagnostic_setting" "postgresql" {
  name                       = "diag-postgresql"
  target_resource_id         = azurerm_postgresql_flexible_server.secureincident_db.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.secureincident.id

  enabled_log {
    category = "PostgreSQLLogs"
  }
  enabled_log {
    category = "PostgreSQLFlexibleSessions"
  }
  metric {
    category = "AllMetrics"
  }
}

# 5. Action Group (sin email, pero necesario para las alertas)
resource "azurerm_monitor_action_group" "secureincident_ag" {
  name                = "ag-secureincident"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  short_name          = "secureag"
}

# 6. Alerta: CPU alta
resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "alert-cpu-high"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  scopes              = [azurerm_linux_web_app.secureincident_app.id]
  description         = "Alerta cuando la CPU supera el 80% durante 5 minutos"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.secureincident_ag.id
  }
}

# 7. Alerta: Reinicios de la aplicación
resource "azurerm_monitor_metric_alert" "app_restarts" {
  name                = "alert-app-restarts"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  scopes              = [azurerm_linux_web_app.secureincident_app.id]
  description         = "Alerta cuando la aplicación se reinicia más de 2 veces en 10 minutos"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "RestartCount"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 2
  }

  action {
    action_group_id = azurerm_monitor_action_group.secureincident_ag.id
  }
}