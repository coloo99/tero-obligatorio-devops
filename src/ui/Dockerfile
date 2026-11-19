# Etapa 1: instalar dependencias exactas (package-lock.json) y compilar TypeScript
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
RUN npm run build && npm prune --omit=dev

# Etapa 2: imagen final con solo lo necesario para ejecutar, usuario no-root
FROM node:22-alpine
ENV NODE_ENV=production PORT=8080
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY public ./public
COPY package.json ./
USER node
EXPOSE 8080
CMD ["node", "dist/app.js"]
