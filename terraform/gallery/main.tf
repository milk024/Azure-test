resource "azurerm_resource_group" "gallery" {
  name     = var.resource_group_name
  location = var.location
}

# --- SSH key pair (replaces the portal-downloaded key-gallery.pem) ---
resource "tls_private_key" "gallery" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "gallery_private_key" {
  content         = tls_private_key.gallery.private_key_pem
  filename        = "${path.module}/key-gallery.pem"
  file_permission = "0400"
}

# --- Networking ---
resource "azurerm_virtual_network" "gallery" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.gallery.location
  resource_group_name = azurerm_resource_group.gallery.name
}

resource "azurerm_subnet" "gallery" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.gallery.name
  virtual_network_name = azurerm_virtual_network.gallery.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "gallery" {
  name                = "${var.vm_name}-ip"
  location            = azurerm_resource_group.gallery.location
  resource_group_name = azurerm_resource_group.gallery.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "gallery" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.gallery.location
  resource_group_name = azurerm_resource_group.gallery.name

  security_rule {
    name                       = "Allow-SSH-22"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-TCP-8080"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "gallery" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.gallery.location
  resource_group_name = azurerm_resource_group.gallery.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.gallery.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gallery.id
  }
}

resource "azurerm_network_interface_security_group_association" "gallery" {
  network_interface_id      = azurerm_network_interface.gallery.id
  network_security_group_id = azurerm_network_security_group.gallery.id
}

# --- Virtual machine ---
resource "azurerm_linux_virtual_machine" "gallery" {
  name                = var.vm_name
  location            = azurerm_resource_group.gallery.location
  resource_group_name = azurerm_resource_group.gallery.name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.gallery.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.gallery.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
