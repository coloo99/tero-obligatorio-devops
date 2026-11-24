import express from 'express';
import path from 'path';
import { createProxyMiddleware } from 'http-proxy-middleware';

const app = express();

// No anunciar "X-Powered-By: Express": no dar pistas de versión a un atacante.
app.disable('x-powered-by');

// Las direcciones de los servicios internos se leen solo de variables de entorno
// (docker-compose en local, definición de la tarea en ECS). Sin valor por defecto:
// si falta alguna, el servicio no arranca.
function requiredEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    console.error(`Falta la variable de entorno obligatoria ${name}`);
    process.exit(1);
  }
  return value;
}

const CATALOG_URL  = requiredEnv('RETAIL_UI_ENDPOINTS_CATALOG');
const CARTS_URL    = requiredEnv('RETAIL_UI_ENDPOINTS_CARTS');
const CHECKOUT_URL = requiredEnv('RETAIL_UI_ENDPOINTS_CHECKOUT');
const ORDERS_URL   = requiredEnv('RETAIL_UI_ENDPOINTS_ORDERS');

// Express strips the mount path before the proxy sees it.
// pathRewrite re-adds the service prefix, stripping trailing slash on bare paths.
const rewrite = (prefix: string) => (p: string) => prefix + (p === '/' ? '' : p);

app.use('/api/catalog',  createProxyMiddleware({ target: CATALOG_URL,  changeOrigin: true, pathRewrite: rewrite('/catalog') }));
app.use('/api/carts',    createProxyMiddleware({ target: CARTS_URL,    changeOrigin: true, pathRewrite: rewrite('/carts') }));
app.use('/api/checkout', createProxyMiddleware({ target: CHECKOUT_URL, changeOrigin: true, pathRewrite: rewrite('/checkout') }));
app.use('/api/orders',   createProxyMiddleware({ target: ORDERS_URL,   changeOrigin: true, pathRewrite: rewrite('/orders') }));

app.use(express.static(path.join(__dirname, '../public')));

app.get('/health', (_req, res) => res.send('OK'));

const port = parseInt(process.env.PORT || '8080', 10);
app.listen(port, () => console.log(`UI listening on :${port}`));
