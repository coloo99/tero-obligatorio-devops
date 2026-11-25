variable "name" {
  description = "Nombre del servicio, por ejemplo catalog"
  type        = string
}

variable "environment" {
  description = "Ambiente: dev, test o prod"
  type        = string
}

variable "region" {
  description = "Región de AWS"
  type        = string
}

variable "image" {
  description = "Imagen completa con su tag"
  type        = string
}

variable "cpu" {
  description = "CPU de la tarea en unidades de ECS (256 = 0,25 vCPU)"
  type        = number
}

variable "memory" {
  description = "Memoria de la tarea en MB"
  type        = number
}

variable "desired_count" {
  description = "Cantidad de tareas que se mantienen corriendo"
  type        = number
}

variable "container_port" {
  description = "Puerto en el que escucha el contenedor"
  type        = number
  default     = 8080
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
  description = "ID del cluster de ECS"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC del ambiente"
  type        = string
}

variable "subnet_ids" {
  description = "Subredes donde corren las tareas"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group de las tareas"
  type        = string
}

variable "execution_role_arn" {
  description = "Rol que usa ECS para bajar la imagen, leer secretos y escribir logs (LabRole)"
  type        = string
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
  description = "Días que se guardan los logs en CloudWatch"
  type        = number
}
