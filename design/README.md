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
| `Foundations` | 18 swatches en 3 filas (marca, superficie/texto, estados), escala tipográfica Nunito de 7 niveles, escala de radios 8/12/16/20/pill |
| `Components` | `RateCard`, `RateChip/Default`, `RateChip/Selected`, `StatusBanner`, `AmountCard`, `AmountCard/Default`, `Button/Primary`, `Button/Secondary` y las tres variantes de `TabBar` — todos como componentes reutilizables con instancias en las pantallas |

### Pantallas

| # | Frame | Estado |
|:--|:--|:--|
| 01 | Splash | ✅ |
| 02 | Calculadora · al día | ✅ |
| 02b | Calculadora · escribiendo (teclado numérico) | ✅ |
| 03 | Calculadora · desactualizado | ✅ |
| 04 | Calculadora · sin conexión | ✅ |
| 05 | Tasas BCV | ✅ (faltan los estados cargando y error) |
| 06 | Tasas USDT | ✅ (faltan los estados cargando y error) |
| 07 | Configuración | ✅ |
| 08 | Información (legal) | ✅ |
| 09 | Monedas (modal) | ✅ |
| 10 | Compartir (sheet) | ✅ |

Las cuatro pantallas de Calculadora llevan una sola acción en la cabecera: `Share button` (`share-2`, abre Compartir). Configuración ya no se alcanza desde ahí.

**Barra inferior:** 56 px flotante, tres destinos (`Calculadora`, `Tasas`, `Configuración`), con tres componentes — uno por estado activo. La llevan 02, 03, 04, 05, 06 y 07; no la llevan 02b (teclado abierto) ni 08 Información (detalle).

### Variables

Creadas en el documento con los nombres exactos de `DESIGN_SYSTEM.md`: colores (`bg/*`, `text/*`, `brand/*`, `state/*`, `variation/*`, `palette/*`), números (`space/1…10`, `radius/sm…pill`) y la fuente (`font/family` = `Nunito`).

---

## Lo que falta (para ti)

1. **Estados de carga y error** de Tasas BCV y Tasas USDT: skeleton de dos `RateCard` y el bloque `No pudimos actualizar las tasas.` + `Reintentar`. El copy y el comportamiento están en `DESIGN_SYSTEM.md` §13.4; solo falta dibujarlos.
2. **Wordmark e isotipo vectoriales**: hoy el splash usa el emblema PNG + texto `cambiami` en Nunito 800. Falta el lockup horizontal y la versión monocroma en SVG real.
3. **Icono de app, adaptive icon y splash nativo** (ver `DESIGN_SYSTEM.md` §11).
4. **Variante de 360 px de ancho** (Android común): revisar que los 4 chips de tasa sigan entrando sin cortar el valor.

La navegación **no se cablea** en el archivo: pen.dev no tiene un modo de prototipo con hotspots. El mapa de flujo y las rutas están en `DESIGN_SYSTEM.md` §12 y se implementan en el router de Flutter.

---

## Notas de implementación

- Los colores de marca saturados (`#FFD166`, `#FF705F`, `#20C6C8`) **no se usan como texto**. Para texto van sus variantes `-ink` (`#7A5200`, `#C93B2A`, `#0B7C7E`), que cumplen AA sobre el fondo del banner.
- El estado del dato siempre es icono + texto, nunca solo color.
- Formato es-VE: coma decimal, punto de miles, `Bs` después del número (`889,58 Bs`), `$` antes (`$ 1,00`).
- Cero emojis en la UI. Todos los iconos son Lucide.
- La pantalla `02b` conserva el monto al cambiar de tasa: es la regla de negocio que el clon rompía.

---

## Regenerar los PNG

Los PNG de `exports/` se generaron con `Export(...)` desde pen.dev. Si editas `cambiami.pen`, vuelve a exportar los frames que cambiaste para que las capturas no queden desfasadas.

---

*Diseño de Cambiami · v1.1 · 2026-11-11 · IDUCDEV para TasaVE C.A.*
