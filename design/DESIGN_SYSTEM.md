# Cambiami — Sistema de diseño

> **Producto:** Cambiami (app móvil de tasas de cambio y calculadora USD/VES)
> **Entidad legal:** TasaVE C.A. · RIF J-30452819-5
> **Plataforma:** Flutter (Android + iOS)
> **Versión:** 1.1 · 2026-11-11
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

### Variantes requeridas

| Variante | Archivo | Uso |
|:--|:--|:--|
| Emblema | `design/assets/emblem.png` (1080×1147, alpha) | Splash, icono de app, avatar |
| Lockup horizontal | *pendiente de exportar* | Cabeceras, landing, tienda |
| Monocromo | *pendiente de exportar* | Fondos de color, marca de agua |
| Wordmark | *pendiente de exportar en SVG* | Textos de marca |

### Reglas

- **Área de respeto:** el alto del emblema ÷ 2 en todos los lados.
- **Tamaño mínimo:** emblema 24 px; lockup 96 px de ancho.
- **Fondo:** el emblema va sobre `#29243D`, `#FFF9F1` o `#FFFFFF`. Nunca sobre coral, ámbar ni fotografías.
- **Prohibido:** deformar, rotar, recolorear, añadir sombras, recortar el brillo, ponerlo dentro de otra forma.
- **Versión pequeña (< 48 px):** usar la monocroma. El emblema glossy pierde definición a tamaño de icono pequeño.

### Estado de los assets (importante)

- `design/cambiami_logo_exact.svg` **no es vectorial**: contiene un PNG embebido en base64.
- `design/Cambiami Brand Style Board (Editado).svg` es un autotrace (VTracer) del board, no un logo limpio.
- **Acción pendiente:** exportar lockup horizontal y monocromo como SVG real desde el archivo fuente de marca antes de H4 (build de tienda).

---

## 3. Color

### 3.1 Paleta primitiva

| Token | Hex | Nombre |
|:--|:--|:--|
| `palette/purple-500` | `#9944EE` | Morado Cambiami |
| `palette/purple-700` | `#7A2BD1` | Morado pulsado |
| `palette/purple-100` | `#F1E4FE` | Morado suave |
| `palette/teal-500` | `#20C6C8` | Teal |
| `palette/teal-700` | `#0B7C7E` | Teal tinta |
| `palette/coral-500` | `#FF705F` | Coral |
| `palette/coral-700` | `#C93B2A` | Coral tinta |
| `palette/amber-500` | `#FFD166` | Ámbar |
| `palette/amber-700` | `#7A5200` | Ámbar tinta |
| `palette/cream-50` | `#FFF9F1` | Crema |
| `palette/ink-900` | `#29243D` | Tinta |
| `palette/indigo-950` | `#1D0F50` | Índigo profundo |
| `palette/gray-200` | `#EDEBF2` | Borde |
| `palette/gray-300` | `#DDD9E6` | Borde fuerte |

### 3.2 Tokens semánticos (tema claro — único en v1)

| Token | Hex | Uso |
|:--|:--|:--|
| `bg/canvas` | `#FFF9F1` | Fondo de todas las pantallas |
| `bg/surface` | `#FFFFFF` | Tarjetas, campos, sheets |
| `bg/inverse` | `#29243D` | Splash, botón oscuro |
| `bg/brand-soft` | `#F1E4FE` | Chip seleccionado, highlight |
| `text/primary` | `#29243D` | Cifras, títulos (14,2:1) |
| `text/secondary` | `#76717E` | Fuente, fecha, estado (4,53:1) |
| `text/tertiary` | `#A29DAE` | Solo decorativo / deshabilitado (2,52:1 — **nunca texto esencial**) |
| `text/on-brand` | `#FFFFFF` | Texto sobre morado (4,76:1) |
| `text/on-inverse` | `#FFF9F1` | Texto sobre `bg/inverse` (14,2:1) |
| `text/on-inverse-soft` | `#B9AEDC` | Tagline y versión sobre `bg/inverse` (7,2:1) |
| `border/subtle` | `#EDEBF2` | Divisores |
| `border/strong` | `#DDD9E6` | Bordes de campo |
| `brand/primary` | `#9944EE` | Acción primaria, selección |
| `brand/primary-pressed` | `#7A2BD1` | Estado pulsado |
| `focus/ring` | `#9944EE` @ 24 % | Anillo de foco |
| `state/ok-ink` | `#0B7C7E` | Texto e icono del estado "al día" |
| `state/warn-ink` | `#7A5200` | Texto e icono del estado "desactualizado" |
| `state/offline-ink` | `#C93B2A` | Texto e icono del estado "sin conexión" |
| `state/ok-bg` | `#E3F8F8` | Fondo del banner "al día" |
| `state/warn-bg` | `#FFD166` | Fondo del banner "desactualizado" |
| `state/offline-bg` | `#FFF0EE` | Fondo del banner "sin conexión" |

Los `state/*-bg` son **sólidos**, no alpha: así el contraste no depende de la superficie que haya debajo y es el mismo en cualquier pantalla.

### 3.3 Estados del dato (F-02 / BN-06)

| Estado | Fondo | Texto/icono | Hex de texto | Contraste |
|:--|:--|:--|:--|:--|
| `al_dia` | `state/ok-bg` `#E3F8F8` | `state/ok-ink` | `#0B7C7E` | 4,54:1 ✅ |
| `desactualizado` | `state/warn-bg` `#FFD166` | `state/warn-ink` | `#7A5200` | 4,80:1 ✅ |
| `sin_conexión` | `state/offline-bg` `#FFF0EE` | `state/offline-ink` | `#C93B2A` | 4,57:1 ✅ |

Los contrastes de esta tabla son **texto sobre el fondo del banner**, no sobre `bg/canvas`. Es la medida que importa: es donde el texto vive.

**Regla dura:** `#FFD166`, `#FF705F` y `#20C6C8` **no se usan como color de texto**. Solo como relleno, icono o borde. Para texto se usan siempre sus variantes `-ink`.

### 3.4 Variación de tasa

| Token | Hex | Uso |
|:--|:--|:--|
| `variation/up` | `#0B7C7E` | Flecha ↗ y cifra positiva |
| `variation/down` | `#C93B2A` | Flecha ↘ y cifra negativa |
| `variation/flat` | `#76717E` | Sin cambio (→) |

La variación no es buena ni mala: no se usan verde/rojo semánticos de éxito/error. Se usan los tokens `variation/*`.

### 3.5 Tema oscuro (Fase 2 — no se implementa en v1)

| Token | Hex |
|:--|:--|
| `bg/canvas` | `#1D0F50` |
| `bg/surface` | `#2A1C63` |
| `text/primary` | `#F6F2FF` (15,4:1) |
| `text/secondary` | `#B9AEDC` (8,2:1) |

Los tokens se definen desde ya para no renombrar nada en Fase 2, pero la app v1 solo envía tema claro.

---

## 4. Tipografía — Nunito

Familia única: **Nunito** (Google Fonts, OFL). Pesos usados: 400, 600, 700, 800.

| Token | Tamaño / interlínea | Peso | Uso |
|:--|:--|:--|:--|
| `type/display` | 44 / 48 | 800 | Resultado en Bs de la calculadora |
| `type/h1` | 28 / 34 | 800 | Título de pantalla (solo splash/landing) |
| `type/h2` | 22 / 28 | 800 | Título de pantalla (`Calculadora`, `Tasas BCV`) |
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
- Padding horizontal de pantalla: **20 px**, aplicado una sola vez en el contenedor.
- Separación entre secciones: **24 px**. Dentro de una sección: **12 px**.
- Alto del status bar: **62 px**. Nunca se dibuja UI debajo.
- Tab bar: **56 px** de alto, flotante, inset 16 px laterales y 12 px inferiores.
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

- Librería única: **Lucide** (línea, 2 px, esquinas redondeadas). En Flutter: `lucide_icons`.
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
| Mi tasa | `pencil` |
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

### 7.2 `RateCard` — tarjeta de tasa (pantallas Tasas)

```
┌──────────────────────────────────┐
│ Dólar              889,5754 Bs ↗ │  h3 + body-strong + variation
│ +0,32 Bs (0,04 %)                │  caption, variation/up
│ BCV · Lunes, 02/11/26 · al día   │  caption, text/secondary
└──────────────────────────────────┘
```

Tres niveles: valor (grande, 800) → variación (caption, color de variación) → procedencia (caption, secundario). La procedencia **nunca** se omite.

### 7.3 `RateChip` — selector multi-tasa (máx. 4)

```
┌────────────┐
│ BCV        │  type/micro, secondary
│ 889,58     │  type/label, primary
└────────────┘
```

| Estado | Fondo | Borde | Texto |
|:--|:--|:--|:--|
| Normal | `bg/surface` | `border/subtle` 1 px | `text/secondary` / `text/primary` |
| Seleccionado | `bg/brand-soft` | `brand/primary` 2 px | `brand/primary-pressed` / `text/primary` |

Ancho: `fill_container` (4 en fila, gap 8). Alto mínimo 56. Radio `radius/md`.

### 7.4 `StatusBanner`

```
┌──────────────────────────────────┐
│ ⚠  Sin conexión · mostrando la    │
│    tasa del 01/11/26              │
└──────────────────────────────────┘
```

- Alto mínimo 44, padding [10, 12], radio `radius/md`, gap 8.
- Icono 16 + texto `type/caption` en el `-ink` del estado.
- Aparece entre el header y el contenido. Nunca flota sobre el contenido.

### 7.5 `TabBar` (3 destinos en v1)

- Flotante, 56 px de alto y 350 de ancho, radio pill, `bg/surface` + `shadow/floating`, padding 4.
- Items de 48 de alto (área táctil mínima), ancho igual repartido, radio pill.
- Item: icono 24 **arriba**, label `type/micro` debajo, gap 2. Vertical, no horizontal: con 3 destinos la etiqueta `Configuración` no cabe al lado del icono.
- Activo: icono y label en `brand/primary`, fondo pill `bg/brand-soft`. Inactivo: `text/secondary`, sin fondo.
- Destinos: **Calculadora** (`calculator`), **Tasas** (`trending-up`) y **Configuración** (`settings`).

Con 3 items cada uno mide 111 px y `Configuración` (76 px a 11/700) cabe incluso con el texto escalado a 1,3×. Un cuarto destino no cabría con etiqueta visible: a 86 px no entra icono + label.

En el archivo hay tres componentes, uno por estado activo: `TabBar / Calculadora`, `TabBar / Tasas` y `TabBar / Configuracion`.

### 7.6 Botones

| Variante | Fondo | Texto | Uso |
|:--|:--|:--|:--|
| Primario | `brand/primary` | `text/on-brand` | Compartir cálculo |
| Secundario | `bg/surface` + borde `border/strong` | `text/primary` | Acciones alternativas |
| Ghost | transparente | `brand/primary` | Enlaces, "Volver" |
| Icono | transparente | `text/secondary` | Cabecera |

Alto 48, radio `radius/md`, padding horizontal 20, texto `type/body-strong`.

### 7.7 `RateRow` (lista en modal Monedas)

Fila de 56 px: nombre (`type/body-strong`) + valor (`type/body-strong`, derecha) + indicador "En calculadora" (`type/caption`, `brand/primary`) cuando aplica.

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

| Asset | Tamaño | Estado |
|:--|:--|:--|
| `design/assets/emblem.png` | 1080×1147, alpha | ✅ listo |
| `design/assets/emblem-512.png` | 512×512 | ✅ listo |
| Icono app 1024×1024 | PNG opaco | ⬜ pendiente |
| Adaptive icon (fg/bg) | 432×432 + 108 dp | ⬜ pendiente |
| Splash nativo (Android/iOS) | varias densidades | ⬜ pendiente |
| Lockup horizontal SVG | — | ⬜ pendiente |
| Monocromo SVG | — | ⬜ pendiente |
| Feature graphic tienda | 1024×500 | ⬜ pendiente (H4) |
| Capturas de tienda | 1080×1920 ×5 | ⬜ pendiente (H4) |

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
| 05 | Tasas BCV | normal · cargando · error | `Screen / 05 · Tasas BCV` |
| 06 | Tasas USDT | normal · cargando · error | `Screen / 06 · Tasas USDT` |
| 07 | Configuración | normal | `Screen / 07 · Configuracion` |
| 08 | Información | normal | `Screen / 08 · Informacion` |
| 09 | Monedas | modal sobre Calculadora | `Screen / 09 · Monedas (modal)` |
| 10 | Compartir | sheet sobre Calculadora | `Screen / 10 · Compartir (sheet)` |

Los estados `cargando` y `error` de Tasas (05 y 06) están especificados en §13.4 pero **todavía no dibujados**: son lo único que falta en el archivo de diseño.

### 12.1 Flujo de navegación

| Desde | Acción | Hacia |
|:--|:--|:--|
| 01 Splash | espera 400 ms | 02 Calculadora |
| 02 Calculadora | tap `RateSelector` | 09 Monedas |
| 09 Monedas | tap `Aplicar` o `✕` | 02 Calculadora |
| 02 Calculadora | tap `share-2` | 10 Compartir |
| 02 Calculadora | tap tab `Tasas` | 05 Tasas BCV |
| 02 Calculadora | tap tab `Configuración` | 07 Configuración |
| 05 Tasas BCV | tap tab `Calculadora` | 02 Calculadora |
| 05 Tasas BCV | tap tab `Configuración` | 07 Configuración |
| 05 Tasas BCV | tap `info` | 08 Información |
| 05 Tasas BCV | tap `Compartir tasas` | 10 Compartir |
| 06 Tasas USDT | tap tab `Calculadora` | 02 Calculadora |
| 06 Tasas USDT | tap tab `Configuración` | 07 Configuración |
| 06 Tasas USDT | tap `info` | 08 Información |
| 06 Tasas USDT | tap `Compartir tasas` | 10 Compartir |
| 07 Configuración | tap tab `Calculadora` | 02 Calculadora |
| 07 Configuración | tap tab `Tasas` | 05 Tasas BCV |
| 07 Configuración | tap `Información` | 08 Información |
| 08 Información | tap `Volver` o `‹` | pop (Configuración o Tasas, según de dónde venga) |

El botón de volver **siempre hace `pop`**, no navega a un destino fijo: se puede llegar a Información desde Configuración o desde el icono `info` de Tasas.

**Barra inferior:** la llevan las pantallas de primer nivel — 02, 03, 04, 05, 06 y 07. No la llevan 02b (el teclado la cubre) ni 08 Información (pantalla de detalle, se sale con `‹`). Configuración dejó de ser secundaria: ya no tiene botón de volver, se llega y se sale por la barra.

### 12.2 Rutas en Flutter

| Ruta | Pantalla |
|:--|:--|
| `/` | 02 Calculadora |
| `/tasas/bcv` | 05 Tasas BCV |
| `/tasas/usdt` | 06 Tasas USDT |
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
| Títulos de pantalla | `Calculadora` · `Tasas BCV` · `Tasas USDT` · `Configuración` · `Información` · `Monedas` · `Compartir` |
| Splash | `cambiami` · `La tasa, clara y al día.` · `v1.0 · TasaVE C.A.` |
| Tabs | `Calculadora` · `Tasas` · `Configuración` |
| Campos de monto | `Dólares` · `Bolívares` |
| Chips de tasa | `BCV` · `USDT` · `Euro` · `Mi tasa` |
| Tasas USDT | `Compra` · `Venta` · `Promedio` · `Brecha ($/USDT)` |
| Monedas | `En calculadora` · `Aplicar` |
| Acciones | `Compartir cálculo` · `Compartir tasas` · `Copiar texto` · `WhatsApp` · `Reintentar` · `Volver` |
| Configuración | `Moneda predeterminada` · `Esta moneda se mostrará en la calculadora al abrir la app.` · `Información` · `TasaVE C.A. · v1.0` |

### 13.3 Estados del dato (F-02 / BN-06)

| Estado | Banner | Línea de procedencia |
|:--|:--|:--|
| `al_dia` | sin banner | `BCV · Lunes, 02/11/26 · al día` |
| `desactualizado` | `Tasa de ayer · se actualiza a las 5:00 p. m.` | `BCV · Domingo, 01/11/26 · desactualizado` |
| `sin_conexión` | `Sin conexión · mostrando la tasa del 01/11/26` | `BCV · Domingo, 01/11/26 · sin conexión` |

El banner **no sustituye** la procedencia: cuando hay banner, se muestran los dos. En `al_dia` no hay banner porque el estado ya viaja en la línea de procedencia.

### 13.4 Carga y error

| Situación | Texto | Nota |
|:--|:--|:--|
| Cargando (Tasas BCV / USDT) | ninguno visible | Skeleton de dos `RateCard`; el lector de pantalla anuncia `Actualizando tasas` |
| Error (Tasas BCV / USDT) | `No pudimos actualizar las tasas.` + botón ghost `Reintentar` | Icono `cloud-off` 32 |
| Sin datos de una moneda | *pendiente (H1)* | No inventar copy antes de ver la respuesta real del backend |

### 13.5 Compartir (mensaje literal)

```
$ 1,00 = 889,58 Bs

Tasa BCV: 1 $ = 889,58 Bs
Fecha valor: Lunes, 02/11/26

Descarga Cambiami: https://cambiami.app
```

- El monto y la tasa se toman de la calculadora en el momento de compartir; el bloque de arriba es el estado por defecto.
- El enlace definitivo se confirma en H4. Nunca `bit.ly/alcambio-app` (era del clon).

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
  ├─ Header
  ├─ Content
  │   ├─ <Componente>
  │   └─ <Componente>
  └─ Tab wrap
```

Nunca `Frame 123`, `Rectangle 45` ni `Group 8`.

### Mapa diseño → Flutter

| Diseño | Flutter |
|:--|:--|
| Variable color `bg/canvas` | `AppColors.bgCanvas` |
| Text style `type/h2` | `AppTypography.h2` |
| Variable number `space/4` | `AppSpacing.s4` |
| Variable number `radius/lg` | `AppRadius.lg` |
| Componente `RateCard` | `RateCard` widget |
| Componente `RateChip` | `RateChip` widget |
| Componente `StatusBanner` | `StatusBanner` widget |
| Componente `AmountCard` | `AmountField` widget |

---

*Sistema de diseño de Cambiami · v1.1 · 2026-11-11 · IDUCDEV para TasaVE C.A.*
