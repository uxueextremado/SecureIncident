# Variables globales
variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "spaincentral"   # ← Cambiado para cumplir la política
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "rg-secureincident"
}

variable "db_password" {
  description = "Contraseña del administrador de PostgreSQL"
  type        = string
  sensitive   = true
}

# Variables para la red virtual
variable "vnet_address_space" {
  description = "Espacio de direcciones de la VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_private_prefix" {
  description = "Prefijo de la subred privada (para PostgreSQL)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_integration_prefix" {
  description = "Prefijo de la subred para integración de App Service"
  type        = string
  default     = "10.0.2.0/24"
}

# Variables para PostgreSQL
variable "postgresql_server_name" {
  description = "Nombre del servidor PostgreSQL Flexible"
  type        = string
  default     = "postgres-secureincident"
}

variable "postgresql_admin_login" {
  description = "Usuario administrador de PostgreSQL"
  type        = string
  default     = "dbadmin"
}

variable "postgresql_database_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "secureincident_db"
}

# Variables para App Service
variable "app_service_plan_name" {
  description = "Nombre del plan de App Service"
  type        = string
  default     = "asp-secureincident"
}

variable "web_app_name" {
  description = "Nombre de la Web App"
  type        = string
  default     = "webapp-secureincident"
}

# Variables para despliegue desde GitHub
variable "github_repo_url" {
  description = "URL de tu repositorio de GitHub"
  type        = string
}

variable "github_branch" {
  description = "Rama del repositorio"
  type        = string
  default     = "main"
}

# Clave secreta de la aplicación (Flask)
variable "secret_key" {
  description = "SECRET_KEY de Flask"
  type        = string
  sensitive   = true
}

# Variables para usuarios por defecto (seguridad)
variable "default_security_email" {
  description = "Email del usuario de seguridad por defecto"
  type        = string
  default     = "security@secureincident.com"
}

variable "default_security_username" {
  description = "Nombre de usuario del administrador de seguridad"
  type        = string
  default     = "security_team"
}

variable "default_security_password" {
  description = "Contraseña del usuario de seguridad por defecto"
  type        = string
  sensitive   = true
  default     = "Security123!"
}

# Variables para usuario empleado por defecto
variable "default_employee_email" {
  description = "Email del empleado por defecto"
  type        = string
  default     = "employee@secureincident.com"
}

variable "default_employee_username" {
  description = "Nombre del empleado por defecto"
  type        = string
  default     = "employee1"
}

variable "default_employee_password" {
  description = "Contraseña del empleado por defecto"
  type        = string
  sensitive   = true
  default     = "Employee123!"
}