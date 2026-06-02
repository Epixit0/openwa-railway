# OpenWA en Railway — qué hacer tú (solo esto)

## Por qué perdiste la sesión al crear el volumen

Al montar el volumen **por primera vez** en ese deploy, Railway montó un disco **vacío** en `/app/data`.  
La sesión anterior estaba en el disco **temporal** del contenedor y se borró.

**Solución:** variables correctas + escanear QR **una última vez**. Los siguientes deploys no deberían pedir QR.

---

## Paso 1 — Variables en Railway

1. Servicio **openwa-railway** → **Variables** → **RAW Editor**
2. Borra todo y pega el contenido de **`.env.railway`**
3. Cambia `API_MASTER_KEY` si no quieres `dev-admin-key`
4. **Elimina** `DATABASE_URL` si aparece (plugin Postgres rompe SQLite)
5. Guarda

## Paso 2 — Volumen (ya lo tienes)

- Nombre: `openwa-data`
- Mount: `/app/data`
- No lo borres nunca

## Paso 3 — Push y redeploy

Sube estos cambios del repo OpenWA a GitHub y deja que Railway redeploye.

## Dashboard web (UI)

Después de desplegar el código con dashboard integrado:

- **UI:** `https://openwa-railway-production.up.railway.app/dashboard/`
- **API docs:** `https://openwa-railway-production.up.railway.app/api/docs`

Login del dashboard: tu `API_MASTER_KEY` (ej. `dev-admin-key`).

## Paso 4 — Una vez después del deploy

1. Abre `https://TU-URL/dashboard/` (o el dashboard local si aún no desplegaste)
2. **Start** en tu sesión (o espera ~1 min si `SESSION_AUTO_START=true`)
3. Si pide QR → escanéalo **esta última vez**
4. Copia el **ID** de la sesión (UUID) a Vercel: `OPENWA_SESSION_ID=...`

## Paso 5 — Webhook (una vez)

Desde tu PC:

```bash
cd ~/work/Odontologia
export OPENWA_API_URL=https://openwa-railway-production.up.railway.app
export OPENWA_API_KEY=dev-admin-key
export OPENWA_SESSION_ID=tu-uuid-de-sesion
./scripts/openwa-webhook.sh
```

---

## Comprobar que persiste

1. Railway → **Redeploy**
2. Espera 2 minutos
3. La sesión debe volver a **READY** sin QR
4. Si pide QR otra vez → revisa Variables (paths `/app/data/...`) y que el volumen siga montado
