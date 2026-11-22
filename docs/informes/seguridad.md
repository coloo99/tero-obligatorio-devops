# Informe de seguridad

Registro de los hallazgos de las herramientas del pipeline de CI (Gitleaks, Semgrep, Trivy) y de los problemas de seguridad del propio pipeline. Cada hallazgo se corrige o se justifica por escrito; ninguno se ignora sin registro.

## Primera corrida (22/11/2026)

Corrida 44976990801 del PR #44. Resultado por job:

| Job | Herramienta | Resultado |
| --- | --- | --- |
| secretos | Gitleaks 8.21.2 | Falló: 2 hallazgos |
| sast | Semgrep (p/default, ERROR) | Pasó: sin hallazgos |
| sca | Trivy fs | No llegó a escanear: la action no existe en la versión indicada |
| calidad | SonarCloud | Falló: quality gate no aprobado |
| test | docker compose + Newman | Pasó |
| imagenes (6) | docker build + Trivy image | No llegaron a escanear: misma causa que sca |

## Hallazgos

| Fecha | Herramienta | Hallazgo (CVE o regla) | Severidad | Servicio | Acción | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| 22/11/2026 | Gitleaks | generic-api-key en `sonar-project.properties`, línea 3 | Falso positivo | Configuración | Es `sonar.projectKey`, el identificador público del proyecto, no una credencial. Excepción por fingerprint en `.gitleaksignore` | En curso |
| 22/11/2026 | Gitleaks | generic-api-key en `src/checkout/.yarn/releases/yarn-4.11.0.cjs`, línea 583 | Falso positivo | checkout | Clave pública de búsqueda (Algolia) incluida en el binario oficial de Yarn; código de terceros. Excepción por fingerprint en `.gitleaksignore` | En curso |
| 22/11/2026 | GitHub Actions | `aquasecurity/trivy-action@0.28.0` no se puede resolver: los tags viejos se eliminaron tras el ataque de cadena de suministro de marzo de 2026 (CVE-2026-33634) | Alta | Pipeline | Actualizar a v0.36.0 fijada por SHA de commit, para que un tag reescrito no cambie el código que corre | En curso |
| 22/11/2026 | GitHub Actions | `SonarSource/sonarqube-scan-action@v5` sin soporte y con una vulnerabilidad avisada por el propio job | Media | Pipeline | Actualizar a v8.5.0 fijada por SHA de commit | En curso |

Los hallazgos de Trivy (fs e imágenes) se agregan cuando corran por primera vez con la action corregida.
