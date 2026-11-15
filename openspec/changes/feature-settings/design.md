## Context

Ver `proposal.md`. El cascarón entrega router con `/configuracion` e `/informacion`,
tema, DI y ARB. `feature-calculator` consume la moneda predeterminada como campo de
entrada. Este change es el que la guarda y el que publica el legal.

El copy es literal de `DESIGN_SYSTEM.md` §13.2, §13.6 y §13.7. La pantalla 08 es
estática por diseño: no tiene cubit ni datos remotos.

## Goals / Non-Goals

**Goals:**

- Preferencia de moneda persistente, validada y aplicada al abrir.
- Información con el texto legal completo y navegación por `pop`.
- Identidad correcta: Cambiami visible, TasaVE C.A. solo como entidad legal.
- Cero emojis y todo el copy en ARB.

**Non-Goals:**

- Tema oscuro, idioma alterno, notificaciones, cuenta.
- Preferencias de formato o de redondeo.
- Edición del legal desde la app.
- Enlaces a tiendas o soporte.

## Ficheros afectados

| Elemento | Capa | Archivo | Req |
|---|---|---|---|
| Entidad `DefaultCurrency` | domain | `features/settings/domain/entities/default_currency.dart` | REQ-SET-001 |
| Contrato de repositorio | domain | `features/settings/domain/repositories/settings_repository.dart` | REQ-SET-001 |
| `GetDefaultCurrency` | domain | `features/settings/domain/usecases/get_default_currency.dart` | REQ-SET-001 |
| `SetDefaultCurrency` | domain | `features/settings/domain/usecases/set_default_currency.dart` | REQ-SET-001 |
| DataSource local | data | `features/settings/data/datasources/settings_local_data_source.dart` | REQ-SET-001 |
| Implementación de contrato | data | `features/settings/data/repositories/settings_repository_impl.dart` | REQ-SET-001 |
| Estados de UI | presentation | `features/settings/presentation/cubit/settings_state.dart` | REQ-SET-001 |
| `SettingsCubit` | presentation | `features/settings/presentation/cubit/settings_cubit.dart` | REQ-SET-001 |
| Página `Configuración` | presentation | `features/settings/presentation/pages/settings_page.dart` | REQ-SET-001, REQ-SET-003, REQ-SET-004 |
| Página `Información` | presentation | `features/settings/presentation/pages/info_page.dart` | REQ-SET-002, REQ-SET-004 |
| Selector de moneda | presentation | `features/settings/presentation/widgets/currency_selector.dart` | REQ-SET-001 |
| Lectura inicial de la preferencia | core (composition root) | `core/app/app_shell.dart` | REQ-SET-001 |
| Versión de la app | core | `core/utils/app_info.dart` | REQ-SET-003 |
| Copy de ambas pantallas | l10n | `lib/l10n/arb/app_es.arb` | REQ-SET-002, REQ-SET-003, REQ-SET-004 |

## Contratos Dart clave

```dart
// domain/entities/default_currency.dart
class DefaultCurrency extends Equatable {
  const DefaultCurrency(this.code);

  static const fallback = DefaultCurrency('USD');
  static const supported = {'USD', 'EUR', 'USDT'};

  final String code;

  bool get isValid => supported.contains(code);
}
```

```dart
// domain/repositories/settings_repository.dart
abstract class SettingsRepository {
  Future<Either<Failure, String>> getDefaultCurrency();
  Future<Either<Failure, Unit>> setDefaultCurrency(String code);
}
```

```dart
// presentation/cubit/settings_state.dart
sealed class SettingsState extends Equatable {
  const SettingsState();
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded(this.defaultCurrency);
  final String defaultCurrency;
}

final class SettingsSaving extends SettingsState {
  const SettingsSaving(this.defaultCurrency);
  final String defaultCurrency;
}
```

```dart
// domain/usecases/get_default_currency.dart
class GetDefaultCurrency {
  Future<Either<Failure, String>> call();
}

// domain/usecases/set_default_currency.dart
class SetDefaultCurrency {
  Future<Either<Failure, Unit>> call(String code);
}
```

## Decisions

- **D1 — `USD` es el default y el único fallback.** Si la clave no existe, si el
  JSON es ilegible o si el código no está en `{USD, EUR, USDT}`, se devuelve `USD`
  y se reescribe la preferencia.
- **D2 — La validación vive en `DefaultCurrency`**, no en el cubit ni en la
  página. Un solo lugar decide qué códigos son válidos.
- **D3 — La preferencia se aplica al abrir, no en caliente.** El shell la lee una
  vez antes del primer frame de la calculadora; cambiarla no altera la pantalla ya
  montada (FEATURES §5.3).
- **D4 — `SettingsCubit` es `@lazySingleton`.** El shell lo resuelve al arrancar,
  llama a `load()` y usa `defaultCurrency` para la calculadora; la página 07 usa la
  misma instancia. Un cubit por pantalla dejaría al arranque sin forma de leer la
  preferencia sin duplicar el usecase.
- **D5 — Información no tiene cubit ni estado.** Es un `StatelessWidget` con texto
  del ARB y navegación por `pop`. Agregarle estado sería ceremonia sin caso de uso.
- **D6 — El legal es una sola cadena ARB.** No se parte en párrafos ni se traduce:
  §13.6 exige mostrarlo completo.
- **D7 — La versión sale de `PackageInfo`**, no de un literal. El pie se compone
  como `TasaVE C.A. · v{major}.{minor}`: `1.0.0` se muestra `v1.0`, para no
  desviarse de §13.2. Si `PackageInfo` falla, el pie cae a `v1.0` y registra el
  error en el log.
- **D8 — No hay pantalla de preferencias genérica.** Solo existe la moneda; un
  listado de ajustes vacío en v1 sería una promesa falsa.

## Backend Supabase

Ninguno. La preferencia es local (`shared_preferences`) y el legal vive en el ARB.
No hay tabla, vista ni RPC que consultar.

## Flujo de datos

```
AppShell ──► GetDefaultCurrency ──► SettingsRepository ──► SettingsLocalDataSource
                                                              └─ cambiami.default_currency.v1
                     │
                     └──► CalculatorCubit (dirección inicial)

SettingsPage ──► SettingsCubit.select(code) ──► SetDefaultCurrency ──► cambiami.default_currency.v1
                                                      └─ emit SettingsLoaded | SettingsSaving

SettingsPage ──► push /informacion ──► InfoPage (ARB, sin estado) ──► pop
```

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| El legal se recorta al migrar a ARB | Test que compara la cadena con el párrafo de §13.6 |
| La versión del pie se desactualiza | Se lee de `PackageInfo`, no se escribe a mano |
| Cambiar la moneda no surte efecto y parece un bug | La pantalla explica `Esta moneda se mostrará en la calculadora al abrir la app.` |
| El selector permite un código inválido | `DefaultCurrency.isValid` filtra antes de persistir; test de tabla |
| `Información` se abre sin barra y el usuario queda atrapado | `Volver` y `‹` hacen `pop`; test de navegación desde ambas entradas |
| El pie muestra la marca equivocada | Revisión de copy: `Cambiami` en la UI, `TasaVE C.A.` solo en el pie legal |

## Migration Plan

1. Entidad, repositorio y usecases con tests de validación y persistencia.
2. `SettingsCubit` con `blocTest` de carga y guardado.
3. Páginas 07 y 08 con golden tests a 390 px.
4. Cableado del shell para la lectura inicial y verificación de que la calculadora
   abre con la moneda guardada.
5. Rollback: borrar `features/settings/` y las claves ARB de la feature; el router
   pierde dos rutas y el cascarón sigue compilando.

## Open Questions

- Si H4 agrega enlaces de tienda o soporte, Información gana una sección; no se
  prepara ahora.
- Confirmar si `TasaVE C.A.` debe incluir el RIF `J-30452819-5` en el pie o solo en
  el legal de tienda. El diseño actual no lo muestra en pantalla.
