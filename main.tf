resource "azurerm_virtual_network" "main" {
  name                = "myvnet01"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = "bhoomirg"
}

resource "azurerm_subnet" "internal" {
  name                 = "internalsub"
  resource_group_name  = "bhoomirg"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "mynic01"
  location            = "westeurope"
  resource_group_name = "bhoomirg"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
    count = var.vm ? 5:0
  name                  = "vm01"
  location              = "westeurope"
  resource_group_name   = "bhoomirg"
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"



  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}