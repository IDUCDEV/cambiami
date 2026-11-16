-- 001_structure.sql
-- Estructura del esquema y restricciones declarativas.

begin;

select plan(17);

-- Aísla el test de los datos reales del colector: todo se revierte al final.
delete from public.rate_snapshots;

-- Tablas
select has_table('public', 'currencies',     'existe currencies');
select has_table('public', 'sources',        'existe sources');
select has_table('public', 'rate_snapshots', 'existe rate_snapshots');
select has_table('public', 'collector_runs', 'existe collector_runs');

-- Superficie de lectura
select has_view('public', 'rates_latest', 'existe la vista rates_latest');

-- Claves primarias
select ok(
  exists (select 1 from pg_constraint
          where conrelid = 'public.currencies'::regclass and contype = 'p'),
  'currencies tiene PK'
);
select ok(
  exists (select 1 from pg_constraint
          where conrelid = 'public.sources'::regclass and contype = 'p'),
  'sources tiene PK'
);
select ok(
  exists (select 1 from pg_constraint
          where conrelid = 'public.rate_snapshots'::regclass and contype = 'p'),
  'rate_snapshots tiene PK'
);
select ok(
  exists (select 1 from pg_constraint
          where conrelid = 'public.collector_runs'::regclass and contype = 'p'),
  'collector_runs tiene PK'
);

-- Claves foráneas
select ok(
  exists (select 1 from pg_constraint
          where conname = 'rate_snapshots_currency_fk' and contype = 'f'),
  'rate_snapshots apunta a currencies'
);
select ok(
  exists (select 1 from pg_constraint
          where conname = 'rate_snapshots_source_fk' and contype = 'f'),
  'rate_snapshots apunta a sources'
);
select ok(
  exists (select 1 from pg_constraint
          where conname = 'collector_runs_source_fk' and contype = 'f'),
  'collector_runs apunta a sources'
);

-- Unicidad de la publicación
select ok(
  exists (select 1 from pg_constraint
          where conname = 'rate_snapshots_publication_unique' and contype = 'u'),
  'la combinación moneda + tipo + vigencia es única'
);

-- Checks de dominio
select throws_ok(
  $$select tests.add_snapshot('USD', 'bcv', 'oficial', 0, now())$$,
  '23514', null, 'rechaza una tasa no positiva'
);
select throws_ok(
  $$select tests.add_snapshot('USD', 'bcv', 'otro', 1, now())$$,
  '23514', null, 'rechaza un tipo desconocido'
);

-- Reintento del colector: idempotente y sin duplicado
select tests.add_snapshot('USD', 'bcv', 'oficial', 889.5754, '2026-11-01T00:00:00Z');
select is(
  tests.add_snapshot('USD', 'bcv', 'oficial', 889.5754, '2026-11-01T00:00:00Z'),
  null, 'el reintento devuelve NULL'
);
select is(
  (select count(*) from public.rate_snapshots
   where currency_code = 'USD' and type = 'oficial'),
  1::bigint, 'el reintento no duplica filas'
);

select * from finish();
rollback;
