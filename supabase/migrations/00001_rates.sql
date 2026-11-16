-- 00001_rates.sql
-- Esquema base del catálogo de tasas.
-- Contrato: docs/DOMINIO.md §4. Escritura reservada al colector.
-- Las policies de lectura viven en esta misma migración (ADR 0005).

-- 1. Catálogo de monedas -----------------------------------------------------

create table public.currencies (
  code       text        not null,
  name       text        not null,
  symbol     text        not null,
  decimals   smallint    not null default 2,
  kind       text        not null,
  is_active  boolean     not null default true,
  created_at timestamptz not null default now(),

  constraint currencies_pkey primary key (code),
  constraint currencies_code_format check (code ~ '^[A-Z]{3,6}$'),
  constraint currencies_decimals_range check (decimals between 0 and 6),
  constraint currencies_kind_valid check (kind in ('fiat', 'stablecoin'))
);

comment on table public.currencies is
  'Monedas del catálogo. Una stablecoin nueva es una fila, no una migración.';

-- 2. Fuentes -----------------------------------------------------------------

create table public.sources (
  code      text    not null,
  name      text    not null,
  url       text    not null,
  kind      text    not null,
  is_active boolean not null default true,

  constraint sources_pkey primary key (code),
  constraint sources_kind_valid check (kind in ('oficial', 'p2p'))
);

comment on table public.sources is
  'Quién publica la tasa. `kind` define el mercado y de ahí sale el booleano `official` de la vista.';

-- 3. Publicaciones de tasas --------------------------------------------------

create table public.rate_snapshots (
  id             bigint        generated always as identity,
  currency_code  text          not null,
  source_code    text          not null,
  type           text          not null,
  rate_value     numeric(18,6) not null,
  effective_from timestamptz   not null,
  published_at   timestamptz,
  fetched_at     timestamptz   not null default now(),
  change_pct     numeric(8,4),

  constraint rate_snapshots_pkey primary key (id),
  constraint rate_snapshots_currency_fk foreign key (currency_code)
    references public.currencies (code),
  constraint rate_snapshots_source_fk foreign key (source_code)
    references public.sources (code),
  constraint rate_snapshots_type_valid
    check (type in ('oficial', 'p2p_buy', 'p2p_sell', 'p2p_avg')),
  constraint rate_snapshots_rate_value_positive check (rate_value > 0),
  constraint rate_snapshots_publication_unique
    unique (currency_code, type, effective_from)
);

comment on table public.rate_snapshots is
  'Append-only: el colector inserta, nunca actualiza. Una publicación no se reescribe.';
comment on column public.rate_snapshots.fetched_at is
  'Cuándo el colector trajo el dato a la base. Lo pone la base con now().';
comment on column public.rate_snapshots.change_pct is
  'Variación contra la publicación anterior del mismo (currency_code, type). NULL en la primera.';

-- Alimenta `distinct on` de la vista.
create index rate_snapshots_latest_idx
  on public.rate_snapshots (currency_code, type, effective_from desc);

-- Depuración y retención.
create index rate_snapshots_fetched_at_idx
  on public.rate_snapshots (fetched_at desc);

-- 4. Ejecuciones del colector -------------------------------------------------

create table public.collector_runs (
  id            bigint      generated always as identity,
  source_code   text        not null,
  started_at    timestamptz not null default now(),
  finished_at   timestamptz,
  status        text        not null default 'running',
  rows_written  integer     not null default 0,
  error_message text,

  constraint collector_runs_pkey primary key (id),
  constraint collector_runs_source_fk foreign key (source_code)
    references public.sources (code),
  constraint collector_runs_status_valid
    check (status in ('running', 'ok', 'partial', 'error')),
  constraint collector_runs_rows_written_non_negative check (rows_written >= 0)
);

comment on table public.collector_runs is
  'Salud del colector. La app no la lee en v1: sin policies y sin grants (ADR 0005).';

create index collector_runs_source_started_idx
  on public.collector_runs (source_code, started_at desc);

-- 5. Escritura del colector ---------------------------------------------------

-- Único camino de escritura de tasas. Calcula la variación contra la publicación
-- anterior del mismo (currency_code, type) e ignora el duplicado exacto.
create or replace function public.record_rate_snapshot(
  p_currency_code  text,
  p_source_code    text,
  p_type           text,
  p_rate_value     numeric,
  p_effective_from timestamptz,
  p_published_at   timestamptz default null
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

comment on function public.record_rate_snapshot is
  'Escritura idempotente del colector. Devuelve el id insertado o NULL si la publicación ya existía.';

-- Sin `revoke` previo, `public` conserva EXECUTE por defecto en toda función nueva.
revoke execute on function public.record_rate_snapshot(
  text, text, text, numeric, timestamptz, timestamptz
) from public, anon, authenticated;

grant execute on function public.record_rate_snapshot(
  text, text, text, numeric, timestamptz, timestamptz
) to service_role;

-- 6. Lectura pública ----------------------------------------------------------

-- Única superficie que lee la app. Una fila por moneda y tipo, con la
-- publicación vigente. `security_invoker` hace que respete el RLS del rol que
-- consulta (ADR 0005).
create view public.rates_latest
with (security_invoker = true)
as
select distinct on (s.currency_code, s.type)
  s.currency_code,
  c.name                 as currency_name,
  c.symbol,
  c.decimals,
  s.type,
  s.rate_value,
  s.source_code,
  src.name               as source_name,
  src.url                as source_url,
  (src.kind = 'oficial') as official,
  s.effective_from,
  s.published_at,
  s.fetched_at,
  s.change_pct
from public.rate_snapshots s
join public.currencies c   on c.code = s.currency_code
join public.sources   src  on src.code = s.source_code
where s.effective_from <= now()
  and c.is_active
order by s.currency_code, s.type, s.effective_from desc, s.fetched_at desc;

comment on view public.rates_latest is
  'Contrato de lectura de la app (docs/DOMINIO.md §8). No almacena: proyecta la fila vigente.';

-- 7. Permisos de lectura ------------------------------------------------------

-- Solo lectura para la API (ADR 0005). La escritura del catálogo es del CI y la
-- de las tasas del colector; ninguna pasa por `anon` ni `authenticated`.
alter table public.currencies     enable row level security;
alter table public.sources        enable row level security;
alter table public.rate_snapshots enable row level security;

create policy "lectura publica" on public.currencies
  for select to anon, authenticated using (true);
create policy "lectura publica" on public.sources
  for select to anon, authenticated using (true);
create policy "lectura publica" on public.rate_snapshots
  for select to anon, authenticated using (true);

-- RLS ya deniega la escritura sin policy; quitar el privilegio evita que un
-- cambio futuro de policy abra la puerta por accidente.
revoke insert, update, delete
  on public.currencies, public.sources, public.rate_snapshots
  from anon, authenticated;

grant select on public.rates_latest to anon, authenticated;

-- Diagnóstico del colector: fuera del alcance de la API. RLS sin policies y sin
-- privilegios. Solo `service_role` (que saltea RLS) y `postgres` la ven.
alter table public.collector_runs enable row level security;

revoke select, insert, update, delete on public.collector_runs
  from anon, authenticated;
