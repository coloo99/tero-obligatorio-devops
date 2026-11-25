# Desarrollo: lo mínimo para probar, sin respaldos.
environment              = "dev"
vpc_cidr                 = "10.10.0.0/16"
desired_count            = 1
task_cpu                 = 256
task_memory              = 512
db_instance_class        = "db.t3.micro"
db_multi_az              = false
db_backup_retention_days = 0
db_deletion_protection   = false
redis_node_type          = "cache.t3.micro"
log_retention_days       = 7
