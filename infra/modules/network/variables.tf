variable "name" {
  description = "Prefijo de los nombres, por ejemplo tero-dev"
  type        = string
}

variable "vpc_cidr" {
  description = "Rango de IP de la VPC (/16)"
  type        = string
}

variable "azs" {
  description = "Zonas de disponibilidad (dos, porque el ALB y RDS las exigen)"
  type        = list(string)
}
