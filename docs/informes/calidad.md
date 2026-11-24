# Informe de calidad

Análisis estático del código de Tero con SonarCloud (quality gate "Sonar way"). El análisis corre en el pipeline de CI en cada Pull Request y en cada push a `main`; el job falla si el quality gate no pasa.

## Resultados de SonarCloud

| Métrica | Inicial (21/11/2026) | Final |
| --- | --- | --- |
| Quality gate (Sonar way) | No calculado (primer análisis) | Aprobado (main, 23/11/2026) |
| Seguridad | 10 issues · nota C | 10 issues · nota C |
| Confiabilidad (bugs) | 31 issues · nota C | 31 issues · nota C |
| Mantenibilidad (code smells) | 6 issues · nota A | 6 issues · nota A |
| Security Hotspots | 0 | 0 |
| Duplicación | 0,0 % | 0,0 % |
| Cobertura | Sin datos (no hay tests unitarios) | Sin datos (no hay tests unitarios) |
| Riesgos de dependencias | 153 · nota D | No figura en el resumen de main; las dependencias vulnerables se controlan con Trivy (ver seguridad.md) |
| Líneas de código | 3,7 mil | 3,2 mil |

Evidencia: inicial en `docs/evidencia/fase-2/03-sonar-inicial.png` y `04-sonar-inicial-detalle.png`; final en `10-sonar-final.png` (código nuevo) y `10b-sonar-final.png` (código total).

Nota: la página Overview muestra 41 issues y la suma de las tres categorías da 47, porque un mismo issue puede afectar a más de una categoría (por ejemplo, seguridad y confiabilidad).

## Primer análisis desde el pipeline (PR #44, 22/11/2026)

Quality gate: **no aprobado**. Una condición falló: la nota de seguridad del código nuevo es C y el gate exige A. Sobre 169 líneas nuevas hubo 7 issues nuevos, 0 security hotspots, 0,0 % de duplicación y 7 riesgos de dependencias.

## Umbrales del quality gate

Se usa el quality gate "Sonar way" sobre el código nuevo: notas A en seguridad, confiabilidad y mantenibilidad, todos los security hotspots revisados y duplicación de 3 % o menos.

La cobertura no se evalúa porque Tero no tiene tests unitarios (`sonar.coverage.exclusions=**/*`). La calidad funcional se cubre con los tests de integración de Newman, que recorren el flujo de compra completo en cada corrida del pipeline.

## Hallazgos importantes


| Hallazgo | Servicio | Severidad | Acción |
| --- | --- | --- | --- |
| Descarga con curl que sigue redirecciones sin exigir HTTPS (`ci.yml`, instalación de Gitleaks) | Pipeline | Seguridad · media | Se fuerza HTTPS y TLS 1.2 (`--proto '=https' --tlsv1.2`) y que falle ante errores HTTP (`-f`) |
| `pip install semgrep` sin versión fija y permitiendo paquetes fuente con scripts de instalación (`ci.yml`) | Pipeline | Seguridad · media (2 issues) | Versión fija `semgrep==1.186.0` e instalación solo desde paquetes binarios (`--only-binary=:all:`) |
| `npx` instala paquetes en el momento y ejecuta sus scripts de instalación (`ci.yml`, tests de Newman) | Pipeline | Seguridad · media | Newman se instala en un paso aparte con versión fija `6.2.3` y `--ignore-scripts` |

## Interpretación y recomendaciones

El quality gate aprobó en el PR #44 y en `main`: el código nuevo de la Fase 2 tiene 0 issues, 0,0 % de duplicación y nota A en seguridad. El gate de "Sonar way" evalúa solo el código nuevo, así que no se puede empeorar lo que ya existe.

Los números del código total no cambiaron (10 issues de seguridad, 31 de confiabilidad y 6 de mantenibilidad): son problemas heredados del código original de Tero y de los Dockerfiles, que esta fase no tenía como objetivo. Las líneas bajaron de 3,7 mil a 3,2 mil porque dejaron de analizarse archivos de terceros.

Recomendaciones para Tero: corregir primero los 10 issues de seguridad, empezando por los de los Dockerfiles (instalaciones de npm y pip que permiten ejecutar scripts), y después los 31 de confiabilidad; mantener el gate sobre código nuevo para que la deuda no crezca; y agregar tests unitarios para poder medir cobertura.
