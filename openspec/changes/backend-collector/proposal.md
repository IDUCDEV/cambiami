## Why

El esquema y la vista pública de tasas ya existen, pero nadie escribe en
`rate_snapshots`: `rates_latest` está vacía y la app solo puede mostrar
`No hay tasas publicadas.` Sin un colector, el MVP no tiene datos reales.

## What Changes

- Edge Function `collect-rates` que lee el BCV (USD y EUR) y el mercado P2P de
  Binance (USDT), y publica con `record_rate_snapshot` usando `service_role`.
- Registro de cada corrida en `collector_runs` (`running` → `ok|partial|error`),
  con filas escritas y mensaje de diagnóstico.
- Programación cada 30 min con `pg_cron` + `pg_net`, con el secreto en Vault.
- Purga diaria de datos viejos: snapshots > 90 días (salvo la última publicación
  de cada moneda y tipo) y corridas > 30 días.
- Bundle del certificado intermedio de Sectigo que el BCV no envía, para que el
  `fetch` desde Edge Functions valide la cadena TLS.
- ADR 0007 con plataforma, frecuencia, retención, convención P2P y manejo de
  fallos.
- Runbook de despliegue remoto y plantilla de variables, sin claves en el repo.

## Capabilities

### New Capabilities

- `collector`: ejecución programada, publicación idempotente en las fuentes,
  registro de corridas, retención de datos y secreto fuera del cliente.

### Modified Capabilities

Ninguna. `rates` no cambia: el colector consume el contrato ya publicado.

## Impact

- `supabase/functions/collect-rates/` (nuevo).
- `supabase/migrations/00002_collector.sql` (nuevo): extensiones, purga,
  programación y grants.
- `supabase/config.toml`: `verify_jwt = false` para la función; el secreto se
  valida dentro de la función.
- `supabase/tests/005_collector.sql` (nuevo).
- `docs/adr/0007-colector-de-tasas.md` (nuevo).
- `docs/DOMINIO.md`: convención `p2p_buy`/`p2p_sell` y fallback de `published_at`.
- `docs/SUPABASE_REMOTO.md`, `.env.example`, `Makefile` (nuevos).
- No toca la app móvil ni el contrato de lectura de `rates_latest`.
