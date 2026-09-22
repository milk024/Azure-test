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
  app_port            = var.app_port
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

  connection {
    type        = "ssh"
    host        = module.network.public_ip_address
    user        = var.admin_username
    private_key = tls_private_key.gallery.private_key_pem
  }

  # Create the remote workspace before copying source into it.
  provisioner "remote-exec" {
    inline = ["mkdir -p /home/${var.admin_username}/workspace/gallery-spring-boot"]
  }

  # Copy the local source tree to the VM — no git/GitHub account involved.
  # (Terraform's built-in SCP communicator doesn't expand "~", so use an absolute path.)
  provisioner "file" {
    source      = "${path.module}/${var.app_source_path}/"
    destination = "/home/${var.admin_username}/workspace/gallery-spring-boot"
  }

  # Build with Maven and register as a systemd service.
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y openjdk-21-jdk",
      "cd /home/${var.admin_username}/workspace/gallery-spring-boot && chmod +x ./mvnw && ./mvnw clean package -DskipTests -Dbuild.finalName=gallery",
      "sudo mkdir -p /opt/gallery && sudo chown $USER:$USER /opt/gallery",
      "mv /home/${var.admin_username}/workspace/gallery-spring-boot/target/gallery.jar /opt/gallery",
      "sudo tee /etc/systemd/system/gallery.service > /dev/null <<'EOF'\n[Unit]\nDescription=Gallery Spring Boot Application\nAfter=network.target\n\n[Service]\nType=simple\nUser=${var.admin_username}\nWorkingDirectory=/opt/gallery\nExecStart=/usr/bin/java -jar /opt/gallery/gallery.jar --spring.profiles.active=dev\nRestart=on-failure\nStandardOutput=journal\nStandardError=journal\nSyslogIdentifier=gallery\n\n[Install]\nWantedBy=multi-user.target\nEOF",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable --now gallery",
    ]
  }
}
