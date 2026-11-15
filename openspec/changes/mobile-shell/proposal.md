## Why

No existe todavía una app Flutter en el repo. Antes de escribir features reales
hace falta un cascarón verificado: tema, router, DI, contrato de errores, formato
es-VE y localización. Sin ese cascarón, el primer bug aparece a mitad de la primera
feature y no se sabe si es del dominio o del cableado.

## What Changes

- Crear `apps/mobile` con `flutter create` y el `pubspec.yaml` del proyecto.
- Implementar el tema a partir de `design/DESIGN_SYSTEM.md` (paleta, Nunito,
  espaciado, radios) con tokens en Dart.
- Implementar `EsVeFormatter` como única puerta de salida de números.
- Implementar el contrato de errores (`Failure`/`Exception` + `ErrorMapper`).
- Configurar GetIt + `injectable` con un módulo externo.
- Configurar GoRouter con `StatefulShellRoute` de tres destinos y la barra con
  Calculadora elevada.
- Configurar el pipeline de l10n (ARB `es`, `gen-l10n`).
- Implementar el splash de 400 ms como puerta de arranque.
- Crear el slice `example` en memoria como prueba de cableado y dejarlo borrable
  con `make drop-feature`.
- Tests de core: formatter, errores, resolución de DI y arranque.

## Capabilities

### New Capabilities

- `app-shell`: arranque, navegación principal, identidad visual, formato numérico,
  manejo de errores, composición de dependencias y localización.

### Modified Capabilities

Ninguna: no existen specs previas.

## Impact

- `apps/mobile/` completo.
- `docs/FEATURES.md` §7 y §10: estructura de carpetas y delta de dependencias.
- `docs/adr/0002-di-y-codegen.md`, `0003-cache-local.md`, `0006-kernel-de-dominio.md`.
- No toca `supabase/` ni la vista `rates_latest`.
- Fuera de alcance: features `rates`, `calculator` y `settings`; assets de marca
  definitivos; flavors de Android/iOS; CI.
