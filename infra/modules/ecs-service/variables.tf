variable "name" {
  description = "Nombre del servicio, por ejemplo catalog"
  type        = string
}

variable "environment" {
  description = "Ambiente: dev, test o prod"
  type        = string
}

variable "region" {
  type = string
}

variable "image" {
  description = "Imagen completa con su tag"
  type        = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "desired_count" {
  type = number
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "environment_variables" {
  description = "Variables de entorno sin secretos"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Variable de entorno => ARN del secreto (con :clave:: para tomar una clave del JSON)"
  type        = map(string)
  default     = {}
}

variable "cluster_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "listener_arn" {
  description = "Listener del balanceador que recibe el tráfico de este servicio"
  type        = string
}

variable "listener_priority" {
  description = "Prioridad de la regla dentro del listener (única por listener)"
  type        = number
}

variable "path_patterns" {
  description = "Rutas que se mandan a este servicio"
  type        = list(string)
}

variable "log_retention_days" {
  type = number
}
