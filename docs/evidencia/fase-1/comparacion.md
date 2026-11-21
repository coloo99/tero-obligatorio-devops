# Comparación de imágenes: antes y después de la Fase 1

Fuente: `docs/evidencia/antes/antes-imagenes.txt`, `docs/evidencia/fase-1/despues-imagenes.txt` y `docs/evidencia/fase-1/despues-usuarios.txt` (salida de `docker image ls` y `docker image inspect`). Fecha de medición: 21/11/2026.

| Servicio | Base antes | Base después | Tamaño antes | Tamaño después | Reducción | Usuario antes | Usuario después |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ui | node:22 | node:22-alpine | 1,72 GB | 249 MB | 85,5 % | root | node |
| catalog | golang:1.24 | distroless/static | 2,26 GB | 38,5 MB | 98,3 % | root | nonroot |
| carts | python:3.12 | python:3.12-slim | 1,71 GB | 261 MB | 84,7 % | root | 10001 |
| checkout | node:22 | node:22-alpine | 2,03 GB | 329 MB | 83,8 % | root | node |
| orders | golang:1.24 | distroless/static | 2,03 GB | 28,2 MB | 98,6 % | root | nonroot |
| admin | node:22 | node:22-alpine | 1,73 GB | 247 MB | 85,7 % | root | node |
| **Total** | | | **11,48 GB** | **1,15 GB** | **90,0 %** | | |

Tamaño = columna DISK USAGE de `docker image ls` (espacio en disco de la imagen descomprimida). El tamaño comprimido, que es lo que se descarga desde el registry, bajó en la misma proporción: de 2,83 GB a 276 MB en total (90,3 %).

## Conclusión

Las seis imágenes pasaron de una sola etapa sobre la imagen base completa, ejecutándose como root, a builds multi-stage con base mínima y usuario sin privilegios. En total ocupan un 90 % menos. Los servicios en Go son los que más bajaron (más del 98 %): su binario es estático y no necesita sistema operativo, así que la imagen final solo contiene el ejecutable. Los servicios en Node y Python bajaron entre 84 % y 86 % porque necesitan su runtime, pero ya no incluyen compiladores, dependencias de desarrollo ni el sistema operativo completo.

Esto cierra la observación 2 del auditor. Imágenes más chicas se descargan y despliegan más rápido y tienen menos paquetes que puedan tener vulnerabilidades. Además, ningún proceso corre como root: si alguien comprometiera un contenedor, no tendría privilegios de administrador dentro de él.
