# Cambiami — Mapa de features (v1)

> **Estado:** vigente · **Versión:** 1.0 · **Fecha:** 2026-11-14
> **Entradas:** `docs/PLAN_DE_DESARROLLO.md` (HU), `design/DESIGN_SYSTEM.md` (§7, §12),
> `docs/DOMINIO.md` (contrato de datos), `docs/adr/` (decisiones).
> **Salida:** specs de OpenSpec y estructura de carpetas de `apps/mobile`.

---

## 0. Para qué existe

Las HU son de producto y las pantallas son de diseño. Ninguna de las dos dice en
qué módulos se corta el código. Sin esa traducción, las features terminan
nombradas por pantalla (`calculator_page`) en vez de por capacidad, y el router
manda sobre el dominio.

Este documento es la traducción. **No contiene código**: contiene módulos,
usecases, estados y reglas.

---

## 1. Principios de corte

1. **Una feature es una capacidad, no una pantalla.** `rates` existe porque hay
   tasas que listar y seleccionar, no porque exista la pantalla 05.
2. **Una pantalla puede consumir varias features.** La calculadora usa `calculator`
   (conversión), `rates` (selección) y `settings` (moneda por defecto).
3. **Una feature puede tener varias pantallas o ninguna.** `settings` tiene dos
   páginas; `rates` tiene una página y dos sheets.
4. **Lo transversal no es feature.** Splash, compartir, formato y frescura viven en
   `core`.
5. **Regla de borrado:** si borrás `features/<f>/`, la app sigue compilando y el
   resto de las features no cambia. Si no se cumple, el corte está mal.

---

## 2. Resumen

| Módulo | Pantallas | HU | Features de producto (F-xx) | Entidades | Usecases | Estados |
|---|---|---|---|---|---|---|
| `rates` | 05 Tasas, 09 Monedas, 09b Mi tasa | HU-03, HU-06, HU-11 | F-02, F-05 | `Rate`, `SelectedRate` | 6 | 4 + 2 + 2 |
| `calculator` | 02, 02b, 03, 04, 10 | HU-01, HU-02, HU-04, HU-05, HU-10 | F-01, F-03, F-04, F-07 | `Rate`, `SelectedRate`, `Conversion` | 3 | 3 |
| `settings` | 07 Configuración, 08 Información | HU-07, HU-08 | F-08, F-12 | `DefaultCurrency` | 2 | 2 |

**Dos vocabularios que no hay que mezclar.** Una **feature de producto** (`F-xx`) es
una promesa del plan; no implica un módulo de código. Un **módulo** (`rates`,
`calculator`, `settings`) es un corte de Clean Architecture. `F-01` (cold start),
`F-04` (formato) y `F-07` (compartir) se implementan en `core/` y no son features
de código: por eso `calculator` las lista como producto pero no las contiene.

**La columna Estados cuenta cubits**, no clases de estado: `rates` tiene
`RatesCubit` (4 estados), `SelectionCubit` (2) y `CustomRateCubit` (2).

Transversales: splash (bootstrap), compartir (sheet), formato es-VE, frescura.

---

## 3. Módulo `rates`

**Capacidad:** obtener el catálogo vigente, mostrar su procedencia y elegir con qué
tasa se calcula.

**Pantallas:**

- 05 Tasas: catálogo agrupado por mercado (`Oficial`, `Mercado P2P`), con carga
  (skeleton) y error (`Reintentar`).
- 09 Monedas: sheet de selección sobre la calculadora.
- 09b Mi tasa: sheet de edición de la tasa manual.

### 3.1 Usecases

| Usecase | Entrada | Salida | Regla |
|---|---|---|---|
| `GetCachedRates` | — | `Either<Failure, List<Rate>>` | Lee `cambiami.rates.v1`; lista vacía si no hay cache |
| `FetchLatestRates` | — | `Either<Failure, List<Rate>>` | Lee `rates_latest`, descarta `rate_value <= 0`, escribe cache |
| `WatchSelectedRate` | — | `Stream<SelectedRate>` | Emite al cambiar la selección |
| `SelectRate` | `SelectedRate` | `Either<Failure, Unit>` | Persiste; `CustomRate` no se guarda en el catálogo |
| `SaveCustomRate` | `double` (Bs) | `Either<Failure, Unit>` | `<= 0` equivale a borrar |
| `ClearCustomRate` | — | `Either<Failure, Unit>` | Deja `SelectedRate` en la tasa por defecto |

`WatchSelectedRate` **no es reactividad del almacenamiento**. `shared_preferences`
no expone `watch()` (ADR 0003): el repositorio mantiene un `StreamController` en
memoria y emite cuando `SelectRate`, `SaveCustomRate` o `ClearCustomRate` cambian
la selección. Al reiniciar, el stream arranca con el valor leído del cache.

### 3.2 Estados

**`RatesCubit`** (catálogo, vive en el nivel de app):

| Estado | Cuándo | Qué muestra |
|---|---|---|
| `RatesLoading` | Arranque sin cache | Skeleton de 3 fichas |
| `RatesLoaded(rates, status, fetchedAt, isRefreshing)` | Hay datos (cache o red) | Catálogo + `FreshnessStrip` |
| `RatesEmpty` | Red OK y vista vacía | `No hay tasas publicadas.` + `Reintentar` |
| `RatesError(message)` | Red falló y no hay cache | Error con `Reintentar` |

**`SelectionCubit`** (app):

| Estado | Cuándo |
|---|---|
| `SelectionLoaded(selected, customRate)` | Siempre; `selected` es `CatalogRate` o `CustomRate` |
| `SelectionSaving` | Mientras persiste |

**`CustomRateCubit`** (sheet 09b): `CustomRateEditing(value, isValid)` y
`CustomRateSaved`. Sin estado de error de copy: el helper explica la consecuencia
antes de guardar (diseño §7.10).

### 3.3 Reglas

- El catálogo se agrupa por `official`, no por `source_code` (DOMINIO §5).
- La ficha P2P se arma con tres filas (`p2p_avg`, `p2p_buy`, `p2p_sell`) y muestra
  el promedio como valor.
- La brecha se calcula en la UI con los valores ya cargados; no se pide al backend.
- Mi tasa no aparece en el catálogo de 05; solo en 09 y en la calculadora.
- Tocar una tasa de 09 cambia la selección y **conserva el monto** de la calculadora.

### 3.4 Componentes

`RateCard` (ficha), `RateCardCompact`, `SectionHeader`, `MethodNote`,
`FreshnessStrip`, `RateRow`, `MiTasaSheet`, `StatusBanner`.

---

## 4. Módulo `calculator`

**Capacidad:** convertir un monto con la tasa seleccionada, sin red y sin botón.

**Pantallas:** 02/02b/03/04 (estados de la misma pantalla), 10 Compartir (sheet).
El splash es bootstrap y vive en `core/app/` (§6).

### 4.1 Usecases

| Usecase | Entrada | Salida | Regla |
|---|---|---|---|
| `ParseAmount` | `String` | `Either<ValidationFailure, double>` | Acepta coma y punto; solo dígitos y un separador; máx. 12 dígitos |
| `ConvertAmount` | `double`, `double` (tasa) | `Either<Failure, Conversion>` | `rate <= 0` → falla; sin red no importa |
| `BuildShareText` | monto, tasa, fecha | `String` | Formato literal de `DESIGN_SYSTEM.md` §13.5 |

### 4.2 Estados

| Estado | Contenido |
|---|---|
| `CalculatorInitial` | Sin monto; resultado `0,00` |
| `CalculatorReady` | `amount`, `direction`, `converted`, `rate`, `status`, `fetchedAt` |
| `CalculatorError` | `message`; resultado deshabilitado |

Eventos: `AmountChanged`, `DirectionToggled`, `SelectedRateChanged`, `Retry`,
`ShareTapped`.

`SelectedRateChanged` **no lo dispara la UI**: lo emite el *composition root* (el
shell de la app), que escucha `SelectionCubit` y alimenta `CalculatorCubit`. Es la
forma de cumplir §8 sin que `calculator` importe `rates`.

### 4.3 Reglas

- No hay botón "calcular": cada cambio de monto recalcula.
- Bidireccional: escribir en `$` produce `Bs` y al revés.
- Cambiar de tasa conserva el monto y recalcula (S-06 del brief).
- Con `sinConexion`, calcula igual con el cache y muestra banner.
- Al recuperar red, refresca sola sin reiniciar.
- El resultado se muestra con 2 decimales; la tasa de la ficha conserva todos.
- El splash dura 400 ms y es la ventana mínima para leer cache y preferencias; la
  red se lanza sin esperarla.

### 4.4 Componentes

`CalculatorBody`, `AmountField`, `RateCardCompact`, `FreshnessStrip`,
`StatusBanner`, `AppButton` (Compartir), `TabBar`.

---

## 5. Módulo `settings`

**Capacidad:** preferencias locales y texto legal.

**Pantallas:** 07 Configuración, 08 Información.

### 5.1 Usecases

| Usecase | Entrada | Salida | Regla |
|---|---|---|---|
| `GetDefaultCurrency` | — | `Either<Failure, String>` | Default `USD` si no hay valor |
| `SetDefaultCurrency` | `String` | `Either<Failure, Unit>` | Solo `USD`, `EUR`, `USDT` |

### 5.2 Estados

`SettingsLoaded(defaultCurrency)` y `SettingsSaving`.

### 5.3 Reglas

- La moneda por defecto se aplica al abrir la calculadora, no en caliente.
- Información es una página estática: sin cubit, texto desde ARB.
- El texto legal se muestra completo y no se reparte (`DESIGN_SYSTEM.md` §13.6).
- `TasaVE C.A. · v1.0` es el pie de Configuración; la marca visible es Cambiami.

---

## 6. Transversales (no son features)

| Pieza | Dónde vive | Por qué no es feature |
|---|---|---|
| Splash y bootstrap | `core/app/` | No tiene dominio; espera 400 ms, lee cache y preferencias y lanza la red sin esperarla |
| Compartir | `core/share/` + `core/widgets/share_sheet.dart` | Lo usan calculadora y tasas; no tiene estado propio |
| Formato es-VE | `core/formatters/es_ve_formatter.dart` | Función pura; la usan todas las pantallas |
| Frescura | `core/domain/rate_status_resolver.dart` | Función pura sobre `published_at` y red |
| Tema y tokens | `core/theme/` | Contrato de diseño, no capacidad |
| Red | `core/network/` | Infraestructura |

Estas piezas implementan features de producto sin ser módulos: `F-01` (cold start)
en `core/app/`, `F-04` (formato) en `core/formatters/` y `F-07` (compartir) en
`core/share/`. Una `F` no obliga a crear `features/<f>/`.

Compartir usa `url_launcher` (`whatsapp://send?text=` con fallback a
`https://wa.me/?text=`) y `Clipboard` de Flutter. **No se agrega `share_plus`.**
El enlace del mensaje es `AppConfig.shareUrl` (`https://cambiami.app`).

---

## 7. Estructura de carpetas

```
apps/mobile/lib/
├── core/
│   ├── app/app_bootstrap.dart
│   ├── common/usecase.dart
│   ├── config/app_config.dart
│   ├── constants/constants.dart          # umbrales de frescura, límites
│   ├── data/local/preferences_service.dart
│   ├── di/{service_locator,external_module}.dart
│   ├── domain/                           # kernel (ADR 0006)
│   │   ├── entities/{rate,selected_rate}.dart
│   │   ├── enums/{rate_type,rate_status}.dart
│   │   └── rate_status_resolver.dart
│   ├── error/{failures,exceptions}.dart
│   ├── formatters/es_ve_formatter.dart
│   ├── network/network_info.dart
│   ├── routing/app_router.dart
│   ├── services/cache_manager.dart
│   ├── share/share_text_builder.dart
│   ├── theme/{app_theme,app_colors,app_typography,app_spacing,app_radius}.dart
│   ├── utils/{app_info,error_mapper,snackbar_helper,validators}.dart
│   └── widgets/                          # AmountField, StatusBanner, TabBar, ShareSheet
├── features/
│   ├── rates/{data,domain,presentation}/
│   ├── calculator/{domain,presentation}/
│   └── settings/{data,domain,presentation}/
├── l10n/
└── main.dart
```

Convenciones de archivo: `<algo>_data_source.dart`, `<algo>_repository.dart` +
`_impl.dart`, `<algo>_entity.dart`, `<algo>_cubit.dart` + `_state.dart` (`part of`).

---

## 8. Reglas de dependencia

```
presentation ──► domain ◄── data
      │            │
      └────────────┴──────► core/domain (kernel)
                                 ▲
                        core (infra) ──✗──► features
features A ──✗──► features B
```

- `core` no importa `features/`.
- Una feature no importa otra feature.
- `domain` no importa Flutter, Supabase ni `shared_preferences`.
- `data` no importa `presentation`.
- Ningún widget usa hex sueltos: todo pasa por `AppColors`.

### 8.1 Cableado entre features

La regla "una feature no importa otra" deja una pregunta abierta: ¿cómo llega la
tasa seleccionada de `rates` a `calculator`?

Respuesta: **las une el composition root**, no una importación.

```
SelectionCubit (rates) ──emite──► AppShell ──evento──► CalculatorCubit (calculator)
                                     │
                                     └──► RatesCubit (rates)
                                     └──► SettingsCubit (settings)
```

- `AppShell`, en `core/app/`, es el único punto que conoce los tres cubits.
- Las features se comunican por tipos del kernel (`SelectedRate`) y por eventos,
  nunca por imports cruzados.
- Si aparece una cuarta feature, se suma al shell; no se toca el interior de las
  otras.

Lo mismo vale para la moneda por defecto: `SettingsCubit` la publica y el shell la
pasa a `CalculatorCubit` al arrancar, no en caliente (§5.3).

---

## 9. Matriz HU → módulo

| HU | Módulo principal | Módulos que toca |
|---|---|---|
| HU-01 Cold start | `calculator` | `core/app`, `rates` (cache) |
| HU-02 Calcular | `calculator` | `rates` (selección), `core/formatters` |
| HU-03 Frescura | `rates` | `calculator`, `core/domain` |
| HU-04 Offline | `calculator` | `core/data`, `core/network` |
| HU-05 Formato | — | `core/formatters` |
| HU-06 Multi-tasa | `rates` | `calculator` |
| HU-07 Moneda por defecto | `settings` | `calculator` |
| HU-08 Legal | `settings` | — |
| HU-09 Siguiente día hábil | **Fase 2** | — |
| HU-10 Compartir | `calculator` | `rates` (compartir tasas), `core/share` |
| HU-11 Detalle de tasas | `rates` | — |

---

## 10. Dependencias: delta contra el scaffold

| Acción | Paquete | Motivo |
|---|---|---|
| Quitar | `isar_community`, `isar_community_flutter_libs`, `isar_community_generator` | ADR 0003 |
| Quitar | `path_provider` | Solo lo usaba Isar |
| Agregar | `shared_preferences` | Cache y preferencias (ADR 0003) |
| Agregar | `lucide_icons_flutter` | Iconografía única del diseño (§6); `lucide_icons` 0.257 no compila con Flutter 3.47 |
| Mantener | `url_launcher` | Compartir por WhatsApp |
| Mantener | `intl` | Base de `EsVeFormatter` |
| Mantener | `get_it`, `injectable`, `injectable_generator` | ADR 0002 |

Nunito se bundlea en `assets/fonts/` y se declara en `pubspec.yaml`; no se usa
`google_fonts`. El emblema del splash se exporta a PNG desde el SVG de marca, así
que no se agrega `flutter_svg`.

---

## 11. Definición de terminado por módulo

| Módulo | Terminado cuando |
|---|---|
| `rates` | Las 5 filas se muestran agrupadas, con fuente, publicación, vigencia y estado; carga y error dibujados; selección persiste tras reiniciar |
| `calculator` | Convierte en ambos sentidos en < 100 ms; conserva el monto al cambiar de tasa; funciona en modo avión; el texto de compartir coincide con §13.5 |
| `settings` | La moneda por defecto persiste y se aplica al reabrir; el legal se muestra completo; la app no muestra ningún emoji |

Y la regla transversal: `flutter analyze` con 0 warnings y los tests del módulo en
verde antes de abrir el siguiente change.

---

## 12. Fuera de alcance v1

Onboarding, escáner de precios, perfiles de pago, premium, histórico y gráficas,
tema oscuro, multi-país, web. Cada uno tiene su lugar en Fase 2 y no se prepara
código para ellos.

---

*Mapa de features de Cambiami · v1.0 · 2026-11-14 · IDUCDEV para TasaVE C.A.*
