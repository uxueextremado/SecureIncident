resource "azurerm_linux_virtual_machine" "secureincident_vm" {
  name                = "vm-secureincident"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  location            = azurerm_resource_group.secureincident_rg.location
  size                = "Standard_B1s"

  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.secureincident_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  identity {
  type = "UserAssigned"

  identity_ids = [
    azurerm_user_assigned_identity.vm_identity.id
    ]
  }
}