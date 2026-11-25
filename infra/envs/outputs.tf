output "alb_url" {
  description = "URL de la tienda (balanceador público, puerto 80)"
  value       = "http://${aws_lb.public.dns_name}"
}

output "admin_url" {
  description = "URL del panel de administración (balanceador público, puerto 8081)"
  value       = "http://${aws_lb.public.dns_name}:8081"
}

output "ecs_cluster" {
  description = "Nombre del cluster de ECS del ambiente"
  value       = aws_ecs_cluster.this.name
}

output "db_init_command" {
  description = "Comando que ejecuta la tarea db-init: crea catalogdb, cartdb y la tabla del carrito (una vez por base nueva)"
  value = join(" ", [
    "aws ecs run-task --region ${var.region}",
    "--cluster ${aws_ecs_cluster.this.name}",
    "--launch-type FARGATE",
    "--task-definition ${module.data.db_init_task_definition_arn}",
    "--network-configuration 'awsvpcConfiguration={subnets=[${join(",", module.network.public_subnet_ids)}],securityGroups=[${aws_security_group.tasks.id}],assignPublicIp=ENABLED}'",
    "--query 'tasks[0].taskArn' --output text",
  ])
}

output "redeploy_command" {
  description = "Comando que reinicia los servicios que usan PostgreSQL, para que se conecten después de db-init"
  value       = "for s in catalog carts orders admin; do aws ecs update-service --region ${var.region} --cluster ${aws_ecs_cluster.this.name} --service $s --force-new-deployment --query 'service.serviceName' --output text; done"
}
