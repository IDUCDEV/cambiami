## Context

Ver `proposal.md` — Why. El esquema de `00001_rates.sql` ya está congelado: existe
`record_rate_snapshot()` como único camino de escritura, la vista `rates_latest`
y `collector_runs` sin grants para la API (ADR 0005). Este change no cambia el
contrato de lectura.

Restricciones que condicionan el diseño:

- **Sin servidor propio.** El proyecto es Flutter + Supabase; no hay un host donde
  correr un daemon.
- **El BCV no envía el certificado intermedio de Sectigo.** Un `fetch` normal
  falla con `unable to get local issuer certificate`; el intermedio se descarga
  de `http://crt.sectigo.com/` y se embebe en la función.
- **La clave de escritura nunca sale del backend.** La app es anónima y solo
  tiene la clave publicable.
- **Una publicación no se reescribe.** `record_rate_snapshot()` es idempotente
  por `(currency_code, type, effective_from)` y calcula `change_pct`.
- **Local primero.** Todo se prueba contra el stack local; el despliegue remoto
  queda documentado, no ejecutado.

## Goals / Non-Goals

**Goals:**

- Un colector que corre solo cada 30 min y que también se puede invocar a mano.
- Publicar BCV (USD, EUR) y Binance P2P (USDT compra, venta, promedio) sin
  duplicar y sin inventar datos.
- Que un fallo de una fuente no tumbe la otra ni deje la corrida muda.
- Purga automática que respete la publicación vigente.
- Secreto y clave de servicio fuera del repo y del cliente.

**Non-Goals:**

- Histórico o gráficas (Fase 2). El colector alimenta la vista, no una serie.
- Fuente puente para el BCV: el fetch directo con el bundle TLS funciona.
- Reintentos con backoff ni cola de trabajos: una corrida por ventana.
- Alertas o dashboard de salud: `collector_runs` se consulta a mano en v1.
- Rate limiting propio (ADR 0005): el umbral queda documentado.

## Decisions

### 1. Edge Function + `pg_cron` + `pg_net`

La lógica vive en una Edge Function (`collect-rates`) y el disparo en
`pg_cron`, que llama por `pg_net` a la URL de la función.

- **Por qué:** no hay host propio; la función corre cerca de la base y `pg_cron`
  ya está disponible en el proyecto. El secreto se guarda en Vault y el job lo
  lee de ahí, así que no queda en la migración.
- **Alternativas:** un cron externo (GitHub Actions) añade un proveedor y un
  token; un worker en la base con `pg_net` no puede parsear HTML con comodidad.
- **Consecuencia:** el job depende de que la URL de la función sea alcanzable
  desde Postgres. En local es `http://kong:8000/functions/v1/collect-rates`; en
  remoto, `https://<ref>.supabase.co/functions/v1/collect-rates`.

### 2. Una corrida por fuente, no una por ejecución

Cada invocación abre una fila `running` en `collector_runs` por fuente
(`bcv`, `binance_p2p`) y la cierra en `ok` o `error` con `rows_written` y
`error_message`.

- **Por qué:** `collector_runs.source_code` es `not null` y referencia
  `sources`; una fila por fuente hace legible el diagnóstico y permite que una
  fuente pase y la otra falle (`partial`).
- **`partial`** queda disponible en el esquema pero el colector no lo usa en v1:
  el estado agregado se deriva mirando las filas de la corrida. Si una fuente
  falla, su fila va a `error` y la otra a `ok`.
- **Alternativa:** una sola fila con `source_code = 'bcv'` y un JSON de detalle.
  Se descarta porque rompe la FK y mezcla salud de dos fuentes.

### 3. BCV: fecha valor como `effective_from` y como `published_at`

El BCV publica la fecha valor en `content="2026-11-16T00:00:00-04:00"` pero no
la hora de publicación.

- `effective_from` = fecha valor del BCV.
- `published_at` = `effective_from`, porque es el único instante verificable.
- **Por qué:** un reintento el mismo día vuelve a producir la misma
  `effective_from` y `record_rate_snapshot()` lo ignora; no se duplica. Usar
  `now()` como `effective_from` sí duplicaría en cada corrida.
- **Limitación documentada:** la ficha mostrará `Publicado` igual a
  `Vigente desde`. Se anota en `DOMINIO.md` y en el ADR 0007.

### 4. Binance: tres tipos, promedio solo con ambos lados

- `tradeType: "BUY"` (anuncios que compran USDT; el usuario vende) → `p2p_buy`.
- `tradeType: "SELL"` (anuncios que venden USDT; el usuario compra) → `p2p_sell`.
- `p2p_avg` = promedio simple de los dos promedios, solo si ambos son positivos
  (I-04 de `DOMINIO.md`).
- `effective_from` = instante de la corrida (el P2P no tiene fecha de vigencia
  propia), truncado al minuto para que dos corridas del mismo minuto no
  dupliquen.
- **Promedio de anuncios:** se descartan anuncios sin precio válido o con
  `surplusAmount` no positivo y se promedian los primeros `rows` devueltos por
  la API (una página). No se pondera por volumen: el brief pide el promedio del
  mercado, no un VWAP.
- **Alternativa:** usar el mejor precio (primero de la lista). Se descarta
  porque un solo anuncio manipula el valor.

### 5. Certificado intermedio embebido

`supabase/functions/collect-rates/certs/intermediate.ts` exporta el
intermedio de Sectigo como cadena. La función crea un cliente con
`Deno.createHttpClient({ caCerts: [PEM] })` y lo pasa al `fetch` del BCV.

- **Por qué:** verificado en edge-runtime 1.78.1 (Deno 2.1.4): sin el bundle el
  fetch falla; con el bundle devuelve 200 y el HTML completo. Incluir el
  intermedio no debilita la validación: la cadena se sigue verificando hasta la
  raíz del sistema.
- **Alternativas:** `--unsafely-ignore-certificate-errors` desactiva TLS (se
  descarta); una fuente puente cambia la procedencia visible (se descarta en
  v1).
- **Mantenimiento:** el intermedio vence en 2036; el leaf del BCV, en 2026. Si
  el BCV cambia de CA, el fetch falla y la corrida queda en `error` con la causa.

### 6. Secreto compartido validado dentro de la función

`verify_jwt = false` en `supabase/config.toml`; la función exige la cabecera
`x-collector-secret` y la compara con `COLLECTOR_SECRET`.

- **Por qué:** `pg_net` no firma JWTs; la función la llama el cron con un secreto
  estático. Comparar en tiempo constante evita filtrar el secreto por tiempos.
- **Alternativa:** dejar `verify_jwt = true` y usar la clave de servicio como
  bearer. Se descarta: reparte la clave de servicio en el job y en el cuerpo de
  la petición.
- **Rotación:** cambiar el secreto en Vault y en los secrets de la función; el
  procedimiento va en `docs/SUPABASE_REMOTO.md`.

### 7. Purga diaria que conserva la publicación vigente

`purge_old_data()` borra:

- `rate_snapshots` con `fetched_at < now() - interval '90 days'`, **salvo** la
  última fila de cada `(currency_code, type)`.
- `collector_runs` con `started_at < now() - interval '30 days'`.

- **Por qué:** sin la excepción, un tipo que dejó de publicarse (p. ej. un
  `p2p_avg` que dejó de calcularse) desaparecería de `rates_latest` y la app
  mostraría la moneda sin fila.
- **Implementación:** `delete ... using (select distinct on (...) id ...)` o
  `not in` sobre la subconsulta de máximos. Se ejecuta en un job diario a las
  03:00 UTC, fuera de las ventanas de publicación del BCV.
- **Alternativa:** retención infinita. Se descarta: la tabla crece ~1.400 filas
  al día con el colector cada 30 min.

### 8. Fallo de una fuente no bloquea la otra

La función envuelve cada fuente en su propio `try/catch`. Si el BCV falla, se
publica igual el P2P y viceversa; la respuesta HTTP es `207`-equivalente (JSON
con `results` por fuente) pero el cron solo mira que la petición se haya
completado.

- **Por qué:** el mercado P2P opera 24/7 y el BCV no; acoplar las fuentes haría
  que un fallo del BCV congelara el USDT.
- **Timeout:** 10 s por fuente. Una fuente que tarda más se marca `error` y no
  bloquea la corrida.

## Risks / Trade-offs

- **El BCV cambia el HTML** → el parseo falla ruidosamente (`error` con la causa)
  y la última tasa sigue vigente en la vista. No se publica basura.
- **El BCV cambia de CA** → hay que reemplazar el PEM embebido. El ADR 0007
  documenta cómo extraerlo.
- **Binance limita o cambia el endpoint no oficial** → la corrida P2P falla, la
  oficial sigue. Si se vuelve crónico, se evalúa un proveedor alternativo.
- **El secreto se filtra** → rotarlo invalida el job hasta actualizar ambos
  lados; el runbook tiene el orden exacto.
- **Dos corridas solapadas** → `record_rate_snapshot()` es idempotente por
  `effective_from`; el peor caso es una fila duplicada en `collector_runs`, no
  en las tasas.
- **`effective_from` truncado al minuto en P2P** → dos corridas dentro del mismo
  minuto publican una sola vez. Aceptable: el cron corre cada 30 min.
- **La purga borra historia útil para Fase 2** → 90 días cubren de sobra el
  desarrollo; el histórico de gráficas necesitará su propia tabla agregada.

## Migration Plan

1. `00002_collector.sql`: `create extension if not exists pg_cron`, `pg_net`;
   `purge_old_data()`; `schedule_collector()` (lee URL y secreto de Vault y
   programa los dos jobs); grants de `service_role` sobre `collector_runs` y la
   función de purga.
2. `supabase/functions/collect-rates/`: `index.ts`, `bcv.ts`, `binance.ts`,
   `certs/intermediate.ts`.
3. `supabase/config.toml`: bloque `[functions.collect-rates]` con
   `verify_jwt = false`.
4. En local: `supabase db reset`, `supabase functions serve`, y una invocación
   manual con `x-collector-secret` para llenar la vista. El cron local se prueba
   llamando a `schedule_collector()` con la URL de Kong.
5. En remoto (documentado, no ejecutado): `supabase db push`, `supabase secrets
   set COLLECTOR_SECRET=...`, `supabase functions deploy collect-rates`, y
   guardar la URL y el secreto en Vault antes de programar.

**Rollback:** `cron.unschedule` de los dos jobs y `drop function
purge_old_data()`; la función se puede dejar desplegada sin secreto válido. Los
snapshots escritos se conservan: son datos reales, no un esquema.

## Open Questions

Ninguna que cambie specs, enfoque o tareas. La frecuencia (30 min), la retención
(90/30 días) y la convención P2P quedan cerradas en este documento y en el ADR
0007.
