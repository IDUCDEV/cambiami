# Cambiami — Contrato de dominio (v1)

> **Estado:** vigente · **Versión:** 1.0 · **Fecha:** 2026-11-14
> **Alcance:** MVP v1 (8 features). Fase 2 se documenta solo como extensión prevista.
> **Documentos relacionados:** `docs/PLAN_DE_DESARROLLO.md` (HU y features),
> `design/DESIGN_SYSTEM.md` (contrato visual), `docs/adr/` (decisiones técnicas).

---

## 0. Para qué existe este documento

El mismo dato vive en tres lugares con tres formas: una tabla en Postgres, un
objeto en Dart y un registro en el cache local. Si no hay un documento que fije
la forma canónica, los tres divergen y el error aparece como un `null` en la UI.

Este documento es **el contrato de datos de v1**. Todo lo que lo contradiga
(migración, modelo Dart, cache, tests) está mal, salvo que exista un ADR que lo
reemplace.

**Regla de oro:** si un dato no está acá, no existe. No se inventan campos en la
UI ni en el cliente.

---

## 1. Alcance

### 1.1 Dentro de v1

| Objeto | Tipo | Motivo |
|---|---|---|
| `currencies` | tabla | Catálogo de monedas (USD, EUR, USDT) |
| `sources` | tabla | Fuente y mercado de cada tasa (BCV, Binance P2P) |
| `rate_snapshots` | tabla | Historial crudo de publicaciones del colector |
| `collector_runs` | tabla | Registro de ejecuciones del colector (salud y depuración) |
| `rates_latest` | vista | Una fila vigente por `currency_code` + `type`. Es lo único que lee la app |

### 1.2 Fuera de v1

| Objeto | Por qué queda afuera | Cuándo entra |
|---|---|---|
| `countries` | v1 es solo Venezuela; `VES` se hardcodea | Fase 2 (multi-país) |
| `rate_series` | No hay gráficas ni histórico en v1 | Fase 2 |
| `usdt_averages` | El promedio P2P se guarda como fila `p2p_avg` | No hace falta |
| `rate_health` | La salud se deriva de `collector_runs` y del cliente | Fase 2 (panel) |
| `payment_profiles` | Requiere usuarios | Fase 2 (F-11) |
| `alert_subscriptions`, `device_tokens` | Requiere auth y push | Fase 2 |
| `articles`, `methodology_docs`, `app_config` | El copy vive en ARB y en el diseño | Fase 2 |
| `auth.users`, `profiles` | La app es anónima (ADR 0005) | Fase 2, si aparece una feature con cuenta |

La lista de 13 tablas del brief es inventario aspiracional, no el modelo de v1.

---

## 2. Glosario

| Término | Definición |
|---|---|
| **Tasa** | Valor de una moneda expresado en bolívares. Siempre `Bs` por 1 unidad. |
| **Snapshot** | Una publicación concreta de una fuente, con su fecha de vigencia. |
| **`published_at`** | Cuándo la fuente publicó el dato (BCV: 5:00 p. m. de días hábiles). |
| **`effective_from`** | Desde cuándo rige el dato. Puede ser posterior a `published_at`. |
| **`fetched_at`** | Cuándo el colector trajo el dato a la base. |
| **Fuente** | Quién publica: `bcv`, `binance_p2p`. |
| **Mercado** | Agrupación visual: `oficial` o `p2p`. Se deriva de `sources.kind`. |
| **Tipo** | Rol del valor dentro de la moneda: `oficial`, `p2p_buy`, `p2p_sell`, `p2p_avg`. |
| **Mi tasa** | Tasa manual del usuario, en bolívares. **Nunca** se guarda en la base. |
| **Frescura** | Estado derivado en el cliente: `al_dia`, `desactualizado`, `sin_conexion`. |
| **Brecha** | Diferencia porcentual entre el promedio P2P y la tasa oficial. Se calcula en la UI. |

`published_at` y `effective_from` son campos distintos y no se sustituyen entre sí
(supuesto S-05 del brief). Si el BCV no distingue ambos, el colector los iguala y
lo deja registrado en `collector_runs.error_message`.

---

## 3. Modelo

```
currencies ──< rate_snapshots >── sources
                    │
                    └── rates_latest (vista, 1 fila por currency_code + type)

collector_runs >── sources
```

- `rate_snapshots` es **append-only**: el colector inserta, nunca actualiza.
- `rates_latest` no almacena: proyecta la última fila vigente de cada tipo.
- `collector_runs` no se lee desde la app en v1; existe para operar el colector.

---

## 4. Tablas

### 4.1 `currencies`

| Columna | Tipo | Nulo | Default | Restricción |
|---|---|---|---|---|
| `code` | `text` | no | — | PK, 3–6 mayúsculas |
| `name` | `text` | no | — | — |
| `symbol` | `text` | no | — | — |
| `decimals` | `smallint` | no | `2` | `between 0 and 6` |
| `kind` | `text` | no | — | `in ('fiat','stablecoin')` |
| `is_active` | `boolean` | no | `true` | — |
| `created_at` | `timestamptz` | no | `now()` | — |

Filas de v1: `USD` (Dólar, `$`, fiat), `EUR` (Euro, `€`, fiat), `USDT` (Tether,
`₮`, stablecoin).

### 4.2 `sources`

| Columna | Tipo | Nulo | Default | Restricción |
|---|---|---|---|---|
| `code` | `text` | no | — | PK |
| `name` | `text` | no | — | — |
| `url` | `text` | no | — | URL pública |
| `kind` | `text` | no | — | `in ('oficial','p2p')` |
| `is_active` | `boolean` | no | `true` | — |

Filas de v1: `bcv` (BCV, `https://www.bcv.org.ve`, oficial), `binance_p2p`
(Binance P2P, `https://p2p.binance.com`, p2p).

### 4.3 `rate_snapshots`

| Columna | Tipo | Nulo | Default | Restricción |
|---|---|---|---|---|
| `id` | `bigint` | no | identity | PK |
| `currency_code` | `text` | no | — | FK → `currencies.code` |
| `source_code` | `text` | no | — | FK → `sources.code` |
| `type` | `text` | no | — | `in ('oficial','p2p_buy','p2p_sell','p2p_avg')` |
| `rate_value` | `numeric(18,6)` | no | — | `> 0` |
| `effective_from` | `timestamptz` | no | — | — |
| `published_at` | `timestamptz` | sí | — | — |
| `fetched_at` | `timestamptz` | no | `now()` | — |
| `change_pct` | `numeric(8,4)` | sí | — | — |

Restricciones:

- `unique (currency_code, type, effective_from)` → el colector hace `upsert` y
  reintentar es idempotente.
- Índice `(currency_code, type, effective_from desc)` → alimenta la vista.
- Índice `(fetched_at desc)` → depuración y retención.

**Campos que NO existen y por qué:**

| Ausente | Motivo |
|---|---|
| `status` | Es estado derivado del cliente (§6). Guardarlo obliga a un job que lo actualice y miente cuando el usuario está sin red |
| `is_down` | Se deriva del signo de `change_pct` |
| `official` | Se deriva de `sources.kind`; la vista lo expone como booleano |
| `principal` | En v1 la moneda por defecto es una preferencia local, no un atributo del dato |
| `country_code` | v1 es solo `VE` |
| `base_currency_code` | v1 expresa todo en `VES`; agregarlo después es una migración de una línea |

### 4.4 `collector_runs`

| Columna | Tipo | Nulo | Default | Restricción |
|---|---|---|---|---|
| `id` | `bigint` | no | identity | PK |
| `source_code` | `text` | no | — | FK → `sources.code` |
| `started_at` | `timestamptz` | no | `now()` | — |
| `finished_at` | `timestamptz` | sí | — | — |
| `status` | `text` | no | `'running'` | `in ('running','ok','partial','error')` |
| `rows_written` | `integer` | no | `0` | `>= 0` |
| `error_message` | `text` | sí | — | — |

Índice `(source_code, started_at desc)`.

---

## 5. Vista `rates_latest`

Una fila por `currency_code` + `type`, con la publicación vigente. Es el **único**
objeto que lee la app.

```sql
create view public.rates_latest
with (security_invoker = true)
as
select distinct on (s.currency_code, s.type)
  s.currency_code,
  c.name                    as currency_name,
  c.symbol,
  c.decimals,
  s.type,
  s.rate_value,
  s.source_code,
  src.name                  as source_name,
  src.url                   as source_url,
  (src.kind = 'oficial')    as official,
  s.effective_from,
  s.published_at,
  s.fetched_at,
  s.change_pct
from public.rate_snapshots s
join public.currencies c  on c.code = s.currency_code
join public.sources   src on src.code = s.source_code
where s.effective_from <= now()
order by s.currency_code, s.type, s.effective_from desc, s.fetched_at desc;
```

Decisiones:

- **`security_invoker = true`**: la vista respeta las policies del que consulta.
  No hay `security definer` en v1 (ADR 0005).
- **`effective_from <= now()`**: una tasa programada no se muestra antes de regir.
- **`official` sale de `sources.kind`**, no de una columna duplicada. Una stablecoin
  nueva entra como fila del grupo que le corresponde sin tocar el esquema.
- **`distinct on`** exige que el `order by` empiece con las mismas columnas.

---

## 6. Frescura y estado

El estado **no se guarda**: se calcula en el cliente, en
`lib/core/domain/rate_status_resolver.dart`.

| Estado | Condición | Prioridad |
|---|---|---|
| `sinConexion` | La última consulta de red falló | 1 (gana siempre) |
| `desactualizado` | La consulta funcionó y la edad del dato supera el umbral de su tipo | 2 |
| `alDia` | La consulta funcionó y la edad está dentro del umbral | 3 |

Edad = `now - published_at` (si `published_at` es nulo, `now - fetched_at`).

| Tipo | Umbral v1 | Motivo |
|---|---|---|
| `oficial` | 26 h | BCV publica a las 17:00 en días hábiles; 26 h cubre un fin de semana corto |
| `p2p_*` | 2 h | Binance opera 24/7; el colector corre cada 30 min |
| Mi tasa | no aplica | No tiene `published_at` ni `fetched_at`; la ficha dice `Definida por ti` |

Los umbrales viven en `lib/core/constants/constants.dart` y son **provisionales**:
se validan en H1 con la respuesta real del BCV (S-05). Cambiarlos no es un cambio
de dominio, es un ajuste de constante.

La UI usa `fetched_at` para el texto de la franja (`Actualizado hoy · 9:41 a. m.`)
y el estado derivado para el pill. El banner de `desactualizado` y
`sin_conexion` sale de `DESIGN_SYSTEM.md` §13.3.

---

## 7. Mapeo a Dart

| Concepto SQL | Tipo Dart | Archivo | Nota |
|---|---|---|---|
| Fila de `rates_latest` | `Rate` (entidad) | `lib/core/domain/entities/rate.dart` | Inmutable, `Equatable` |
| JSON de la vista | `RateModel` (modelo) | `lib/features/rates/data/models/rate_model.dart` | `fromJson`/`toJson` explícitos |
| `type` | `enum RateType` | `lib/core/domain/enums/rate_type.dart` | `oficial`, `p2pBuy`, `p2pSell`, `p2pAvg` |
| Estado derivado | `enum RateStatus` | `lib/core/domain/enums/rate_status.dart` | `alDia`, `desactualizado`, `sinConexion` |
| Tasa seleccionada | `sealed SelectedRate` | `lib/core/domain/entities/selected_rate.dart` | `CatalogRate(Rate)` \| `CustomRate(double)` |
| `rate_value`, `change_pct` | `double` | — | Solo para mostrar y multiplicar |
| `published_at`, `effective_from`, `fetched_at` | `DateTime` (UTC) | — | Se convierten a local al formatear |
| `currency_code` | `String` | — | Catálogo viene de la base, no de un enum |
| `official` | `bool` | — | Agrupa el catálogo |

**`RateSnapshot` no existe en Dart en v1.** La app nunca lee la tabla cruda: lee
la vista. El equivalente es `RateModel`. Si en Fase 2 aparece el histórico, se
agrega entonces, no antes.

Reglas de tipos:

- No hay `Decimal` en Dart. `double` alcanza porque solo se muestra y se
  multiplica; el redondeo es visual y ocurre en `EsVeFormatter`.
- No hay `Money` como value object en v1: agrega ceremonia sin evitar un error
  real. El formateador es la única puerta de salida de un número.
- `SelectedRate` es `sealed` para que la UI no pueda olvidar el caso Mi tasa.

---

## 8. Contrato de lectura

La app consulta la vista por PostgREST con la clave publicable y RLS de lectura.

```
GET /rest/v1/rates_latest
  ?select=currency_code,currency_name,symbol,decimals,type,rate_value,
          source_code,source_name,source_url,official,
          effective_from,published_at,fetched_at,change_pct
  &order=official.desc,currency_code.asc,type.asc
```

- Sin `limit` explícito: la vista devuelve como máximo 5 filas en v1.
- Sin filtro por fecha: la vista ya resuelve la vigencia.
- `order` deja el catálogo listo para pintar: primero Oficial, después P2P.

Respuesta (una fila):

```json
{
  "currency_code": "USD",
  "currency_name": "Dólar",
  "symbol": "$",
  "decimals": 2,
  "type": "oficial",
  "rate_value": 889.5754,
  "source_code": "bcv",
  "source_name": "BCV",
  "source_url": "https://www.bcv.org.ve",
  "official": true,
  "effective_from": "2026-11-03T00:00:00-04:00",
  "published_at": "2026-11-02T17:00:00-04:00",
  "fetched_at": "2026-11-02T21:10:00-04:00",
  "change_pct": 0.04
}
```

Errores esperados:

| Situación | Qué hace el cliente |
|---|---|
| `401` / `403` | `ServerFailure`: configuración inválida, no se reintenta |
| `5xx` o timeout | `NetworkFailure`: muestra cache y marca `sinConexion` |
| Respuesta vacía | `RatesEmpty`: estado vacío, sin inventar tasas |
| Fila con `rate_value <= 0` | Se descarta en el modelo |

---

## 9. Cache local

`shared_preferences` (ADR 0003). Claves versionadas; un cambio de forma sube la
versión y descarta la anterior.

| Clave | Contenido | Se escribe |
|---|---|---|
| `cambiami.rates.v1` | JSON `{ "savedAt": "...", "rows": [RateModel...] }` | Tras cada consulta exitosa |
| `cambiami.selected_rate.v1` | `{ "kind": "catalog", "currencyCode": "USD", "type": "oficial" }` o `{ "kind": "custom" }` | Al elegir en Monedas |
| `cambiami.custom_rate.v1` | `double` en bolívares | Al guardar Mi tasa |
| `cambiami.default_currency.v1` | `String` (`USD`, `EUR`, `USDT`) | En Configuración |

Reglas:

- **Escritura:** solo después de una respuesta válida. Nunca se cachea un error.
- **Lectura:** al arrancar, antes del primer frame de la calculadora. El splash de
  400 ms es la ventana para leer el cache.
- **Invalidación:** no hay TTL. El dato viejo se muestra con estado
  `desactualizado` o `sin_conexion`; nunca se borra por tiempo.
- **Mi tasa** es local y no entra en `cambiami.rates.v1` ni en el catálogo.

---

## 10. Invariantes y casos borde

| # | Invariante | Dónde se hace cumplir |
|---|---|---|
| I-01 | `rate_value > 0` | `check` en la tabla y descarte en el modelo |
| I-02 | Una fila vigente por `currency_code` + `type` | `distinct on` de la vista |
| I-03 | Reintentar el colector no duplica | `unique` + `upsert` |
| I-04 | `p2p_avg` es el promedio de `p2p_buy` y `p2p_sell` | Colector; si falta un lado, no hay `p2p_avg` |
| I-05 | `change_pct` compara con la publicación anterior del mismo tipo | Colector al insertar; `null` si no hay anterior |
| I-06 | Mi tasa no viaja al backend | Solo `shared_preferences` |
| I-07 | El estado no se persiste | `RateStatusResolver` en el cliente |

Casos borde de la calculadora:

- Tasa `<= 0` → no se calcula, se muestra error de validación.
- Monto vacío → `0,00`, no error.
- Entrada con coma o punto → se normaliza; solo dígitos y un separador.
- Más de 12 dígitos → se recorta la entrada.
- Cambiar de tasa conserva el monto y recalcula.
- Moneda sin fila en `rates_latest` → no se muestra tarjeta. El copy de "sin datos
  de una moneda" está **pendiente (H1)** y no se inventa.
- Redondeo: solo visual, half-up a la cantidad de decimales de la moneda.

---

## 11. Extensión prevista (no implementar)

| Necesidad futura | Cambio mínimo |
|---|---|
| Multi-país | `countries` + `country_code` en `rate_snapshots` + filtro en la vista |
| Histórico y gráficas | Leer `rate_snapshots` con rango; `rate_series` no hace falta |
| Tasa del siguiente día hábil (F-06) | Calendario de feriados versionado + `effective_from` futuro (la vista ya lo respeta) |
| Otra stablecoin | Una fila en `currencies` y filas del colector; cero cambios de esquema |
| Auth y perfiles | `auth.users` + tablas propias con RLS por `user_id` |

---

## 12. Trazabilidad

| Objeto | Historias | Features |
|---|---|---|
| `currencies` | HU-06, HU-07 | F-05, F-08 |
| `sources` | HU-03, HU-08, HU-11 | F-02, F-12 |
| `rate_snapshots` | HU-03, HU-11 | F-02 |
| `collector_runs` | — (operación) | F-02 |
| `rates_latest` | HU-02, HU-03, HU-06, HU-11 | F-01, F-02, F-03, F-05 |
| Cache local | HU-01, HU-04, HU-07 | F-01, F-03, F-08 |
| Mi tasa | HU-06 | F-05 |

---

*Contrato de dominio de Cambiami · v1.0 · 2026-11-14 · IDUCDEV para TasaVE C.A.*
