# ADR 0004 · Contrato de errores y copy

- **Estado:** aceptada
- **Fecha:** 2026-11-14
- **Decisores:** IDUCDEV
- **Relacionados:** `PROMPT-POR-FASES/03-fase-3-core-flutter.md` §3.7, `DESIGN_SYSTEM.md` §13.4

## Contexto

Hay tres capas que pueden fallar (red, parseo, cache) y una que decide qué ve el
usuario. Sin un contrato, cada feature inventa su forma de error: unas devuelven
`String`, otras lanzan excepciones, otras muestran el mensaje crudo del backend en
inglés.

Además hay dos fuentes de texto posibles: los archivos ARB y un mapeador de
errores. Hay que decidir cuál manda para qué.

## Decisión

### Tipos

- **`Exception`** en la capa de datos (`ServerException`, `NetworkException`,
  `ParseException`, `CacheException`). Nunca cruzan a dominio ni a presentación.
- **`Failure`** sellada en dominio, devuelta dentro de `Either` de `fpdart`:

| `Failure` | Origen | ¿Reintentable? |
|---|---|---|
| `NetworkFailure` | sin red, timeout, DNS | sí |
| `ServerFailure(code, detail)` | HTTP 4xx/5xx, error de PostgREST | según `code` |
| `ParseFailure(field)` | JSON inesperado o tipo incorrecto | no |
| `CacheFailure` | lectura/escritura local | no (degradación silenciosa) |
| `ValidationFailure(field)` | entrada del usuario | no |

- El **repositorio** traduce `Exception` → `Failure`. Ni el cubit ni el widget
  conocen `dio`, `http` ni PostgREST.

### Presentación

- El **estado del cubit lleva `String message`**, no `Failure`. La presentación
  muestra texto; si llevara el `Failure`, cada widget tendría que saber convertirlo
  y esa conversión se duplicaría.
- La traducción ocurre en **un solo lugar**: `lib/core/utils/error_mapper.dart`.
- **Nunca se muestra el mensaje del backend.** Se mapea por código; el detalle
  técnico va al log, no a la pantalla.

### Copy

- **ARB** para todo el texto estático: títulos, botones, etiquetas, legal,
  estados vacíos.
- **`ErrorMapper`** para los errores, porque dependen del tipo de fallo y del
  código HTTP, y el ARB no puede recibir lógica.
- v1 tiene un solo locale (`es-VE`), pero el pipeline de ARB se mantiene armado
  para que Fase 2 no obligue a reescribir la UI.

Mensajes canónicos de v1:

| Situación | Texto | Acción |
|---|---|---|
| Fallo de red al actualizar | `No pudimos actualizar las tasas.` | ghost `Reintentar` |
| Error del servidor | `No pudimos actualizar las tasas.` | ghost `Reintentar` |
| Sin conexión con cache | sin banner de error; banner `Sin conexión · mostrando la tasa del 01/11/26` | ninguna |
| Monto inválido | `Ingresa un monto válido.` | inline bajo el campo |
| Tasa `<= 0` | `No hay una tasa válida para calcular.` | deshabilita el resultado |

## Alternativas descartadas

| Alternativa | Por qué no |
|---|---|
| `Failure` en el estado | Cada widget convierte; se duplica el mapeo y se filtra infraestructura a la UI |
| Mostrar `message` del backend | Texto técnico en inglés, sin control de tono ni de es-VE |
| Todo el copy en ARB, incluidos errores | El ARB no puede ramificar por código HTTP sin lógica en la capa equivocada |
| Excepciones hasta la UI | `try/catch` en widgets; se pierde el tipado y el manejo se vuelve inconsistente |
| Un enum de errores con texto adentro | Mezcla contrato con copy; cambiar una palabra obliga a tocar dominio |

## Consecuencias

### Positivas

- Un solo punto de traducción de errores.
- Los tests verifican que **todo** `Failure` produce un mensaje no vacío.
- Cambiar el tono del copy no toca la lógica.

### Negativas / costo

- **Dos fuentes de copy** (ARB + mapper). Es deuda declarada: un revisor tiene que
  saber dónde buscar. Mitigación: el mapper solo contiene errores; todo lo demás
  vive en ARB.
- `CacheFailure` se degrada en silencio: si falla la escritura, el usuario no se
  entera. Es deliberado, pero hay que loguearlo.

## Verificación

- Test: cada `Failure` del enum produce `message.isNotEmpty`.
- Test: `ServerFailure(401)` no se reintenta; `NetworkFailure` sí.
- Test: un JSON con `rate_value` como string produce `ParseFailure`, no crash.

## Cuándo revisar

- Si entra un segundo idioma.
- Si el backend empieza a devolver códigos de error de negocio que el usuario deba
  entender (por ejemplo, en un flujo con cuenta).
