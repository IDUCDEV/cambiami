# Cambiami · Supabase remoto

Runbook para llevar el backend local a un proyecto remoto. **Nada de esto se
ejecuta todavía**: el desarrollo sigue en local. Las claves reales no se
commitean; este documento solo describe dónde viven.

Referencias: `docs/DOMINIO.md`, ADR 0005 y ADR 0007.

---

## 1. Requisitos

- Supabase CLI 3.x (`supabase --version`).
- Un proyecto creado en el dashboard.
- Token personal de la CLI (Account → Access Tokens).

```bash
export SUPABASE_ACCESS_TOKEN=...        # no se guarda en el repo
export SUPABASE_PROJECT_REF=...         # el <ref> de la URL del dashboard
```

## 2. Vincular el proyecto

```bash
supabase login
supabase link --project-ref "$SUPABASE_PROJECT_REF"
```

`link` escribe `supabase/.temp/` (ignorado por git). No copia datos.

## 3. Esquema

```bash
supabase db push
```

Aplica `00001_rates.sql` y `00002_collector.sql`. Después, cargar el catálogo
(`currencies` y `sources`) desde el SQL editor con el contenido de
`supabase/seed.sql`. Es idempotente.

Verificar:

```sql
select code from public.currencies order by code;   -- EUR, USD, USDT
select code from public.sources order by code;      -- bcv, binance_p2p
```

## 4. Secreto de la Edge Function

Generar un secreto largo y aleatorio (no reutilizar la clave de servicio):

```bash
openssl rand -hex 32
supabase secrets set COLLECTOR_SECRET=<secreto>
```

La función lo lee de `Deno.env.get("COLLECTOR_SECRET")`. `SUPABASE_URL` y
`SUPABASE_SERVICE_ROLE_KEY` los inyecta la plataforma; no se configuran a mano.

## 5. Desplegar la función

```bash
supabase functions deploy collect-rates
```

`supabase/config.toml` ya declara `verify_jwt = false` para esta función: la
autorización la hace el secreto, porque `pg_net` no firma JWTs.

Probar sin escribir en la base (un 401 confirma que la función responde):

```bash
curl -i -X POST \
  "https://$SUPABASE_PROJECT_REF.supabase.co/functions/v1/collect-rates"
```

## 6. Programar el colector

Guardar la URL y el secreto en Vault. Ejecutar en el SQL editor **como
`postgres`**:

```sql
select vault.create_secret(
  'https://<ref>.supabase.co/functions/v1/collect-rates',
  'collector_url'
);
select vault.create_secret('<el-mismo-secreto-del-paso-4>', 'collector_secret');

select public.schedule_collector();
```

`schedule_collector()` es idempotente: desprograma los jobs con esos nombres y
los vuelve a crear. Programa:

| Job | Frecuencia | Qué hace |
|---|---|---|
| `collect-rates` | cada 30 min | `pg_net` llama a la función |
| `purge-old-data` | 03:00 UTC | retención de 90/30 días |

Verificar:

```sql
select jobname, schedule, active from cron.job order by jobname;
```

## 7. Primera corrida y verificación

```bash
curl -s -X POST \
  "https://$SUPABASE_PROJECT_REF.supabase.co/functions/v1/collect-rates" \
  -H "x-collector-secret: <secreto>"
```

Respuesta esperada:

```json
{"ok":true,"results":[
  {"source":"bcv","status":"ok","rows":2},
  {"source":"binance_p2p","status":"ok","rows":3}
]}
```

Luego:

```sql
select currency_code, type, rate_value, effective_from, change_pct
from public.rates_latest order by currency_code, type;

select source_code, status, rows_written, error_message
from public.collector_runs order by id desc limit 10;
```

Si `rates_latest` sigue vacía, revisar `collector_runs.error_message` y los logs
en el dashboard (Edge Functions → `collect-rates` → Logs).

## 8. Rotación del secreto

1. Generar uno nuevo (`openssl rand -hex 32`).
2. `supabase secrets set COLLECTOR_SECRET=<nuevo>`.
3. Actualizar el valor en Vault:
   ```sql
   select vault.update_secret(
     (select id from vault.secrets where name = 'collector_secret'),
     '<nuevo>'
   );
   ```
4. `select public.schedule_collector();` para que el job lea el valor nuevo en
   la próxima ejecución.

Entre el paso 2 y el 3 las corridas fallan con 401. Es una ventana de segundos.

## 9. Rollback

```sql
select cron.unschedule('collect-rates');
select cron.unschedule('purge-old-data');
```

La función puede quedarse desplegada sin secreto válido. Los snapshots escritos
se conservan: son datos reales, no esquema. Para revertir el esquema, restaurar
desde un backup del dashboard.

## 10. Claves y higiene

- **App móvil:** solo la clave publicable (`sb_publishable_...`). Es pública por
  diseño (ADR 0005).
- **Clave de servicio:** solo en el entorno de la Edge Function. Nunca en la app,
  nunca en el repo, nunca en un chat.
- **Secreto del colector:** en `supabase secrets` y en Vault. Si se filtra,
  rotarlo con el §8.
- **`.env`:** local, ignorado por git. `.env.example` solo tiene placeholders.
- **Rotación de la clave de servicio:** dashboard → Settings → API → Rotate. Hay
  que volver a desplegar la función para que tome la nueva.
