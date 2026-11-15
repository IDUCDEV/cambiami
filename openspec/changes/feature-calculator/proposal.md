## Why

La promesa central del producto es una calculadora que convierte con la tasa
vigente, sin botón, sin red y sin ambigüedad de formato. El cascarón ya tiene el
formatter es-VE y `feature-rates` entrega la tasa seleccionada; falta el módulo que
hace la conversión y la comparte.

Este change implementa el módulo `calculator` de `docs/FEATURES.md` §4: entrada de
monto, conversión bidireccional, comportamiento offline y texto de compartir. No
toca el catálogo ni las preferencias.

## What Changes

- Entidad `Conversion` y tres usecases: `ParseAmount`, `ConvertAmount`,
  `BuildShareText`.
- `CalculatorCubit` con `CalculatorInitial`, `CalculatorReady` y `CalculatorError`,
  y los eventos `AmountChanged`, `DirectionToggled`, `SelectedRateChanged`,
  `Retry` y `ShareTapped`.
- Pantalla 02 Calculadora con sus estados 02b, 03 y 04, sin animación de entrada.
- `CalculatorBody`, `AmountField`, `ShareSheet` y el builder de texto en `core/`.
- Cableado del composition root: `SelectionCubit` alimenta `CalculatorCubit` sin
  que `calculator` importe `rates`.
- **BREAKING:** ninguno. Es código nuevo sobre un cascarón sin features.

## Capabilities

### New Capabilities

- `calculator`: conversión de montos, entrada tolerante, conservación del monto,
  cálculo offline, compartir y respuesta inmediata.

### Modified Capabilities

Ninguna: la capacidad `rates` no cambia; `calculator` solo consume su tipo de
kernel `SelectedRate`.

## Impact

- `apps/mobile/lib/features/calculator/{domain,presentation}/`.
- `apps/mobile/lib/core/share/share_text_builder.dart`.
- `apps/mobile/lib/core/widgets/{amount_field,share_sheet}.dart`.
- `apps/mobile/lib/core/app/app_shell.dart` (evento de tasa y de moneda inicial).
- `apps/mobile/lib/l10n/arb/app_es.arb`.
- Depende de `mobile-shell` (formatter, tema, DI, errores) y de `feature-rates`
  (`Rate`, `SelectedRate`, `SelectionCubit`).
- Fuera de alcance: historial de cálculos, favoritos, teclado propio, conversión
  entre dos monedas distintas de VES.
