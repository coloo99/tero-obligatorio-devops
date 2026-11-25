variable "environment" {
  description = "Ambiente: dev, test o prod. Tiene que coincidir con el workspace"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment tiene que ser dev, test o prod."
  }
}

variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "azs" {
  description = "Dos zonas de disponibilidad"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "Rango de la VPC; distinto en cada ambiente"
  type        = string
}

variable "image_tag" {
  description = "Tag de las imágenes a desplegar (SHA corto del commit). Se pasa con -var"
  type        = string
}

variable "desired_count" {
  description = "Tareas por servicio"
  type        = number
}

variable "task_cpu" {
  description = "CPU de cada tarea (256 = 0,25 vCPU)"
  type        = number
}

variable "task_memory" {
  description = "Memoria de cada tarea en MiB"
  type        = number
}

variable "db_instance_class" {
  description = "Tamaño de la instancia de RDS"
  type        = string
}

variable "db_multi_az" {
  description = "RDS con réplica en otra zona (false en el Learner Lab)"
  type        = bool
}

variable "db_backup_retention_days" {
  description = "Días que se guardan los respaldos automáticos de RDS (0 = sin respaldos)"
  type        = number
}

variable "db_deletion_protection" {
  description = "Impide borrar la base con destroy (false en el Learner Lab)"
  type        = bool
}

variable "redis_node_type" {
  description = "Tamaño del nodo de ElastiCache"
  type        = string
}

variable "log_retention_days" {
  description = "Días que se guardan los logs en CloudWatch"
  type        = number
}
