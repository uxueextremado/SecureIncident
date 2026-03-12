# Variable para la ubicación de los recursos (con valor por defecto)
variable "location" {
  default = "westeurope"  # Región por defecto: Europa Oeste
}

# Variable para el nombre del grupo de recursos (con valor por defecto)
variable "resource_group_name" {
  default = "rg-secureincident"
}

# Variable para la contraseña de la base de datos
# sensitive = true evita que se muestre en pantalla al hacer plan/apply
variable "db_password" {
  sensitive = true  # La contraseña se debe pasar al ejecutar (ej: TF_VAR_db_password=...)
}