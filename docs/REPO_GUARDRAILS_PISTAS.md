# Pistas para definir a mano el change `repo-guardrails`

> Material de trabajo, no el change. El change lo escribís vos con OpenSpec.
> Cuando termines, borrá este archivo: el change archivado es la fuente de verdad.

## 0. Qué vas a practicar

- Crear un change con `openspec new change`.
- Escribir `proposal.md`, `design.md` y `tasks.md` en orden de dependencia.
- Decidir si el change lleva spec o `skip_specs`.
- Validar con `openspec validate --strict`.
- Aplicar por bloques y archivar.

No es un change de producto: no toca `lib/`, no toca `supabase/migrations/`, no
agrega pantallas. Es el cambio que hace que el repo se pueda construir y revisar
sin depender de la memoria de una persona.

## 1. Leé antes de escribir

| Fuente | Para qué |
|---|---|
| `docs/GUIA_DE_CIMIENTO.md` §3.4 y §5.4 | Formato de change, EARS, tareas |
| `docs/GUIA_DE_CIMIENTO.md` §3.6 y §5.6 | Etapa de guardrails, plantillas y trampas |
| `openspec/changes/mobile-shell/` | Ejemplo real de proposal, spec, design y tasks |
| `openspec/specs/rates/spec.md` y `collector/spec.md` | Nivel de detalle de una spec archivada |
| `Makefile` | Targets que ya existen |
| `.env.example` | Contrato de variables y secretos |
| `apps/mobile/pubspec.yaml` | Stack y versiones reales |
| `docs/adr/0001`, `0005`, `0006`, `0007` | Contratos que el CI debe respetar |
| `docs/FEATURES.md` §11 | Definición de terminado por módulo |

Regla de trabajo: del material de origen se toma el **contrato** (qué garantiza),
no el **contenido** (qué proyecto asume). Si contradice un ADR, gana el ADR.

## 2. Decisión de entrada: ¿spec o `skip_specs`?

OpenSpec 2.0 rechaza un change con cero deltas salvo que `.openspec.yaml`
declare `skip_specs: true`. La guía de OpenSpec reserva esa salida para
tooling, docs y refactors puros: cosas que no cambian comportamiento de
producto.

Dos caminos válidos:

**A. `skip_specs: true` (recomendado).** El change lleva `proposal.md`,
`design.md` y `tasks.md`. Prácticas el flujo completo sin inventar una
capability de producto. Los criterios de aceptación viven en las tareas.

**B. Capability `dev-workflow`.** Si querés practicar EARS y escenarios, creá
`specs/dev-workflow/spec.md`. Es defendible: el workflow del repo es un
comportamiento observable. Pero no es la lectura canónica de OpenSpec para
tooling.

Inventario actual de specs:

```bash
openspec list --specs
openspec show rates --type spec --json --no-scenarios
```

Hoy hay dos: `rates` y `collector`. No existe `dev-workflow`.

## 3. Crear el change

```bash
cd "$(git rev-parse --show-toplevel)"
openspec new change repo-guardrails
openspec status --change repo-guardrails --json
```

`openspec new change` crea el directorio y `.openspec.yaml`. Si elegís A,
agregá la marca:

```yaml
schema: spec-driven
created: 2026-11-18
skip_specs: true
```

Después:

```bash
openspec status --change repo-guardrails --json
```

La spec debe aparecer como `skipped`. Si no, `validate` va a rechazar el change
por cero deltas.

Para cada artefacto, pedí la plantilla y las reglas:

```bash
openspec instructions proposal --change repo-guardrails --json
openspec instructions design   --change repo-guardrails --json
openspec instructions tasks    --change repo-guardrails --json
```

Orden de dependencia: `proposal` → (`specs`) → `design` → `tasks`. El JSON de
`status` te dice cuál está `ready`. No copies el bloque `context` ni `rules` al
archivo: son restricciones para vos.

## 4. Proposal: materia prima

### Why

El repo no tiene puerta de entrada (`README.md`), no tiene un comando único de
verificación, no tiene CI, no tiene gate de commits y no tiene contrato para
agentes. La guía §3.6 exige `make check` verde en CI como gate de la etapa 6 y
hoy el repo no tiene CI.

### What Changes

- Raíz: `README.md`, `.editorconfig`, `.gitattributes`, `.gitignore`,
  `SECURITY.md`, `CONTRIBUTING.md`, `docs/BITACORA.md`.
- Comandos: `apps/mobile/Makefile` y ampliación del `Makefile` raíz con
  `doctor`, `check`, `check-all`, `db-check`, `git-verify`, `git-history` y
  delegados `mobile-*`.
- Commits: hook `commit-msg` + `make commitlint` + regla documentada.
- CI: `.github/workflows/mobile.yml`, `db.yml`, `security.yml` y
  `.github/dependabot.yml`.
- Cobertura: `flutter test --coverage`, artefacto `lcov.info` y resumen en el
  log. Umbral numérico diferido.
- Agentes: `AGENTS.md` raíz y `openspec/config.yaml` con contexto y reglas.

### Non-goals

- `apps/web`, auth, `rpc-publicas`, `storage`.
- CD o deploy automático: el despliegue sigue siendo el runbook manual de
  `docs/SUPABASE_REMOTO.md`.
- Flavors y firma de release.
- Commitlint/commitizen si elegís el hook propio.
- Umbral numérico de cobertura.
- Archify.
- Cambios de código de la app o del esquema.

### Capabilities

- Si A: ninguna, más `skip_specs: true`.
- Si B: `dev-workflow` (nueva).

### Impact

- Archivos raíz, `.github/`, `Makefile`, `apps/mobile/Makefile`,
  `apps/mobile/README.md`, `docs/GUIA_DE_CIMIENTO.md`, `docs/BITACORA.md` y
  `openspec/config.yaml`.
- No toca `lib/`, `supabase/migrations/` ni `pubspec.yaml` (salvo alguna dev
  dependency si hiciera falta).

### Riesgos y mitigación

| Riesgo | Mitigación |
|---|---|
| CI rojo por trabajo a medias en la rama de `mobile-shell` | CI en PR y `main`; no en cada push de rama |
| Minutos de Actions | Repo público: gratis; build APK solo en `main` o `workflow_dispatch` |
| Acciones por tag | `permissions: contents: read` + Dependabot; SHA antes de cualquier deploy |
| Secreto en el historial | Regex de secreto real, no la palabra `sb_secret_` |
| Deriva entre Makefile y CI | Un solo contrato de comandos; el CI llama a `make` |

### Rollout

- PR 1: higiene, comandos y `AGENTS.md`.
- PR 2: commits, CI y cobertura.
- PR 3: cierre, verificación y nota en la guía.

## 5. Design: decisiones que tenés que tomar

| Decisión | Opciones | Recomendación | Por qué |
|---|---|---|---|
| Commits | Hook propio vs commitlint + husky + commitizen | Hook propio | Evita `package.json` y `node_modules` en un repo Flutter/Supabase |
| Acciones | Tag (`@v4`) vs SHA completo | Tag ahora | No hay secretos en CI; `contents: read` acota el daño |
| Cobertura | Artefacto vs umbral | Artefacto ahora | Con dos tests, un umbral es decorativo |
| FVM | `.fvmrc` vs solo `environment.flutter` | Solo `pubspec` | El `pub get` ya falla con un SDK viejo |
| Flavors | Ahora vs después del package id | Después | Tocan `applicationId` y esquemas de iOS |
| `make check` | Solo mobile vs mobile + DB | `check` mobile; `check-all` suma DB | El comando rápido no depende de Docker |
| CD | Automático vs manual | Manual | El despliegue remoto está documentado, no ejecutado |
| Scan de secretos | `git log` + gitleaks | Los dos | El historial es el riesgo real; gitleaks cubre el working tree |
| DB en CI | `supabase start` vs compose propio | `supabase start` | No hay compose propio; el CLI ya resuelve el stack |
| Build APK en CI | Cada PR vs `main`/dispatch | `main`/dispatch | Feedback rápido en PR; empaquetado donde importa |
| Dependabot | Pub + Actions (+ npm) | Pub + Actions | No hay app Node si elegís hook propio |
| `build_runner` | Actualizar vs ignorar | Ignorar hasta que el analyzer lo permita | 2.17.1 no es resoluble hoy |

Contratos que el design debe fijar:

- Targets: `make check`, `make check-all`, `make doctor`, `make git-verify`,
  `make git-history`, `make coverage`.
- Workflows: `mobile.yml`, `db.yml`, `security.yml`.
- Regla dura: **el CI no usa secretos de Supabase**.
- `AGENTS.md` es la fuente para agentes; `openspec/config.yaml` es el contexto
  que OpenSpec inyecta en cada artefacto.

Riesgos y trade-offs:

- Un workflow monolítico es más fácil de escribir y más difícil de leer.
- Un `make check` que incluye DB es más honesto y más lento.
- Un umbral de cobertura bajo se convierte en un número que nadie mira.

Open questions que pueden esperar:

- `applicationId` definitivo (no bloquea este change).
- Base de lints (`very_good_analysis` vs `flutter_lints`): afecta
  `--fatal-infos`.
- `l10n.yaml`: afecta el paso `gen-l10n`.
- Umbral de cobertura: se decide después del kernel.

## 6. Tasks: cómo cortarlas

Formato: `- [ ] X.Y Descripción · R-xx · Verificación: comando`.
Cada tarea, una sesión. Cada grupo lleva su verificación; no dejes los tests
para un grupo final.

### Bloque 1 · Agentes

- [ ] 1.1 Escribir `AGENTS.md` con stack, comandos, convenciones, límites y
  fuentes de verdad. Verificación: un agente nuevo puede responder dónde vive
  cada regla sin abrir el código.
- [ ] 1.2 Llenar `openspec/config.yaml` con `context` y `rules`.
  Verificación: `openspec context --json` devuelve el contexto.

### Bloque 2 · Higiene

- [ ] 2.1 `.editorconfig`, `.gitattributes`, `.gitignore`.
  Verificación: `git status` no muestra `.env`, `coverage/`, `.idea/` ni
  `*.iml`.
- [ ] 2.2 `README.md` raíz. Verificación: seguir el arranque desde un clon
  limpio, sin pasos mentales.
- [ ] 2.3 `SECURITY.md` y `CONTRIBUTING.md`. Verificación: la superficie de
  secretos y el flujo de PR están escritos.

### Bloque 3 · Comandos

- [ ] 3.1 `apps/mobile/Makefile` con `install`, `gen`, `l10n`, `analyze`,
  `format`, `test`, `coverage`, `check`, `clean`, `run`, `run-linux`,
  `build-apk`. Verificación: `make -C apps/mobile check`.
- [ ] 3.2 `Makefile` raíz con `doctor`, `check`, `check-all`, `db-check`,
  `git-verify`, `git-history` y delegados. Verificación: `make help` y
  `make check`.
- [ ] 3.3 `make coverage` con `genhtml` (ya está instalado).
  Verificación: `coverage/html/index.html` existe.

### Bloque 4 · Commits

- [ ] 4.1 Hook `commit-msg` con la lista de tipos del prompt y header máximo
  100. Verificación: un mensaje inválido se rechaza; uno válido pasa.
- [ ] 4.2 `make commitlint` para validar el último mensaje.
  Verificación: `make commitlint` sobre el HEAD actual.
- [ ] 4.3 Documentar el formato en `CONTRIBUTING.md`.
  Verificación: el ejemplo del doc pasa el hook.

### Bloque 5 · CI

- [ ] 5.1 `mobile.yml`: `pub get`, `analyze --fatal-warnings --fatal-infos`,
  `dart format --set-exit-if-changed`, `test --coverage`, artefacto y resumen
  `lcov`. Verificación: workflow verde en un PR.
- [ ] 5.2 `db.yml`: `make db-check` (levanta Supabase, resetea y corre pgTAP).
  Verificación: los 6 archivos pgTAP pasan en el runner.
- [ ] 5.3 `security.yml`: `permissions: contents: read`, regex de secreto real,
  `.env` trackeados, gitleaks. Verificación: workflow verde y una prueba con un
  secreto falso que lo ponga en rojo.
- [ ] 5.4 `dependabot.yml`: `pub` y `github-actions`, semanal.
  Verificación: Dependabot abre un PR de prueba.
- [ ] 5.5 Verificar que ningún workflow usa secretos de Supabase.
  Verificación: `grep -r "secrets\." .github/workflows` solo muestra
  `GITHUB_TOKEN`.

### Bloque 6 · Cierre

- [ ] 6.1 `make check` y `make check-all` verdes.
- [ ] 6.2 CI verde en un PR real.
- [ ] 6.3 Verificar que `docs/GUIA_DE_CIMIENTO.md` §3.6 y §5.6 coincidan con lo
  implementado. Verificación: cada comando de la guía existe en el `Makefile`.
- [ ] 6.4 Crear `docs/BITACORA.md` y registrar la prueba de fuego por capa.
  Verificación: una fila por capa con el resultado real.
- [ ] 6.5 `openspec validate repo-guardrails --strict` y archivar.

Comandos de verificación que podés usar tal cual:

```bash
cd apps/mobile
flutter analyze --fatal-warnings --fatal-infos
dart format --output=none --set-exit-if-changed lib test
flutter test --coverage

cd ../..
make check
make check-all
git ls-files | grep -E '(^|/)\.env$'
git log -p --all | grep -oE 'sb_secret_[A-Za-z0-9_-]{20,}'
```

## 7. Si elegís la capability `dev-workflow`

Requisitos posibles, en EARS. Escribí el texto final vos; esto es la intención.

| ID | Patrón | Intención |
|---|---|---|
| R-01 | Ubicuo | `make check` verifica formato, análisis y tests de mobile, y falla con código distinto de cero |
| R-02 | Por evento | Un PR o un push a `main` ejecuta los gates sin secretos de Supabase |
| R-03 | No deseado | Si el historial tiene una clave `sb_secret_` real o un `.env` trackeado, el workflow de seguridad falla |
| R-04 | Por evento | Un commit que no sigue Conventional Commits se rechaza con el formato esperado |
| R-05 | Ubicuo | `AGENTS.md` permite a un agente nuevo encontrar stack, comandos, convenciones, límites y fuentes de verdad |
| R-06 | Por evento | Cada ejecución de tests de mobile publica `lcov.info` como artefacto |
| R-07 | No deseado | Si aparece una dependencia o símbolo de autenticación en `apps/mobile/lib`, el CI falla (ADR 0003) |

Para cada uno, un escenario `Given / When / Then` con resultado observable.
No metas nombres de archivo, YAML ni clases en el requirement: eso es design.

## 8. Validar antes de implementar

```bash
openspec validate repo-guardrails --strict
openspec show repo-guardrails
openspec status --change repo-guardrails
```

Checklist:

- [ ] El proposal tiene non-goals.
- [ ] Cada tarea tiene verificación.
- [ ] Cada decisión del design tiene alternativa y motivo.
- [ ] El design no tiene cuerpos de código.
- [ ] Si hay spec: cada requirement tiene ID, patrón EARS y escenario.
- [ ] Si hay spec: cada requirement mapea a una tarea y un test.
- [ ] Si no hay spec: `skip_specs: true` está en `.openspec.yaml`.

Errores de validación típicos:

- Cero deltas sin `skip_specs`.
- Requirement sin escenario.
- Tarea sin checkbox o sin verificación.
- Spec en una ruta que no coincide con la capability del proposal.

## 9. Aplicar y archivar

```bash
# después de implementar y marcar tareas
openspec validate repo-guardrails --strict
openspec archive repo-guardrails
```

Con `skip_specs`, el archivo no sincroniza ninguna spec principal. Con
`dev-workflow`, el archive mueve los requisitos a `openspec/specs/dev-workflow/`.

## 10. Trampas específicas de este repo

| Trampa | Qué pasa | Qué hacer |
|---|---|---|
| `sb_secret_reemplazar` en el historial | El grep naive del prompt falla en el commit `b5ff35e` | Buscar `sb_secret_[A-Za-z0-9_-]{20,}` |
| Repo público | gitleaks-action funciona sin licencia; el pinning importa más | `permissions: contents: read`; SHA antes de deploy |
| Flutter 3.50 / Dart 3.14 | `package:flutter/material.dart` está deprecado | Usar `package:material_ui/material_ui.dart` |
| Sin emulador Android | `flutter run` no tiene dispositivo Android | `flutter build apk` para empaquetar; `flutter run -d linux` para iterar |
| `build_runner` 2.16.1 | 2.17.1 no es resoluble por el analyzer | No lo fuerces; ignorá ese PR de Dependabot |
| Formatter nuevo de Dart | `dart format` puede reescribir todo | Corré `dart format lib test` una vez antes de activar el gate |
| Sin `l10n.yaml` ni DI todavía | `gen-l10n` y `build_runner` no verifican nada | Agregá esos pasos cuando existan; no antes |
| `.vscode/settings.json` con ruta absoluta | Rompe en otra máquina | Ignorar `.vscode/` |
| No hay CD | Prometer deploy automático sería falso | El deploy sigue en `docs/SUPABASE_REMOTO.md` |

## 11. Criterio de terminado del change

- [ ] `make check` verde en local.
- [ ] CI verde en un PR real.
- [ ] `security.yml` verde y probado con un secreto falso.
- [ ] `README.md` reproducible desde un clon limpio.
- [ ] `AGENTS.md` usable por un agente nuevo.
- [ ] `docs/BITACORA.md` registra la prueba de fuego por capa.
- [ ] `openspec validate repo-guardrails --strict` pasa.
- [ ] El change está archivado.

## 12. Piezas del prompt: qué se queda y qué se va

El directorio `PROMPT-POR-FASES/` ya se retiró del repo. Esta tabla conserva las
decisiones que se extrajeron de él para que el change no dependa de un archivo
ausente.

| Pieza | Se queda | Se va | Destino |
|---|---|---|---|
| `.editorconfig` | Contrato de formato | Nada | Raíz |
| `.gitattributes` | LF y binarios | Nada | Raíz |
| `README.md` | Puerta de entrada | Next.js, FVM, commitizen | Raíz |
| `AGENTS.md` | Contrato para agentes | Isar, auth, `ErrorHandler` | Raíz |
| `SECURITY.md` | Superficie y rotación | Nada | Raíz |
| `CONTRIBUTING.md` | Flujo de PR y commits | Web | Raíz |
| `Makefile` raíz | Un comando por tarea | `web-*`, `env-usb`, `env-ip` | Raíz |
| `apps/mobile/Makefile` | Ciclo de mobile | Flavors, `drop-feature` | `apps/mobile` |
| `commitlint` | Convención | Node si elegís hook | Raíz |
| `mobile.yml` | Gates de mobile | Flutter 3.41, Isar, web | `.github/workflows` |
| `db.yml` | pgTAP en CI | Compose propio | `.github/workflows` |
| `security.yml` | Historial limpio | Grep naive | `.github/workflows` |
| `web.yml` | Nada | Todo | Descartar |
| Packs auth/rpc/storage | Nada | Todo | Descartar |
| Fase 8 checklist | Gate binario | Reporte de bootstrap | `make check` + guía |
