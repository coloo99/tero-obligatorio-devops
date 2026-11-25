variable "name" {
  description = "Prefijo de los nombres, por ejemplo tero-dev"
  type        = string
}

variable "environment" {
  description = "Ambiente: dev, test o prod"
  type        = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "tasks_security_group_id" {
  description = "Security group de las tareas de ECS, el único que puede conectarse a las bases"
  type        = string
}

variable "execution_role_arn" {
  description = "Rol con el que ECS baja la imagen y lee los secretos (LabRole en el Learner Lab)"
  type        = string
}

variable "db_username" {
  description = "Usuario administrador de PostgreSQL; init-db.sql le da permisos con este nombre"
  type        = string
  default     = "retail_user"
}

variable "db_instance_class" {
  type = string
}

variable "db_multi_az" {
  type = bool
}

variable "db_backup_retention_days" {
  type = number
}

variable "db_deletion_protection" {
  type = bool
}

variable "redis_node_type" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "init_sql" {
  description = "Contenido de init-db.sql"
  type        = string
}
