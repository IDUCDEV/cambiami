## 1. Estructura y configuración

- [ ] 1.1 Crear `supabase/config.toml` con Postgres 17, API en `public` y seed apuntando a `seed.sql`; verificar con `supabase start` que el stack levanta
- [ ] 1.2 Crear `supabase/migrations/README.md` con el contrato de migraciones (nombre, flujo, reglas de seguridad); verificar que la CLI lo ignora en `supabase db reset`
- [ ] 1.3 Crear `supabase/migrations/00001_rates.sql` con las cuatro tablas, índices y restricciones; verificar que `supabase db reset` termina sin error

## 2. Lógica de escritura

- [ ] 2.1 Implementar `public.record_rate_snapshot(...)` con `security definer`, `search_path = ''`, cálculo de `change_pct` y `on conflict do nothing`; verificar con una llamada manual que devuelve id y no duplica
- [ ] 2.2 Revocar la ejecución de la función a `public`, `anon` y `authenticated`, y otorgarla a `service_role`; verificar que `anon` recibe error al invocarla

## 3. Lectura pública

- [ ] 3.1 Crear la vista `public.rates_latest` con `security_invoker = true`, filtro `effective_from <= now()` y una fila por moneda y tipo; verificar con dos publicaciones que devuelve solo la vigente
- [ ] 3.2 Habilitar RLS en `currencies`, `sources` y `rate_snapshots` y crear las policies de lectura para `anon` y `authenticated`; verificar que la vista devuelve filas con la clave publicable

## 4. Catálogo

- [ ] 4.1 Escribir `supabase/seed.sql` con `USD`, `EUR`, `USDT`, `bcv` y `binance_p2p` usando `on conflict do nothing`; verificar que `supabase db reset` dos veces seguidas no duplica filas

## 5. Tests pgTAP

- [ ] 5.1 Crear `supabase/tests/000_helpers.sql` con helpers de autenticación y aserciones reutilizables; verificar que `supabase test db` los carga sin error
- [ ] 5.2 Test de estructura: existen las cuatro tablas, la vista, las PK, las FK y el `unique`; verificar que el test falla si se quita una restricción
- [ ] 5.3 Test de vista: con dos snapshots del mismo tipo devuelve el más reciente vigente y oculta el futuro; verificar los dos escenarios
- [ ] 5.4 Test de permisos: `anon` puede leer las tres tablas y la vista, y no puede insertar, actualizar ni borrar; verificar los cuatro casos
- [ ] 5.5 Test de variación: la segunda publicación calcula `change_pct` y la primera lo deja nulo; verificar ambos valores

## 6. Verificación final

- [ ] 6.1 Correr `supabase db reset` y `supabase test db` desde cero y confirmar que todo pasa en verde
- [ ] 6.2 Consultar `rates_latest` con `curl` usando la clave publicable y confirmar que el JSON coincide con el contrato de `docs/DOMINIO.md` §8
- [ ] 6.3 Registrar en el reporte del change las desviaciones respecto de `DOMINIO.md` y los `TODO` que queden
