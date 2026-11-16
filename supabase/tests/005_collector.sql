-- 005_collector.sql
-- Retención, permisos de escritura y programación del colector (ADR 0007).

begin;

select plan(17);

-- 1. Datos de prueba ---------------------------------------------------------

-- Aísla el test de los datos reales del colector: todo se revierte al final.
delete from public.rate_snapshots;
delete from public.collector_runs;

-- USD: publicación vieja y publicación nueva del mismo tipo.
select tests.add_snapshot('USD', 'bcv', 'oficial', 100, now() - interval '100 days') as old_usd \gset
select tests.add_snapshot('USD', 'bcv', 'oficial', 110, now() - interval '10 days') as new_usd \gset

-- EUR: única publicación, vieja. Debe conservarse por ser la vigente.
select tests.add_snapshot('EUR', 'bcv', 'oficial', 200, now() - interval '100 days') as old_eur \gset

-- USDT: publicación reciente. No se toca.
select tests.add_snapshot('USDT', 'binance_p2p', 'p2p_avg', 300, now() - interval '1 day') as recent_usdt \gset

update public.rate_snapshots
set fetched_at = now() - interval '100 days'
where id in (:old_usd, :old_eur);

-- Corridas: una vieja y una reciente.
insert into public.collector_runs (source_code, status)
values ('bcv', 'ok') returning id as old_run \gset
insert into public.collector_runs (source_code, status)
values ('binance_p2p', 'ok') returning id as recent_run \gset

update public.collector_runs
set started_at = now() - interval '40 days', finished_at = now() - interval '40 days'
where id = :old_run;

-- 2. Purga -------------------------------------------------------------------

create temporary table purge_result as
select * from public.purge_old_data();

select is(
  (select count(*)::int from public.rate_snapshots where id = :old_usd),
  0,
  'purga borra el snapshot viejo con publicación más nueva'
);
select is(
  (select count(*)::int from public.rate_snapshots where id = :new_usd),
  1,
  'purga conserva el snapshot nuevo'
);
select is(
  (select count(*)::int from public.rate_snapshots where id = :old_eur),
  1,
  'purga conserva la última publicación aunque supere el corte'
);
select is(
  (select count(*)::int from public.rate_snapshots where id = :recent_usdt),
  1,
  'purga no toca snapshots recientes'
);
select is(
  (select count(*)::int from public.collector_runs where id = :old_run),
  0,
  'purga borra la corrida vieja'
);
select is(
  (select count(*)::int from public.collector_runs where id = :recent_run),
  1,
  'purga conserva la corrida reciente'
);
select is(
  (select snapshots_deleted from purge_result),
  1::bigint,
  'purga informa un snapshot borrado'
);
select is(
  (select runs_deleted from purge_result),
  1::bigint,
  'purga informa una corrida borrada'
);

-- 3. Permisos ----------------------------------------------------------------

select lives_ok(
  tests.as_service_role('select * from public.collector_runs'),
  'service_role lee collector_runs'
);
select lives_ok(
  tests.as_service_role($$insert into public.collector_runs (source_code) values ('bcv')$$),
  'service_role inserta corridas'
);
select throws_ok(
  tests.as_anon('select public.purge_old_data()'),
  '42501', null, 'anon no ejecuta la purga'
);
select lives_ok(
  tests.as_service_role('select public.purge_old_data()'),
  'service_role ejecuta la purga'
);

-- 4. Programación ------------------------------------------------------------

-- Los secretos locales pueden existir de una corrida anterior.
delete from vault.secrets where name in ('collector_url', 'collector_secret');

select vault.create_secret(
  'http://127.0.0.1:54321/functions/v1/collect-rates', 'collector_url'
);
select vault.create_secret('secreto-de-prueba', 'collector_secret');

select public.schedule_collector();

select is(
  (select count(*)::int from cron.job
    where jobname in ('collect-rates', 'purge-old-data')),
  2,
  'schedule_collector crea los dos jobs'
);

select public.schedule_collector();

select is(
  (select count(*)::int from cron.job
    where jobname in ('collect-rates', 'purge-old-data')),
  2,
  'schedule_collector es idempotente'
);

select is(
  (select schedule from cron.job where jobname = 'collect-rates'),
  '*/30 * * * *',
  'el colector corre cada 30 minutos'
);

select is(
  (select schedule from cron.job where jobname = 'purge-old-data'),
  '0 3 * * *',
  'la purga corre a las 03:00 UTC'
);

select ok(
  (select position('secreto-de-prueba' in command) = 0
   from cron.job where jobname = 'collect-rates'),
  'el secreto no queda escrito en cron.job'
);

select * from finish();
rollback;
