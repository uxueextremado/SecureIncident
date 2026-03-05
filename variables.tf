variable "location" {
  default = "westeurope"
}

variable "resource_group_name" {
  default = "rg-secureincident"
}

variable "db_password" {
  sensitive = true
}