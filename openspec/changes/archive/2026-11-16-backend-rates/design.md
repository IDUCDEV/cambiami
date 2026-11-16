## Context

Ver `proposal.md` para la motivación. El backend está vacío: `supabase/` solo
contiene `.temp`. El contrato de datos ya está fijado en `docs/DOMINIO.md` y las
decisiones de exposición en `docs/adr/0005-backend-lectura-publica.md`. Este
change los implementa.

Restricciones:

- Supabase local con Postgres 17.
- La app es anónima: no hay auth, no hay datos personales.
- El cliente solo lee; el colector es el único que escribe.
- La app móvil todavía no existe: el contrato de lectura debe quedar cerrado acá.

## Goals / Non-Goals

**Goals:**

- Esquema mínimo con integridad declarativa (PK, FK, unique, check).
- Una superficie de lectura pública y estable: la vista `rates_latest`.
- RLS de solo lectura y escritura reservada a `service_role`.
- Lógica de variación en un solo lugar, testeable con pgTAP.
- Seed idempotente del catálogo del MVP.

**Non-Goals:**

- Implementar o desplegar el colector (Edge Function, scraping, TLS del BCV).
- Programar `pg_cron`.
- Retención o purga de snapshots.
- Multi-país, histórico, series o salud del dato.
- Cambios en la app Flutter.

## Decisions

### 1. Filas por tipo, no columnas por tipo

`rate_snapshots` guarda una fila por `(currency_code, type, effective_from)` en
lugar de columnas `buy_value` / `sell_value` / `avg_value`.

- **Por qué:** una stablecoin nueva o un tipo nuevo es una fila, no una migración.
  El catálogo y la UI agrupan por `official` sin cambiar el esquema.
- **Alternativa descartada:** columnas fijas. Obliga a migrar para cada tipo y deja
  columnas nulas cuando una fuente no publica compra o venta.

### 2. `official` se deriva de la fuente

No se guarda una columna `official` en `rate_snapshots`; la vista la calcula como
`sources.kind = 'oficial'`.

- **Por qué:** evita una bandera duplicada que puede contradecir a la fuente.
- **Alternativa descartada:** columna booleana. Requiere mantener dos verdades y
  permite filas incoherentes.

### 3. Estado y edad se calculan en el cliente

La tabla no tiene `status` ni `is_down`; la vista no expone `age_minutes`.

- **Por qué:** el estado depende de la red del usuario, no de la base. Persistirlo
  obliga a un job que lo actualice y miente cuando el dispositivo está offline.
- **Alternativa descartada:** columna `status` actualizada por el colector. Genera
  dos fuentes de verdad y un estado "al día" falso en modo avión.

### 4. La vista respeta la vigencia y RLS

`rates_latest` filtra `effective_from <= now()` y usa `security_invoker = true`.

- **Por qué:** una tasa programada no debe mostrarse antes de regir, y la vista no
  debe saltarse las policies del rol que consulta.
- **Alternativa descartada:** vista `security definer` con `revoke` sobre las
  tablas. Funciona, pero el linter de Supabase la marca y esconde el modelo de
  permisos.

### 5. `change_pct` se calcula en una función SQL

El colector llama a `public.record_rate_snapshot(...)`, que busca la publicación
anterior del mismo `(currency_code, type)`, calcula la variación, inserta con
`on conflict do nothing` y devuelve el id.

- **Por qué:** la regla vive cerca del dato, es idempotente y se testea con pgTAP
  sin Deno ni red.
- **Alternativa descartada:** calcular en la Edge Function. Duplica la consulta y
  deja la regla fuera de los tests de base.

Esbozo:

```sql
create or replace function public.record_rate_snapshot(
  p_currency_code text,
  p_source_code   text,
  p_type          text,
  p_rate_value    numeric,
  p_effective_from timestamptz,
  p_published_at  timestamptz default null
) returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_previous numeric;
  v_change   numeric;
  v_id       bigint;
begin
  select r.rate_value into v_previous
  from public.rate_snapshots r
  where r.currency_code = p_currency_code
    and r.type = p_type
    and r.effective_from < p_effective_from
  order by r.effective_from desc
  limit 1;

  if v_previous is not null and v_previous > 0 then
    v_change := round(((p_rate_value - v_previous) / v_previous) * 100, 4);
  end if;

  insert into public.rate_snapshots (
    currency_code, source_code, type, rate_value,
    effective_from, published_at, change_pct
  ) values (
    p_currency_code, p_source_code, p_type, p_rate_value,
    p_effective_from, p_published_at, v_change
  )
  on conflict (currency_code, type, effective_from) do nothing
  returning id into v_id;

  return v_id;
end;
$$;

revoke execute on function public.record_rate_snapshot(...) from public, anon, authenticated;
grant execute on function public.record_rate_snapshot(...) to service_role;
```

### 6. Identidad y marcas de tiempo

- `bigint generated always as identity` como PK (no `serial`, no `uuid`).
- Todas las fechas son `timestamptz`. La zona de presentación es
  `America/Caracas`, pero se aplica en el cliente.
- `fetched_at` usa `now()` en la base; el colector no lo envía.

### 7. Seed idempotente

`seed.sql` usa `insert ... on conflict do nothing` para `currencies` y `sources`.
No siembra tasas: un dato inventado en el seed contamina la lectura pública.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| El BCV no distingue `published_at` de `effective_from` | El colector los iguala y lo registra en `collector_runs.error_message`; el contrato admite ambos |
| Una tasa oficial vieja se marca `desactualizado` todo el fin de semana | El umbral de 26 h es provisional (S-05) y vive en el cliente; se ajusta en H1 sin tocar la base |
| El colector inserta una tasa con `effective_from` futuro por error | La vista la oculta hasta que rija; el test cubre el caso |
| La clave publicable se usa para abuso | Solo hay lectura y el volumen es mínimo; si aparece abuso, se agrega cache o límite en la plataforma |
| `on conflict do nothing` oculta un cambio de valor con la misma vigencia | Es deliberado: una publicación no se reescribe; si la fuente corrige, usa otra `effective_from` |
| Zona horaria mal aplicada en la UI | La base guarda UTC; el cliente formatea en `America/Caracas` y hay test de formato |

## Migration Plan

1. `supabase start` y `supabase db reset` con la migración y el seed.
2. `supabase test db` con los tests pgTAP.
3. Revisar `select * from rates_latest` con datos de prueba.
4. `supabase db push` al proyecto remoto cuando exista.
5. Rollback: al ser el primer esquema, `drop schema` no aplica en producción; en
   local se resuelve con `db reset`.

## Open Questions

- Frecuencia del colector y retención de snapshots: se deciden al implementarlo,
  no cambian el esquema ni el contrato de lectura.
- Si el BCV publica una corrección con la misma fecha de vigencia: se resolverá
  con una nueva `effective_from` o con una columna de versión; hoy no hay evidencia.
