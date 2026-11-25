# Datos de un ambiente: PostgreSQL en RDS, Redis en ElastiCache y la tarea
# db-init que crea las bases de catalog y cart (lo mismo que init-db.sql en local).
# Las dos bases quedan en subredes privadas y solo aceptan conexiones de las tareas.

# ── PostgreSQL ───────────────────────────────────────────────────────────────

resource "aws_security_group" "db" {
  name        = "${var.name}-db"
  description = "PostgreSQL: solo desde las tareas de ECS"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "db_from_tasks" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = var.tasks_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "PostgreSQL desde las tareas"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db"
  subnet_ids = var.private_subnet_ids
}

# PostgreSQL 15 en adelante exige SSL por defecto en RDS. catalog y orders se
# conectan con sslmode=disable y admin sin SSL (código original de Tero), así que
# se desactiva la exigencia. El tráfico no sale de la VPC.
resource "aws_db_parameter_group" "this" {
  name   = "${var.name}-postgres16"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name}-db"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  # La base "orders" se crea con la instancia; catalogdb y cartdb las crea db-init.
  db_name  = "orders"
  username = var.db_username

  # RDS genera la contraseña y la guarda en Secrets Manager: no aparece
  # ni en el código ni en el estado de Terraform.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = var.db_multi_az

  backup_retention_period = var.db_backup_retention_days
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = true
  apply_immediately       = true
}

# ── Redis ────────────────────────────────────────────────────────────────────

resource "aws_security_group" "redis" {
  name        = "${var.name}-redis"
  description = "Redis: solo desde las tareas de ECS"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_tasks" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = var.tasks_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  description                  = "Redis desde las tareas"
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-redis"
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_cluster" "this" {
  cluster_id           = "${var.name}-redis"
  engine               = "redis"
  engine_version       = "7.1"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.redis.id]
}

# ── Tarea db-init ────────────────────────────────────────────────────────────
# Se ejecuta una vez después de crear la base (comando en el output db_init_command).
# Corre psql con el mismo init-db.sql que usa docker compose en local.

resource "aws_cloudwatch_log_group" "db_init" {
  name              = "/tero/${var.environment}/db-init"
  retention_in_days = var.log_retention_days
}

resource "aws_ecs_task_definition" "db_init" {
  family                   = "${var.name}-db-init"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn

  container_definitions = jsonencode([{
    name      = "db-init"
    image     = "public.ecr.aws/docker/library/postgres:16-alpine"
    essential = true
    command   = ["sh", "-c", "printf '%s' \"$INIT_SQL\" | psql -v ON_ERROR_STOP=1"]

    environment = [
      { name = "PGHOST", value = aws_db_instance.this.address },
      { name = "PGPORT", value = "5432" },
      { name = "PGUSER", value = var.db_username },
      { name = "PGDATABASE", value = "orders" },
      { name = "INIT_SQL", value = var.init_sql },
    ]

    secrets = [
      { name = "PGPASSWORD", valueFrom = "${aws_db_instance.this.master_user_secret[0].secret_arn}:password::" },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.db_init.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "db-init"
      }
    }
  }])
}
