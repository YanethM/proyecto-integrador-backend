# Despliegue en Render — Grupo 2

Este repositorio expone `POST /auth/registro` y `GET /health`. Login y emisión de JWT todavía no están implementados en este proyecto. La base de Supabase y el servicio de Render son independientes de los del grupo 1.

## 1. Preparar la base de datos

Usar la conexión del proyecto de Supabase del grupo 2. El backend requiere la tabla `grupo_2.usuarios` sin el campo `equipo`.

Si la base ya está configurada, no volver a ejecutar los scripts. Para una base nueva, aplicar en el SQL Editor, en este orden:

1. `supabase/sql/20261023_grupo_2.sql`.
2. `supabase/sql/20261023_remove_usuario_equipo.sql`.

El primer script crea las tablas de negocio de `saga_up` y la tabla de autenticación. El segundo elimina el campo `equipo` de usuarios. La API solo expone registro, aunque existan otras tablas en la base.

Copiar las conexiones desde **Connect** en Supabase: Transaction pooler para `DATABASE_URL` y Session pooler para `DIRECT_URL`. Reemplazar el marcador de contraseña. Los caracteres especiales de la contraseña deben codificarse para su uso en una URL.

## 2. Preparar el repositorio

Subir a GitHub los archivos del proyecto, incluyendo `render.yaml`, `.node-version`, `tsconfig.build.json` y `package-lock.json`. No subir `.env`, `node_modules`, `generated` ni `dist`.

Para comprobar localmente:

```bash
npm ci --include=dev
npm run test:integration
npm run typecheck
```

La prueba de integración requiere Docker activo: crea PostgreSQL temporal, verifica registro y CORS, y arranca el código compilado en modo producción. No modifica Supabase.

## 3. Crear el servicio en Render

1. Seleccionar **New → Blueprint**.
2. Conectar el repositorio del grupo 2 y la rama con estos archivos.
3. Revisar el servicio `proyecto-integrador-backend-g2` y el plan propuesto `free` antes de confirmar.
4. Completar las variables solicitadas:
   - `DATABASE_URL`: conexión Transaction pooler del grupo 2.
   - `DIRECT_URL`: conexión Session pooler del mismo proyecto.
   - `CORS_ORIGINS`: orígenes exactos de los frontends autorizados, separados por comas.
5. Crear el servicio y revisar los logs de compilación y arranque.

`render.yaml` configura `NODE_ENV=production`, `HOST=0.0.0.0` y `TRUST_PROXY_HOPS=1`. El servidor lee `PORT` de Render; no copiar el puerto local a Render. No se necesita `JWT_SECRET` mientras este backend solo implemente registro.

El build ejecuta `npm ci --include=dev && npm run build`; genera Prisma y compila TypeScript. El arranque ejecuta `npm start`, que utiliza `dist/src/server.js`. No ejecuta SQL ni migraciones durante el despliegue.

Las variables marcadas `sync: false` se solicitan al crear el Blueprint. Para cambiarlas después, entrar en **Environment** del servicio. Referencias: [Blueprints](https://render.com/docs/blueprint-spec) y [Web Services](https://render.com/docs/web-services).

Como alternativa, crear **New → Web Service** con runtime Node, Root Directory vacío si el proyecto está en la raíz del repositorio, los mismos comandos y variables, y Health Check Path `/health`. No crear otra base de datos en Render.

## 4. Autorizar los frontends

Ejemplo de `CORS_ORIGINS`:

```dotenv
CORS_ORIGINS=https://equipo1.example.com,https://equipo2.example.com,http://localhost:5173
```

Reemplazar los dominios por los reales, sin rutas ni barra final. No usar `*`. Cada equipo comunica el origen de su frontend al responsable del servicio. Para desarrollo local, agregar también `CORS_ORIGINS` al `.env`; los ejemplos están en `.env.example`.

El servidor permite preflight `OPTIONS`. Un origen no autorizado recibe `403`. CORS controla el acceso desde navegadores; no bloquea clientes sin cabecera `Origin` ni sustituye autenticación.

## 5. Comprobar el servicio desplegado

Usar la URL real asignada por Render:

```bash
curl -i https://NOMBRE-REAL.onrender.com/health
```

Se espera `200` con `{"status":"ok"}`. Si PostgreSQL no está disponible, devuelve `503`.

Para registrar un usuario de prueba, usar un correo nuevo; esta petición crea un registro real:

```bash
curl -i https://NOMBRE-REAL.onrender.com/auth/registro \
  -H 'Content-Type: application/json' \
  -d '{"nombre":"Ana Peña","correo":"prueba-render@example.com","clave":"ClavePruebaRender123!"}'
```

Se espera `201`, con `id`, `nombre`, `correo` y `creadoEn`, sin contraseña. Un correo repetido devuelve `409`. La contraseña requiere al menos 12 caracteres y como máximo 72 bytes UTF-8. No enviar `equipo` ni campos adicionales.

Verificar también el registro desde cada frontend autorizado. Si recibe `403`, revisar `CORS_ORIGINS`. Si el servicio no arranca, revisar conexión, credenciales y existencia de `grupo_2.usuarios` en los logs.

El límite de registro es de 20 intentos por IP en 15 minutos. `TRUST_PROXY_HOPS=1` supone un proxy delante de Express; comprobar el comportamiento por IP en Render. Si se añade un CDN u otro proxy, ajustar según la cadena real. El contador reside en memoria: se reinicia con el proceso y no se comparte entre instancias.

## 6. Qué compartir con los equipos

Compartir la URL pública HTTPS del servicio y el contrato [postman/openapi.json](postman/openapi.json). Los equipos llaman a `POST /auth/registro` con `nombre`, `correo` y `clave`.

```js
const respuesta = await fetch(`${apiUrl}/auth/registro`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ nombre, correo, clave }),
});
const resultado = await respuesta.json();
if (!respuesta.ok) throw new Error(resultado.error);
```

La URL pública puede configurarse como `VITE_API_URL` o `NEXT_PUBLIC_API_URL`. No compartir `DATABASE_URL`, `DIRECT_URL` ni la contraseña de PostgreSQL con los frontends. Las bases de negocio de los equipos se administran por separado.

`POST /auth/login` y `GET /auth/perfil` no existen en esta versión: no anunciar esos endpoints hasta implementarlos y probarlos.
