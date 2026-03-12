# Red virtual principal con espacio de direcciones 10.0.0.0/16
resource "azurerm_virtual_network" "secureincident_vnet" {
  name                = "vnet-secureincident"
  location            = azurerm_resource_group.secureincident_rg.location
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  address_space       = ["10.0.0.0/16"]  # Rango completo de IPs para la VNet
}

# IP pública estática para acceder a la VM desde internet
resource "azurerm_public_ip" "secureincident_public_ip" {
  name                = "pip-secureincident"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  location            = azurerm_resource_group.secureincident_rg.location
  allocation_method   = "Static"  # IP fija (no cambia al reiniciar)
}

# Subred pública (10.0.1.0/24) - Aquí irá la VM con la aplicación web
resource "azurerm_subnet" "secureincident_subnet_public" {
  name                 = "subnet-public"
  resource_group_name  = azurerm_resource_group.secureincident_rg.name
  virtual_network_name = azurerm_virtual_network.secureincident_vnet.name
  address_prefixes     = ["10.0.1.0/24"]  # Rango para la subred pública
}

# Subred privada (10.0.2.0/24) - Aquí irá la base de datos PostgreSQL
resource "azurerm_subnet" "secureincident_subnet_private" {
  name                 = "subnet-private"
  resource_group_name  = azurerm_resource_group.secureincident_rg.name
  virtual_network_name = azurerm_virtual_network.secureincident_vnet.name
  address_prefixes     = ["10.0.2.0/24"]  # Rango para la subred privada

  # Delegación: indica que esta subred puede alojar PostgreSQL Flexible Server
  delegation {
    name = "postgres-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Interfaz de red para la VM (conexión entre VM y red)
resource "azurerm_network_interface" "secureincident_nic" {
  name                = "nic-secureincident"
  location            = azurerm_resource_group.secureincident_rg.location
  resource_group_name = azurerm_resource_group.secureincident_rg.name

  # Configuración IP: asigna IP privada dinámica y la IP pública creada
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.secureincident_subnet_public.id
    private_ip_address_allocation = "Dynamic"  # IP privada automática
    public_ip_address_id          = azurerm_public_ip.secureincident_public_ip.id
  }
}