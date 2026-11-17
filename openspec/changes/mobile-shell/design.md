## Context

Ver `proposal.md`. El repo no tiene app Flutter. El sistema de diseño
(`design/DESIGN_SYSTEM.md`) fija paleta, tipografía, componentes, rutas y microcopy.
Los ADRs 0002, 0003 y 0006 fijan DI, cache y kernel. Este change crea el cascarón
que hace cumplir esos contratos.

Restricciones del entorno: Flutter 3.50.0 / Dart 3.14.0 instalados. Las versiones
de paquetes se verifican al instalar, no se copian a ciegas.

## Goals / Non-Goals

**Goals:**

- App que compila, corre y navega entre tres destinos.
- Tema construido desde tokens, con Nunito bundleada.
- Un solo formateador es-VE y un solo mapeador de errores.
- DI verificable y slice descartable que pruebe el cableado.
- `flutter analyze` sin warnings y tests de core en verde.

**Non-Goals:**

- Features reales (`rates`, `calculator`, `settings`).
- Android/iOS signing, flavors, iconos de launcher definitivos.
- CI y web.
- Consumo real de Supabase (el slice es en memoria).

## Decisions

### 1. Versiones y dependencias

- `environment: sdk: ^3.14.0`, `flutter: ">=3.50.0"`.
- Se quitan `isar_community`, `isar_community_flutter_libs`,
  `isar_community_generator` y `path_provider` (ADR 0003).
- Se agregan `shared_preferences` y `lucide_icons_flutter`.
- `build_runner` genera solo el archivo de DI (ADR 0002).
- **Paquete de iconos resuelto:** `lucide_icons` 0.257.0 no compila con Flutter
  3.47 porque `LucideIconData extends IconData` y `IconData` pasó a ser `final`.
  Se usa `lucide_icons_flutter` 4.0.3 (`sdk: ^3.0.0`), que expone los 17 iconos de
  §6 con los nombres nuevos (`circleCheck`, `trendingUp`, `share2`). Verificado con
  `flutter analyze`, test de los 17 iconos y `flutter build web --release`.

### 2. Tema por tokens

```
core/theme/
├── app_colors.dart      primitivos + semánticos (bg/canvas, text/primary, state/*)
├── app_typography.dart  Nunito 400/600/700/800, escala del DS
├── app_spacing.dart     space/4 … space/32
├── app_radius.dart      sm/md/lg/pill
└── app_theme.dart       ThemeData claro, sin tema oscuro
```

- Ningún widget usa `Color(0x...)`; el lint lo prohíbe con una regla de revisión.
- Nunito se bundlea en `assets/fonts/` y se declara en `pubspec.yaml`. No se usa
  `google_fonts`: el primer arranque sin red no debe cambiar la tipografía.
- El tema oscuro se define en tokens pero no se activa (Fase 2).

### 3. Router con shell persistente

- `StatefulShellRoute.indexedStack` con tres ramas: `/` (Calculadora), `/tasas`,
  `/configuracion`.
- `/informacion` cuelga del navigator raíz para tapar la barra inferior y hacer
  `pop` al volver.
- Monedas (09), Mi tasa (09b) y Compartir (10) **no son rutas**: se abren con
  `showModalBottomSheet` sobre la rama activa.
- La barra es un widget propio (`AppTabBar`), no `NavigationBar`: el diseño exige
  FAB central elevado, alturas de 72 px y tabs de 137 px.

### 4. Arranque como puerta, no como ruta

`AppBootstrap` muestra `SplashPage` mientras corre `Future.wait` de preferencias y
cache, con un mínimo de 400 ms. Cuando termina, construye `MaterialApp.router`.
Así el splash no ensucia el historial ni se puede volver a él con `pop`.

### 5. Composición

- `ServiceLocator.init()` en `main`, antes de `runApp`.
- `external_module.dart` registra `SharedPreferencesWithCache`, `http.Client` y
  `PackageInfo`.
- Repositorios, datasources y servicios con `@lazySingleton`; también
  `RatesCubit`, `SelectionCubit` y `SettingsCubit`. `CalculatorCubit` y
  `CustomRateCubit` con `@injectable`.
- Los widgets reciben el cubit por `BlocProvider`; nunca llaman al localizador.

### 6. Errores y copy

- `Failure` sellada (`NetworkFailure`, `ServerFailure`, `ParseFailure`,
  `CacheFailure`, `ValidationFailure`) y `Exception` en datos (ADR 0004).
- `ErrorMapper` es el único que produce mensajes de error.
- El resto del copy vive en ARB.

### 7. Formateador

`EsVeFormatter` envuelve `intl` pero **no depende del locale `es_VE` del sistema**:
define símbolos y patrones explícitos.

- Decimal coma, miles punto, `Bs` pospuesto, `$` antepuesto.
- Menos tipográfico `U+2212`.
- `parse(String)` acepta coma y punto y normaliza.
- Fechas `Lunes, 02/11/26` y horas `9:41 a. m.`.
- Test de tabla con los 11 casos del sistema de diseño §8.

### 8. Localización

- `l10n.yaml` con `arb-dir: lib/l10n/arb`, `template-arb-file: app_es.arb`,
  `output-localization-file: app_localizations.dart`.
- Las claves del slice se borran junto con el slice; las claves del cascarón
  (`appTitle`, `tabCalculator`, `tabRates`, `tabSettings`, `retry`, `cancel`)
  quedan.

### 9. Slice descartable

`features/example/` con datasource en memoria, entidad, repositorio, dos usecases
y un cubit. Se registra en DI y en una ruta de depuración. `make drop-feature`
borra la carpeta y falla si quedan imports.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| `lucide_icons_flutter` cambia de API en una versión menor | Fijar `^4.0.3` y cubrir los 17 iconos con un test de widget que falle si falta un nombre |
| Nunito no está instalada en el sistema | Bundlear los `.ttf` en `assets/fonts/`; no depender de la fuente del SO |
| `StatefulShellRoute` con FAB elevado se desalinea | Widget propio con posiciones absolutas y golden test de la barra |
| `intl` con locale `es_VE` produce símbolos distintos según plataforma | Patrones explícitos y test de tabla, sin confiar en el locale del SO |
| El slice se acopla y no se puede borrar | `make drop-feature` es parte del gate: si falla, el change no cierra |
| El arranque supera 1 s por leer prefs | Leer en paralelo y mantener el splash en 400 ms; medir en dispositivo |

## Migration Plan

1. `flutter create` en `apps/mobile` y `flutter pub get`.
2. Implementar core y slice; `make gen`, `make l10n`, `flutter analyze`.
3. `flutter test` y `flutter run` en un dispositivo o emulador.
4. `make drop-feature` y verificar que la app sigue compilando.
5. Rollback: al ser una app nueva, se borra la carpeta y se vuelve al estado previo.

## Open Questions

- Ninguna bloqueante. El paquete de iconos quedó resuelto en `lucide_icons_flutter`
  4.0.3 y el splash usa el emblema glossy a 160 px, como fija
  `DESIGN_SYSTEM.md` §5 y §12; el plano queda para el icono de app.
