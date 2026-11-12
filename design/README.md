# Design — Cambiami

Carpeta de diseño del MVP v1. Contiene tres cosas distintas:

| Archivo | Qué es | Estado |
|:--|:--|:--|
| `cambiami.pen` | Diseño en pen.dev (canvas infinito, editable) | Generado al ~90 %, lo terminas tú |
| `assets/` | Emblema recortado con alpha | Listo |
| `../exports/` | PNG de cada pantalla y de las páginas Foundations/Components | Generado |

La fuente de verdad de tokens, tipografía, componentes, **microcopy** y navegación es **`DESIGN_SYSTEM.md`**. Este README solo describe el archivo de diseño.

---

## Qué hay dentro de `cambiami.pen`

### Páginas

| Frame | Contenido |
|:--|:--|
| `Foundations` | 23 swatches en 4 filas (marca, superficie/texto, estados, tintes de identidad), escala tipográfica Nunito de 7 niveles, escala de radios 8/12/16/20/pill |
| `Components` | `RateCard` (ficha completa), `RateCard / Compacta` (ficha de la calculadora y selector de tasa), `Calculator / Body` (cuerpo de la calculadora), `RateChip/Default`, `RateChip/Selected`, `StatusBanner`, `AmountCard`, `AmountCard/Default`, `Button/Primary`, `Button/Secondary` y las tres variantes de `TabBar` — todos como componentes reutilizables con instancias en las pantallas |

### Pantallas

| # | Frame | Estado |
|:--|:--|:--|
| 01 | Splash | ✅ |
| 02 | Calculadora · al día | ✅ |
| 02b | Calculadora · escribiendo (teclado numérico) | ✅ |
| 03 | Calculadora · desactualizado | ✅ |
| 04 | Calculadora · sin conexión | ✅ |
| 05 | Tasas (catálogo por mercado) | ✅ (ficha completa + brecha verificable + estados) |
| 07 | Configuración | ✅ |
| 08 | Información (legal) | ✅ |
| 09 | Monedas (modal) | ✅ |
| 10 | Compartir (sheet) | ✅ |

Las cuatro pantallas de Calculadora son **la misma instancia de `Calculator / Body`**: la cabecera solo lleva el título y la única acción de compartir es el CTA `Compartir cálculo`. La ficha `RateCard / Compacta` hace de selector de tasa (chevron en el nombre) y sigue a la tasa elegida; en 02b se oculta mientras se escribe.

**Barra inferior:** 72 px flotante con la **Calculadora elevada en el centro** (FAB circular de 60 px que sobresale 16 px), tres destinos (`Tasas`, `Calculadora`, `Configuración`), con tres componentes — uno por estado activo. La llevan 02, 03, 04, 05 y 07; no la llevan 02b (teclado abierto) ni 08 Información (detalle).

### Organización por historia de usuario

El frame `Board · Pantallas por historia` agrupa las 10 pantallas por las HU de `docs/PLAN_DE_DESARROLLO.md`. Regla: **una sola copia de cada pantalla**, colocada bajo la historia de la que es sujeto.

| Grupo | Pantallas |
|:--|:--|
| HU-01 · Abrir la app y ver la tasa inmediatamente | 01 Splash |
| HU-02 · Calcular dólares a bolívares al instante | 02, 02b |
| HU-03 · Saber si la tasa está actualizada | 03 |
| HU-04 · Calcular sin internet | 04 |
| HU-06 · Ver varias tasas al mismo tiempo | 09 |
| HU-07 · Elegir mi moneda predeterminada | 07 |
| HU-08 · Saber de dónde vienen los datos | 08 |
| HU-10 · Compartir el cálculo por WhatsApp | 10 |
| HU-11 · Consultar las tasas en detalle | 05 + `Estados · Tasas` |

**Matriz de apariciones** (una pantalla puede salir en varias historias sin duplicarse):

| Pantalla | Sujeto de | También aparece en |
|:--|:--|:--|
| 01 Splash | HU-01 | — |
| 02 Calculadora | HU-02 | HU-01 (destino del arranque), HU-03, HU-04, HU-06 |
| 02b Calculadora · escribiendo | HU-02 | — |
| 03 Calculadora · desactualizado | HU-03 | HU-04 |
| 04 Calculadora · sin conexión | HU-04 | HU-03 |
| 05 Tasas | HU-11 | HU-03 (estado del dato) |
| 07 Configuración | HU-07 | HU-08 (se entra a Información desde ahí) |
| 08 Información | HU-08 | — |
| 09 Monedas | HU-06 | — |
| 10 Compartir | HU-10 | — |

HU-05 (formato es-VE) es transversal: no tiene pantalla propia, aplica a todas.

**Numeración:** el diseño usa `01–10`. El brief (`docs/TASAVE_DOCUMENTO_UNIFICADO.md`) usa `APP-SCR-01…11` con otra correspondencia (su `APP-SCR-03` es Tasas BCV, no la calculadora desactualizada). En este repositorio manda la numeración del diseño.

### Variables

Creadas en el documento con los nombres exactos de `DESIGN_SYSTEM.md`: colores (`bg/*`, `text/*`, `brand/*`, `state/*`, `variation/*`, `palette/*`), números (`space/1…10`, `radius/sm…pill`) y la fuente (`font/family` = `Nunito`).

---

## Lo que falta (para ti)

1. **Wordmark e isotipo vectoriales**: hoy el splash usa el emblema PNG + texto `cambiami` en Nunito 800. Falta el lockup horizontal y la versión monocroma en SVG real.
2. **Icono de app, adaptive icon y splash nativo** (ver `DESIGN_SYSTEM.md` §11).
3. **Variante de 360 px de ancho** (Android común): revisar que los 4 chips de tasa sigan entrando sin cortar el valor.

La navegación **no se cablea** en el archivo: pen.dev no tiene un modo de prototipo con hotspots. El mapa de flujo y las rutas están en `DESIGN_SYSTEM.md` §12 y se implementan en el router de Flutter.

---

## Notas de implementación

- Los colores de marca saturados (`#FFD166`, `#FF705F`, `#20C6C8`) **no se usan como texto**. Para texto van sus variantes `-ink` (`#7A5200`, `#C93B2A`, `#0B7C7E`), que cumplen AA sobre el fondo del banner.
- **Reparto de color 60/30/10** (`DESIGN_SYSTEM.md` §3.6): 60 % neutro, 30 % tintes suaves, 10 % acento. Máximo 3 acentos fuertes por pantalla.
- **Identidad por fuente:** chip de 40 px en `RateCard` y de 32 px en las filas de Monedas — BCV índigo, Euro ámbar, USDT lavanda, Mi tasa coral. El chip es identidad, nunca estado. La ficha compacta de la calculadora usa el chip de 28 px.
- **Una calculadora, cuatro estados:** 02, 02b, 03 y 04 son instancias del maestro `Calculator / Body` (`Header` → banner → `Rate block` → `Amounts` → `Share CTA`). El `Rate block` es la franja de frescura + la ficha compacta, y la ficha **hace de selector**: se toca para abrir Monedas, así que la tasa no se repite en otro bloque. 02b oculta solo la ficha; el banner y la franja se quedan.
- **La frescura manda sobre el valor:** en la calculadora la franja `Actualizado hoy · 9:41 a. m.` + pill va sobre la ficha, de modo que el estado del dato se lee antes que el número.
- **Tinte por estado:** el `Content` de 03 va en ámbar suave y el de 04 en coral suave; el banner conserva sus tokens `state/*`. En la ficha P2P, Compra y Venta van sin tinte propio: el color direccional vive en la variación.
- **La tarjeta se titula con la moneda, no con la estadística:** la ficha del P2P dice `USDT` (como `Dólar` y `Euro`) y el promedio va como calificador de la variación (`Promedio · +2,19 Bs`). Titularla `Promedio` dejaba al usuario sin saber qué tasa estaba viendo y no coincidía con la fila `USDT` de Monedas ni con la brecha.
- **Catálogo por mercado, no por fuente:** la pestaña `Tasas` es una sola pantalla con los grupos `Oficial` y `Mercado P2P`. Agrupar por fuente (`BCV | USDT`) convertía un concepto del modelo (`source_code`) en navegación y no escalaba: con USDC habría hecho falta un tercer segmento. La fuente sigue en el pie de cada ficha.
- El estado del dato siempre es icono + texto, nunca solo color.
- **Tres fechas, tres sitios** (`DESIGN_SYSTEM.md` §7.2/§7.8): `published_at` → `Publicado` en la tarjeta, `effective_from` → `Vigente desde` en la tarjeta, `fetched_at` → franja de frescura. Ninguna se repite.
- **Brecha verificable:** el porcentaje se acompaña siempre de la fórmula y de los dos valores con los que se calculó (`(USDT promedio − BCV) ÷ BCV`). Un porcentaje sin sus operandos no se muestra.
- **Nada fuera de `rate_snapshots`:** no hay histórico, ni mín/máx, ni número de anuncios. Si el modelo no lo tiene, no se dibuja.
- Formato es-VE: coma decimal, punto de miles, `Bs` después del número (`889,58 Bs`), `$` antes (`$ 1,00`).
- Cero emojis en la UI. Todos los iconos son Lucide.
- La pantalla `02b` conserva el monto al cambiar de tasa: es la regla de negocio que el clon rompía.

---

## Regenerar los PNG

Los PNG de `exports/` se generaron con `Export(...)` desde pen.dev. Si editas `cambiami.pen`, vuelve a exportar los frames que cambiaste para que las capturas no queden desfasadas.

---

*Diseño de Cambiami · v1.1 · 2026-11-11 · IDUCDEV para TasaVE C.A.*
