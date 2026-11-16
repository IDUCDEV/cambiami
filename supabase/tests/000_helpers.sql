-- 000_helpers.sql
-- Helpers compartidos por los tests. Este archivo hace COMMIT a propósito: los
-- objetos del esquema `tests` tienen que sobrevivir a los demás archivos, que sí
-- corren en una transacción con rollback.

begin;

create extension if not exists pgtap with schema extensions;

-- Se recrea en cada corrida para no arrastrar helpers viejos.
drop schema if exists tests cascade;
create schema tests;

-- Envuelve una sentencia para que corra con el rol de la API. `set local role`
-- vive lo que vive la subtransacción de `lives_ok` / `throws_ok`.
create or replace function tests.as_anon(stmt text) returns text
language sql immutable as $$
  select 'set local role anon; ' || stmt || '; reset role';
$$;

create or replace function tests.as_authenticated(stmt text) returns text
language sql immutable as $$
  select 'set local role authenticated; ' || stmt || '; reset role';
$$;

create or replace function tests.as_service_role(stmt text) returns text
language sql immutable as $$
  select 'set local role service_role; ' || stmt || '; reset role';
$$;

-- Publica una tasa por el mismo camino que usa el colector.
create or replace function tests.add_snapshot(
  p_currency_code  text,
  p_source_code    text,
  p_type           text,
  p_rate_value     numeric,
  p_effective_from timestamptz,
  p_published_at   timestamptz default null
) returns bigint
language sql as $$
  select public.record_rate_snapshot(
    p_currency_code, p_source_code, p_type,
    p_rate_value, p_effective_from, p_published_at
  );
$$;

select plan(1);
select ok(true, 'helpers disponibles');
select * from finish();

commit;
