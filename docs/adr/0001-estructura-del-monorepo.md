# ADR 0001 · Estructura del monorepo

- **Estado:** aceptada
- **Fecha:** 2026-11-14
- **Decisores:** IDUCDEV
- **Relacionados:** `docs/DOMINIO.md`, `PROMPT-POR-FASES/01-fase-1-raiz-del-monorepo.md`

## Contexto

Cambiami es una app Flutter con backend Supabase y una landing pública que llega
en H4. El repo ya contiene `design/` (sistema de diseño y `.pen`), `docs/`
(producto) y `openspec/` (configuración). Trabaja una sola persona.

Hay que decidir cuántos repositorios existen, qué carpetas de primer nivel se
crean ahora y qué se difiere.

## Decisión

Un **repo único** con estas raíces:

```
cambiami/
├── apps/
│   └── mobile/          Flutter (v1)
├── supabase/            migraciones, tests pgTAP, functions/
├── docs/                producto, dominio, ADRs
├── design/              sistema de diseño, .pen, assets de marca
├── openspec/            changes y specs
├── tools/               scripts de operación
├── Makefile             orquesta todo
└── .github/workflows/   CI con filtros por ruta
```

- **`apps/web` no se crea en v1.** La landing es H4 y no está entre las 8 features
  del MVP. El monorepo queda preparado: agregarla es crear una carpeta y un
  workflow, sin mover nada.
- **No hay `packages/shared`.** No existe código compartido entre Flutter y
  Next.js: comparten el esquema de datos, y eso se comparte por contrato
  (`docs/DOMINIO.md`), no por paquete.
- **`openspec/` vive en la raíz**, no en `docs/openspec/`. Es la convención del CLI
  y donde ya está `config.yaml`. El prompt original lo ubicaba en `docs/`; esta
  decisión lo reemplaza.
- **`design/` y `docs/` son de primera clase**, no anexos. El sistema de diseño es
  un contrato verificable, no una referencia.

## Alternativas descartadas

| Alternativa | Por qué no |
|---|---|
| Polyrepo (app, backend, web) | Un solo desarrollador; coordinar tres PRs para un cambio de esquema cuesta más de lo que aísla |
| Crear `apps/web` ahora | No está en el MVP; una app Next.js vacía es deuda de CI y dependencias |
| `packages/shared` con tipos Dart/TS | No hay tipos compartidos; el contrato es el esquema Postgres y la vista |
| App Flutter en la raíz del repo | Impide agregar `apps/web` y mezcla tooling de mobile con tooling de repo |

## Consecuencias

### Positivas

- Un PR puede cambiar migración, modelo y UI de forma atómica.
- Un solo `make check` valida todo.
- `design/`, `docs/` y `openspec/` quedan versionados junto al código que rigen.

### Negativas / costo

- El CI necesita filtros por ruta para no correr Flutter cuando solo cambió SQL.
- El `Makefile` raíz es un punto único de fallo: si se rompe, se rompe todo.
- Un repo grande se vuelve lento de clonar con el tiempo (mitigable con
  `--filter=blob:none`).

## Verificación

- `tree -L 2` muestra exactamente las raíces de arriba.
- `make doctor` valida Flutter, Dart, Node, Supabase CLI y `gh`.
- El workflow de mobile no se dispara con cambios solo en `supabase/`.

## Cuándo revisar

- Cuando entre un segundo desarrollador con áreas separadas.
- Cuando la landing pase a producción (H4): se crea `apps/web` y se revisa el CI.
- Si aparece código realmente compartido entre mobile y web.
