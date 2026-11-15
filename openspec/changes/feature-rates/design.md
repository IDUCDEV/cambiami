## Context

Ver `proposal.md`. El cascarón de `mobile-shell` ya entrega tema, router, DI,
`EsVeFormatter`, `Failure`/`ErrorMapper`, `PreferencesService` y el kernel mínimo
(`RateType`, `RateStatus`, `RateStatusResolver`). El backend de `backend-rates` ya
expone `rates_latest` con RLS de solo lectura.

Lo que falta es el módulo que consume esa vista. `docs/FEATURES.md` §3 fija sus seis
usecases y sus tres cubits; `docs/DOMINIO.md` §5, §7 y §9 fijan el contrato de
lectura y las claves de cache; `design/DESIGN_SYSTEM.md` §7.2, §7.6–7.10 y §13 fijan
componentes y copy. Este change no redefine nada de eso: lo implementa.

## Goals / Non-Goals

**Goals:**

- Catálogo agrupado por mercado, con procedencia y frescura visibles.
- Selección persistente que llega a la calculadora sin imports cruzados.
- Mi tasa manual, local y fuera del catálogo.
- Estados de carga, vacío y error dibujados, no improvisados.
- Cache tolerante a datos corruptos y a filas inválidas.

**Non-Goals:**

- Conversión de montos (`feature-calculator`).
- Histórico, gráficas, panel de salud del colector.
- Escritura en Supabase, RPC o auth.
- Copia de "sin datos de una moneda": pendiente de H1 y no se inventa.

## Ficheros afectados

| Elemento | Capa | Archivo | Req |
|---|---|---|---|
| Entidad `Rate` | domain (kernel) | `core/domain/entities/rate.dart` | REQ-CAT-001, REQ-CAT-003 |
| Entidad `SelectedRate` | domain (kernel) | `core/domain/entities/selected_rate.dart` | REQ-CAT-005, REQ-CAT-006 |
| Modelo `RateModel` | data | `features/rates/data/models/rate_model.dart` | REQ-CAT-001, REQ-CAT-007 |
| DataSource remoto | data | `features/rates/data/datasources/rates_remote_data_source.dart` | REQ-CAT-001 |
| DataSource local | data | `features/rates/data/datasources/rates_local_data_source.dart` | REQ-CAT-001, REQ-CAT-005, REQ-CAT-006, REQ-CAT-007 |
| Contrato de repositorio | domain | `features/rates/domain/repositories/rates_repository.dart` | REQ-CAT-001…007 |
| Implementación de contrato | data | `features/rates/data/repositories/rates_repository_impl.dart` | REQ-CAT-001…007 |
| `GetCachedRates` | domain | `features/rates/domain/usecases/get_cached_rates.dart` | REQ-CAT-001 |
| `FetchLatestRates` | domain | `features/rates/domain/usecases/fetch_latest_rates.dart` | REQ-CAT-001, REQ-CAT-007 |
| `WatchSelectedRate` | domain | `features/rates/domain/usecases/watch_selected_rate.dart` | REQ-CAT-005 |
| `SelectRate` | domain | `features/rates/domain/usecases/select_rate.dart` | REQ-CAT-005 |
| `SaveCustomRate` | domain | `features/rates/domain/usecases/save_custom_rate.dart` | REQ-CAT-006 |
| `ClearCustomRate` | domain | `features/rates/domain/usecases/clear_custom_rate.dart` | REQ-CAT-006 |
| Estados de UI (catálogo) | presentation | `features/rates/presentation/cubit/rates_state.dart` | REQ-CAT-001…004 |
| `RatesCubit` | presentation | `features/rates/presentation/cubit/rates_cubit.dart` | REQ-CAT-001…004 |
| Estados de UI (selección) | presentation | `features/rates/presentation/cubit/selection_state.dart` | REQ-CAT-005 |
| `SelectionCubit` | presentation | `features/rates/presentation/cubit/selection_cubit.dart` | REQ-CAT-005 |
| Estados de UI (Mi tasa) | presentation | `features/rates/presentation/cubit/custom_rate_state.dart` | REQ-CAT-006 |
| `CustomRateCubit` | presentation | `features/rates/presentation/cubit/custom_rate_cubit.dart` | REQ-CAT-006 |
| Página `Tasas` | presentation | `features/rates/presentation/pages/rates_page.dart` | REQ-CAT-002, REQ-CAT-003, REQ-CAT-004 |
| `RateCard` | presentation | `features/rates/presentation/widgets/rate_card.dart` | REQ-CAT-002, REQ-CAT-003 |
| `RateCardCompact` | presentation | `features/rates/presentation/widgets/rate_card_compact.dart` | REQ-CAT-003 |
| `SectionHeader` | presentation | `features/rates/presentation/widgets/section_header.dart` | REQ-CAT-002 |
| `MethodNote` | presentation | `features/rates/presentation/widgets/method_note.dart` | REQ-CAT-003 |
| `FreshnessStrip` | presentation | `features/rates/presentation/widgets/freshness_strip.dart` | REQ-CAT-003 |
| `RateRow` | presentation | `features/rates/presentation/widgets/rate_row.dart` | REQ-CAT-005 |
| Sheet `Monedas` | presentation | `features/rates/presentation/widgets/coins_sheet.dart` | REQ-CAT-005 |
| Sheet `Mi tasa` | presentation | `features/rates/presentation/widgets/mi_tasa_sheet.dart` | REQ-CAT-006 |
| Escucha de selección | core (composition root) | `core/app/app_shell.dart` | REQ-CAT-005 |
| Copy de la feature | l10n | `lib/l10n/arb/app_es.arb` | REQ-CAT-003, REQ-CAT-004, REQ-CAT-006 |

## Contratos Dart clave

```dart
// domain/repositories/rates_repository.dart
abstract class RatesRepository {
  Future<Either<Failure, List<Rate>>> getCachedRates();
  Future<Either<Failure, List<Rate>>> fetchLatestRates();
  Stream<SelectedRate> watchSelectedRate();
  Future<Either<Failure, Unit>> selectRate(SelectedRate rate);
  Future<Either<Failure, Unit>> saveCustomRate(double value);
  Future<Either<Failure, Unit>> clearCustomRate();
}
```

```dart
// presentation/cubit/rates_state.dart
sealed class RatesState extends Equatable {
  const RatesState();
}

final class RatesLoading extends RatesState {
  const RatesLoading();
}

final class RatesLoaded extends RatesState {
  const RatesLoaded({
    required this.rates,
    required this.status,
    required this.fetchedAt,
    this.isRefreshing = false,
  });

  final List<Rate> rates;
  final RateStatus status;
  final DateTime? fetchedAt;
  final bool isRefreshing;
}

final class RatesEmpty extends RatesState {
  const RatesEmpty();
}

final class RatesError extends RatesState {
  const RatesError(this.message);
  final String message;
}
```

```dart
// presentation/cubit/selection_state.dart
sealed class SelectionState extends Equatable {
  const SelectionState();
}

final class SelectionLoaded extends SelectionState {
  const SelectionLoaded({required this.selected, this.customRate});
  final SelectedRate selected;
  final double? customRate;
}

final class SelectionSaving extends SelectionState {
  const SelectionSaving({required this.selected, this.customRate});
  final SelectedRate selected;
  final double? customRate;
}
```

```dart
// presentation/cubit/custom_rate_state.dart
sealed class CustomRateState extends Equatable {
  const CustomRateState();
}

final class CustomRateEditing extends CustomRateState {
  const CustomRateEditing({required this.input, required this.isValid});
  final String input;
  final bool isValid;
}

final class CustomRateSaved extends CustomRateState {
  const CustomRateSaved();
}
```

```dart
// core/domain/entities/rate.dart
class Rate extends Equatable {
  const Rate({
    required this.currencyCode,
    required this.currencyName,
    required this.symbol,
    required this.decimals,
    required this.type,
    required this.value,
    required this.sourceCode,
    required this.sourceName,
    required this.sourceUrl,
    required this.official,
    required this.effectiveFrom,
    required this.fetchedAt,
    this.publishedAt,
    this.changePct,
  });

  final String currencyCode;
  final String currencyName;
  final String symbol;
  final int decimals;
  final RateType type;
  final double value;
  final String sourceCode;
  final String sourceName;
  final String sourceUrl;
  final bool official;
  final DateTime effectiveFrom;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final double? changePct;
}
```

```dart
// core/domain/entities/selected_rate.dart
sealed class SelectedRate extends Equatable {
  const SelectedRate();
}

final class CatalogRate extends SelectedRate {
  const CatalogRate({required this.currencyCode, required this.type});
  final String currencyCode;
  final RateType type;
}

final class CustomRate extends SelectedRate {
  const CustomRate(this.value);
  final double value;
}
```

## Decisions

- **D1 — `Rate` y `SelectedRate` viven en el kernel**, no en `features/rates/domain/`.
  Las tres features los consumen (ADR 0006). `RateModel` sí es de la feature.
- **D2 — El catálogo se lee solo de `rates_latest`.** No se consulta
  `rate_snapshots` ni se piden tasas por moneda: una sola petición por refresco.
- **D3 — La frescura se deriva, no se persiste.** `RateStatusResolver` recibe
  `publishedAt`, `fetchedAt`, el tipo y si la última consulta falló. El cache
  guarda datos, no estados.
- **D4 — El cache es un único JSON** bajo `cambiami.rates.v1` con
  `{ "savedAt": "...", "rows": [...] }`. Un solo `setString` es atómico; una clave
  por fila no lo sería. `savedAt` es cuándo se guardó, no `fetched_at`.
- **D5 — Selección huérfana cae al default.** Si `cambiami.selected_rate.v1`
  apunta a una fila ausente, se usa `CatalogRate(USD, oficial)`, se reescribe la
  preferencia y se registra en el log. No se deja la calculadora sin tasa. La
  forma guardada es `{"kind":"catalog","currencyCode":"USD","type":"oficial"}` o
  `{"kind":"custom"}`, y `cambiami.custom_rate.v1` guarda el `double` en bolívares.
- **D6 — `RatesCubit` y `SelectionCubit` son `@lazySingleton`; `CustomRateCubit`
  es `@injectable`.** Los dos primeros los comparten la página 05, la calculadora
  y el sheet 09; el tercero muere al cerrar el sheet 09b.
- **D7 — Refresco sin vaciar el catálogo.** Un refresco con datos en pantalla emite
  `RatesLoaded(isRefreshing: true)` y conserva las filas; solo `RatesLoading` vacía.
- **D8 — Mi tasa nunca entra al catálogo** ni al JSON de tasas: es una preferencia
  local con su propia clave (I-06 de `DOMINIO.md`).
- **D9 — La brecha se calcula en la UI** con `p2p_avg` y `oficial` ya cargados.
  No es un campo del backend y no se cachea aparte.
- **D10 — `WatchSelectedRate` es un `StreamController` en memoria** del
  repositorio, no un `watch()` del almacenamiento (ADR 0003). Al reiniciar, el
  primer valor sale del cache.

## Backend Supabase

| Objeto | Tipo | Uso en el módulo |
|---|---|---|
| `public.rates_latest` | vista (select) | Única lectura del catálogo |
| `public.currencies` | tabla (select) | Indirecto: la vista ya trae `currency_name` y `symbol` |
| `public.sources` | tabla (select) | Indirecto: la vista ya trae `source_name` y `source_url` |

- Sin RPC y sin escritura: la app es anónima y de solo lectura (ADR 0005).
- Columnas seleccionadas: `currency_code,currency_name,symbol,decimals,type,rate_value,source_code,source_name,source_url,official,effective_from,published_at,fetched_at,change_pct`.
- Orden: `official.desc,currency_code.asc,type.asc`.
- `rate_value <= 0` se descarta en `RateModel.fromJson`, antes de llegar al estado.

## Flujo de datos

```
TasasPage ──► RatesCubit.load()
                 ├─ GetCachedRates ──► RatesRepository ──► RatesLocalDataSource ──► SharedPreferencesWithCache
                 └─ FetchLatestRates ─► RatesRepository ──► RatesRemoteDataSource ─► PostgREST /rates_latest
                                                                  │
                                                                  ├─ RateModel.fromJson ──► Rate
                                                                  └─ RatesLocalDataSource.save() ──► cambiami.rates.v1

CoinsSheet ──► SelectionCubit.select() ──► SelectRate ──► RatesRepository ──► cambiami.selected_rate.v1
                                                                  └─ StreamController.add(SelectedRate)
                                                                        └─ AppShell ──► CalculatorCubit.rateChanged()

MiTasaSheet ──► CustomRateCubit.save() ──► SaveCustomRate | ClearCustomRate ──► cambiami.custom_rate.v1
```

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| El catálogo se pinta antes de que `RatesCubit` esté registrado | El registro es `@lazySingleton` y el shell lo resuelve antes del primer frame útil |
| `distinct on` devuelve dos filas para el mismo tipo si `effective_from` empata | El `order by` desempata por `fetched_at desc`; el test de backend ya lo cubre |
| El sheet `Monedas` y la calculadora ven selecciones distintas | `SelectionCubit` es singleton; el test de cableado lo verifica |
| Cache con filas de una moneda retirada | Se muestran hasta el próximo refresco; no se borra por tiempo (sin TTL) |
| Brecha negativa o división por cero | Si `oficial <= 0` no se dibuja la brecha; se cubre con test de widget |
| `change_pct` nulo rompe la variación de la ficha | La variación se oculta si `changePct` es nulo |

## Migration Plan

1. Crear entidades de kernel y `RateModel` con sus tests de `fromJson`.
2. Implementar datasources y repositorio; test con un doble en memoria de
   `SharedPreferencesWithCache` y `http.Client` simulado.
3. Implementar usecases y cubits; test de estados.
4. Implementar página y sheets; golden test de la ficha y del sheet.
5. Registrar en DI, cablear `AppShell` y verificar selección extremo a extremo.
6. Rollback: borrar `features/rates/`, las dos entidades de kernel y sus registros;
   el resto del cascarón sigue compilando.

## Open Questions

- Copy del estado vacío y de "moneda sin datos": pendiente de H1 (§13.4). No se
  escribe hasta ver la respuesta real.
- Si `change_pct` llega como `null` en la primera publicación, la ficha oculta la
  variación; confirmar con el primer dato real del colector.
