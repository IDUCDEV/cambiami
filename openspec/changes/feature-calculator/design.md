## Context

Ver `proposal.md`. El cascarón entrega `EsVeFormatter`, tema, DI y `Failure`; el
change `feature-rates` entrega `Rate`, `SelectedRate` y `SelectionCubit`. Este
change no lee Supabase ni `shared_preferences`: recibe una tasa por evento y
convierte.

Las restricciones de comportamiento están en `docs/FEATURES.md` §4 y en
`docs/DOMINIO.md` §10 (casos borde). El texto de compartir es literal de
`DESIGN_SYSTEM.md` §13.5 y no se reescribe.

## Goals / Non-Goals

**Goals:**

- Conversión bidireccional correcta y sin botón.
- Entrada tolerante y con límite, sin estados de error ruidosos.
- Cálculo con cache y banner cuando no hay red.
- Texto de compartir idéntico al sistema de diseño.
- Resultado pintado en el primer frame y actualización por debajo de 100 ms.

**Non-Goals:**

- Leer red o cache directamente.
- Cambiar la selección de tasa (eso es `rates`).
- Persistir cálculos, historial o favoritos.
- Teclado propio, conversión cruzada USD↔EUR.
- `share_plus`.

## Ficheros afectados

| Elemento | Capa | Archivo | Req |
|---|---|---|---|
| Entidad `Conversion` | domain | `features/calculator/domain/entities/conversion.dart` | REQ-CAL-001, REQ-CAL-005 |
| `ParseAmount` | domain | `features/calculator/domain/usecases/parse_amount.dart` | REQ-CAL-002 |
| `ConvertAmount` | domain | `features/calculator/domain/usecases/convert_amount.dart` | REQ-CAL-001, REQ-CAL-003 |
| `BuildShareText` | domain | `features/calculator/domain/usecases/build_share_text.dart` | REQ-CAL-005 |
| Builder de texto puro | core | `core/share/share_text_builder.dart` | REQ-CAL-005 |
| Estados de UI | presentation | `features/calculator/presentation/cubit/calculator_state.dart` | REQ-CAL-001…006 |
| `CalculatorCubit` | presentation | `features/calculator/presentation/cubit/calculator_cubit.dart` | REQ-CAL-001…006 |
| Página `Calculadora` | presentation | `features/calculator/presentation/pages/calculator_page.dart` | REQ-CAL-001…006 |
| `CalculatorBody` | presentation | `features/calculator/presentation/widgets/calculator_body.dart` | REQ-CAL-001, REQ-CAL-004 |
| `AmountField` | core | `core/widgets/amount_field.dart` | REQ-CAL-001, REQ-CAL-002 |
| `ShareSheet` | core | `core/widgets/share_sheet.dart` | REQ-CAL-005 |
| Escucha de selección y moneda | core (composition root) | `core/app/app_shell.dart` | REQ-CAL-003, REQ-CAL-004, REQ-CAL-006 |
| Copy de la feature | l10n | `lib/l10n/arb/app_es.arb` | REQ-CAL-001, REQ-CAL-005, REQ-CAL-006 |

## Contratos Dart clave

```dart
// domain/entities/conversion.dart
enum ConversionDirection { usdToBs, bsToUsd }

class Conversion extends Equatable {
  const Conversion({
    required this.amount,
    required this.rate,
    required this.direction,
    required this.converted,
  });

  final double amount;
  final double rate;
  final ConversionDirection direction;
  final double converted;
}
```

```dart
// domain/usecases/parse_amount.dart
class ParseAmount {
  Either<ValidationFailure, double> call(String input);
}

// domain/usecases/convert_amount.dart
class ConvertAmount {
  Either<Failure, Conversion> call(
    double amount,
    double rate, {
    required ConversionDirection direction,
  });
}

// domain/usecases/build_share_text.dart
class BuildShareText {
  String call({
    required double amount,
    required double rate,
    required DateTime valueDate,
    required String sourceName,
  });
}
```

```dart
// presentation/cubit/calculator_state.dart
sealed class CalculatorState extends Equatable {
  const CalculatorState();
}

final class CalculatorInitial extends CalculatorState {
  const CalculatorInitial({this.rate, this.status, this.fetchedAt});
  final SelectedRate? rate;
  final RateStatus? status;
  final DateTime? fetchedAt;
}

final class CalculatorReady extends CalculatorState {
  const CalculatorReady({
    required this.amount,
    required this.direction,
    required this.converted,
    required this.rate,
    required this.status,
    required this.fetchedAt,
  });

  final double amount;
  final ConversionDirection direction;
  final double converted;
  final SelectedRate rate;
  final RateStatus status;
  final DateTime? fetchedAt;
}

final class CalculatorError extends CalculatorState {
  const CalculatorError(this.message);
  final String message;
}
```

```dart
// presentation/cubit/calculator_cubit.dart (eventos)
abstract class CalculatorEvent extends Equatable {}

final class AmountChanged extends CalculatorEvent {
  const AmountChanged(this.input);
  final String input;
}

final class DirectionToggled extends CalculatorEvent {
  const DirectionToggled(this.direction);
  final ConversionDirection direction;
}

final class SelectedRateChanged extends CalculatorEvent {
  const SelectedRateChanged({
    required this.rate,
    required this.status,
    required this.fetchedAt,
  });
  final SelectedRate rate;
  final RateStatus status;
  final DateTime? fetchedAt;
}

final class Retry extends CalculatorEvent {
  const Retry();
}

final class ShareTapped extends CalculatorEvent {
  const ShareTapped();
}
```

## Decisions

- **D1 — No hay botón de calcular.** `AmountChanged` recalcula en el mismo evento;
  la conversión es aritmética pura y no toca disco ni red.
- **D2 — El widget guarda el texto, el cubit guarda el número.** `AmountField`
  conserva el `TextEditingController` para que `1,` no se borre mientras se
  escribe; el estado solo lleva el `double` ya parseado.
- **D3 — `SelectedRateChanged` lo emite el composition root.** `AppShell` escucha
  `SelectionCubit` y `RatesCubit` y llama al cubit con tasa, estado y `fetchedAt`.
  `calculator` no importa `rates`: solo el kernel.
- **D4 — La dirección la decide el campo enfocado.** Tocar un campo emite
  `DirectionToggled`; no hay selector aparte.
- **D5 — El texto de compartir es una función pura** en `core/share/` y el usecase
  es un adaptador fino. Así `rates` puede compartir tasas con el mismo builder.
- **D6 — Offline no se detecta acá.** El estado `sinConexion` y el `fetchedAt`
  llegan por `SelectedRateChanged`; el cubit solo los pinta.
- **D7 — Tasa no positiva es error de dato, no de entrada.** Se deshabilita el
  resultado y se usa el copy de error de tasas, que ya existe en §13.4.
- **D8 — Compartir usa `url_launcher` + `Clipboard`**, con fallback a
  `https://wa.me/?text=`. No se agrega `share_plus` (FEATURES §6). El enlace del
  mensaje sale de `AppConfig.shareUrl` (`https://cambiami.app`), un solo literal.
- **D9 — La moneda inicial viene de `SettingsCubit` (singleton de app) una sola
  vez**, al construir la página. Un cambio de preferencia no altera la calculadora
  abierta.
- **D10 — `Retry` no hace red.** La página recibe un `VoidCallback onRetry` que el
  `AppShell` cablea a `RatesCubit.refresh()`; el evento del cubit re-ejecuta la
  conversión con el último monto y la última tasa válida, o vuelve a
  `CalculatorInitial` si no hay tasa, sin borrar el texto del campo. Así el botón
  `Reintentar` refresca tasas sin que `calculator` importe `rates`.
- **D11 — Las etiquetas del campo salen de §13.2.** `USD` → `Dólares`, `EUR` →
  `Euros`, `VES` → `Bolívares`, `USDT` → `USDT`. No se usa `currency_name` del
  backend para rotular el campo.

## Backend Supabase

Ninguno directo. La calculadora no consulta tablas, vistas ni RPC: consume
`SelectedRate` y `RateStatus` del kernel, que `feature-rates` ya obtuvo de
`rates_latest`.

## Flujo de datos

```
AmountField ──onChanged──► CalculatorCubit(AmountChanged)
                              ├─ ParseAmount ──► double
                              ├─ ConvertAmount ──► Conversion
                              └─ emit CalculatorReady | CalculatorError

AppShell ──SelectionCubit.stream──► CalculatorCubit(SelectedRateChanged)
        └─SettingsCubit.state────► dirección inicial al construir la página

CalculatorPage ──Reintentar──► onRetry (cableado en AppShell) ──► RatesCubit.refresh()

ShareSheet ──► CalculatorCubit(ShareTapped) ──► BuildShareText ──► core/share/share_text_builder.dart
                                                      ├─ url_launcher (whatsapp:// | https://wa.me)
                                                      └─ Clipboard.setData
```

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| El texto del campo y el número del estado se desincronizan | El campo es la fuente del texto; el estado solo refleja el parseo y nunca reescribe el campo |
| Recalcular en cada tecla produce jank | La conversión es una multiplicación; se mide con el test de rendimiento y no hay `await` en el evento |
| El banner de offline no aparece porque `calculator` no consulta red | `AppShell` propaga el estado de `RatesCubit` en cada emisión; test de cableado |
| El texto de compartir se desvía del diseño | Test de igualdad literal contra el bloque de §13.5, con coma y `Bs` |
| `whatsapp://` falla en escritorio o web | Fallback a `wa.me` y test con un `UrlLauncherPlatform` falso |
| Cambiar de moneda en caliente rompe el monto | La preferencia solo se aplica al abrir; el cambio en caliente está fuera de alcance |

## Migration Plan

1. Entidad y usecases con tests de tabla de parseo y conversión.
2. `CalculatorCubit` con `blocTest` de los cinco eventos.
3. `AmountField`, `CalculatorBody` y `ShareSheet` con golden tests.
4. Cableado en `AppShell` y verificación de que el monto sobrevive al cambio de tasa.
5. Rollback: borrar `features/calculator/` y los widgets de `core/` que solo usa
   esta feature; el cascarón sigue compilando.

## Open Questions

- Copy para tasa no positiva: se reutiliza el de error de tasas hasta que H1
  confirme si el colector puede publicar `0`.
- Si `SettingsCubit` cambia la moneda mientras la calculadora está montada, se
  aplica en la próxima apertura; confirmar que el usuario no espera efecto inmediato.
