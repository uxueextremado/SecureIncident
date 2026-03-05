resource "azurerm_virtual_network" "secureincident_vnet" {
  name                = "vnet-secureincident"
  location            = azurerm_resource_group.secureincident_rg.location
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_public_ip" "secureincident_public_ip" {
  name                = "pip-secureincident"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  location            = azurerm_resource_group.secureincident_rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_subnet" "secureincident_subnet_public" {
  name                 = "subnet-public"
  resource_group_name  = azurerm_resource_group.secureincident_rg.name
  virtual_network_name = azurerm_virtual_network.secureincident_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "secureincident_subnet_private" {
  name                 = "subnet-private"
  resource_group_name  = azurerm_resource_group.secureincident_rg.name
  virtual_network_name = azurerm_virtual_network.secureincident_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "secureincident_nic" {
  name                = "nic-secureincident"
  location            = azurerm_resource_group.secureincident_rg.location
  resource_group_name = azurerm_resource_group.secureincident_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.secureincident_subnet_public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.secureincident_public_ip.id
  }
}