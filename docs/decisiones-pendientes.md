# Decisiones y notas para ADRs

Anotar acá cada decisión en el momento en que se toma. En la Fase 7 cada una se pasa a un ADR en docs/adr/.

| Fecha | Decisión | Alternativas descartadas | Por qué |
| --- | --- | --- | --- |
| 18/11/2026 | Repositorio público en GitHub | Repo privado | En cuentas gratuitas, branch protection y aprobaciones de Environments solo están en repos públicos; SonarCloud es gratis solo para repos públicos. Estas herramientas las utilizamos en los LAB de la materia. Antes del primer commit se quitaron todas las credenciales. |
| 18/11/2026 | Repositorio nuevo sin el historial original | Importar con historial | El historial original contiene contraseñas; aunque se borren, seguirían en commits viejos. |
| 19/11/2026 | Revisión de PRs con una segunda cuenta de GitHub | Formar grupo; mergear sin revisión | Trabajo individual; el docente autorizó por mail (18/11) aprobar desde una cuenta secundaria. |
| 19/11/2026 | Un workspace de Terraform por ambiente (dev, test, prod) | Un archivo de backend por ambiente | Visto en el lab de estado remoto y workspaces (T05); mismo bucket S3, un estado por ambiente |
| 19/11/2026 | ALB interno con reglas por path para la comunicación entre servicios | ECS Service Connect | Usa ALB y target groups como en el lab de ECS (T06) y no requiere cambios en el código |
| 19/11/2026 | Redis en ElastiCache | Redis como contenedor en ECS | Servicio gestionado de Redis, como RDS (T04) lo es de PostgreSQL; el contenedor necesitaría descubrimiento de servicios, que no se vio en el curso |
| 19/11/2026 | Escaneo de IaC con Trivy (modo config) | Checkov, tfsec | Escaneo de IaC visto en T09; es la misma herramienta que ya se usa para dependencias e imágenes |