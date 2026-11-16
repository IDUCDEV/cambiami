# ADR 0005 · Backend de lectura pública

- **Estado:** aceptada
- **Fecha:** 2026-11-14
- **Decisores:** IDUCDEV
- **Relacionados:** `docs/DOMINIO.md` §5 y §8, `PROMPT-POR-FASES/09-parte-b-packs.md` (pack `rpc-publicas`)

## Contexto

La app es anónima: no hay login, no hay usuarios, no hay datos personales. Todo lo
que el cliente necesita es el catálogo de tasas vigentes.

Hay que decidir cómo se expone ese dato y cómo se escribe, sin abrir la puerta a
escrituras desde el cliente.

## Decisión

- **Clave publicable (`sb_publishable_...`) en la app.** Es pública por diseño: va
  en el bundle y cualquiera puede leerla.
- **RLS de solo lectura** en `currencies`, `sources` y `rate_snapshots`:

```sql
alter table public.currencies      enable row level security;
alter table public.sources         enable row level security;
alter table public.rate_snapshots  enable row level security;

create policy "lectura publica" on public.currencies
  for select to anon, authenticated using (true);
create policy "lectura publica" on public.sources
  for select to anon, authenticated using (true);
create policy "lectura publica" on public.rate_snapshots
  for select to anon, authenticated using (true);
```

- **La app lee solo la vista `rates_latest`**, creada con `security_invoker = true`
  para que respete RLS y no genere el warning de `security_definer_view`.
- **Sin RPC en v1.** No hay agregación que lo justifique: la vista ya entrega una
  fila por tipo. El pack `rpc-publicas` queda disponible si en Fase 2 aparece una
  consulta que cruce varias tablas con datos que no deban ser públicos.
- **Escritura solo con `service_role`**, desde la Edge Function del colector y
  desde el CI. La clave secreta nunca sale del servidor.
- **Sin auth.** No hay `auth.users`, ni `profiles`, ni `middleware.ts`.

## Alternativas descartadas

| Alternativa | Por qué no |
|---|---|
| RPC `security definer` para todo | Más superficie y más código para leer una vista pública; el patrón queda para cuando haga falta ocultar tablas base |
| Edge Function como proxy de lectura | Agrega latencia y un punto de fallo sin beneficio: el dato es público |
| Exigir login para ver tasas | Rompe HU-01 y el producto: la app es informativa y anónima |
| `service_role` en la app | Saltea RLS; una filtración abre la base entera |
| Tablas sin RLS y solo permisos por rol | RLS es la defensa en profundidad que Supabase espera; los grants solos no alcanzan |

## Consecuencias

### Positivas

- El cliente no puede escribir ni borrar nada, aunque la clave se filtre.
- No hay superficie de autenticación que mantener.
- La vista se puede versionar y la app no cambia si se agrega una moneda.
- El linter de Supabase queda limpio (sin vistas `security definer`).

### Negativas / costo

- **El dato es público.** Es aceptable porque no hay PII ni nada privado. Si en
  Fase 2 entra un perfil o una alerta, esa tabla necesita su propia policy por
  `user_id` y este ADR no la cubre.
- **Sin rate limiting propio.** Se depende de los límites de la plataforma. La
  app hace una consulta al abrir y otra por refresco manual: no hay sondeo. El
  umbral para revisar la decisión es **300 peticiones/minuto sostenidas desde una
  misma IP** o **50.000 peticiones/día** al proyecto; por debajo, un limiter
  propio solo agrega latencia y un punto de fallo. Si se cruza, la salida barata
  es cache en el borde y, si no alcanza, una función intermedia.
- **La vista es un contrato más.** Cambiar sus columnas rompe la app: por eso está
  documentada en `DOMINIO.md` §8.

## Verificación

- pgTAP: `anon` puede `select` en las tres tablas y en la vista.
- pgTAP: `anon` recibe error al intentar `insert`, `update` o `delete`.
- pgTAP: la vista devuelve una sola fila por `currency_code` + `type`.
- Manual: `curl` con la clave publicable devuelve el catálogo; con la secreta
  también, pero la secreta no está en el repo.

## Cuándo revisar

- Cuando entre cualquier dato de usuario (Fase 2).
- Si aparece una consulta que necesite ocultar tablas base.
- Si el tráfico exige cache en el borde.
