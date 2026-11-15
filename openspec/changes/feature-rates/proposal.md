## Why

El backend ya publica `rates_latest` y el cascarón ya tiene tema, router, DI y
formato. Falta el módulo que convierte esa vista en el catálogo que el usuario ve
y en la tasa con la que calcula. Sin él, la calculadora no tiene de dónde sacar un
valor y la pantalla Tasas no existe.

Este change implementa el módulo `rates` de `docs/FEATURES.md` §3: leer el
catálogo, mostrar su procedencia y frescura, dejar elegir una tasa y guardar una
tasa manual. No toca el backend ni la conversión.

## What Changes

- Entidades de kernel `Rate` y `SelectedRate` en `core/domain/` (ADR 0006), con
  `RateModel` en la capa de datos.
- `RatesRemoteDataSource` sobre PostgREST (`rates_latest`) y
  `RatesLocalDataSource` sobre `shared_preferences` (`cambiami.rates.v1`,
  `cambiami.selected_rate.v1`, `cambiami.custom_rate.v1`).
- Repositorio con seis operaciones: cache, red, observación de la selección,
  selección, guardar y borrar Mi tasa.
- `RatesCubit`, `SelectionCubit` y `CustomRateCubit` con sus estados.
- Pantalla 05 Tasas (catálogo agrupado, skeleton, vacío y error), sheet 09 Monedas
  y sheet 09b Mi tasa.
- Widgets de la feature: `RateCard`, `RateCardCompact`, `SectionHeader`,
  `MethodNote`, `FreshnessStrip`, `RateRow`.
- **BREAKING:** ninguno. Es código nuevo sobre un cascarón sin features.

## Capabilities

### New Capabilities

Ninguna: este change **agrega requisitos de cliente a la capacidad `rates`**, que
`backend-rates` abrió con el contrato de datos. Los nombres de requisito no
colisionan porque el spec del backend no usa IDs y acá se numeran como
`REQ-CAT-001…007` para poder citarlos en `design.md` y `tasks.md`.

### Modified Capabilities

- `rates`: se agregan los requisitos de catálogo, agrupación, frescura en
  pantalla, selección persistente y tasa manual. No se modifican ni se retiran los
  requisitos del backend.

## Impact

- `apps/mobile/lib/core/domain/entities/{rate,selected_rate}.dart`.
- `apps/mobile/lib/features/rates/{data,domain,presentation}/`.
- `apps/mobile/lib/core/di/service_locator.dart` (registro de datasources,
  repositorio, usecases y cubits).
- `apps/mobile/lib/core/app/app_shell.dart` (escucha de `SelectionCubit`).
- `apps/mobile/lib/l10n/arb/app_es.arb` (copy de la feature).
- Depende de `mobile-shell` (tema, router, DI, formatter, errores) y de
  `backend-rates` (vista `rates_latest` y RLS de lectura).
- Fuera de alcance: histórico, gráficas, brecha persistida, panel de salud del
  colector y cualquier escritura desde la app.
