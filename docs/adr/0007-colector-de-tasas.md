# ADR 0007 · Colector de tasas

- **Estado:** aceptada
- **Fecha:** 2026-11-16
- **Decisores:** IDUCDEV
- **Relacionados:** `docs/DOMINIO.md` §4, §6 y §10, ADR 0005,
  `openspec/changes/backend-collector/`

## Contexto

El esquema de tasas está publicado y congelado (`00001_rates.sql`), pero nadie
escribe en `rate_snapshots`: la vista `rates_latest` nace vacía y la app solo
puede mostrar `No hay tasas publicadas.`

El producto necesita datos reales de dos fuentes:

- **BCV** (`https://www.bcv.org.ve`): dólar y euro, en días hábiles. La página
  no envía el certificado intermedio de Sectigo, así que un `fetch` normal falla
  con `unable to get local issuer certificate`.
- **Binance P2P** (endpoint interno `bapi/c2c/v2/friendly/c2c/adv/search`):
  anuncios de compra y venta de USDT contra VES, 24/7.

No hay host propio: el proyecto es Flutter + Supabase. La clave de escritura no
puede salir del backend porque la app es anónima (ADR 0005).

## Decisión

### 1. Plataforma: Edge Function + `pg_cron` + `pg_net`

La lógica de scraping y publicación vive en una **Edge Function** (`collect-rates`).
El disparo periódico lo hace **`pg_cron`**, que llama a la función con **`pg_net`**.

- La URL de la función y el secreto se guardan en **Vault**; el job los lee con
  `vault.decrypted_secrets`. No quedan en la migración ni en el repositorio.
- La función escribe con `service_role` a través de `record_rate_snapshot()`, el
  único camino de escritura que ya define `00001_rates.sql`.

**Alternativas descartadas:**

| Alternativa | Por qué no |
|---|---|
| Cron externo (GitHub Actions, cron-job.org) | Añade un proveedor, un token y un punto de fallo fuera del proyecto |
| Worker en Postgres con `pg_net` y parseo SQL | Parsear HTML y JSON en PL/pgSQL es frágil y difícil de testear |
| Daemon propio (VPS) | No hay host; contradice el stack del proyecto |

### 2. Frecuencia: cada 30 minutos

El P2P se mueve todo el día y la app promete frescura de 2 h para `p2p_*`. Con
30 min hay margen para dos fallos consecutivos sin que el dato quede viejo.

El BCV publica una vez al día en días hábiles: sus corridas extra son baratas y
la idempotencia por fecha valor evita duplicados.

La purga corre **una vez al día a las 03:00 UTC**, fuera de la ventana de
publicación del BCV.

### 3. Retención: 90 días de snapshots, 30 días de corridas

`purge_old_data()` borra:

- `rate_snapshots` con `fetched_at` anterior a 90 días, **salvo la publicación
  más reciente de cada `(currency_code, type)`**.
- `collector_runs` con `started_at` anterior a 30 días.

La excepción es obligatoria: si un tipo deja de publicarse (por ejemplo un
`p2p_avg` que ya no se puede calcular), su última fila sigue siendo la vigente y
no debe desaparecer de `rates_latest`.

Con una corrida cada 30 min, 90 días son unas 4.300 corridas por fuente y unas
13.000 filas de snapshots en el peor caso: manejable para Postgres y suficiente
para depurar.

### 4. Convención del mercado P2P

| `tradeType` de Binance | Significado | `type` publicado |
|---|---|---|
| `BUY` | Anuncios que **compran** USDT (el usuario vende) | `p2p_buy` |
| `SELL` | Anuncios que **venden** USDT (el usuario compra) | `p2p_sell` |
| — | Promedio simple de los dos promedios | `p2p_avg` |

- `p2p_avg` solo se publica si **ambos** lados tienen un promedio positivo (I-04).
- Se descartan anuncios sin precio válido o con `surplusAmount` no positivo y se
  promedian los primeros `rows` de una página. No se pondera por volumen: el
  brief pide el promedio del mercado, no un VWAP.
- `effective_from` es el instante de la corrida truncado al minuto. El P2P no
  tiene fecha de vigencia propia; truncar evita que dos corridas del mismo minuto
  dupliquen.

### 5. Fechas del BCV: `published_at = effective_from`

La página del BCV informa la **fecha valor** (`content="...T00:00:00-04:00"`)
pero no la hora de publicación.

- `effective_from` = fecha valor.
- `published_at` = `effective_from`, porque es el único instante verificable.

Consecuencia visible: en la ficha, `Publicado` y `Vigente desde` coinciden. Es
preferible a inventar una hora. Queda anotado en `DOMINIO.md` §4.3.

Un reintento el mismo día produce la misma `effective_from` y
`record_rate_snapshot()` lo ignora (`unique` + `on conflict do nothing`).

### 6. TLS del BCV: intermedio de Sectigo embebido

`supabase/functions/collect-rates/certs/intermediate.ts` exporta el intermedio
`Sectigo Public Server Authentication CA DV R36` como cadena, descargado de
`http://crt.sectigo.com/SectigoPublicServerAuthenticationCADVR36.crt` y
convertido a PEM. Va como módulo porque el deploy solo empaqueta módulos
importados, no archivos sueltos.

La función crea un cliente con:

```ts
Deno.createHttpClient({ caCerts: [INTERMEDIATE_PEM] })
```

y lo pasa al `fetch` del BCV. Verificado en edge-runtime 1.78.1 (Deno 2.1.4):
sin el bundle el fetch falla; con el bundle devuelve 200 y el HTML completo. La
cadena se sigue verificando hasta la raíz del sistema: no se desactiva TLS.

**Si el BCV cambia de CA:**

1. `openssl s_client -connect www.bcv.org.ve:443 -servername www.bcv.org.ve -showcerts`
2. Leer la URI `CA Issuers` del certificado hoja.
3. Descargar el `.crt`, convertir con `openssl x509 -in ... -out intermedio.pem`.
4. Reemplazar la cadena en `certs/intermediate.ts` y volver a desplegar.

### 7. Secreto compartido, no JWT

`verify_jwt = false` en `supabase/config.toml`. La función exige la cabecera
`x-collector-secret` y la compara con `COLLECTOR_SECRET` en tiempo constante.

`pg_net` no firma JWTs; el cron envía un secreto estático. La clave de servicio
vive solo en el entorno de la función.

**Rotación:** generar un secreto nuevo, `supabase secrets set COLLECTOR_SECRET=...`,
actualizar el valor en Vault y volver a programar. El orden exacto está en
`docs/SUPABASE_REMOTO.md`.

### 8. Fallo aislado por fuente

Cada fuente corre en su propio `try/catch` con timeout de 10 s. Si el BCV falla,
el P2P se publica igual; si el P2P falla, el BCV se publica igual.

`collector_runs` registra **una fila por fuente** (`bcv`, `binance_p2p`), de
`running` a `ok` o `error`, con `rows_written` y `error_message`. El estado
`partial` existe en el esquema pero no se usa en v1: la salud agregada se lee
mirando las filas de la corrida.

## Consecuencias

- El MVP tiene datos reales sin servidor propio ni claves en el cliente.
- Un fallo de scraping es visible y diagnosticable, no silencioso.
- La retención acota el crecimiento sin romper la vista.
- El intermedio TLS es un activo a mantener: vence en 2036 y el leaf del BCV en
  2026. Un cambio de CA se detecta como corrida en `error`.

## Alternativas descartadas (resumen)

| Alternativa | Por qué no |
|---|---|
| Fuente puente para el BCV (`dolarapi.com`) en v1 | El fetch directo funciona con el bundle; una fuente puente cambia la procedencia visible y hay que nombrarla distinto |
| `--unsafely-ignore-certificate-errors` | Desactiva la validación TLS |
| Promedio ponderado por volumen | El brief pide el promedio del mercado, no un VWAP |
| Una sola fila de `collector_runs` con JSON de detalle | Rompe la FK con `sources` y mezcla salud de dos fuentes |
| Retención infinita | Crecimiento innecesario; el histórico de gráficas es Fase 2 y necesitará otra tabla |
