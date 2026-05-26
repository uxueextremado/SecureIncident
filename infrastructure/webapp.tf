# Plan de App Service
resource "azurerm_service_plan" "secureincident_asp" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  location            = azurerm_resource_group.secureincident_rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Web App Linux con Python
resource "azurerm_linux_web_app" "secureincident_app" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  location            = azurerm_resource_group.secureincident_rg.location
  service_plan_id     = azurerm_service_plan.secureincident_asp.id

  site_config {
    application_stack {
      python_version = "3.12"
    }
    always_on           = false
    vnet_route_all_enabled = true
  }

  https_only = true

  app_settings = {
    "DATABASE_URL" = "postgresql://${var.postgresql_admin_login}:${azurerm_key_vault_secret.db_password.value}@${var.postgresql_server_name}.postgres.database.azure.com:5432/${var.postgresql_database_name}?sslmode=require"
    "SECRET_KEY"   = var.secret_key
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    
    "DEFAULT_SECURITY_EMAIL"    = var.default_security_email
    "DEFAULT_SECURITY_USERNAME" = var.default_security_username
    "DEFAULT_SECURITY_PASSWORD" = var.default_security_password
    
    "DEFAULT_EMPLOYEE_EMAIL"    = var.default_employee_email
    "DEFAULT_EMPLOYEE_USERNAME" = var.default_employee_username
    "DEFAULT_EMPLOYEE_PASSWORD" = var.default_employee_password

    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.secureincident.connection_string
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Project = "Incidencias"
  }
}

# Configurar VNet Integration con dependencia explicita
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.secureincident_app.id
  subnet_id      = azurerm_subnet.app_integration_subnet.id

  depends_on = [
    azurerm_subnet.app_integration_subnet
  ]
}