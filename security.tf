# Grupo de Seguridad de Red (firewall) para controlar el tráfico
resource "azurerm_network_security_group" "secureincident_nsg" {
  name                = "nsg-secureincident"
  location            = azurerm_resource_group.secureincident_rg.location
  resource_group_name = azurerm_resource_group.secureincident_rg.name
}

# Regla: permite acceso SSH (puerto 22) solo desde mi IP
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 100      # Prioridad alta (números bajos = más prioridad)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"      # Cualquier puerto de origen
  destination_port_range      = "22"     # Puerto SSH

  source_address_prefix       = "IP/32"  # IMPORTANTE: cambiar por mi IP (ej: "84.123.45.67/32")
  destination_address_prefix   = "*"

  resource_group_name         = azurerm_resource_group.secureincident_rg.name
  network_security_group_name = azurerm_network_security_group.secureincident_nsg.name
}

# Regla: permite tráfico HTTP (puerto 80) desde cualquier origen
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "allow-http"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "80"     # Puerto HTTP

  source_address_prefix       = "*"      # Cualquier IP puede acceder a la web
  destination_address_prefix   = "*"

  resource_group_name         = azurerm_resource_group.secureincident_rg.name
  network_security_group_name = azurerm_network_security_group.secureincident_nsg.name
}

# Asocia el NSG a la subred pública (las reglas se aplican a la VM)
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.secureincident_subnet_public.id
  network_security_group_id = azurerm_network_security_group.secureincident_nsg.id
}