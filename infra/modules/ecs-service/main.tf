# Un microservicio de Tero en ECS Fargate: su grupo de logs, la definición de la
# tarea, el target group, la regla del balanceador que le manda tráfico y el
# servicio de ECS. El ambiente llama a este módulo una vez por cada servicio.

resource "aws_cloudwatch_log_group" "this" {
  name              = "/tero/${var.environment}/${var.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_ecs_task_definition" "this" {
  family                   = "tero-${var.environment}-${var.name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn

  container_definitions = jsonencode([{
    name      = var.name
    image     = var.image
    essential = true

    portMappings = [{
      containerPort = var.container_port
      protocol      = "tcp"
    }]

    environment = [for k, v in var.environment_variables : { name = k, value = v }]
    secrets     = [for k, v in var.secrets : { name = k, valueFrom = v }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = var.region
        awslogs-stream-prefix = var.name
      }
    }
  }])
}

resource "aws_lb_target_group" "this" {
  name        = "tero-${var.environment}-${var.name}"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  deregistration_delay = 30

  health_check {
    path                = "/health"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = var.path_patterns
    }
  }
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.name
    container_port   = var.container_port
  }

  # Si una versión nueva no levanta, ECS vuelve sola a la anterior.
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # El target group tiene que estar conectado al balanceador antes de crear el servicio.
  depends_on = [aws_lb_listener_rule.this]
}
