# Etapa 1: instalar dependencias exactas (package-lock.json) y compilar TypeScript.
# --ignore-scripts: ningún paquete necesita scripts de instalación y así no se ejecuta código de terceros al instalar.
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts
COPY tsconfig.json ./
COPY src ./src
RUN npm run build && npm prune --omit=dev

# Etapa 2: imagen final con solo lo necesario para ejecutar, usuario no-root
FROM node:22-alpine
# Sin npm, npx, yarn ni corepack: la app no los usa al ejecutar y traen dependencias con CVE
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/corepack /opt/yarn-* \
 && rm -f /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack /usr/local/bin/yarn /usr/local/bin/yarnpkg
ENV NODE_ENV=production PORT=8080
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY public ./public
COPY package.json ./
USER node
EXPOSE 8080
CMD ["node", "dist/app.js"]
