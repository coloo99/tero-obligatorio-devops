# Etapa 1: instalar dependencias exactas (yarn.lock) con el Yarn incluido en el repo y compilar
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/releases ./.yarn/releases
RUN node .yarn/releases/yarn-4.11.0.cjs install --immutable
COPY tsconfig.json tsconfig.build.json nest-cli.json ./
COPY src ./src
RUN node .yarn/releases/yarn-4.11.0.cjs build \
 && node .yarn/releases/yarn-4.11.0.cjs workspaces focus --production

# Etapa 2: imagen final con solo dependencias de producción, usuario no-root
FROM node:22-alpine
ENV NODE_ENV=production PORT=8080
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./
USER node
EXPOSE 8080
CMD ["node", "dist/main.js"]
