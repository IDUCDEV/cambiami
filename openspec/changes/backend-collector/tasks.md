## 1. Documentación y decisiones

- [x] 1.1 Escribir `docs/adr/0007-colector-de-tasas.md` con plataforma, frecuencia, retención, convención P2P, TLS del BCV y rotación del secreto; verificar que `docs/adr/README.md` (si existe) lo liste
- [x] 1.2 Añadir a `docs/DOMINIO.md` la convención `p2p_buy`/`p2p_sell`/`p2p_avg` y la igualdad `published_at = effective_from` del BCV; verificar con `grep` que ambas reglas aparecen junto a la tabla de `rate_snapshots`

## 2. Base de datos

- [x] 2.1 Crear `supabase/migrations/00002_collector.sql` con `create extension if not exists pg_cron` y `pg_net`; verificar con `supabase db reset` que las extensiones quedan instaladas
- [x] 2.2 Implementar `public.purge_old_data()` (snapshots > 90 días salvo la última de cada moneda y tipo; corridas > 30 días) con `security definer` y `search_path = ''`; verificar con los tests de 5.2
- [x] 2.3 Implementar `public.schedule_collector()`: lee `collector_url` y `collector_secret` de `vault.decrypted_secrets`, desprograma jobs previos y programa el colector cada 30 min y la purga a las 03:00 UTC; verificar que `cron.job` lista exactamente dos jobs con los `schedule` esperados
- [x] 2.4 Otorgar `execute` de `purge_old_data()` y `select/insert/update` sobre `collector_runs` solo a `service_role`; verificar que `anon` y `authenticated` reciben permiso denegado
- [x] 2.5 Escribir `supabase/tests/005_collector.sql` con pgTAP: purga borra lo viejo, conserva la última publicación, borra corridas viejas y los permisos son los esperados; verificar con `supabase test db` en verde

## 3. Edge Function

- [x] 3.1 Crear `supabase/functions/collect-rates/index.ts` con validación de `x-collector-secret` en tiempo constante, respuesta 401 sin escritura y orquestación por fuente con `try/catch`; verificar con `curl` sin cabecera (401) y con cabecera correcta (200)
- [x] 3.2 Crear `supabase/functions/collect-rates/bcv.ts`: parseo de `id="dolar"` y `id="euro"`, normalización es-VE, `published_at = effective_from`, cliente TLS con el PEM embebido y timeout de 10 s; verificar contra el HTML real con una invocación local que devuelve dos snapshots `oficial`
- [x] 3.3 Añadir `supabase/functions/collect-rates/certs/intermediate.ts` con el intermedio de Sectigo como módulo; verificar que el `fetch` al BCV devuelve 200 dentro del runtime local
- [x] 3.4 Crear `supabase/functions/collect-rates/binance.ts`: `POST` al endpoint P2P con `tradeType` BUY y SELL, filtrado de anuncios inválidos, promedio de cada lado y `p2p_avg` solo con ambos positivos; verificar que con datos reales se publican los tres tipos y con un lado vacío solo dos
- [x] 3.5 Registrar la corrida en `collector_runs` por fuente (`running` → `ok|error`) con `rows_written` y `error_message`; verificar que tras una invocación exitosa no queda ninguna fila en `running`
- [x] 3.6 Configurar `[functions.collect-rates]` con `verify_jwt = false` en `supabase/config.toml`; verificar que `supabase functions serve` la levanta sin JWT y que el 401 lo produce la función, no el gateway

## 4. Verificación local de punta a punta

- [x] 4.1 Ejecutar `supabase db reset && supabase functions serve` y una invocación manual con el secreto; verificar que `rates_latest` devuelve USD oficial, EUR oficial, USDT `p2p_buy`, `p2p_sell` y `p2p_avg`
- [x] 4.2 Invocar dos veces dentro del mismo minuto y verificar que el BCV no crece (idempotencia por fecha valor) y que el P2P solo publica una vez por minuto
- [x] 4.3 Simular fallo del BCV (URL inválida en el test o bloqueo temporal) y verificar que el P2P se publica igual y la corrida del BCV queda en `error` con causa
- [x] 4.4 Ejecutar `schedule_collector()` en local y verificar que `pg_net` dispara la función y que la corrida aparece en `collector_runs`
- [x] 4.5 Correr `supabase test db` completo y verificar que 001–005 pasan sin tocar el esquema congelado de `00001_rates.sql`

## 5. Preparación de despliegue

- [x] 5.1 Escribir `docs/SUPABASE_REMOTO.md` con login, link, `db push`, `secrets set`, `functions deploy`, carga de URL y secreto en Vault, programación, rotación y rollback; verificar que no contiene claves reales
- [x] 5.2 Crear `.env.example` con placeholders (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `COLLECTOR_SECRET`) y verificar que `.gitignore` ignora `.env` y `supabase/.env`
- [x] 5.3 Crear `Makefile` con `db-reset`, `test-db`, `fn-serve`, `collect` y `deploy`; verificar que cada objetivo corre en local sin secretos embebidos
- [x] 5.4 Eliminar `supabase/functions/spike-bcv/` y verificar que `supabase functions serve` solo lista `collect-rates`

## 6. Cierre

- [x] 6.1 Ejecutar `openspec validate backend-collector --strict` y corregir cualquier error
- [ ] 6.2 Confirmar con el usuario antes de archivar el change y verificar que `openspec/specs/collector/spec.md` queda creado
