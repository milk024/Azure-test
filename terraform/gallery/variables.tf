variable "location" {
  description = "Azure region"
  type        = string
  default     = "Korea Central"
}

variable "resource_group_name" {
  description = "Resource group for the Gallery workload"
  type        = string
  default     = "rg-gallery"
}

variable "vm_name" {
  description = "Name of the Gallery web VM"
  type        = string
  default     = "vm-gallery-web"
}

variable "vm_size" {
  description = "VM size for the Gallery web server"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "my_ip_cidr" {
  description = "CIDR allowed to reach SSH (22). Use your own public IP /32 for safety; \"*\" opens to the internet like the lab does."
  type        = string
  default     = "*"
}
