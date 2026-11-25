variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "services" {
  description = "Servicios de Tero que tienen imagen propia"
  type        = list(string)
  default     = ["ui", "catalog", "carts", "checkout", "orders", "admin"]
}

variable "environments" {
  description = "Ambientes que necesitan su secreto del admin"
  type        = list(string)
  default     = ["dev", "test", "prod"]
}
