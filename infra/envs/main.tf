# Un ambiente completo de Tero: red, balanceadores, cluster de ECS, bases de datos
# y los seis servicios. El mismo código se usa para dev, test y prod; lo que cambia
# está en <ambiente>.tfvars y cada ambiente tiene su propio workspace y estado.

locals {
  name     = "tero-${var.environment}"
  registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  internal = "http://${aws_lb.internal.dns_name}"
}

# Evita aplicar el tfvars de un ambiente sobre el estado de otro.
resource "terraform_data" "workspace_guard" {
  lifecycle {
    precondition {
      condition     = terraform.workspace == var.environment
      error_message = "El workspace no coincide con el tfvars: usá 'terraform workspace select ${var.environment}'."
    }
  }
}

data "aws_caller_identity" "current" {}

# En el Learner Lab no se pueden crear roles de IAM: ECS usa el rol LabRole.
data "aws_iam_role" "lab" {
  name = "LabRole"
}

# Creado en infra/shared; su valor se carga con la CLI.
data "aws_secretsmanager_secret" "admin" {
  name = "tero/${var.environment}/admin"
}

module "network" {
  source = "../modules/network"

  name     = local.name
  vpc_cidr = var.vpc_cidr
  azs      = var.azs
}

# ── Security groups ──────────────────────────────────────────────────────────

resource "aws_security_group" "alb_public" {
  name        = "${local.name}-alb-public"
  description = "ALB publico: tienda (80) y admin (8081)"
  vpc_id      = module.network.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "alb_public" {
  for_each = toset(["80", "8081"])

  security_group_id = aws_security_group.alb_public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  description       = "HTTP desde internet"
}

resource "aws_vpc_security_group_egress_rule" "alb_public" {
  security_group_id = aws_security_group.alb_public.id
  cidr_ipv4         = module.network.vpc_cidr
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
  description       = "Hacia las tareas, dentro de la VPC"
}

resource "aws_security_group" "alb_internal" {
  name        = "${local.name}-alb-internal"
  description = "ALB interno: llamadas entre servicios"
  vpc_id      = module.network.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "alb_internal" {
  security_group_id            = aws_security_group.alb_internal.id
  referenced_security_group_id = aws_security_group.tasks.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "HTTP desde las tareas"
}

resource "aws_vpc_security_group_egress_rule" "alb_internal" {
  security_group_id = aws_security_group.alb_internal.id
  cidr_ipv4         = module.network.vpc_cidr
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
  description       = "Hacia las tareas, dentro de la VPC"
}

resource "aws_security_group" "tasks" {
  name        = "${local.name}-tasks"
  description = "Tareas de ECS: solo reciben trafico de los dos ALB"
  vpc_id      = module.network.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "tasks" {
  for_each = {
    public   = aws_security_group.alb_public.id
    internal = aws_security_group.alb_internal.id
  }

  security_group_id            = aws_security_group.tasks.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  description                  = "Desde el ALB ${each.key}"
}

# Salida de las tareas, solo lo que necesitan:
# - HTTPS (443) a internet: ECR, Secrets Manager y CloudWatch Logs. Sin NAT ni VPC
#   endpoints (descartados por costo) se alcanzan por sus IP públicas, que no son fijas.
# - 80, 5432 y 6379 dentro de la VPC: ALB interno, PostgreSQL y Redis.
# Excepción de Trivy justificada en docs/informes/seguridad.md.
#trivy:ignore:AWS-0104
resource "aws_vpc_security_group_egress_rule" "tasks_https" {
  security_group_id = aws_security_group.tasks.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS a ECR, Secrets Manager y CloudWatch Logs"
}

resource "aws_vpc_security_group_egress_rule" "tasks_vpc" {
  for_each = {
    alb-interno = 80
    postgres    = 5432
    redis       = 6379
  }

  security_group_id = aws_security_group.tasks.id
  cidr_ipv4         = module.network.vpc_cidr
  ip_protocol       = "tcp"
  from_port         = each.value
  to_port           = each.value
  description       = "Hacia ${each.key}, dentro de la VPC"
}

# ── Balanceadores ────────────────────────────────────────────────────────────
# Público: la tienda en el puerto 80 y el admin en el 8081.
# Interno: catalog, carts, checkout y orders, separados por ruta. ui y checkout
# llaman a los demás servicios a través de este balanceador.
# Cada servicio agrega su propia regla (módulo ecs-service); lo que no coincide
# con ninguna regla recibe un 404.

# Tiene que ser público: es la entrada de la tienda y del admin (Trivy AWS-0053).
# Solo expone el 80 y el 8081 y reenvía únicamente al 8080 de las tareas.
#trivy:ignore:AWS-0053
resource "aws_lb" "public" {
  name               = "${local.name}-public"
  load_balancer_type = "application"
  internal           = false
  subnets            = module.network.public_subnet_ids
  security_groups    = [aws_security_group.alb_public.id]

  drop_invalid_header_fields = true
}

# HTTP sin TLS (Trivy AWS-0054): el Learner Lab no permite dominio ni certificado
# de ACM. En una cuenta real: listener 443 con ACM y el 80 redirigiendo al 443.
#trivy:ignore:AWS-0054
resource "aws_lb_listener" "public" {
  for_each = toset(["80", "8081"])

  load_balancer_arn = aws_lb.public.arn
  port              = tonumber(each.key)
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb" "internal" {
  name               = "${local.name}-internal"
  load_balancer_type = "application"
  internal           = true
  subnets            = module.network.public_subnet_ids
  security_groups    = [aws_security_group.alb_internal.id]

  drop_invalid_header_fields = true
}

# HTTP sin TLS (Trivy AWS-0054): tráfico entre servicios dentro de la VPC, por un
# balanceador interno que solo acepta a las tareas. Mismo límite del certificado.
#trivy:ignore:AWS-0054
resource "aws_lb_listener" "internal" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

# ── Cluster y datos ──────────────────────────────────────────────────────────

resource "aws_ecs_cluster" "this" {
  name = local.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

module "data" {
  source = "../modules/data"

  name                     = local.name
  environment              = var.environment
  region                   = var.region
  vpc_id                   = module.network.vpc_id
  private_subnet_ids       = module.network.private_subnet_ids
  tasks_security_group_id  = aws_security_group.tasks.id
  execution_role_arn       = data.aws_iam_role.lab.arn
  db_instance_class        = var.db_instance_class
  db_multi_az              = var.db_multi_az
  db_backup_retention_days = var.db_backup_retention_days
  db_deletion_protection   = var.db_deletion_protection
  redis_node_type          = var.redis_node_type
  log_retention_days       = var.log_retention_days
  init_sql                 = file("${path.root}/../../init-db.sql")
}

# ── Servicios ────────────────────────────────────────────────────────────────

locals {
  db_password = "${module.data.db_password_secret_arn}:password::"
  admin_arn   = data.aws_secretsmanager_secret.admin.arn

  services = {
    ui = {
      listener = aws_lb_listener.public["80"].arn
      priority = 10
      paths    = ["/*"]
      env = {
        RETAIL_UI_ENDPOINTS_CATALOG  = local.internal
        RETAIL_UI_ENDPOINTS_CARTS    = local.internal
        RETAIL_UI_ENDPOINTS_CHECKOUT = local.internal
        RETAIL_UI_ENDPOINTS_ORDERS   = local.internal
      }
      secrets = {}
    }

    admin = {
      listener = aws_lb_listener.public["8081"].arn
      priority = 10
      paths    = ["/*"]
      env = {
        DB_HOST = module.data.db_address
        DB_PORT = "5432"
        DB_USER = module.data.db_username
      }
      secrets = {
        DB_PASSWORD      = local.db_password
        ADMIN_USERNAME   = "${local.admin_arn}:ADMIN_USERNAME::"
        ADMIN_PASSWORD   = "${local.admin_arn}:ADMIN_PASSWORD::"
        ADMIN_JWT_SECRET = "${local.admin_arn}:ADMIN_JWT_SECRET::"
      }
    }

    catalog = {
      listener = aws_lb_listener.internal.arn
      priority = 10
      paths    = ["/catalog", "/catalog/*"]
      env = {
        GIN_MODE                            = "release"
        RETAIL_CATALOG_PERSISTENCE_PROVIDER = "postgres"
        RETAIL_CATALOG_PERSISTENCE_ENDPOINT = "${module.data.db_address}:5432"
        RETAIL_CATALOG_PERSISTENCE_DB_NAME  = "catalogdb"
        RETAIL_CATALOG_PERSISTENCE_USER     = module.data.db_username
      }
      secrets = {
        RETAIL_CATALOG_PERSISTENCE_PASSWORD = local.db_password
      }
    }

    carts = {
      listener = aws_lb_listener.internal.arn
      priority = 20
      paths    = ["/carts", "/carts/*"]
      env = {
        CART_PERSISTENCE_PROVIDER = "postgres"
        CART_POSTGRES_HOST        = module.data.db_address
        CART_POSTGRES_PORT        = "5432"
        CART_POSTGRES_DB          = "cartdb"
        CART_POSTGRES_USER        = module.data.db_username
        PORT                      = "8080"
      }
      secrets = {
        CART_POSTGRES_PASSWORD = local.db_password
      }
    }

    checkout = {
      listener = aws_lb_listener.internal.arn
      priority = 30
      paths    = ["/checkout", "/checkout/*"]
      env = {
        RETAIL_CHECKOUT_PERSISTENCE_PROVIDER  = "redis"
        RETAIL_CHECKOUT_PERSISTENCE_REDIS_URL = "redis://${module.data.redis_address}:6379"
        RETAIL_CHECKOUT_ENDPOINTS_ORDERS      = local.internal
      }
      secrets = {}
    }

    orders = {
      listener = aws_lb_listener.internal.arn
      priority = 40
      paths    = ["/orders", "/orders/*"]
      env = {
        GIN_MODE                           = "release"
        RETAIL_ORDERS_PERSISTENCE_ENDPOINT = "${module.data.db_address}:5432"
        RETAIL_ORDERS_PERSISTENCE_NAME     = "orders"
        RETAIL_ORDERS_PERSISTENCE_USERNAME = module.data.db_username
      }
      secrets = {
        RETAIL_ORDERS_PERSISTENCE_PASSWORD = local.db_password
      }
    }
  }
}

module "service" {
  source   = "../modules/ecs-service"
  for_each = local.services

  name               = each.key
  environment        = var.environment
  region             = var.region
  image              = "${local.registry}/tero-${each.key}:${var.image_tag}"
  cpu                = var.task_cpu
  memory             = var.task_memory
  desired_count      = var.desired_count
  cluster_id         = aws_ecs_cluster.this.id
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids
  security_group_id  = aws_security_group.tasks.id
  execution_role_arn = data.aws_iam_role.lab.arn
  listener_arn       = each.value.listener
  listener_priority  = each.value.priority
  path_patterns      = each.value.paths
  log_retention_days = var.log_retention_days

  environment_variables = each.value.env
  secrets               = each.value.secrets

  depends_on = [terraform_data.workspace_guard]
}
