# ADR 0003 · Cache local

- **Estado:** aceptada
- **Fecha:** 2026-11-14
- **Decisores:** IDUCDEV
- **Relacionados:** `docs/DOMINIO.md` §9, ADR 0002, `DESIGN_SYSTEM.md` §7.10

## Contexto

La app tiene que abrir sin red y mostrar la última tasa cacheada (HU-04, F-03).
Además guarda el catálogo cacheado y tres preferencias: tasa seleccionada, Mi tasa
y moneda por defecto.

El volumen de datos es mínimo: cinco filas de la vista `rates_latest` y tres
valores escalares. No hay consultas, no hay relaciones, no hay histórico en v1.

Hay tres propuestas contradictorias en los documentos actuales:

- El brief (`TASAVE_DOCUMENTO_UNIFICADO.md`) dice **Drift**.
- El scaffold (`PROMPT-POR-FASES/`) trae **Isar** cableado con su generador.
- El sistema de diseño ya usa **`shared_preferences`** para Mi tasa, y la API
  vigente del paquete es `SharedPreferencesWithCache`.

## Decisión

**`shared_preferences` con `SharedPreferencesWithCache` para todo el estado local
de v1.**

- La respuesta de `rates_latest` se guarda como un JSON único en
  `cambiami.rates.v1`, con `savedAt` y las filas.
- Las preferencias usan claves versionadas propias (`cambiami.*.v1`).
- La instancia se crea una vez con
  `SharedPreferencesWithCache.create(cacheOptions:
  const SharedPreferencesWithCacheOptions(allowList: {...}))` y un `allowList`
  cerrado de cuatro claves: `cambiami.rates.v1`, `cambiami.selected_rate.v1`,
  `cambiami.custom_rate.v1` y `cambiami.default_currency.v1`. Una clave fuera de
  la lista se rechaza en escritura y no se lee.
- La lectura ocurre antes del primer frame de la calculadora, durante el splash de
  400 ms que ya define el diseño; la red se lanza en paralelo y no se espera.
- No hay TTL: el dato viejo se muestra con estado `desactualizado` o
  `sin_conexion`, nunca se borra por tiempo.
- `CacheManager` se mantiene como registro de limpiadores, pero con una sola
  implementación; no se justifica una abstracción por datasource.

## Alternativas descartadas

| Alternativa | Por qué no |
|---|---|
| Isar (scaffold) | Base de datos completa para cinco filas; suma codegen, librerías nativas y un generador atado a `analyzer < 11` |
| Drift (brief) | Lo mismo que Isar, con SQL y migraciones de esquema que v1 no necesita |
| Hive | Igual de capaz que Isar sin el generador, pero sigue siendo un motor de más |
| `sqflite` | Se paga el costo de SQL sin necesidad de consultas |
| Archivo JSON en `path_provider` | `SharedPreferencesWithCache` ya resuelve atomicidad y plataforma sin dependencia extra |

## Consecuencias

### Positivas

- Cero codegen de cache: `build_runner` queda solo para DI (ADR 0002).
- El `pubspec` no queda atado a versiones viejas de `analyzer`; se puede usar el
  Flutter instalado (3.47) sin pelear con el generador.
- El cache es inspeccionable y testeable con un doble en memoria detrás de
  `SharedPreferencesWithCache`.
- El arranque sin red es un test unitario simple: se precarga el JSON y se verifica
  el primer estado del cubit.

### Negativas / costo

- **No hay consultas reactivas.** No existe `watch()`: cuando cambia el cache, el
  cubit emite el nuevo estado a mano. Aceptable porque solo escribe la app.
- **La selección se propaga por un stream en memoria**, no por el almacenamiento.
  El repositorio mantiene un `StreamController` que emite al escribir la selección;
  al reiniciar, el primer valor sale del cache. No es `watch()` de
  `SharedPreferencesWithCache` y no contradice el punto anterior.
- **Sin índices ni migraciones de esquema.** Un cambio de forma se resuelve subiendo
  la versión de la clave y descartando la anterior.
- **Si en Fase 2 entra el histórico**, hay que migrar a Drift o Isar. El costo está
  acotado porque el acceso pasa por un repositorio, no por widgets.
- `SharedPreferencesWithCache` no es para datos sensibles. Acá no hay ninguno: no
  hay tokens ni credenciales de usuario.

## Verificación

- Test: con el JSON precargado y la red caída, el primer estado es
  `RatesLoaded` con `sinConexion` y la calculadora convierte.
- Test: tras una respuesta válida, la clave `cambiami.rates.v1` contiene las filas.
- Test: escribir una clave fuera del `allowList` se rechaza y no deja rastro en el
  almacenamiento.
- Test: un JSON corrupto en `cambiami.rates.v1` arranca sin cache y sin excepción.
- Test: subir la versión de la clave descarta la anterior sin excepción.
- Prueba manual: modo avión, abrir la app, calcular, cerrar y reabrir.

## Cuándo revisar

- Cuando entre histórico o gráficas (Fase 2).
- Si el cache supera los ~100 KB o necesita consultas por rango.
- Si aparece cualquier dato sensible que requiera almacenamiento seguro.
