# Bitácora del proyecto

Una fila por sesión de trabajo. De acá salen las lecciones aprendidas y la sección de uso de IA de la entrega.

| Fecha | Fase | Qué se hizo | Problema encontrado y cómo se resolvió | Uso de IA (herramienta y para qué) |
| --- | --- | --- | --- | --- |
| 17/11/2026 | 0 | Análisis de la letra y del repo; Tero levantado local con docker compose | — | Claude: análisis de la letra, plan de trabajo y revisión del código de Tero |
| 18/11/2026 | 0 | Instalación de Docker Desktop y del resto de las herramientas; Tero copiado a C:\devops sin historial; archivos sin credenciales aplicados | Docker no se instalaba desde la Microsoft Store (error 0x00000001): se instaló con el instalador oficial y WSL 2. El Escritorio está en OneDrive y fallaba guardar en $HOME\Desktop. Los archivos antes-*.txt no estaban en la carpeta del proyecto: se buscaron y copiaron | Claude: guía de la fase 0, script de verificación de herramientas y consultas puntuales de comandos |
| 19/11/2026 | 0 | Verificación sin credenciales con Gitleaks; .env con claves nuevas y prueba local; evidencia del "antes" ordenada; repo público tero-obligatorio-devops; cuenta revisora; tablero Kanban con 42 tareas y captura de inicio | versiones.txt no se había guardado: se regeneró directo en la carpeta de evidencia con las versiones que instalé. Se revisó que la letra no prohíbe un repo público | Claude: comparación del plan que armé con el contenido del curso para alinear herramientas a utilizar (workspaces, ALB interno, Trivy IaC) y consultas puntuales |