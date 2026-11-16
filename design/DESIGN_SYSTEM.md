# Cambiami — Sistema de diseño

> **Producto:** Cambiami (app móvil de tasas de cambio y calculadora USD/VES)
> **Entidad legal:** TasaVE C.A. · RIF J-30452819-5
> **Plataforma:** Flutter (Android + iOS)
> **Versión:** 1.2 · 2026-11-13
> **Fuentes de verdad:** `PLAN_DE_DESARROLLO.md` (alcance), `TASAVE_DOCUMENTO_UNIFICADO.md` (brief)
> **Assets de marca:** `design/`
> **Archivo de diseño:** `design/cambiami.pen` (pen.dev)

Este documento es la referencia única de color, tipografía, espaciado, componentes y microcopy. Todo lo que se dibuje en `design/cambiami.pen` o se programe en Flutter debe salir de aquí. Si un valor no está en este documento, no se usa.

---

## 1. Marca

| Campo | Valor |
|:--|:--|
| Nombre visible | **Cambiami** (siempre en minúsculas cuando es el logotipo; "Cambiami" en texto corrido) |
| Entidad legal | TasaVE C.A. — solo en pantalla Información y textos legales |
| Categoría | Fintech · tipo de cambio · Venezuela |
| Promesa | "La tasa, clara y al día." |
| Tono de voz | Directo, breve, sin tecnicismos. Nunca promete exactitud oficial ni da consejos financieros. |
| Idiomas | es-VE (único en v1) |

### Reglas de nombre

- La app se llama **Cambiami**. `TasaVE` **no** aparece en la UI salvo en el descargo legal.
- `applicationId`: `com.cambiami.app` · `bundleId`: `com.cambiami.app`
- Nunca se escribe "Cambiami App", "CAMBIAMI" ni "CambiAmí".

---

## 2. Logo

### Variantes

| Variante | Archivo | Uso |
|:--|:--|:--|
| Emblema plano | `design/assets/brand/emblem.svg` (3 colores) | Icono de app, splash, cabeceras |
| Emblema monocromo | `design/assets/brand/emblem-mono.svg` (`currentColor`) | Iconos temáticos, una sola tinta |
| Wordmark | `design/assets/brand/wordmark.svg` (`#FFF9F1`), `wordmark-purple.svg` (`#9944EE`), `wordmark-mono.svg` (`currentColor`) | Textos de marca |
| Emblema glossy | `design/assets/emblem.png` (1080×1147, alpha) | Solo splash grande (≥ 160 px) |
| Lockup horizontal | *pendiente* | Landing y tienda (H4) |

### Construcción del emblema

El emblema son **dos medialunas entrelazadas** —violeta arriba a la izquierda, teal abajo a la derecha— más un **acento ámbar** arriba a la derecha. La versión vectorial conserva la geometría del render original y la repinta plana, sin degradados:

| Zona | Token | Hex |
|:--|:--|:--|
| Medialuna violeta | `brand/primary` | `#9944EE` |
| Medialuna teal | `palette/teal-500` | `#20C6C8` |
| Acento ámbar | `palette/amber-500` | `#FFD166` |

El SVG lleva una **silueta base en violeta** debajo de las tres tintas: así las juntas entre medialunas no muestran ninguna costura, y la capa de abajo nunca es un color ajeno a la marca.

El wordmark es `cambiami` en Nunito 800, 32 px y tracking −0,5, **convertido a curvas**: no depende de que la fuente esté instalada. Su avance (141 px) coincide con el nodo `n4R8P` del `.pen`.

### Reglas

- **Área de respeto:** el alto del emblema ÷ 2 en todos los lados.
- **Tamaño mínimo:** emblema plano 24 px; wordmark 32 px.
- **Fondo:** el emblema va sobre `#29243D`, `#FFF9F1` o `#FFFFFF`. Nunca sobre coral, ámbar ni fotografías.
- **El icono de app va sobre `#29243D`.** Sobre crema el teal cae a 2,01:1 y el ámbar a 1,38:1, por debajo del 3:1 de WCAG 1.4.11.
- **Prohibido:** deformar, rotar, recolorear fuera de las tres tintas, añadir sombras o recortar el emblema.
- **El glossy no se usa como icono:** a 48 px el degradado se convierte en una mancha. Solo vive en el splash, a 160 px o más.

### Estado de los assets (importante)

- `design/cambiami_logo_exact.svg` **no es vectorial**: contiene un PNG embebido en base64. No se usa.
- `design/Cambiami Brand Style Board (Editado).svg` es un autotrace (VTracer) del board, no un logo limpio. No se usa.
- **Acción pendiente:** exportar el lockup horizontal como SVG real antes de H4 (build de tienda).

---

## 3. Color

### 3.1 Paleta primitiva

En el archivo solo existen como variable los primitivos que la UI usa de verdad. El resto de la paleta de marca vive en los tokens semánticos de §3.2 con el mismo valor.

| Token | Hex | Nombre |
|:--|:--|:--|
| `palette/indigo-900` | `#1D0F50` | Índigo profundo (fondo inverso, tinta BCV) |
| `palette/indigo-soft` | `#EDE9F7` | Índigo suave (tinte BCV) |
| `palette/teal-500` | `#20C6C8` | Teal |
| `palette/teal-soft` | `#E3F8F8` | Teal suave (tinte compra) |
| `palette/coral-500` | `#FF705F` | Coral |
| `palette/coral-soft` | `#FFF4F2` | Coral suave (tinte venta, "mi tasa") |
| `palette/amber-500` | `#FFD166` | Ámbar |
| `palette/amber-soft` | `#FFF6E0` | Ámbar suave (tinte euro, estado desactualizado) |

**Referencia de marca (brand board):** índigo `#17094C`, cian `#04E2EC`, violeta `#9A28FC`, ámbar `#FEB81E`, coral `#FD544B`. No se usan crudos en la UI: la app trabaja con las versiones accesibles de §3.2 y los tintes de §3.6.

`palette/teal-soft` y `state/ok-bg` comparten hex hoy, pero no son lo mismo: el primero es un tinte de identidad, el segundo el fondo de un banner de estado. Si mañana cambia el banner, el tinte no se mueve.

### 3.2 Tokens semánticos (tema claro — único en v1)

| Token | Hex | Uso |
|:--|:--|:--|
| `bg/canvas` | `#FFF9F1` | Fondo base de pantalla; el `Content` de 02–04 se tinta por estado (§3.6) |
| `bg/surface` | `#FFFFFF` | Tarjetas, campos, sheets |
| `bg/inverse` | `#29243D` | Splash, botón oscuro |
| `bg/brand-soft` | `#F1E4FE` | Chip seleccionado, highlight |
| `text/primary` | `#29243D` | Cifras, títulos (14,2:1) |
| `text/secondary` | `#6B6673` | Fuente, fecha, estado (5,32:1) |
| `text/tertiary` | `#A29DAE` | Solo decorativo / deshabilitado (2,52:1 — **nunca texto esencial**) |
| `text/on-brand` | `#FFFFFF` | Texto sobre morado (4,76:1) |
| `text/on-inverse` | `#FFF9F1` | Texto sobre `bg/inverse` (14,2:1) |
| `text/on-inverse-soft` | `#B9AEDC` | Tagline y versión sobre `bg/inverse` (7,2:1) |
| `border/subtle` | `#EDEBF2` | Divisores |
| `border/strong` | `#DDD9E6` | Bordes de campo |
| `brand/primary` | `#9944EE` | Acción primaria, selección |
| `brand/primary-pressed` | `#7A2BD1` | Estado pulsado |
| `focus/ring` | `#9944EE` @ 24 % | Anillo de foco |
| `state/ok-ink` | `#0A7476` | Texto e icono del estado "al día" |
| `state/warn-ink` | `#7A5200` | Texto e icono del estado "desactualizado" |
| `state/offline-ink` | `#C93B2A` | Texto e icono del estado "sin conexión" |
| `state/ok-bg` | `#E3F8F8` | Fondo del banner "al día" |
| `state/warn-bg` | `#FFD166` | Fondo del banner "desactualizado" |
| `state/offline-bg` | `#FFF0EE` | Fondo del banner "sin conexión" |

Los `state/*-bg` son **sólidos**, no alpha: así el contraste no depende de la superficie que haya debajo y es el mismo en cualquier pantalla.

### 3.3 Estados del dato (F-02 / BN-06)

| Estado | Fondo | Texto/icono | Hex de texto | Contraste |
|:--|:--|:--|:--|:--|
| `al_dia` | `state/ok-bg` `#E3F8F8` | `state/ok-ink` | `#0A7476` | 5,05:1 ✅ |
| `desactualizado` | `state/warn-bg` `#FFD166` | `state/warn-ink` | `#7A5200` | 4,80:1 ✅ |
| `sin_conexión` | `state/offline-bg` `#FFF0EE` | `state/offline-ink` | `#C93B2A` | 4,57:1 ✅ |

Los contrastes de esta tabla son **texto sobre el fondo del banner**, no sobre `bg/canvas`. Es la medida que importa: es donde el texto vive.

**Regla dura:** `#FFD166`, `#FF705F` y `#20C6C8` **no se usan como color de texto**. Solo como relleno, icono o borde. Para texto se usan siempre sus variantes `-ink`.

### 3.4 Variación de tasa

| Token | Hex | Uso |
|:--|:--|:--|
| `variation/up` | `#0A7476` | Flecha ↗ y cifra positiva |
| `variation/down` | `#C93B2A` | Flecha ↘ y cifra negativa |
| `variation/flat` | `#6B6673` | Sin cambio (→) |

La variación no es buena ni mala: no se usan verde/rojo semánticos de éxito/error. Se usan los tokens `variation/*`.

### 3.5 Tema oscuro (Fase 2 — no se implementa en v1)

| Token | Hex |
|:--|:--|
| `bg/canvas` | `#1D0F50` |
| `bg/surface` | `#2A1C63` |
| `text/primary` | `#F6F2FF` (15,4:1) |
| `text/secondary` | `#B9AEDC` (8,2:1) |

Los tokens se definen desde ya para no renombrar nada en Fase 2, pero la app v1 solo envía tema claro.

### 3.6 Tintes de identidad y reparto del color

La paleta es rica, pero el color no puede competir con la lectura de cifras. Se reparte en tres capas, con una proporción objetivo **60 / 30 / 10** por pantalla:

| Capa | Proporción | Qué es | Dónde |
|:--|:--|:--|:--|
| Neutro | ~60 % | `bg/canvas`, `bg/surface`, `text/primary`, `text/secondary` | Cuerpo, tarjetas, textos |
| Tinte | ~30 % | Fondos suaves y chips de identidad | Fondo por estado, tarjetas de compra/venta, chips de fuente |
| Acento | ~10 % | `brand/primary`, `variation/*`, `*-ink` | FAB, CTA, flechas, iconos |

**Regla:** máximo **3 acentos fuertes** por pantalla. Los tintes suaves no cuentan como acento.

#### Tintes de identidad por fuente

Cada fuente de tasa tiene un color y un icono fijos. Se usan en el chip de `RateCard` (§7.2), en las filas de Monedas (09) y en cualquier lista de tasas.

| Fuente | Fondo | Icono | Icono Lucide |
|:--|:--|:--|:--|
| BCV (dólar, oficial) | `palette/indigo-soft` `#EDE9F7` | `palette/indigo-900` `#1D0F50` | `landmark` |
| Euro | `palette/amber-soft` `#FFF6E0` | `state/warn-ink` `#7A5200` | `euro` |
| USDT | `bg/brand-soft` `#F1E4FE` | `brand/primary-pressed` `#7A2BD1` | `circle-dollar-sign` |
| Mi tasa | `palette/coral-soft` `#FFF4F2` | `state/offline-ink` `#C93B2A` | `star` |

El promedio del P2P no tiene identidad propia: es el valor de la tasa USDT y usa su chip.

Sobre una tarjeta tintada (por estado), el chip va en `bg/surface` para no desaparecer.

#### Tinte por estado del dato

El fondo del contenido cambia con el estado, no solo el banner:

| Estado | Fondo del `Content` |
|:--|:--|
| `al_dia` | `bg/canvas` (02 usa `bg/brand-soft` por decisión de marca) |
| `desactualizado` | `palette/amber-soft` `#FFF6E0` |
| `sin_conexión` | `palette/coral-soft` `#FFF4F2` |

El banner de estado conserva sus tokens `state/*` para que el contraste del texto no dependa del fondo de la pantalla.

#### Compra y venta

Dentro de la ficha P2P, **Compra** y **Venta** van sin tinte propio: el color direccional vive en la variación (`variation/up` / `variation/down`) y el tinte se reserva para el chip de identidad. Dos bloques tintados dentro de una tarjeta con borde de marca daban tres fondos en el mismo elemento.

#### Estado vs. identidad

- **Color de estado** → banner o flecha pequeña, siempre con icono y texto.
- **Color de identidad** → chip de icono, sin texto de estado.
- Nunca los dos en el mismo elemento: una tarjeta no puede ser a la vez "desactualizada" y "BCV" por color.

---

## 4. Tipografía — Nunito

Familia única: **Nunito** (Google Fonts, OFL). Pesos usados: 400, 600, 700, 800.

| Token | Tamaño / interlínea | Peso | Uso |
|:--|:--|:--|:--|
| `type/display` | 44 / 48 | 800 | Resultado en Bs de la calculadora |
| `type/h1` | 28 / 34 | 800 | Título de pantalla (solo splash/landing) |
| `type/h2` | 22 / 28 | 800 | Título de pantalla (`Calculadora`, `Tasas`) |
| `type/h3` | 18 / 24 | 700 | Nombre de moneda en tarjeta de tasa |
| `type/amount` | 28 / 32 | 800 | Monto en el campo activo |
| `type/body` | 16 / 24 | 400 | Párrafos, legal |
| `type/body-strong` | 16 / 24 | 600 | Texto de botón, valores de fila |
| `type/label` | 14 / 20 | 600 | Etiquetas de campo, tabs |
| `type/caption` | 12 / 16 | 600 | Fuente, fecha, estado, brecha |
| `type/micro` | 11 / 14 | 700 | Badges, texto sobre banner (con `letterSpacing` 0.4) |

### Reglas

- **Cifras siempre con `FontFeature.tabularFigures()`** para que los montos no bailen al escribir. Verificar que Nunito exponga `tnum`; si no, usar `Nunito` con `letterSpacing: 0` y alinear a la derecha.
- Nunca más de 2 tamaños distintos en una misma tarjeta.
- El título de pantalla es **siempre** `type/h2`, igual en todas las pantallas.
- Nada de mayúsculas sostenidas excepto `type/micro`.
- No se usa otra familia en v1. Ni siquiera para el logo (el wordmark es imagen, no texto).

---

## 5. Espaciado, grid y forma

### Escala (base 4)

| Token | px |
|:--|:--|
| `space/1` | 4 |
| `space/2` | 8 |
| `space/3` | 12 |
| `space/4` | 16 |
| `space/5` | 20 |
| `space/6` | 24 |
| `space/8` | 32 |
| `space/10` | 40 |
| `space/12` | 48 |

### Layout

- Ancho de referencia: **390 px** (iPhone 14/15). Verificar en **360 px** (Android común).
- Padding horizontal de pantalla: **24 px**, aplicado una sola vez en el contenedor de contenido (`Content`), nunca en el frame raíz.
- Padding vertical del contenido: **12 px** arriba y **20 px** abajo.
- En las pantallas con barra flotante (02, 03, 04, 05, 07) el scroll reserva **96 px** abajo: 20 de padding + 72 de barra + 4 de holgura. El frame de diseño muestra el contenido completo con la barra debajo; el `96` es una regla de implementación en Flutter para que el último elemento no quede tapado.
- Separación entre secciones: **24 px**. Dentro de una sección: **12 px**.
- Alto del status bar: **62 px**. Nunca se dibuja UI debajo.
- Tab bar: **72 px** de alto, flotante, inset 16 px laterales y 12 px inferiores. El FAB central de 60 px sobresale 16 px por encima.
- Área táctil mínima: **48×48 px**.

### Radios

| Token | px | Uso |
|:--|:--|:--|
| `radius/sm` | 8 | Badges, chips pequeños |
| `radius/md` | 12 | Campos, botones |
| `radius/lg` | 16 | Tarjetas |
| `radius/xl` | 20 | Sheets, tarjetas destacadas |
| `radius/pill` | 999 | Tab bar, chips de tasa |

### Elevación

| Token | Valor | Uso |
|:--|:--|:--|
| `shadow/none` | — | Por defecto. Las tarjetas se separan con borde `#EDEBF2`, no con sombra. |
| `shadow/floating` | `0 8 24 rgba(41,36,61,0.10)` | Solo tab bar y bottom sheet |

---

## 6. Iconografía

- Librería única: **Lucide** (línea, 2 px, esquinas redondeadas). En Flutter: `lucide_icons_flutter`.
- Tamaños: 16 (inline), 20 (botón), 24 (cabecera), 28 (tab bar).
- Color: `text/primary` o `text/secondary`. Nunca un color de marca salvo en estado activo.
- **Se eliminan todos los emojis del brief** (`💵 💶 💸 💰 📊 📋 🔽 🔄`). Eran marcadores de posición de la evidencia del clon.

| Concepto | Icono Lucide |
|:--|:--|
| Calculadora | `calculator` |
| Tasas | `trending-up` |
| Compartir | `share-2` |
| Copiar | `copy` |
| Selector de moneda | `chevron-down` |
| Invertir | `arrow-up-down` |
| Menú | `menu` |
| Información | `info` |
| Configuración | `settings` |
| Fuente oficial | `badge-check` |
| Sin conexión | `cloud-off` |
| Desactualizado | `clock` |
| Al día | `circle-check` |
| Mi tasa (identidad) | `star` |
| Editar Mi tasa (acción) | `pencil` |
| Flecha sube | `arrow-up-right` |
| Flecha baja | `arrow-down-right` |

---

## 7. Componentes

### 7.1 `AmountCard` — campo de monto

```
┌──────────────────────────────────┐
│ Dólares                      $   │  label (type/label, secondary)
│ 1,00                             │  type/amount, primary
└──────────────────────────────────┘
```

| Propiedad | Valor |
|:--|:--|
| Fondo | `bg/surface` |
| Borde | `border/strong` 1 px · activo: `brand/primary` 2 px |
| Radio | `radius/lg` |
| Padding | 16 |
| Gap label→valor | 4 |
| Botón copiar | icono 20, `text/secondary`, área 48×48 |

### 7.2 `RateCard / Ficha` — tarjeta de tasa (pantallas Tasas)

```
┌──────────────────────────────────┐
│ ╭──╮ Dólar          889,5754 Bs ↗│  chip + h3 + body-strong + variation
│ ╰──╯ +0,32 Bs (0,04 %)           │  caption, variation/up
│ ──────────────────────────────── │  divider, border/subtle
│ Publicado       Vigente desde    │  micro, text/secondary
│ 02/11/26 · 5:00 p. m.   03/11/26 │  caption, text/primary
│ ──────────────────────────────── │  divider, border/subtle
│ BCV · bcv.org.ve →               │  caption, text/secondary + external-link
└──────────────────────────────────┘
```

Cuatro niveles: valor (18/800) → variación (12/600, color de variación) → fechas de la fuente (micro + caption) → procedencia enlazable (caption). La procedencia **nunca** se omite.

| Propiedad | Valor |
|:--|:--|
| Fondo | `bg/surface` |
| Borde | `border/subtle` 1 px |
| Radio | `radius/lg` |
| Padding | 16 |
| Chip de fuente | 40×40, radio 12, icono Lucide 20 — colores en §3.6 |
| Gap chip→nombre | 10 |
| Gap interno | 4 entre Head y Change; 6 dentro de `Details` |
| Alto | **164** (con las dos fechas) |

El chip es la identidad de la fuente (§3.6), no su estado. El estado vive en el `StatusPill` de la franja de frescura (§7.7). Si una tasa concreta se desvía del estado global, su `Source link` antepone la palabra (`desactualizado`, `sin conexión`) en `state/warn-ink` o `state/offline-ink`.

**Las tres fechas.** `Publicado` = `published_at`, `Vigente desde` = `effective_from`; la tercera, `fetched_at`, va en la franja (§7.7). Ninguna se repite en dos sitios.

**Variación ausente.** Si `change_pct` es nulo —primera publicación de ese tipo— la fila de variación no se dibuja: ni `0 %` ni `—`. El alto de la ficha baja en esa línea: de **164** a **146** en la ficha completa y de **213** a **195** en la variante USDT. El espacio no se rellena con otro dato.

**USDT.** En las tasas P2P `effective_from` puede coincidir con `published_at`: si coinciden, la segunda columna se oculta y la rejilla pasa a una columna. No se inventa una fecha distinta.

**Variante USDT (`RateCard / Ficha · USDT P2P`).** La ficha se titula **`USDT`** (la moneda), no `Promedio` (la estadística): el nombre de la tarjeta responde a *qué tasa es*, igual que `Dólar` y `Euro`. El valor grande es el promedio y la variación lo declara (`Promedio · +2,19 Bs (+0,22 %)`). Entre la variación y las fechas añade una fila de dos columnas con `Compra` y `Venta`: etiqueta 11/700 `text/secondary`, valor 14/800 `text/primary`, variación 11/700 en su color. Sube a **213 px**. Fondo `bg/surface` como el resto, con borde `brand/primary` 1 px y chip en `bg/brand-soft` con icono `brand/primary-pressed`. La identidad de USDT vive en el chip y el borde, no en un tinte de fondo: así el valor y la variación se leen siempre sobre `bg/surface`.

**Variante compacta (`RateCard / Compacta`).** Es la ficha de la calculadora (02, 02b, 03 y 04) y **hace de selector**: el nombre y el chevron viven en el mismo `Head`, así que la tasa no se repite en dos bloques.

```
┌────────────────────────────────────────────────┐
│ ╭──╮ Dólar ⌄                     889,5754 Bs ↗ ⇅│  chip 28 · nombre 16/700 · chevron · valor 16/800 · flecha 14 · swap 16
│ ╰──╯ +0,32 Bs (0,04 %)           BCV · bcv.org.ve│  variación 11/600 · fuente 11/600
└────────────────────────────────────────────────┘
```

| Propiedad | Valor |
|:--|:--|
| Fondo | `bg/surface` |
| Borde | `border/subtle` 1 px |
| Radio | `radius/lg` |
| Padding | `[10, 16]` |
| Chip de fuente | 28×28, radio 8, icono Lucide 16 — colores en §3.6 |
| Gap interno | 2 entre `Head` y `Meta`; 10 dentro del `Head` |
| Alto | **65** |

- **`Label`** = nombre de la tasa + `chevron-down` 16 (`text/secondary`). Toda la ficha abre 09 Monedas: es el selector.
- **`Swap`** = `arrow-up-down` 16 al final del `Head`; cambia el sentido del cálculo (dólares ↔ bolívares), no la tasa. Es una acción distinta del toque que abre 09 Monedas: necesita su propio hit target (44×44 mínimo) sin solaparse con el de la ficha.
- Sin `Details` ni divider: no lleva fechas. La procedencia (`BCV · bcv.org.ve`) va en `Meta` y la frescura, en la franja de arriba (§7.7). El nombre es la moneda (`Dólar`, `Euro`, `USDT`, `Mi tasa`), igual que en 05.
- La flecha sigue `is_down` (`arrow-down-right` + `variation/down`).
- **Mi tasa** oculta la franja de frescura y la fuente pasa a `Definida por ti`: no hay `published_at` ni `fetched_at` que mostrar.
- El estado no se escribe dos veces: en la calculadora lo lleva el pill de la franja (§7.7) y el `Source` se queda en `BCV · bcv.org.ve`. El prefijo `desactualizado` / `sin conexión` es solo para la ficha de Tasas, donde no hay franja por tarjeta.
- **USDT** usa esta variante sin Compra/Venta: las dos columnas viven solo en la ficha completa de 05.

### 7.3 `StatusBanner`

```
┌──────────────────────────────────┐
│ ⚠  Sin conexión · mostrando la    │
│    tasa del 01/11/26              │
└──────────────────────────────────┘
```

- Alto mínimo 36, padding [10, 12], radio `radius/md`, gap 8.
- Icono 16 + texto `type/caption` en el `-ink` del estado.
- Aparece entre el header y el contenido. Nunca flota sobre el contenido.

### 7.4 `TabBar` (3 destinos en v1, Calculadora elevada)

- Flotante, **72 px de alto**, radio pill, `bg/surface` + `shadow/floating`, padding `[0, 6, 6, 6]`. Ocupa el ancho disponible entre los insets de 16 px (**358 px** a 390).
- Tres zonas en fila: `Tab / Tasas` (fill), `Center` (72) y `Tab / Configuración` (fill). Los tabs miden 137 × 66.
- Item lateral: icono 24 **arriba**, label 11 debajo, gap 2, alineado abajo. Vertical, no horizontal: `Configuración` no cabe al lado del icono.
- **Centro elevado:** slot de 72 × 66 con un FAB circular de **60 px** en `y = -16`, de modo que sobresale 16 px por encima de la barra. Icono `calculator` de 28 centrado.
- **Activo:** icono y label en `brand/primary`, peso **800**. El FAB va relleno `brand/primary` con icono `text/on-brand`.
- **Inactivo:** `text/secondary`, peso **600**, sin pill de fondo. El FAB va en `bg/brand-soft` con icono `brand/primary`. El peso tipográfico es la segunda señal, no solo el color.
- El label `Calculadora` va centrado bajo el FAB (72 px, `textAlign: center`, `y = 50`).
- Destinos: **Calculadora** (`calculator`), **Tasas** (`trending-up`) y **Configuración** (`settings`).

Los 137 px de cada tab dejan sitio a `Configuración` (76 px a 11/600) incluso con el texto escalado a 1,3×. Un cuarto destino no cabría con etiqueta visible.

En el archivo hay tres componentes, uno por estado activo: `TabBar / Calculadora`, `TabBar / Tasas` y `TabBar / Configuracion`.

### 7.5 Botones

| Variante | Fondo | Texto | Uso |
|:--|:--|:--|:--|
| Primario | `brand/primary` | `text/on-brand` | Compartir cálculo |
| Secundario | `bg/surface` + borde `border/strong` | `text/primary` | Acciones alternativas |
| Ghost | transparente | `brand/primary` | Enlaces, "Volver" |
| Icono | transparente | `text/secondary` | Cabecera |

Alto 48, radio `radius/md`, padding horizontal 20, texto `type/body-strong`.

### 7.6 `RateRow` (lista en modal Monedas)

Fila de 56 px: chip de identidad 32×32 (radio 10, icono 16, colores de §3.6) + nombre (`type/body-strong`) + valor (`type/body-strong`, derecha) + indicador "En calculadora" (`type/micro` 11/700, `brand/primary`) cuando aplica. La fila de la tasa activa lleva el nombre en `brand/primary-pressed` y el indicador; las demás, en `text/primary`.

El sheet de 09 mide **404 px** y reutiliza el patrón de §7.10: radio `[20, 20, 0, 0]`, padding `[12, 20, 20, 20]`, gap 16, asa 36×4, cabecera `Monedas` (`type/h2`) + `✕` de 40×40, filas de 56 separadas por `border/subtle` de 1 px y `Button/Primary` `Aplicar` de 48 al pie. No lleva barra inferior.

### 7.7 `FreshnessStrip` — frescura y estado de la vista

```
⟳ Actualizado hoy · 9:41 a. m.              ● al día
```

- Fila de 20 px, ancho completo, bajo la cabecera y sobre el primer grupo.
- Izquierda: icono `refresh-cw` 14 (`text/secondary`) + `fetched_at` en `type/caption` (`text/secondary`). Formatos: `Actualizado hoy · 9:41 a. m.` / `Actualizado ayer · 5:02 p. m.`.
- Derecha: `StatusPill` = punto de 6 px + palabra en `type/micro`, **sin fondo**. Colores en §3.3.
- El pill es el estado **de la vista**, no de cada tarjeta: no se repite salvo que una tasa se desvíe (§7.2).
- **En la calculadora** va dentro del cuerpo, **sobre la ficha compacta** (§7.2): el estado se lee antes que el valor y la fecha no se duplica con el `Source` de la ficha. En 02b (teclado abierto) se oculta la ficha, nunca la franja. **En Tasas** va bajo la cabecera y sobre el primer grupo.

### 7.8 `MethodNote` — "Cómo se calcula"

```
ⓘ Cómo se calcula
  BCV   El BCV publica en días hábiles a las 5:00 p. m.; la
        fecha de valor indica desde cuándo rige la tasa.
  P2P   Promedio de los anuncios de compra y venta de USDT
        en Binance. 1 USDT ≠ 1 USD.
  bcv.org.ve →   binance.com →
```

- **Sin contenedor**: va sobre `bg/canvas`, separado por el gap de 24 px de la sección. No compite con las tarjetas.
- Una sola nota para las dos fuentes: una fila por fuente, con etiqueta de 34 px en `type/micro` 800 (`text/secondary`) y cuerpo en `type/caption` (`text/secondary`). Los enlaces van juntos en una fila al pie.
- Título en `type/label` 700 (`text/primary`); enlaces en `brand/primary` 700 + `external-link` 12.
- Sustituye a los disclaimers sueltos de 05. El texto legal completo sigue viviendo solo en 08 (§13.6).
- Máximo 2 líneas de cuerpo por fila a 390 px. Si el copy crece, se recorta el copy, no el ancho.

### 7.9 `SectionHeader` — grupos del catálogo de Tasas

- `Oficial` y `Mercado P2P`: `type/label` 13/800 en `text/secondary`, sobre `bg/canvas`, 12 px por encima de la lista.
- Agrupan por **mercado**, no por fuente: `official` está en `rate_snapshots` y la fuente sigue en el pie de cada ficha.
- Un grupo nuevo (USDC, otra stablecoin) es una fila más dentro del grupo existente; no cambia la estructura de la pantalla.

### 7.10 `MiTasaSheet` — editar Mi tasa

```
┌──────────────────────────────────┐
│               ────               │  asa 36×4
│ Mi tasa                      ✕   │  type/h2 + cerrar 40
│ ┌──────────────────────────────┐ │
│ │ Bolívares                 Bs │ │  AmountCard, borde activo
│ │ 1.000,00                     │ │
│ └──────────────────────────────┘ │
│ Déjalo vacío para quitarla de la  │  type/caption, secondary
│ calculadora.                      │
│ ┌──────────────────────────────┐ │
│ │           Guardar            │ │  Button/Primary
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

| Propiedad | Valor |
|:--|:--|
| Ancho | 390 (`fill_container`) |
| Radio | `[20, 20, 0, 0]` |
| Padding | `[12, 20, 20, 20]` |
| Gap | 16 |
| Asa | 36×4, `border/strong`, pill |
| Título | `type/h2` 22/800 |
| Cerrar | icono `x` 22, área 40×40, radio 12 |
| Campo | `AmountCard` activo: borde `brand/primary` 2 px, sin botón copiar |
| Helper | `type/caption`, `text/secondary`, una línea |
| CTA | `Button/Primary`, 48 px, ancho completo |
| Alto | **301** |

- Mismo patrón que 09 (§7.6): asa, cabecera con `✕`, contenido y CTA al pie. No lleva barra inferior.
- Se abre desde el `pencil` de la fila **Mi tasa** en 09, no desde la calculadora: la ficha compacta sigue abriendo 09.
- **Estado vacío:** campo vacío o `0` = quitar Mi tasa. `Guardar` está siempre habilitado y no hay copy de error: el helper explica la consecuencia antes de pulsar. Al guardar, el sheet se cierra y 09 deja la fila `Mi tasa` en `Definir`, que sigue siendo la entrada para volver a crearla; la calculadora deja de ofrecer Mi tasa hasta que se defina otra vez.
- Acepta coma y punto y normaliza a coma al mostrar (§8). Solo dígitos y un separador decimal.
- Mi tasa es local (`shared_preferences`): no tiene `source_code`, `published_at` ni `fetched_at`, y por eso no entra en el catálogo de Tasas.

---

## 8. Formato numérico es-VE (F-04)

Implementación única: `EsVeFormatter` en `lib/core/formatters/`. Ninguna pantalla formatea por su cuenta.

| Caso | Entrada | Salida |
|:--|:--|:--|
| Tasa | `889.5754` | `889,5754 Bs` |
| Monto en Bs | `889.58` | `889,58 Bs` |
| Monto en $ | `1` | `$ 1,00` |
| Miles | `1234.5` | `1.234,50 Bs` |
| Variación + | `0.32`, `0.04` | `+0,32 Bs (0,04 %)` |
| Variación − | `-1.55`, `-0.16` | `−1,55 Bs (−0,16 %)` |
| Sin cambio | `0`, `0` | `0,00 Bs (0,00 %)` |
| Cero | `0` | `0,00 Bs` |
| Fecha | `2026-11-02` | `Lunes, 02/11/26` |
| Hora | `09:00` | `09:00 a. m.` |
| Brecha | `0.1195` | `11,95 %` |

### Reglas

- Decimal: **coma**. Miles: **punto** (solo cuando hay 4+ dígitos).
- Sufijo `Bs` **después** del número, con espacio: `889,58 Bs`. Nunca `Bs. 889,58` ni `Bs889,58`.
- Dólar: `$` **antes**, con espacio: `$ 1,00`.
- Signo menos tipográfico `−` (U+2212), no guion.
- Se muestran todos los decimales que publica la fuente (BN-01). El redondeo es solo visual.
- En la calculadora el resultado se muestra con 2 decimales; la tasa en la tarjeta conserva todos.
- El `input` del usuario acepta coma y punto, y normaliza a coma al mostrar.

---

## 9. Accesibilidad

- Contraste mínimo AA (4,5:1 texto normal, 3:1 texto grande). Todos los pares de §3 cumplen.
- El estado del dato **nunca** se comunica solo con color: siempre icono + texto.
- Escalado de fuente del sistema hasta 1,3× sin romper layout. Los montos pueden truncarse con `…` antes que desbordar.
- Área táctil mínima 48×48.
- Etiquetas semánticas: los montos se leen como "ochocientos ochenta y nueve coma cincuenta y ocho bolívares".
- El campo activo no depende solo del borde: también muestra el cursor y el label en `brand/primary`.

---

## 10. Motion

| Elemento | Duración | Curva |
|:--|:--|:--|
| Splash → Calculadora | 400 ms | `easeOutCubic` |
| Aparición de banner | 200 ms | `easeOut` |
| Cambio de tasa (crossfade del valor) | 150 ms | `linear` |
| Press feedback | 90 ms | `easeOut` |

**Nada** de animaciones de entrada en la calculadora: el número debe estar pintado en el primer frame útil (RNF-01).

---

## 11. Assets

| Asset | Archivo | Estado |
|:--|:--|:--|
| Emblema plano (3 colores) | `design/assets/brand/emblem.svg` | ✅ vectorial |
| Emblema monocromo | `design/assets/brand/emblem-mono.svg` | ✅ vectorial |
| Wordmark (3 tintas) | `design/assets/brand/wordmark*.svg` | ✅ vectorial, en curvas |
| Emblema glossy original | `design/assets/emblem.png` | ✅ solo splash |
| Icono de app (recomendado) | `design/assets/brand/app-icon-dark-1024.png` | ✅ 1024, opaco |
| Icono de app sobre crema | `design/assets/brand/app-icon-cream-1024.png` | ✅ 1024, opaco (no usar: contraste) |
| Adaptive icon foreground | `design/assets/brand/android/ic_launcher_foreground-432.png` | ✅ 432, zona segura |
| Adaptive icon monochrome | `design/assets/brand/android/ic_launcher_monochrome-432.png` | ✅ 432 |
| Icono de notificación | `design/assets/brand/android/ic_notification-96.png` | ✅ 96, blanco |
| Fuente Nunito (OFL) | `design/assets/fonts/Nunito-VariableFont_wght.ttf` | ✅ para Flutter |
| Splash nativo | — | ⬜ lo genera Flutter |
| Lockup horizontal SVG | — | ⬜ pendiente (H4) |
| Feature graphic tienda | 1024×500 | ⬜ pendiente (H4) |
| Capturas de tienda | 1080×1920 ×5 | ⬜ pendiente (H4) |

**Splash nativo:** fondo `#29243D` y emblema glossy (`emblem.png`) a 160 px, para que la transición al splash de Flutter (pantalla 01) no muestre un salto. El icono de app, en cambio, usa el emblema plano.

Regla de peso: la app base debe quedar **< 40 MB** (RNF-09). El emblema no se usa a más de 512 px dentro de la app.

---

## 12. Pantallas y navegación

El MVP v1 son **11 artboards** en `design/cambiami.pen`. Esta es la lista canónica: si una pantalla no está aquí, no entra en v1.

| # | Pantalla | Estado | Frame |
|:--|:--|:--|:--|
| 01 | Splash | único | `Screen / 01 · Splash` |
| 02 | Calculadora | `al_dia` | `Screen / 02 · Calculadora / al_dia` |
| 02b | Calculadora | `escribiendo` (teclado abierto) | `Screen / 02b · Calculadora / escribiendo` |
| 03 | Calculadora | `desactualizado` | `Screen / 03 · Calculadora / desactualizado` |
| 04 | Calculadora | `sin_conexión` | `Screen / 04 · Calculadora / sin_conexion` |
| 05 | Tasas | normal · cargando · error | `Screen / 05 · Tasas` |
| 07 | Configuración | normal | `Screen / 07 · Configuracion` |
| 08 | Información | normal | `Screen / 08 · Informacion` |
| 09 | Monedas | modal sobre Calculadora | `Screen / 09 · Monedas (modal)` |
| 09b | Mi tasa | sheet sobre Calculadora (vía 09) | `Screen / 09b · Mi tasa (sheet)` |
| 10 | Compartir | sheet sobre Calculadora | `Screen / 10 · Compartir (sheet)` |

El número **06 queda vacante**: era `Tasas USDT` y se absorbió en 05 al pasar a catálogo por mercado. Los estados `cargando` y `error` de Tasas están dibujados en el frame `Estados · Tasas` del grupo HU-11 (§13.4).

09, 09b y 10 llevan detrás una **copia estática de 02** (`Backdrop · Calculadora`) bajo un rectángulo de scrim `#29243D66`. pen.dev no permite instanciar una pantalla, así que la copia se mantiene a mano: si 02 cambia, hay que repetir el `Copy`. Sin ese fondo, el export es un scrim sobre el lienzo y no comunica que es un modal.

En el archivo, las 11 pantallas están agrupadas por historia de usuario en el frame `Board · Pantallas por historia` (a la izquierda del canvas). El mapa completo y la matriz de apariciones están en `design/README.md`.

### 12.1 Flujo de navegación

| Desde | Acción | Hacia |
|:--|:--|:--|
| 01 Splash | espera 400 ms | 02 Calculadora |
| 02 Calculadora | tap `RateCard / Compacta` (chevron `⌄`) | 09 Monedas |
| 09 Monedas | tap `Aplicar` o `✕` | 02 Calculadora |
| 09 Monedas | tap `pencil` en la fila Mi tasa | 09b Mi tasa |
| 09b Mi tasa | tap `Guardar` o `✕` | 09 Monedas |
| 02 Calculadora | tap `Compartir cálculo` | 10 Compartir |
| 02 Calculadora | tap tab `Tasas` | 05 Tasas |
| 02 Calculadora | tap tab `Configuración` | 07 Configuración |
| 05 Tasas | tap tab `Calculadora` | 02 Calculadora |
| 05 Tasas | tap tab `Configuración` | 07 Configuración |
| 05 Tasas | tap `info` | 08 Información |
| 05 Tasas | tap `Compartir tasas` | 10 Compartir |
| 07 Configuración | tap tab `Calculadora` | 02 Calculadora |
| 07 Configuración | tap tab `Tasas` | 05 Tasas |
| 07 Configuración | tap `Información` | 08 Información |
| 08 Información | tap `Volver` o `‹` | pop (Configuración o Tasas, según de dónde venga) |

El botón de volver **siempre hace `pop`**, no navega a un destino fijo: se puede llegar a Información desde Configuración o desde el icono `info` de Tasas.

**Sheets sobre la calculadora:** 09, 09b y 10 no son pantallas opacas. El fondo que se ve tras el scrim es 02: el usuario no pierde el contexto del cálculo mientras elige moneda, edita Mi tasa o comparte.

**Barra inferior:** la llevan las pantallas de primer nivel — 02, 03, 04, 05 y 07. No la llevan 02b (el teclado la cubre) ni 08 Información (pantalla de detalle, se sale con `‹`). Configuración dejó de ser secundaria: ya no tiene botón de volver, se llega y se sale por la barra.

### 12.2 Rutas en Flutter

| Ruta | Pantalla |
|:--|:--|
| `/` | 02 Calculadora |
| `/tasas` | 05 Tasas |
| `/configuracion` | 07 Configuración |
| `/informacion` | 08 Información |

Monedas (09) y Compartir (10) **no son rutas**: se abren con `showModalBottomSheet` sobre la pantalla actual.

**Nota:** pen.dev no tiene un modo de prototipo con hotspots como Figma. Este mapa no se cablea en el archivo de diseño; se implementa en el router y se revisa a mano contra los frames.

---

## 13. Microcopy y estados

Todo el texto que ve el usuario vive aquí. Si un texto no está en esta sección, no se escribe.

### 13.1 Reglas de redacción

- es-VE, tuteo neutro, frases cortas. Nada de "por favor" ni de signos de exclamación.
- **Cero emojis.** Los iconos son Lucide (§6).
- Nunca se promete exactitud oficial ni se da consejo financiero.
- Los botones usan verbo en infinitivo: `Compartir`, `Aplicar`, `Reintentar`, `Volver`.
- Las cifras del copy salen de `EsVeFormatter` (§8). No se transcriben a mano.

### 13.2 Títulos y etiquetas

| Dónde | Texto |
|:--|:--|
| Títulos de pantalla | `Calculadora` · `Tasas` · `Configuración` · `Información` · `Monedas` · `Compartir` |
| Splash | `cambiami` · `La tasa, clara y al día.` · `v1.0 · TasaVE C.A.` |
| Tabs | `Calculadora` · `Tasas` · `Configuración` |
| Campos de monto | `Dólares` · `Euros` · `Bolívares` · `USDT` |
| Chips de tasa | `BCV` · `USDT` · `Euro` · `Mi tasa` |
| Ficha de la calculadora | `Dólar` · `Euro` · `USDT` · `Mi tasa` · `Definida por ti` |
| Grupos de Tasas | `Oficial` · `Mercado P2P` |
| Tasas P2P | `Compra` · `Venta` · `Promedio` · `Brecha BCV ↔ USDT` |
| Metadatos de tasa | `Publicado` · `Vigente desde` |
| Frescura | `Actualizado hoy · 9:41 a. m.` · `Actualizado ayer · 5:02 p. m.` |
| Metodología | `Cómo se calcula` · `Ver en bcv.org.ve` · `Ver en binance.com` |
| Fórmula de la brecha | `(USDT promedio − BCV) ÷ BCV` · `BCV 889,5754 Bs · USDT 995,90 Bs` |
| Monedas | `En calculadora` · `Aplicar` |
| Sheet Mi tasa | `Mi tasa` · `Bolívares` · `Déjalo vacío para quitarla de la calculadora.` · `Guardar` |
| Fila Mi tasa sin definir (09) | `Definir` |
| Acciones | `Compartir cálculo` · `Compartir tasas` · `Copiar texto` · `WhatsApp` · `Reintentar` · `Volver` |
| Configuración | `Moneda predeterminada` · `Esta moneda se mostrará en la calculadora al abrir la app.` · `Información` · `TasaVE C.A. · v1.0` |

El RIF `J-30452819-5` no se muestra en la app: el pie queda `TasaVE C.A. · v1.0` y el RIF vive solo en la ficha legal de tienda.

### 13.3 Estados del dato (F-02 / BN-06)

| Estado | Banner | Dónde se ve el estado |
|:--|:--|:--|
| `al_dia` | sin banner | `StatusPill` de la franja (§7.7) en `state/ok-ink` |
| `desactualizado` | `Tasa de ayer · se actualiza a las 5:00 p. m.` | pill en `state/warn-ink`; la tarjeta afectada antepone `desactualizado` en su `Source link` |
| `sin_conexión` | `Sin conexión · mostrando la tasa del 01/11/26` | pill en `state/offline-ink`; todas las tarjetas anteponen `sin conexión` |

El banner **no sustituye** la frescura: cuando hay banner, se muestran los dos. La fecha ya no se repite en la procedencia porque vive en `Publicado` (§7.2).

### 13.4 Carga y error

| Situación | Texto | Nota |
|:--|:--|:--|
| Cargando (Tasas) | ninguno visible | Skeleton de título, dos `SectionHeader` y tres `RateCard / Ficha`, dibujado en `Estados · Tasas`; el lector de pantalla anuncia `Actualizando tasas` |
| Error (Tasas) | `No pudimos actualizar las tasas.` + botón ghost `Reintentar` | Icono `cloud-off` 32; dibujado en `Estados · Tasas` |
| Sin tasas (vista vacía) | `No hay tasas publicadas.` + botón ghost `Reintentar` | La consulta fue correcta y la vista vino sin filas; no se inventan tasas ni se escribe cache |
| Sin datos de una moneda | sin copy | La tarjeta no se dibuja; si esa moneda es la tasa seleccionada, se cae a `USD`/`oficial` como una selección huérfana (REQ-CAT-005) |
| Tasa inválida (calculadora) | `No pudimos calcular con esta tasa.` | La tasa recibida es `0` o negativa; el resultado queda deshabilitado y no se ofrece `Reintentar`, porque no es un fallo de red |

### 13.5 Compartir (mensaje literal)

```
$ 1,00 = 889,58 Bs

Tasa BCV: 1 $ = 889,58 Bs
Fecha valor: Lunes, 02/11/26

Descarga Cambiami: https://cambiami.app
```

- El monto y la tasa se toman de la calculadora en el momento de compartir; el bloque de arriba es el estado por defecto.
- El enlace de v1 es `https://cambiami.app`, centralizado en `AppConfig.shareUrl`. Si H4 cambia el dominio, se actualiza ese único valor. Nunca `bit.ly/alcambio-app` (era del clon).
- El dominio debe estar publicado antes del build de tienda (H4); el literal no cambia por eso.

### 13.6 Texto legal (F-12, obligatorio)

> Los datos mostrados en esta aplicación tienen carácter exclusivamente informativo. Cambiami no fija, certifica ni garantiza tasas de cambio y no está afiliada al Banco Central de Venezuela ni a Binance. La tasa oficial del BCV se publica en días hábiles y se actualiza a las 5:00 p. m. La referencia USDT proviene del mercado P2P de Binance: 1 USDT no equivale a 1 USD. Verifique siempre la tasa antes de operar.

- Se muestra completo en `08 · Información` y se repite en la ficha de tienda.
- No se resume, no se traduce y no se reparte entre pantallas.

### 13.7 Formato dentro del copy

- Fechas: `Lunes, 02/11/26` (día de la semana, coma, dd/mm/aa).
- Horas: `09:00 a. m.` y `5:00 p. m.`, con espacio entre la hora y `a. m.` / `p. m.`.
- `1 USDT ≠ 1 USD` con el signo `≠`, no `!=`.
- `$ 1,00` y `889,58 Bs`: símbolo separado del número por un espacio.

---

## 14. Naming y handoff a Flutter

- Las variables de `design/cambiami.pen` usan el **mismo nombre** que los tokens de este documento (`bg/canvas`, `type/h2`, `space/4`, `radius/lg`).
- En Dart: `AppColors.bgCanvas`, `AppTypography.h2`, `AppSpacing.s4`, `AppRadius.lg`.
- Prohibido hex sueltos en widgets. Todo pasa por `AppColors`.
- Un solo archivo de tema: `lib/core/theme/app_theme.dart`.

### Nombres de capa en el archivo de diseño

```
Screen / <número> · <nombre> / <estado>
  ├─ Status bar
  ├─ Content
  │   └─ Calculator / Body   ← instancia en 02, 02b, 03 y 04
  └─ Tab wrap
```

```
Calculator / Body
  ├─ Header
  ├─ Banner / estado         ← desactivado por defecto
  ├─ Rate block
  │   ├─ Freshness
  │   └─ RateCard / Compacta
  ├─ Amounts
  └─ Share CTA
```

Las cuatro pantallas de Calculadora **son la misma instancia**: solo cambian el fondo del `Content`, el banner, la frescura, la ficha (visible u oculta), los importes y el pill. El `Status bar`, el teclado y la barra quedan fuera del componente.

Nunca `Frame 123`, `Rectangle 45` ni `Group 8`.

### Mapa diseño → Flutter

| Diseño | Flutter |
|:--|:--|
| Variable color `bg/canvas` | `AppColors.bgCanvas` |
| Text style `type/h2` | `AppTypography.h2` |
| Variable number `space/4` | `AppSpacing.s4` |
| Variable number `radius/lg` | `AppRadius.lg` |
| Componente `RateCard` | `RateCard` widget |
| Componente `RateCard / Compacta` | `RateCardCompact` widget |
| Componente `Calculator / Body` | `CalculatorBody` widget |
| Componente `StatusBanner` | `StatusBanner` widget |
| Componente `AmountCard` | `AmountField` widget |

---

*Sistema de diseño de Cambiami · v1.2 · 2026-11-13 · IDUCDEV para TasaVE C.A.*
