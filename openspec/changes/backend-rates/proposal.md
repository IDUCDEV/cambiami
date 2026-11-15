## Why

El cliente móvil necesita una superficie de datos estable antes de escribir una
línea de Flutter: sin esquema, sin vista de lectura y sin policies, la app
inventaría el modelo tres veces (Postgres, Dart y cache). Este change crea el
backend mínimo del MVP: cuatro tablas, una vista pública y sus tests.

## What Changes

- Migración `00001_rates.sql` con `currencies`, `sources`, `rate_snapshots` y
  `collector_runs`, más índices y restricciones.
- Vista `public.rates_latest` con `security_invoker = true`: una fila vigente por
  `currency_code` + `type`.
- RLS de solo lectura para `anon` y `authenticated` en las tres tablas públicas.
  Escritura reservada a `service_role` (colector y CI).
- Seed de catálogo: `USD`, `EUR`, `USDT`, `bcv`, `binance_p2p`.
- Tests pgTAP: estructura, una fila por tipo, lectura anónima y escritura denegada.
- Contrato del colector: `upsert` idempotente, cálculo de `change_pct` y registro
  en `collector_runs`.
- **BREAKING:** ninguno; el backend está vacío.

## Capabilities

### New Capabilities

- `rates`: catálogo de monedas y fuentes, publicaciones de tasas, vista de lectura
  pública y reglas de frescura del dato.

### Modified Capabilities

Ninguna: no existen specs previas.

## Impact

- `supabase/migrations/`, `supabase/tests/`, `supabase/seed.sql`.
- `docs/DOMINIO.md` como contrato; este change lo implementa, no lo redefine.
- `apps/mobile` consume `rates_latest` por PostgREST; el contrato de lectura queda
  fijado acá.
- Fuera de alcance: colector desplegado, `pg_cron`, Edge Functions y la app Flutter.
