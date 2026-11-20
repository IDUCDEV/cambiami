## 1. Creación de la app

- [X]  1.1 Ejecutar `flutter create` en `apps/mobile` con org `com.cambiami` y verificar que `flutter run` levanta la app por defecto
- [X]  1.2 Escribir `pubspec.yaml` con el delta de `docs/FEATURES.md` §10 y verificar que `flutter pub get` resuelve sin conflictos
- [X]  1.3 Agregar `lucide_icons_flutter: ^4.0.3` (no `lucide_icons`, que no compila con Flutter 3.47) y verificar que los 17 iconos de `DESIGN_SYSTEM.md` §6 existen y compilan; `flutter analyze` y `flutter build` limpios

## 2. Tema y tipografía

- [x]  2.1 Descargar Nunito 400/600/700/800, guardarla en `assets/fonts/` y declararla en `pubspec.yaml`; verificar que el texto se renderiza en Nunito en un dispositivo
- [x]  2.2 Implementar `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_radius.dart` y `app_theme.dart` con los tokens de `DESIGN_SYSTEM.md` §3 a §5; verificar que `Theme.of(context)` devuelve los valores esperados en un widget test
- [x]  2.3 Verificar contraste AA de los pares texto/fondo del tema con un test que calcule la razón; los 3 estados deben superar 4,5:1

## 3. Core transversal

- [x]  3.1 Implementar `EsVeFormatter` con decimales, miles, `Bs`, `$`, menos tipográfico, fechas y horas; verificar con el test de tabla de 11 casos de `DESIGN_SYSTEM.md` §8
- [x]  3.2 Implementar `Failure`, `Exception` y `ErrorMapper`; verificar que cada `Failure` produce un mensaje no vacío y que `ServerFailure(401)` no se reintenta
  - Nota: migrado a contrato sellado (ADR 0004) — `Failure` sin `message`, discriminador `field` (`amount`/`rate`), `from(Object)` + `fromAppException`. El mensaje no vacío se verifica sobre `ErrorMapper.map(...).message`.
- [ ]  3.3 Implementar `PreferencesService` sobre `SharedPreferencesWithCache` con un `allowList` de las cuatro claves versionadas; verificar lectura, escritura, rechazo de una clave fuera de la lista y descarte por cambio de versión con un doble en memoria
- [ ]  3.4 Implementar `RateStatusResolver` y los enums del kernel (`RateType`, `RateStatus`); verificar los tres estados con reloj inyectado

## 4. Composición y navegación

- [ ]  4.1 Configurar GetIt + `injectable` con `service_locator.dart` y `external_module.dart`; verificar con un test de humo que resuelve `PreferencesService`
- [ ]  4.2 Implementar `app_router.dart` con `StatefulShellRoute.indexedStack`, las rutas `/`, `/tasas`, `/configuracion` y `/informacion`; verificar navegación y `pop` en un widget test
- [ ]  4.3 Implementar `AppTabBar` con tres destinos, FAB central de 60 px y estados activo/inactivo; verificar con golden test a 390 px de ancho
- [ ]  4.4 Implementar `AppBootstrap` y `SplashPage` con espera mínima de 400 ms, emblema glossy a 160 px sobre `#29243D`, lectura de cache y preferencias antes del primer frame útil y lanzamiento de la red sin esperarla; verificar que el primer frame útil es la calculadora y que no se puede volver al splash

## 5. Localización

- [ ]  5.1 Configurar `l10n.yaml`, `app_es.arb` y `flutter gen-l10n`; verificar que `AppLocalizations` compila y que no hay texto de interfaz hardcodeado en el cascarón

## 6. Slice descartable

- [ ]  6.1 Crear `features/example/` con entidad, datasource en memoria, repositorio, dos usecases, cubit y página; verificar que se puede crear y listar un elemento
- [ ]  6.2 Registrar el slice en DI y en una ruta de depuración; verificar que la app navega a la feature de ejemplo
- [ ]  6.3 Implementar `make drop-feature` y ejecutarlo; verificar que la app sigue compilando, `flutter analyze` pasa y no quedan imports al slice

## 7. Verificación

- [ ]  7.1 Correr `flutter analyze` y confirmar 0 warnings
- [ ]  7.2 Correr `flutter test` y confirmar que pasan formatter, errores, DI, router, barra y arranque
- [ ]  7.3 Correr la app en un dispositivo y medir el arranque en frío; confirmar menos de 1 s hasta la calculadora
- [ ]  7.4 Confirmar que no hay emojis en la interfaz ni hex sueltos en widgets
- [ ]  7.5 Registrar en el reporte las desviaciones y los `TODO` que queden
