output "network_interface_id" {
  value = azurerm_network_interface.this.id
}

output "public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "subnet_id" {
  value = azurerm_subnet.this.id
}

output "network_security_group_id" {
  value = azurerm_network_security_group.this.id
}
