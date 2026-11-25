# Recursos compartidos por los tres ambientes. No se destruyen al final del día:
# guardan las imágenes y los secretos del admin, y cuestan casi nada.

# Un repositorio de imágenes por servicio. Los tags son el SHA corto del commit,
# así que no se pueden pisar (IMMUTABLE) y cada imagen se escanea al subirla.
resource "aws_ecr_repository" "service" {
  for_each = toset(var.services)

  name                 = "tero-${each.key}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Se guardan solo las últimas 20 imágenes de cada servicio.
resource "aws_ecr_lifecycle_policy" "service" {
  for_each = aws_ecr_repository.service

  repository = each.value.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Conservar las ultimas 20 imagenes"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 20
      }
      action = { type = "expire" }
    }]
  })
}

# Credenciales del panel de administración, una por ambiente.
# Terraform crea el secreto vacío: el valor se carga con la CLI (Paso 3.7)
# y nunca pasa por el código ni por el estado.
resource "aws_secretsmanager_secret" "admin" {
  for_each = toset(var.environments)

  name                    = "tero/${each.key}/admin"
  description             = "ADMIN_USERNAME, ADMIN_PASSWORD y ADMIN_JWT_SECRET del admin de Tero (${each.key})"
  recovery_window_in_days = 7
}
