# Muestra la IP pública de la VM después del despliegue
# Útil para conectarse por SSH o acceder a la aplicación web
output "vm_public_ip" {
  value = azurerm_public_ip.secureincident_public_ip.ip_address
}