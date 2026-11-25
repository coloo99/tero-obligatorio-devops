# Producción: dos tareas por servicio y más memoria.
# En una cuenta real iría con multi_az = true y deletion_protection = true;
# en el Learner Lab quedan apagados para poder destruir el ambiente al final del día.
environment              = "prod"
vpc_cidr                 = "10.30.0.0/16"
desired_count            = 2
task_cpu                 = 256
task_memory              = 1024
db_instance_class        = "db.t3.small"
db_multi_az              = false
db_backup_retention_days = 7
db_deletion_protection   = false
redis_node_type          = "cache.t3.micro"
log_retention_days       = 30
