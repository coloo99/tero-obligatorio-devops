# Informe de calidad

Análisis estático del código de Tero con SonarCloud (quality gate "Sonar way"). El análisis corre en el pipeline de CI en cada Pull Request y en cada push a `main`; el job falla si el quality gate no pasa.

## Resultados de SonarCloud

| Métrica | Inicial (21/11/2026) | Final |
| --- | --- | --- |
| Quality gate (Sonar way) | No calculado (primer análisis) | Aprobado (main, 24/11/2026) |
| Seguridad | 10 issues · nota C | 0 issues · nota A (corregidos en el PR #46) |
| Confiabilidad (bugs) | 31 issues · nota C | 31 issues · nota C |
| Mantenibilidad (code smells) | 6 issues · nota A | 6 issues · nota A |
| Security Hotspots | 0 | 0 |
| Duplicación | 0,0 % | 0,0 % |
| Cobertura | Sin datos (no hay tests unitarios) | Sin datos (no hay tests unitarios) |
| Riesgos de dependencias | 153 · nota D | No figura en el resumen de main; las dependencias vulnerables se controlan con Trivy (ver seguridad.md) |
| Líneas de código | 3,7 mil | 3,2 mil |

Evidencia: inicial en `docs/evidencia/fase-2/03-sonar-inicial.png` y `04-sonar-inicial-detalle.png`; final en `10-sonar-final.png` (código nuevo) y `10b-sonar-final.png` (código total); corrección de seguridad en `docs/evidencia/fase-3/00-sonar-dockerfiles.png` y `00b` (antes, 10 abiertos) y `00c-sonar-despues.png` y `00d` (después, los 10 en estado Fixed).

Nota: la página Overview mostraba 41 issues (31 después del PR #46) y la suma de las tres categorías daba 47, porque un mismo issue puede afectar a más de una categoría (por ejemplo, seguridad y confiabilidad).

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
| `npm ci` ejecuta los scripts de instalación de los paquetes (Dockerfiles de admin y ui) | admin, ui | Seguridad · media (2 issues) | `npm ci --ignore-scripts`; se verificó en `package-lock.json` que ningún paquete los necesita |
| pip puede compilar paquetes fuente (`setup.py`) y las dependencias no estaban fijadas con lock (Dockerfile de cart) | cart | Seguridad · media (2 issues) | `--only-binary=:all: --require-hashes`; `requirements.txt` pasa a ser un lock con las 23 dependencias, versión exacta y hash SHA-256, generado desde `requirements.in` |
| Express expone su versión en la cabecera `X-Powered-By` (`app.ts` de admin y ui) | admin, ui | Seguridad · baja (2 issues) | `app.disable('x-powered-by')` |
| URLs `http://` fijas como valor por defecto de los servicios internos (`ui/src/app.ts`) | ui | Seguridad · baja (4 issues) | Se quitan los valores por defecto: las URLs se leen solo de variables de entorno y, si falta una, el servicio no arranca. El tráfico es interno (red de Docker o VPC) y no sale a internet |

## Interpretación y recomendaciones

El quality gate aprobó en el PR #44 y en `main`: el código nuevo de la Fase 2 tiene 0 issues, 0,0 % de duplicación y nota A en seguridad. El gate de "Sonar way" evalúa solo el código nuevo, así que no se puede empeorar lo que ya existe.

Al cierre de la Fase 2, los números del código total no habían cambiado (10 issues de seguridad, 31 de confiabilidad y 6 de mantenibilidad): son problemas heredados del código original de Tero y de los Dockerfiles, que esa fase no tenía como objetivo. Las líneas bajaron de 3,7 mil a 3,2 mil porque dejaron de analizarse archivos de terceros.

Los 10 issues de seguridad se corrigieron en el PR #46 (24/11/2026): seis estaban en los Dockerfiles y en el `app.ts` de admin y ui, y cuatro eran URLs `http://` en ui. Seguridad pasó a 0 issues y nota A, y el total bajó de 41 a 31. Se corrigieron en código, sin marcarlos como aceptados en SonarCloud.

Recomendaciones para Tero: corregir los 31 issues de confiabilidad; mantener el gate sobre código nuevo para que la deuda no crezca; y agregar tests unitarios para poder medir cobertura.
