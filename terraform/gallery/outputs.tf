output "public_ip_address" {
  description = "Public IP of vm-gallery-web"
  value       = azurerm_public_ip.gallery.ip_address
}

output "ssh_command" {
  description = "SSH connection command"
  value       = "ssh -i key-gallery.pem ${var.admin_username}@${azurerm_public_ip.gallery.ip_address}"
}

output "gallery_url" {
  description = "URL of the deployed Gallery app (after manual deployment steps)"
  value       = "http://${azurerm_public_ip.gallery.ip_address}:8080"
}
