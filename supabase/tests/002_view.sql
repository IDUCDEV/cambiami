-- 002_view.sql
-- Comportamiento de `rates_latest`: vigencia, unicidad y procedencia.

begin;

select plan(7);

-- Aísla el test de los datos reales del colector: todo se revierte al final.
delete from public.rate_snapshots;

-- Dos publicaciones pasadas del mismo tipo, una futura y otro tipo.
select tests.add_snapshot('USD', 'bcv',         'oficial',  800.0000, now() - interval '3 days');
select tests.add_snapshot('USD', 'bcv',         'oficial',  890.0000, now() - interval '1 day');
select tests.add_snapshot('USD', 'bcv',         'oficial',  999.0000, now() + interval '1 day');
select tests.add_snapshot('USD', 'binance_p2p', 'p2p_avg',  905.0000, now() - interval '1 hour');

select is(
  (select count(*) from public.rates_latest
   where currency_code = 'USD' and type = 'oficial'),
  1::bigint, 'una sola fila por moneda y tipo'
);

select is(
  (select rate_value from public.rates_latest
   where currency_code = 'USD' and type = 'oficial'),
  890.000000::numeric, 'devuelve la publicación vigente más reciente'
);

select is(
  (select count(*) from public.rates_latest
   where currency_code = 'USD' and rate_value = 999.000000),
  0::bigint, 'oculta la publicación futura'
);

select is(
  (select count(*) from public.rates_latest where currency_code = 'EUR'),
  0::bigint, 'no inventa filas para una moneda sin publicaciones'
);

select is(
  (select official from public.rates_latest
   where currency_code = 'USD' and type = 'oficial'),
  true, 'la tasa del BCV es oficial'
);

select is(
  (select official from public.rates_latest
   where currency_code = 'USD' and type = 'p2p_avg'),
  false, 'la tasa P2P no es oficial'
);

select is(
  (select source_code from public.rates_latest
   where currency_code = 'USD' and type = 'p2p_avg'),
  'binance_p2p', 'la fila trae la fuente que publicó'
);

select * from finish();
rollback;
