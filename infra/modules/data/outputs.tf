output "db_address" {
  description = "Nombre DNS de la instancia de PostgreSQL"
  value       = aws_db_instance.this.address
}

output "db_username" {
  description = "Usuario administrador de PostgreSQL"
  value       = var.db_username
}

output "db_password_secret_arn" {
  description = "ARN del secreto que gestiona RDS (JSON con username y password)"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "redis_address" {
  description = "Nombre DNS del nodo de Redis"
  value       = aws_elasticache_cluster.this.cache_nodes[0].address
}

output "db_init_task_definition_arn" {
  description = "Definición de la tarea que crea catalogdb, cartdb y la tabla del carrito"
  value       = aws_ecs_task_definition.db_init.arn
}
