resource "azurerm_network_security_group" "secureincident_nsg" {
  name                = "nsg-secureincident"
  location            = azurerm_resource_group.secureincident_rg.location
  resource_group_name = azurerm_resource_group.secureincident_rg.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "22"

  source_address_prefix       = "IP/32" #cambiarlo
  destination_address_prefix   = "*"

  resource_group_name         = azurerm_resource_group.secureincident_rg.name
  network_security_group_name = azurerm_network_security_group.secureincident_nsg.name
}
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "allow-http"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "80"

  source_address_prefix       = "*"
  destination_address_prefix   = "*"

  resource_group_name         = azurerm_resource_group.secureincident_rg.name
  network_security_group_name = azurerm_network_security_group.secureincident_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.secureincident_subnet_public.id
  network_security_group_id = azurerm_network_security_group.secureincident_nsg.id
}