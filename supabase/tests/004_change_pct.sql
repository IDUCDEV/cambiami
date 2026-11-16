-- 004_change_pct.sql
-- Variación contra la publicación anterior del mismo (moneda, tipo).

begin;

select plan(3);

-- Aísla el test de los datos reales del colector: todo se revierte al final.
delete from public.rate_snapshots;

-- Primera publicación: sin referencia previa.
select tests.add_snapshot('USD', 'bcv', 'oficial', 800.0000, now() - interval '2 days');
select is(
  (select change_pct from public.rate_snapshots
   where currency_code = 'USD' and type = 'oficial'),
  null::numeric, 'la primera publicación deja la variación vacía'
);

-- Segunda publicación: 800 -> 890.
select tests.add_snapshot('USD', 'bcv', 'oficial', 890.0000, now() - interval '1 day');
select is(
  (select change_pct from public.rate_snapshots
   where currency_code = 'USD' and type = 'oficial'
   order by effective_from desc limit 1),
  11.2500::numeric, 'la segunda publicación calcula la variación'
);

select is(
  (select change_pct from public.rates_latest
   where currency_code = 'USD' and type = 'oficial'),
  11.2500::numeric, 'la vista expone la variación'
);

select * from finish();
rollback;
