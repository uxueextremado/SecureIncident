# Crea la máquina virtual Linux que ejecutará la aplicación web
resource "azurerm_linux_virtual_machine" "secureincident_vm" {
  name                = "vm-secureincident"
  resource_group_name = azurerm_resource_group.secureincident_rg.name
  location            = azurerm_resource_group.secureincident_rg.location
  size                = "Standard_B1s"  # Tamaño básico: 1 vCPU, 1GB RAM (para desarrollo)

  admin_username = "azureuser"  # Usuario administrador

  # Conecta la VM a la interfaz de red creada anteriormente
  network_interface_ids = [
    azurerm_network_interface.secureincident_nic.id
  ]

  # Disco del sistema operativo
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"  # Disco estándar HDD
  }

  # Imagen del sistema operativo: Ubuntu Server 18.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Asigna la identidad gestionada a la VM
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.vm_identity.id  # Identidad creada antes
    ]
  }

  # Configuración de SSH (autenticación con clave pública)
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/uxuee/.ssh/id_rsa.pub")  # Ruta a mi clave pública
  }
  
  # Desactiva autenticación por contraseña (solo SSH con clave)
  disable_password_authentication = true
}