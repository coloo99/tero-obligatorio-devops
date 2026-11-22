# Informe de calidad

Análisis estático del código de Tero con SonarCloud (quality gate "Sonar way"). El análisis corre en el pipeline de CI en cada Pull Request y en cada push a `main`; el job falla si el quality gate no pasa.

## Resultados de SonarCloud

| Métrica | Inicial (21/11/2026) | Final |
| --- | --- | --- |
| Quality gate (Sonar way) | No calculado (primer análisis) | |
| Seguridad | 10 issues · nota C | |
| Confiabilidad (bugs) | 31 issues · nota C | |
| Mantenibilidad (code smells) | 6 issues · nota A | |
| Security Hotspots | 0 | |
| Duplicación | 0,0 % | |
| Cobertura | Sin datos (no hay tests unitarios) | |
| Riesgos de dependencias | 153 · nota D | |
| Líneas de código | 3,7 mil | |

Evidencia: `docs/evidencia/fase-2/03-sonar-inicial.png` y `docs/evidencia/fase-2/04-sonar-inicial-detalle.png`.

Nota: la página Overview muestra 41 issues y la suma de las tres categorías da 47, porque un mismo issue puede afectar a más de una categoría (por ejemplo, seguridad y confiabilidad).

## Primer análisis desde el pipeline (PR #44, 22/11/2026)

Quality gate: **no aprobado**. Una condición falló: la nota de seguridad del código nuevo es C y el gate exige A. Sobre 169 líneas nuevas hubo 7 issues nuevos, 0 security hotspots, 0,0 % de duplicación y 7 riesgos de dependencias.

## Umbrales del quality gate

Se usa el quality gate "Sonar way" sobre el código nuevo: notas A en seguridad, confiabilidad y mantenibilidad, todos los security hotspots revisados y duplicación de 3 % o menos.

La cobertura no se evalúa porque Tero no tiene tests unitarios (`sonar.coverage.exclusions=**/*`). La calidad funcional se cubre con los tests de integración de Newman, que recorren el flujo de compra completo en cada corrida del pipeline.

## Hallazgos importantes

<!-- Completar en el paso 2.6 con los issues más relevantes y qué se hizo con cada uno. -->

| Hallazgo | Servicio | Severidad | Acción |
| --- | --- | --- | --- |
| Descarga con curl que sigue redirecciones sin exigir HTTPS (`ci.yml`, instalación de Gitleaks) | Pipeline | Seguridad · media | Se fuerza HTTPS y TLS 1.2 (`--proto '=https' --tlsv1.2`) y que falle ante errores HTTP (`-f`) |
| `pip install semgrep` sin versión fija y permitiendo paquetes fuente con scripts de instalación (`ci.yml`) | Pipeline | Seguridad · media (2 issues) | Versión fija `semgrep==1.186.0` e instalación solo desde paquetes binarios (`--only-binary=:all:`) |
| `npx` instala paquetes en el momento y ejecuta sus scripts de instalación (`ci.yml`, tests de Newman) | Pipeline | Seguridad · media | Newman se instala en un paso aparte con versión fija `6.2.3` y `--ignore-scripts` |

## Interpretación y recomendaciones

<!-- Completar en el paso 2.6: un párrafo que explique qué mostraron los resultados y qué se recomienda a Tero. -->
