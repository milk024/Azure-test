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
  default     = "Standard_B2als_v2"
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

variable "app_source_path" {
  description = "Path to the Gallery Spring Boot source (relative to this module dir), copied to the VM via provisioner (no git/GitHub account on the VM)"
  type        = string
  default     = "../../azure-fund/Workloads/gallery-spring-boot"
}

variable "app_port" {
  description = "TCP port the Gallery app listens on"
  type        = number
  default     = 8080
}
