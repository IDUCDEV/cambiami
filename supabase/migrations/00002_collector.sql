-- 00002_collector.sql
-- Colector programado, retención y permisos de escritura. ADR 0007.
-- No toca el contrato de lectura de `00001_rates.sql`.

-- 1. Extensiones --------------------------------------------------------------

-- `pg_cron` programa los jobs; `pg_net` hace la petición HTTP a la Edge
-- Function desde Postgres. En Supabase remoto ya vienen instaladas: el
-- `if not exists` las deja como están.
create extension if not exists pg_cron;
create extension if not exists pg_net with schema extensions;

-- 2. Retención ----------------------------------------------------------------

-- Borra snapshots con más de 90 días y corridas con más de 30. Conserva siempre
-- la publicación más reciente de cada (currency_code, type): sin esa excepción,
-- un tipo que dejó de publicarse desaparecería de `rates_latest`.
create or replace function public.purge_old_data()
returns table (snapshots_deleted bigint, runs_deleted bigint)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_snapshots bigint;
  v_runs      bigint;
begin
  with latest as (
    select distinct on (currency_code, type) id
    from public.rate_snapshots
    order by currency_code, type, effective_from desc, fetched_at desc, id desc
  )
  delete from public.rate_snapshots r
  where r.fetched_at < now() - interval '90 days'
    and r.id not in (select id from latest);
  get diagnostics v_snapshots = row_count;

  delete from public.collector_runs
  where started_at < now() - interval '30 days';
  get diagnostics v_runs = row_count;

  return query select v_snapshots, v_runs;
end;
$$;

comment on function public.purge_old_data() is
  'Retención: 90 días de snapshots (salvo la publicación vigente de cada moneda y tipo) y 30 días de corridas.';

-- 3. Programación -------------------------------------------------------------

-- Idempotente: desprograma los jobs con esos nombres y los vuelve a crear. La
-- URL y el secreto se leen de Vault en cada ejecución, así que no quedan
-- escritos en `cron.job`.
create or replace function public.schedule_collector()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1 from vault.decrypted_secrets where name = 'collector_url'
  ) or not exists (
    select 1 from vault.decrypted_secrets where name = 'collector_secret'
  ) then
    raise exception
      'Faltan los secretos collector_url y collector_secret en Vault';
  end if;

  perform cron.unschedule(jobid)
  from cron.job
  where jobname in ('collect-rates', 'purge-old-data');

  perform cron.schedule(
    'collect-rates',
    '*/30 * * * *',
    $job$
      select net.http_post(
        url := (select decrypted_secret from vault.decrypted_secrets where name = 'collector_url'),
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'x-collector-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'collector_secret')
        ),
        body := '{}'::jsonb,
        timeout_milliseconds := 25000
      );
    $job$
  );

  perform cron.schedule(
    'purge-old-data',
    '0 3 * * *',
    $job$select public.purge_old_data();$job$
  );
end;
$$;

comment on function public.schedule_collector() is
  'Programa el colector cada 30 min y la purga diaria a las 03:00 UTC. Requiere collector_url y collector_secret en Vault.';

-- 4. Permisos -----------------------------------------------------------------

-- La función corre como `postgres`; nadie más la ejecuta.
revoke execute on function public.schedule_collector() from public, anon, authenticated;

-- La purga la ejecuta el job (postgres) y, para diagnóstico, `service_role`.
revoke execute on function public.purge_old_data() from public, anon, authenticated;
grant execute on function public.purge_old_data() to service_role;

-- La Edge Function escribe el registro de salud con `service_role`.
grant select, insert, update on public.collector_runs to service_role;
grant usage on sequence public.collector_runs_id_seq to service_role;
