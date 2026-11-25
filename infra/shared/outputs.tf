output "repository_urls" {
  description = "URL de cada repositorio de ECR"
  value       = { for name, repo in aws_ecr_repository.service : name => repo.repository_url }
}

output "admin_secret_names" {
  description = "Nombre del secreto del admin de cada ambiente"
  value       = { for env, secret in aws_secretsmanager_secret.admin : env => secret.name }
}
