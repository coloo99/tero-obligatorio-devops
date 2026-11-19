# Decisiones y notas para ADRs

Anotar acá cada decisión en el momento en que se toma. En la Fase 7 cada una se pasa a un ADR en docs/adr/.

| Fecha | Decisión | Alternativas descartadas | Por qué |
| --- | --- | --- | --- |
| 18/11/2026 | Repositorio público en GitHub | Repo privado | En cuentas gratuitas, branch protection y aprobaciones de Environments solo están en repos públicos; SonarCloud es gratis solo para repos públicos. Antes del primer commit se quitaron todas las credenciales. |
| 18/11/2026 | Repositorio nuevo sin el historial original | Importar con historial | El historial original contiene contraseñas; aunque se borren, seguirían en commits viejos. |
