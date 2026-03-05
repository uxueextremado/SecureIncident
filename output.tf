output "vm_public_ip" {
  value = azurerm_public_ip.secureincident_public_ip.ip_address
}