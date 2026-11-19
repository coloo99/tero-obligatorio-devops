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
| 19/11/2026 | Imagen final de Go (catalog, orders): distroless/static con usuario nonroot | alpine; imagen golang completa | El binario de Go es estático y no necesita nada más: sin shell ni gestor de paquetes la imagen es mínima y casi no tiene superficie de ataque. Contra: no se puede entrar al contenedor a diagnosticar |
| 19/11/2026 | Imagen final de Python (carts): python:3.12-slim con usuario 10001 | python completa; alpine | slim es mucho más chica que la completa y, a diferencia de alpine, es compatible con los paquetes ya compilados (psycopg2-binary, uvicorn) sin tener que compilar nada |
| 19/11/2026 | Imagen final de Node (ui, admin, checkout): node:22-alpine con usuario node | node completa; distroless de Node | alpine es liviana y deja una shell para diagnosticar dentro del contenedor, a cambio de una imagen un poco más grande que distroless. La imagen oficial ya trae el usuario node sin privilegios |
| 19/11/2026 | Builds en dos etapas (multi-stage) en los 6 servicios | Una sola etapa | La etapa de build tiene compiladores y dependencias de desarrollo; la imagen final solo lleva lo necesario para ejecutar. Visto en T06 (buenas prácticas de imágenes) |