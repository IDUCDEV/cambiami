-- seed.sql
-- Catálogo del MVP. Idempotente: `supabase db reset` puede correrlo sin duplicar.
-- Contrato: docs/DOMINIO.md §4.1 y §4.2.
-- Las tasas NO van acá: las escribe el colector en `rate_snapshots`.

insert into public.currencies (code, name, symbol, decimals, kind) values
  ('USD',  'Dólar',  '$', 2, 'fiat'),
  ('EUR',  'Euro',   '€', 2, 'fiat'),
  ('USDT', 'Tether', '₮', 2, 'stablecoin')
on conflict (code) do nothing;

insert into public.sources (code, name, url, kind) values
  ('bcv',         'BCV',         'https://www.bcv.org.ve', 'oficial'),
  ('binance_p2p', 'Binance P2P', 'https://p2p.binance.com', 'p2p')
on conflict (code) do nothing;
