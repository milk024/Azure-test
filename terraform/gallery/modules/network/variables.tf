variable "name_prefix" {
  description = "Prefix used to derive network resource names (matches the VM name, like the Portal wizard does)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group the network resources belong to"
  type        = string
}

variable "address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "Default subnet address prefix"
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "ssh_source_cidr" {
  description = "CIDR allowed to reach SSH (22)"
  type        = string
  default     = "*"
}

variable "app_port" {
  description = "TCP port the application listens on, opened to the internet"
  type        = number
  default     = 8080
}
