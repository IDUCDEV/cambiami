# Reporte de implementación · backend-rates

- **Fecha:** 2026-11-16
- **Estado:** implementado y verificado en local
- **Verificación:** `supabase db reset && supabase test db` → 5 archivos, 37 tests, PASS

## Qué se construyó

| Objeto | Archivo |
|---|---|
| `config.toml` (Postgres 17, `schemas = ["public"]`, seed) | `supabase/config.toml` |
| Contrato de migraciones | `supabase/migrations/README.md` |
| Cuatro tablas, 16 constraints, 8 índices | `supabase/migrations/00001_rates.sql` |
| `record_rate_snapshot(...)` + grants | `supabase/migrations/00001_rates.sql` |
| Vista `rates_latest` (`security_invoker`) | `supabase/migrations/00001_rates.sql` |
| RLS y policies de lectura | `supabase/migrations/00001_rates.sql` |
| Seed idempotente del catálogo | `supabase/seed.sql` |
| Tests pgTAP | `supabase/tests/000_helpers.sql` … `004_change_pct.sql` |

## Verificaciones ejecutadas

- `supabase start`: Postgres 17.11, REST 200, Studio responde.
- `db reset`: aplica `00001_rates.sql`, ignora `README.md`, carga el seed.
- `db reset` dos veces: `currencies = 3`, `sources = 2`, sin duplicados.
- `record_rate_snapshot`: primera llamada devuelve id, la duplicada `NULL` sin
  insertar, la siguiente calcula `change_pct = 0.0590`.
- Función denegada a `anon` (`42501`) por `psql` y por REST con la clave publicable.
- Vista: de dos publicaciones pasadas gana la más reciente; la futura no aparece.
- REST con clave publicable: lectura de las tres tablas y de la vista; escritura y
  `collector_runs` responden `401 / 42501`.
- Test de estructura: al quitar el `unique` de publicación el test falla (13–15).

## Desviaciones respecto de `docs/DOMINIO.md`

1. **§5 no filtraba monedas inactivas.** El spec exige el escenario "Moneda
   inactiva", así que la vista incluye `and c.is_active`. `DOMINIO.md` §5 ya quedó
   corregido en este change.
2. **Timestamps en UTC.** PostgREST devuelve `+00:00`; el ejemplo de §8 muestra
   `-04:00`. Es el mismo instante: el cliente debe parsear ISO-8601, no comparar
   cadenas.
3. **`fetched_at` lo pone la base** con `default now()`. El colector no lo envía;
   así no puede falsear la hora de ingesta.
4. **`record_rate_snapshot` devuelve `NULL`** en un reintento. El colector debe
   contar solo los ids no nulos en `rows_written`.
5. **Privilegios explícitos.** Además del RLS se revocan `insert/update/delete` a
   `anon` y `authenticated` en las tres tablas, y todo privilegio en
   `collector_runs`. Es defensa en profundidad sobre `auto_expose_new_tables`.
6. **`decimals` de `USDT` = 2**, el default de la tabla. No hay regla que exija 6.

## Pendientes (fuera del alcance del change)

- **Colector**: Edge Function + `pg_cron`. Sin él la vista queda vacía y la app
  muestra `No hay tasas publicadas.` No hay ADR de frecuencia, retención ni
  plataforma.
- **Copy de tasa no positiva** en el cliente (el backend ya rechaza `<= 0`).
- **`change_pct` nulo**: la app debe decidir qué muestra en la primera publicación.
- **Efecto de cambiar de moneda con la calculadora abierta** (F-05).
- **Enlaces de tienda** en la ficha legal (H4).
- **Retención/purga** de `rate_snapshots` y **rate limiting** de la API.
- **Proyecto remoto**: `db push` y claves de producción aún no configurados.
