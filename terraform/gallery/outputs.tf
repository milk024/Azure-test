output "public_ip_address" {
  description = "Public IP of vm-gallery-web"
  value       = module.network.public_ip_address
}

output "ssh_command" {
  description = "SSH connection command"
  value       = "ssh -i key-gallery.pem ${var.admin_username}@${module.network.public_ip_address}"
}

output "gallery_url" {
  description = "URL of the deployed Gallery app (after manual deployment steps)"
  value       = "http://${module.network.public_ip_address}:8080"
}
