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

## Tercera corrida (22/11/2026): primer escaneo de Trivy

Corrida #3 del PR #44, ya con las actions corregidas. Gitleaks, Semgrep, SonarCloud y Newman pasan. Trivy (modo fs y modo imagen) encuentra vulnerabilidades CRITICAL y HIGH en todos los servicios: 159 combinaciones de paquete, CVE y servicio. Se agrupan por paquete; el detalle completo queda en los logs de la corrida.

| Fecha | Herramienta | Hallazgo (CVE o regla) | Severidad | Servicio | Acción | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| 22/11/2026 | Trivy fs e imagen | Biblioteca estándar de Go 1.24 (`stdlib`): 23 CVE, entre ellos CVE-2026-25679 y CVE-2026-33818 | CRITICAL/HIGH | catalog, orders | Compilar con Go 1.27 (`golang:1.27-alpine`), que trae la biblioteca estándar parchada | En curso |
| 22/11/2026 | Trivy fs e imagen | Módulos de Go: `pgx/v5` (CVE-2026-33815, CRITICAL), `grpc` (CVE-2026-33186, CRITICAL), `x/crypto`, `x/net`, `x/text`, `otel`, `otel/sdk`, `klauspost/compress` | CRITICAL/HIGH | catalog, orders | Actualizar los módulos a la última versión compatible (`go get -u` y `go mod tidy`) | En curso |
| 22/11/2026 | Trivy fs e imagen | Dependencias de NestJS: `proxy-addr` (CVE-2026-90711, CRITICAL), `body-parser`, `multer` (8 CVE), `path-to-regexp`, `lodash`, `js-yaml`, `glob`, `minimatch`, `brace-expansion` | CRITICAL/HIGH | checkout | NestJS a la última 11.x y dependencias transitivas a versiones parchadas en `yarn.lock` (`yarn up` y `yarn up -R`). Se descartó NestJS 12 por ser un cambio de versión mayor | En curso |
| 22/11/2026 | Trivy imagen | npm incluido en `node:22-alpine`: `brace-expansion`, `ip-address`, `pacote`, `picomatch` (CVE-2026-33671), `sigstore` | HIGH | ui, admin, checkout | La imagen final no necesita npm, npx, yarn ni corepack para ejecutar la app: se borran en el Dockerfile | En curso |
| 22/11/2026 | Trivy imagen | `starlette` 0.38.6 (CVE-2024-47874 y 2 más) | HIGH | carts | FastAPI 0.165.0 (con Starlette 1.10) y resto de dependencias actualizadas en `requirements.txt`; probado con el flujo del carrito | En curso |
| 22/11/2026 | Trivy imagen | Paquetes de Debian 13 de `python:3.12-slim`: `util-linux` y sus bibliotecas, `ncurses`, `sqlite`, `openssl`, `systemd`, `perl`, `acl`, `zlib` (13 CVE, casi todos sin parche publicado) | HIGH | carts | Cambio de imagen base a `python:3.12-alpine` (igual que los servicios Node y Go) con `apk upgrade`: la imagen no incluye esos paquetes y no hace falta justificar CVE sin parche | En curso |
