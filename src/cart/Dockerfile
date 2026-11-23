# Etapa 1: instalar dependencias en un entorno virtual
FROM python:3.12-alpine AS build
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Etapa 2: imagen final con solo el entorno virtual y el código, usuario no-root.
# Alpine en lugar de Debian slim: menos paquetes del sistema y menos CVE sin parche.
FROM python:3.12-alpine
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080
RUN apk upgrade --no-cache && adduser -D -H -u 10001 appuser
WORKDIR /app
COPY --from=build /opt/venv /opt/venv
COPY app ./app
USER 10001
EXPOSE 8080
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]
