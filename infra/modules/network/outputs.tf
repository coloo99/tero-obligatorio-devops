output "vpc_id" {
  description = "ID de la VPC del ambiente"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "Rango de IP de la VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Subredes públicas: balanceadores y tareas de ECS"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Subredes privadas, sin salida a internet: RDS y Redis"
  value       = aws_subnet.private[*].id
}
