## Why

La app necesita dos cosas que no son cálculo ni catálogo: recordar con qué moneda
abre la calculadora y mostrar el texto legal completo. Sin la primera, el usuario
elige la moneda cada vez; sin la segunda, la app no puede publicarse.

Este change implementa el módulo `settings` de `docs/FEATURES.md` §5: preferencia
local de moneda y página estática de Información con el legal de
`DESIGN_SYSTEM.md` §13.6.

## What Changes

- Entidad `DefaultCurrency` y dos usecases: `GetDefaultCurrency` y
  `SetDefaultCurrency`.
- `SettingsRepository` con datasource local sobre `shared_preferences`
  (`cambiami.default_currency.v1`).
- `SettingsCubit` con `SettingsLoaded` y `SettingsSaving`.
- Pantalla 07 Configuración con el selector de moneda y el acceso a Información.
- Pantalla 08 Información: página estática, sin cubit, con el texto legal íntegro.
- Claves ARB del copy de ambas pantallas.
- **BREAKING:** ninguno. Es código nuevo sobre un cascarón sin features.

## Capabilities

### New Capabilities

- `settings`: moneda predeterminada persistente, página de información legal,
  identidad de la app y copy localizado sin emojis.

### Modified Capabilities

Ninguna.

## Impact

- `apps/mobile/lib/features/settings/{data,domain,presentation}/`.
- `apps/mobile/lib/core/app/app_shell.dart` (lectura inicial de la preferencia).
- `apps/mobile/lib/l10n/arb/app_es.arb` (copy de Configuración, Información y legal).
- Depende de `mobile-shell` (router, tema, DI, ARB) y de `feature-calculator` solo
  como consumidor de la preferencia.
- Fuera de alcance: tema oscuro, notificaciones, cuenta, idioma alterno y cualquier
  preferencia que no sea la moneda.
