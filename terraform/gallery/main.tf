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

# --- Networking (VNet/Subnet/NSG/Public IP/NIC), auto-named off var.vm_name ---
module "network" {
  source = "./modules/network"

  name_prefix         = var.vm_name
  location            = azurerm_resource_group.gallery.location
  resource_group_name = azurerm_resource_group.gallery.name
  ssh_source_cidr     = var.my_ip_cidr
  app_port            = 8080
}

# --- Virtual machine ---
resource "azurerm_linux_virtual_machine" "gallery" {
  name                = var.vm_name
  location            = azurerm_resource_group.gallery.location
  resource_group_name = azurerm_resource_group.gallery.name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    module.network.network_interface_id,
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
