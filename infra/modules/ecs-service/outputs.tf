output "service_name" {
  description = "Nombre del servicio de ECS"
  value       = aws_ecs_service.this.name
}

output "target_group_arn" {
  description = "Target group del servicio en el balanceador"
  value       = aws_lb_target_group.this.arn
}

output "log_group_name" {
  description = "Grupo de logs del servicio en CloudWatch"
  value       = aws_cloudwatch_log_group.this.name
}
