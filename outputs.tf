# Muestra la URL de la aplicación desplegada
output "web_app_url" {
  description = "URL de la aplicación SecureIncident"
  value       = "https://${azurerm_linux_web_app.secureincident_app.default_hostname}"
}

# Muestra el nombre del servidor PostgreSQL
output "postgresql_server_name" {
  description = "Nombre del servidor PostgreSQL"
  value       = azurerm_postgresql_flexible_server.secureincident_db.name
}