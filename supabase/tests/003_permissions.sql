-- 003_permissions.sql
-- Lectura anónima permitida, escritura denegada y `collector_runs` fuera de alcance.

begin;

select plan(9);

-- Lectura permitida
select lives_ok(tests.as_anon('select * from public.currencies'),     'anon lee currencies');
select lives_ok(tests.as_anon('select * from public.sources'),        'anon lee sources');
select lives_ok(tests.as_anon('select * from public.rate_snapshots'), 'anon lee rate_snapshots');
select lives_ok(tests.as_anon('select * from public.rates_latest'),   'anon lee la vista');
select lives_ok(
  tests.as_authenticated('select * from public.rates_latest'),
  'authenticated lee la vista'
);

-- Escritura denegada
select throws_ok(
  tests.as_anon($$insert into public.currencies (code, name, symbol, kind)
                  values ('GBP', 'Libra', '£', 'fiat')$$),
  '42501', null, 'anon no inserta monedas'
);
select throws_ok(
  tests.as_anon($$update public.currencies set name = 'X'$$),
  '42501', null, 'anon no actualiza monedas'
);
select throws_ok(
  tests.as_anon($$delete from public.rate_snapshots$$),
  '42501', null, 'anon no borra tasas'
);

-- Diagnóstico del colector
select throws_ok(
  tests.as_anon('select * from public.collector_runs'),
  '42501', null, 'anon no lee collector_runs'
);

select * from finish();
rollback;
