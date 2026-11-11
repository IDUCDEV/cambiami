# TasaVE C.A. — Especificación Técnica del Cliente y Brief de Cotización (Documento Único)

> **Cliente:** TasaVE C.A. (marca propia, ficticia)  
> **Proyecto:** App móvil de consulta de tasas de cambio (Venezuela) y calculadora BCV/USDT  
> **Stack:** Flutter + Supabase (Postgres + Edge Functions + RLS)  
> **Estado:** Listo para cotización  
> **Versión:** 1.0 · Fecha: 2026-11-02  
> **Origen:** consolidado a partir de la evidencia de `clon-al-cambio/` (análisis web, reseñas, auditoría y 23 capturas del móvil)  
> **Fuente de verdad para el desarrollo:** `docs-al-cambio/PLAN_DE_DESARROLLO.md`  
> **Documento único:** combina `BRIEF-TASAVE-MVP.md` y `PROPUESTA-TASAVE-COTIZACION.md`
>
> **Regla de oro:** no construyas nada que no esté en este documento.  
> Si no está aquí, no entra en el MVP.

---

## 1. De qué se trata

App móvil para consultar tasas de cambio en Venezuela (BCV oficial + USDT P2P de Binance) y calcular montos entre dólares y bolívares, con **offline real**, **cero publicidad en el ciclo crítico** y **transparencia de datos** (fuente, hora y estado de cada tasa).

Público objetivo: comercios, remesas, frontera y consulta rápida.

---

## 2. Personas de usuario

| Persona | Necesidad principal | Contexto de uso |
|:--------|:--------------------|:----------------|
| **Comerciante** | Cobrar bien, cumplir la ley (art. 25 IVA) | Caja del negocio, necesita la tasa rápido y sin errores |
| **Receptor de remesas** | Saber cuánto recibe en bolívares | Casa, teléfono, convierte dólares/USDT a Bs |
| **Fronterizo** | Manejar pesos/reales y bolívares | Frontera, conversión cruzada rápida |
| **Consulta rápida** | Precio en segundos | Cualquier momento, abre y cierra la app rápido |
| **Sin conexión** | Trabajar con mala señal | Zona con poco internet, usa la última tasa cacheada |

---

## 3. Historias de usuario

Cada historia sigue el formato: **Como [rol], quiero [acción], para [beneficio].**  
Incluyen criterios de aceptación en lenguaje de usuario.

### HU-01 · Abrir la app y ver la tasa inmediatamente
> **Como** comerciante, **quiero** abrir la app y ver la tasa del dólar en menos de 1 segundo, **para poder** cobrar a mis clientes sin hacerlos esperar.

**Criterios de aceptación:**
- La app abre y muestra la calculadora en < 1 segundo (cronómetro en dispositivo real).
- No hay anuncios entre abrir la app y ver el resultado.
- No hay video, intersticial ni pantalla bloqueante de bienvenida.

**Mapeo:** F-01 · APP-SCR-01 Splash → APP-SCR-02 Calculadora

---

### HU-02 · Calcular dólares a bolívares al instante
> **Como** receptor de remesas, **quiero** escribir una cantidad de dólares y ver el equivalente en bolívares automáticamente, **para saber** cuánto dinero voy a recibir.

**Criterios de aceptación:**
- Escribir en el campo `$` y ver el resultado en `Bs` al instante (cálculo < 100 ms).
- No hay botón "calcular"; el resultado se actualiza solo al escribir.
- El cálculo es bidireccional (también se puede escribir en Bs y ver en $).

**Mapeo:** F-01, F-04 · APP-SCR-02 Calculadora

---

### HU-03 · Saber si la tasa está actualizada
> **Como** comerciante, **quiero** ver de qué fecha es la tasa y si está vigente hoy, **para no** cobrar con un precio viejo y perder dinero.

**Criterios de aceptación:**
- Cada tasa muestra fuente (BCV o Binance P2P).
- Cada tasa muestra fecha/hora de publicación (ej: `Lunes, 02/11/26`).
- Cada tasa muestra estado visible: `al_dia`, `desactualizado` o `sin_conexión`.
- La tasa del dólar en la calculadora muestra `Dólar BCV`, `+0,32 Bs (0,04%)`, `Lunes, 02/11/26`.

**Mapeo:** F-02 · APP-SCR-02, APP-SCR-03, APP-SCR-04

---

### HU-04 · Calcular sin internet
> **Como** usuario en zona con mala señal, **quiero** usar la calculadora y ver la última tasa aunque no tenga conexión, **para no** quedar parado en la caja.

**Criterios de aceptación:**
- Activar modo avión: la app abre y muestra la última tasa cacheada.
- Se puede calcular sin internet.
- Aparece un banner indicando "sin conexión".
- Al recuperar internet, la app se actualiza sola sin reiniciar.

**Mapeo:** F-03 · APP-SCR-02, APP-SCR-03

---

### HU-05 · Un solo formato numérico
> **Como** cualquier usuario, **quiero** que todos los números se vean igual en toda la app (coma decimal, sufijo Bs), **para no** confundirme entre pantallas.

**Criterios de aceptación:**
- Separador decimal: coma (`,`), nunca punto.
- Sufijo: `Bs` después de cada monto en bolívares.
- Ejemplo: `889,58 Bs`, no `889.58` ni `Bs. 889.58`.
- Test de 5 segundos: 4 de 5 personas señalan la tasa correcta sin dudar.

**Mapeo:** F-04 · Todas las pantallas

---

### HU-06 · Ver varias tasas al mismo tiempo
> **Como** comerciante, **quiero** ver el dólar BCV, el USDT y el euro al mismo tiempo, **para comparar** y decidir con cuál operar.

**Criterios de aceptación:**
- Hasta 4 tasas visibles a la vez: BCV, USDT, Euro, "mi tasa".
- Tocar cualquiera de las 4 tasas cambia la tasa de cálculo de la calculadora principal.
- Comparar 3 tasas en menos de 3 segundos.
- No hay que navegar a otra pantalla para cambiar de tasa.

**Mapeo:** F-05 · APP-SCR-02, APP-SCR-09

---

### HU-07 · Elegir mi moneda predeterminada
> **Como** usuario, **quiero** elegir qué moneda abre por defecto en la calculadora, **para no** tener que cambiarla cada vez que abro la app.

**Criterios de aceptación:**
- En Configuración, se puede elegir moneda predeterminada (Dólar BCV, Euro, USDT).
- La elección se guarda y se aplica al reiniciar la app.

**Mapeo:** F-08 · APP-SCR-06 Configuración

---

### HU-08 · Saber de dónde vienen los datos
> **Como** usuario cauteloso, **quiero** leer un disclaimer que diga que la app es informativa y no oficial, **para saber** que no es el Banco Central de Venezuela.

**Criterios de aceptación:**
- Pantalla Información con disclaimer legal visible.
- Se declara que la app no fija tasas ni está afiliada a entes gubernamentales.
- Se cita la fuente BCV (bcv.org.ve) y Binance P2P.

**Mapeo:** F-12 · APP-SCR-11 Información

---

### HU-09 · Aplicar tasa del siguiente día hábil
> **Como** comerciante, **quiero** que la calculadora use la tasa del siguiente día hábil cuando sea fin de semana o feriado, **para cumplir** con el artículo 25 de la Ley de IVA al cobrar a mis clientes.

**Criterios de aceptación:**
- Toggle "Aplicar tasa del siguiente día hábil" disponible en la calculadora.
- En sábado, la calculadora muestra la tasa que regirá el lunes (o el siguiente día hábil).
- En feriado, la calculadora muestra la tasa del siguiente día hábil después del feriado.
- Se muestra claramente qué fecha de tasa se está usando.

**Mapeo:** F-06 · APP-SCR-02, APP-SCR-03

**Estado:** ⏸️ Diferida a Fase 2 (v1.1). No entra en el MVP v1.

---

### HU-10 · Compartir el cálculo por WhatsApp
> **Como** usuario, **quiero** compartir el resultado de un cálculo por WhatsApp, **para enviarle** a un cliente o familiar el monto convertido con la tasa y fecha.

**Criterios de aceptación:**
- Botón "Compartir" disponible en la pantalla de cálculo.
- Al compartir, se envía el monto, la tasa usada, la fecha de valor y un enlace de descarga de la app.
- Se abre WhatsApp con el mensaje prellenado.
- El usuario puede elegir el contacto antes de enviar.

**Mapeo:** F-07 · APP-SCR-10 Compartir

---

## 4. Features críticas (M1–M5) mapeadas a historias

| ID | Feature | Historia de usuario | Pantallas | Prioridad |
|:---|:--------|:--------------------|:----------|:----------|
| F-01 | Cold start sin anuncios | HU-01, HU-02 | APP-SCR-01, APP-SCR-02 | Crítica |
| F-02 | Dato con fuente, fecha y estado | HU-03 | APP-SCR-02, APP-SCR-03, APP-SCR-04 | Crítica |
| F-03 | Offline real | HU-04 | APP-SCR-02, APP-SCR-03 | Crítica |
| F-04 | Formateador único es-VE | HU-05 | Todas | Crítica |
| F-05 | Multi-tasa simultáneo | HU-06 | APP-SCR-02, APP-SCR-09 | Alta |
| F-07 | Compartir por WhatsApp | HU-10 | APP-SCR-10 | MVP v1 |
| F-08 | Configuración | HU-07 | APP-SCR-06 | MVP v1 |
| F-12 | Información / legal | HU-08 | APP-SCR-11 | MVP v1 (obligatorio) |

**Regla:** el MVP v1 queda cerrado con **8 features**: F-01 a F-05 (críticas) + F-07 (compartir), F-08 (configuración) y F-12 (información/legal). F-06 se evaluó y se difiere a Fase 2 por coste (+1,5–2,5 d), dependencia de un calendario de feriados BCV con mantenimiento anual y riesgo de facturación con tasa errónea.

---

## 5. Features no críticas (fuera de alcance MVP)

| ID | Feature | Historia asociada | Por qué esperar |
|:---|:--------|:------------------|:----------------|
| F-06 | Regla siguiente día hábil | HU-09 | Requiere calendario de feriados BCV versionado (+1,5–2,5 d) y añade +1 semana al plazo. Riesgo legal si el calendario falla. Fase 2 (v1.1). |
| F-09 | Onboarding | — | Puede ir en segunda versión. |
| F-10 | Escáner de precios | — | Requiere cámara y OCR. Fase 2. |
| F-11 | Perfiles de pago | — | Requiere backend de usuarios. Fase 2. |

---

## 6. Alcance del MVP (5 bloques obligatorios)

| Bloque | Nombre | Qué incluye | Criterio de aceptación |
| :--- | :--- | :--- | :--- |
| M1 | Cero publicidad en el ciclo crítico | Ningún anuncio en cold start, cálculo, tasas ni estado del dato. Premium y patrocinio solo en pantallas secundarias. | 0 anuncios entre "abrir" y "resultado"; 0 ms de impacto en el cálculo. |
| M2 | El dato es de fiar | `effective_from` + `published_at` + `status`; hora visible; brecha entre series de la misma fecha; "sin dato" cuando falte. | 3 fechas verificadas contra BCV; 0 brechas mixtas; 100 % de vistas con estado. |
| M3 | Offline real | Caché de última tasa con timestamp, cálculo local, banner de estado, reintento. | Modo avión → abre < 1 s, calcula, dice de cuándo es el dato; 0 pantallas en blanco. |
| M4 | El número manda | Un solo formateador es-VE; variación etiquetada; `0 → 0`; jerarquía tipográfica. | Test de 5 s (4/5 señalan la tasa); 0 divergencias de formato en 5 pantallas. |
| M5 | Multi-tasa simultáneo | BCV + USDT + Euro + "mi tasa" visibles a la vez (máx. 4); tocar para calcular. | Comparar 3 tasas < 3 s y 0 toques de navegación. |

---

## 7. Pantallas del móvil (evidenciadas con capturas y recreación visual)

| ID | Pantalla | Título literal | Captura base | Estado |
| :--- | :--- | :--- | :--- | :--- |
| APP-SCR-01 | Splash | — (solo logo) | `Screenshot_20261102-092412.png` | ✅ |
| APP-SCR-02 | Calculadora | `Calculadora` | `Screenshot_20261102-092738.png` | ✅ |
| APP-SCR-03 | Tasas BCV | `Tasas BCV` | `Screenshot_20261102-092742.png` | ✅ |
| APP-SCR-04 | Tasas USDT | `Tasas USDT` | `Screenshot_20261102-092749.png` | ✅ |
| APP-SCR-05 | Perfiles de pago | `Perfiles de pago` | `Screenshot_20261102-092819.png` | ✅ |
| APP-SCR-06 | Configuración | `Configuración` | `Screenshot_20261102-092847.png` | ✅ |
| APP-SCR-07 | Onboarding | `TasaVE · beta` | `Screenshot_20261102-092914.png` | ✅ |
| APP-SCR-08 | Escáner | `Toma una foto para escanear` | `Screenshot_20261102-092923.png` | ✅ |
| APP-SCR-09 | Monedas (modal) | `Monedas` | `Screenshot_20261102-093038.png` | ✅ |
| APP-SCR-10 | Compartir | (WhatsApp) | `Screenshot_20261102-092901.png` | ✅ |
| APP-SCR-11 | Información | `Información` | `Screenshot_20261102-093117.png` | ✅ |

### APP-SCR-01 · Splash

```
┌─────────────────────────────────┐
│                                 │
│             💱                  │
│      TasaVE                     │
│   (logo animado de carga)       │
│                                 │
│         fondo oscuro            │
└─────────────────────────────────┘
```
- **Qué hace:** pantalla de entrada; solo marca, sin anuncios ni intersticial.
- **Captura:** `Screenshot_20261102-092412.png`

---

### APP-SCR-02 · Calculadora

```
┌─────────────────────────────────┐
│  Calculadora                    │
│                                 │
│  Dólar BCV   🔽   🔄            │
│                                 │
│  $  ______________   📋          │
│     1.00           │           │
│                                 │
│  Bs  ______________   📋        │
│    889,58          │           │
│                                 │
│  +0,32 Bs (0,04%) ↗             │
│  Lunes, 02/11/26                │
│                                 │
│  Tasa oficial del BCV           │
│  bcv.org.ve                     │
│                                 │
│  [ Escáner ]   [ Tasas ]        │
└─────────────────────────────────┘
```
- **Job:** convertir $ ↔ Bs con la tasa BCV del día.
- **Entradas:** desde Splash, menú lateral, botón en Tasas.
- **Captura:** `Screenshot_20261102-092738.png`

---

### APP-SCR-03 · Tasas BCV

```
┌─────────────────────────────────┐
│  Tasas BCV                      │
│                                 │
│  💵 Dólar     889,5754 Bs  ↗    │
│       +0,32 Bs (0,04%)          │
│                                 │
│  💶 Euro      991,2539 Bs  ↘    │
│       -1,55 Bs (-0,16%)         │
│                                 │
│  Lunes, 02/11/26                │
│                                 │
│  [ Gráfica ]   [ Compartir ]    │
│                                 │
│  "La fecha de valor indica..."  │
│  (disclaimer de fuente BCV)     │
└─────────────────────────────────┘
```
- **Job:** ver las tasas oficiales del BCV (dólar y euro) del día y sus variaciones.
- **Captura:** `Screenshot_20261102-092742.png`

---

### APP-SCR-04 · Tasas USDT

```
┌─────────────────────────────────┐
│  Tasas USDT                     │
│                                 │
│  💸 Compra   997,49 Bs   ↗      │
│                                 │
│  💰 Venta    994,35 Bs   ↗      │
│                                 │
│  📊 Promedio 995,92 Bs  ↗       │
│       +2,19 Bs (+0,22%)         │
│                                 │
│  Lunes, 02/11/26  09:00 AM      │
│                                 │
│  [ Gráfica ]   [ Compartir ]    │
│                                 │
│  "Actualiza más rápido aquí ⚡"  │
│  (fuente: Binance P2P)          │
└─────────────────────────────────┘
```
- **Job:** ver el precio del USDT (compra, venta, promedio) del mercado P2P de Binance.
- **Captura:** `Screenshot_20261102-092749.png`

---

### APP-SCR-05 · Perfiles de pago

```
┌─────────────────────────────────┐
│  Perfiles de pago               │
│                                 │
│  [ Pago móvil - Banco - Zelle ] │
│                                 │
│  No se ha agregado un perfil    │
│  de pago asociado a este tipo   │
│  de cuenta.                     │
│                                 │
│  [ Agregar Pago móvil   ]       │
│  [ Agregar Cuenta banco ]       │
│  [ Agregar Zelle        ]       │
└─────────────────────────────────┘
```
- **Job:** agregar un perfil de pago (Pago móvil, Cuenta de banco o Zelle).
- **Nota:** pantalla secundaria; el propósito dentro de una app de tasas no queda del todo claro.
- **Captura:** `Screenshot_20261102-092819.png`

---

### APP-SCR-06 · Configuración

```
┌─────────────────────────────────┐
│  Configuración                  │
│                                 │
│  Moneda predeterminada:         │
│     Dólar BCV   🟢              │
│     (Esta moneda se mostrará    │
│      en la calculadora...)      │
│                                 │
│  Sugerencias: Activas   🔘      │
│     (Toque para activar...)     │
└─────────────────────────────────┘
```
- **Job:** elegir moneda predeterminada y activar/desactivar sugerencias.
- **Captura:** `Screenshot_20261102-092847.png`

---

### APP-SCR-07 · Onboarding (TasaVE · beta)

```
┌─────────────────────────────────┐
│                                 │
│  Presentamos:                   │
│                                 │
│      TasaVE · beta              │
│                                 │
│   (teléfono con calculadora)    │
│                                 │
│  Apunta, escanea y convierte    │
│                                 │
│  [ Saltar ]   [ Siguiente ]     │
│                                 │
│  Esta es una versión de prueba, │
│  realizaremos ajustes pronto... │
└─────────────────────────────────┘
```
- **Job:** entender para qué sirve la app y cómo usar el escáner antes de empezar.
- **Nota:** nombre provisional "cámbialo" reemplazado por "TasaVE · beta" en la marca del cliente.
- **Captura:** `Screenshot_20261102-092914.png`

---

### APP-SCR-08 · Escáner (cámara)

```
┌─────────────────────────────────┐
│                                 │
│  Toma una foto para escanear    │
│                                 │
│  ┌─────────────────────────┐   │
│  │   [ VISOR CÁMARA ]      │   │
│  │   (apunta a un precio)  │   │
│  └─────────────────────────┘   │
│                                 │
│  [ 📷 disparo circular ]        │
│                                 │
│  Dólar 🔽     Bolívar 🔽        │
│                                 │
│  [ Galería ]   [ Flash ⭐ ]      │
│                                 │
│  Recuerda: versión de prueba    │
└─────────────────────────────────┘
```
- **Job:** escanear un precio etiquetado y convertirlo de una moneda a otra.
- **Captura:** `Screenshot_20261102-092923.png`

---

### APP-SCR-09 · Monedas (modal)

```
┌─────────────────────────────────┐
│  Monedas                        │
│                                 │
│  Brecha ($/USDT): 11.95%        │
│                                 │
│  Dólar BCV     889,58 Bs        │
│          (En calculadora)       │
│                                 │
│  Euro          991,25 Bs        │
│                                 │
│  Promedio      942,75 Bs        │
│                                 │
│  USDT          995,92 Bs        │
│                                 │
│  Personalizada 1,00 Bs   ✏️     │
└─────────────────────────────────┘
```
- **Job:** ver todas las tasas disponibles a la vez y la brecha entre dólar y USDT.
- **Captura:** `Screenshot_20261102-093038.png`

---

### APP-SCR-10 · Compartir (WhatsApp)

```
┌─────────────────────────────────┐
│  WhatsApp                       │
│                                 │
│  [logo TasaVE]                  │
│                                 │
│  $ 1.00 = 889,58 Bs.            │
│                                 │
│  Tasa BCV: 1$ = Bs. 889,58      │
│  Fecha valor: Lunes, 02/11/26   │
│                                 │
│  ¡Descarga la app!              │
│  https://bit.ly/alcambio-app    │
│                                 │
│  [ enviar a contacto ]          │
└─────────────────────────────────┘
```
- **Job:** enviar la tasa actual y un monto convertido por WhatsApp.
- **Nota:** el enlace `bit.ly/alcambio-app` es evidencia del clon; en TasaVE se usará un enlace propio.
- **Captura:** `Screenshot_20261102-092901.png`

---

### APP-SCR-11 · Información

```
┌─────────────────────────────────┐
│  Información                    │
│                                 │
│  Los datos mostrados en esta    │
│  aplicación tienen un carácter  │
│  exclusivamente informativo.    │
│                                 │
│  Tasa oficial del BCV: se       │
│  actualiza a las 5:00 p.m.      │
│  en días hábiles.              │
│                                 │
│  USDT: referencia P2P de        │
│  Binance (1 USDT ≠ 1 USD).      │
│                                 │
│  [ Volver ]                     │
└─────────────────────────────────┘
```
- **Job:** saber de dónde vienen los datos, si la app es oficial y sus límites legales.
- **Captura:** `Screenshot_20261102-093117.png`

---

### Navegación

- **Tabs inferiores:** Calculadora, Tasas.
- **Menú lateral:** Calculadora · Tasas BCV · Tasas USDT · Perfiles de pago · Configuración · "Obtener Premium".
- **Otros:** calendar picker para fecha, modal de monedas, compartir por WhatsApp, onboarding de 5 pasos.

### Capturas duplicadas

Mismas pantallas, distinto estado/captura: `092834`, `092856`, `093008`, `093015`, `093018`, `093024`, `093043`, `093045`, `093052`.

---

## 8. Flujos de usuario

### APP-FLOW-01 · Consultar la tasa y calcular (CRÍTICO)

**Job del usuario:** "Saber cuánto es X dólares en bolívares, ya."

**Pasos:**
1. Usuario abre la app.
2. Splash se muestra < 1 s (sin anuncios).
3. Aparece la Calculadora con tasa BCV del día.
4. Usuario escribe monto en dólares (`$`).
5. Resultado aparece al instante en bolívares (`Bs`).
6. (Opcional) Usuario toca otra tasa (USDT, Euro, mi tasa) para recalcular.
7. (Opcional) Usuario comparte el resultado por WhatsApp.

**Pantallas:** APP-SCR-01 Splash → APP-SCR-02 Calculadora → APP-SCR-09 Monedas (modal, opcional).

**Estados de dato:**
- `al_dia`: datos frescos, sin banner.
- `desactualizado`: banner amarillo, datos de ayer.
- `sin_conexión`: banner rojo, última tasa cacheada.

**Criterio de éxito:** Usuario tiene un número en el que confía, sin dudar de la fecha, en < 1 s, sin anuncios.

**Métricas:** Cold start < 1 s, cálculo < 100 ms, 0 anuncios en el flujo.

---

### APP-FLOW-02 · Ver tasas BCV y USDT

**Job del usuario:** Ver las tasas oficiales del día y sus variaciones.

**Pasos:**
1. Usuario abre menú inferior o lateral → "Tasas".
2. Ve pantalla Tasas BCV (dólar y euro).
3. Usuario toca pestaña u opción "Tasas USDT".
4. Ve compra, venta y promedio del USDT.
5. (Opcional) Toca botón info → modal Monedas con brecha.

**Pantallas:** APP-SCR-03 Tasas BCV → APP-SCR-04 Tasas USDT → APP-SCR-09 Monedas (modal).

**Criterio de éxito:** Usuario ve todas las tasas relevantes sin navegar más de 2 pantallas.

---

### APP-FLOW-03 · Cambiar moneda predeterminada

**Job del usuario:** Elegir qué moneda abre por defecto en la calculadora.

**Pasos:**
1. Usuario abre menú lateral → "Configuración".
2. Ve "Moneda predeterminada: Dólar BCV".
3. Toca selector, elige otra moneda (Euro, USDT).
4. App guarda preferencia y la usa en la próxima apertura.

**Pantallas:** APP-SCR-06 Configuración.

**Criterio de éxito:** Preferencia guardada y aplicada al reiniciar la app.

---

### APP-FLOW-04 · Escáner de precios (Fase 2, no v1)

**Job del usuario:** Escanear un precio etiquetado y convertirlo.

**Estado:** Diferir a Fase 2 (no bloquea MVP).

---

## 9. Especificaciones técnicas por feature

### F-01 · Cold start sin anuncios

**Objetivo:** Abrir la app y llegar a la calculadora en < 1 segundo, sin ningún anuncio.

**Alcance:**
- Pantalla Splash: solo logo animado, sin intersticial, sin anuncio, sin video bloqueante.
- Transición automática a Calculadora al terminar el splash.
- Cero anuncios entre "abrir" y "resultado".

**Requisitos:**
- RNF-01: Cold start < 1 s (p95).
- RNF-03: 0 ms de impacto de anuncios en el flujo de cálculo.

**Estructura Flutter sugerida:**
```
lib/
  core/
    router/
      app_router.dart          # GoRouter: /splash → /calculadora
  features/
    calculator/
      presentation/
        pages/
          splash_page.dart     # APP-SCR-01
          calculator_page.dart # APP-SCR-02
```

**Riesgo:** Splash demasiado largo → usuario abandona. Mitigación: máximo 1 segundo.

---

### F-02 · Dato con fuente, fecha y estado

**Objetivo:** El usuario nunca dude de si la tasa está actualizada.

**Alcance:**
- Cada tasa muestra: valor (todos los decimales), fuente (BCV / Binance P2P), fecha/hora de publicación, estado.
- En calculadora: `Dólar BCV`, `+0,32 Bs (0,04%)`, `Lunes, 02/11/26`.

**Modelo de datos (Supabase + Drift):**
```
rate_snapshots:
  id, country_code, currency_code, source_code, rate_value,
  base_currency_code, official, principal, type,
  effective_from, published_at, fetched_at,
  change_pct, is_down, status
```
- `status`: `al_dia` | `desactualizado` | `sin_conexión`
- `published_at`: timestamp de publicación de la fuente

**Flujo de datos:**
```
Colector (Edge Function) → Supabase Postgres → PostgREST → Flutter Repository → Drift (cache) → Cubit → UI
```

**Jerarquía visual por tasa:**
```
┌─────────────────────────────────┐
│  💵 Dólar     889,5754 Bs  ↗    │
│       +0,32 Bs (0,04%)          │
│  BCV · Lunes, 02/11/26 · al día │
└─────────────────────────────────┘
```
- Nivel 1: valor (grande, negrita).
- Nivel 2: variación con flecha y color.
- Nivel 3: fuente + fecha + estado (pequeño, gris).

**Riesgos:**
- BCV cambia su web y rompe el scraper → fallback a puente con TLS válido (dolarapi.com).
- Certificado TLS del BCV roto → incluir certificado intermedio en Edge Function.

---

### F-03 · Offline real

**Objetivo:** Usar la calculadora y ver la última tasa sin conexión a internet.

**Alcance:**
- Cache de última tasa con timestamp en Drift (SQLite local).
- Cálculo local sin red.
- Banner de estado "sin conexión" cuando no hay red.
- Reintento automático al recuperar conexión.

**Flujo offline-first:**
```
Usecase → Repository
  ├─ 1) lee Drift → emite resultado local (instantáneo, 0 ms)
  ├─ 2) fetch Supabase/API (stale-while-revalidate)
  ├─ 3) escribe Drift (write-through) → drift.watch() re-emite → Cubit repinta
  └─ 4) si falla la red → mantiene local y marca estado "sin_conexión"
```

**Tablas Drift:**
```sql
CREATE TABLE rate_snapshots (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  country_code TEXT, currency_code TEXT, source_code TEXT,
  rate_value REAL, base_currency_code TEXT,
  official INTEGER, principal INTEGER, type TEXT,
  effective_from INTEGER, published_at INTEGER, fetched_at INTEGER,
  change_pct REAL, is_down INTEGER, status TEXT,
  UNIQUE(country_code, currency_code, source_code, effective_from)
);

CREATE TABLE settings (
  key TEXT PRIMARY KEY, value TEXT
);
```

**Estados de conexión:**
| Estado | Señal visual | Comportamiento |
|:------|:-------------|:---------------|
| `al_dia` | Sin banner | Datos de Supabase, frescos |
| `desactualizado` | Banner amarillo | Datos antiguos, avisar al usuario |
| `sin_conexión` | Banner rojo | Última tasa cacheada, cálculo local |

**Riesgos:**
- Datos muy viejos mostrados como actuales → siempre mostrar `published_at` y estado `desactualizado`.
- Drift migración falla → versionar migraciones con `schemaVersion`.

---

### F-04 · Formateador único es-VE

**Objetivo:** Un solo formato numérico en toda la app.

**Reglas de formato:**
| Elemento | Formato | Ejemplo |
|:---------|:--------|:--------|
| Separador decimal | Coma | `889,58` |
| Separador de miles | Ninguno en tasas | `889,58` (no `889.58`) |
| Sufijo moneda | `Bs` después del número | `Bs 889,58` |
| Dólares | `$` antes del número | `$ 1.00` |
| Variación | `+0,32 Bs (0,04%)` | con flecha ↗ o ↘ |
| Fecha | `Lunes, 02/11/26` | día, DD/MM/YY |

**Formateador Dart sugerido:**
```dart
class EsVeFormatter {
  static String rate(double value) =>
      NumberFormat('#,##0.##', 'es_VE').format(value);
  static String variation(double change, double pct) =>
      '${change >= 0 ? '+' : ''}${EsVeFormatter.rate(change)} Bs '
      '(${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%)';
}
```

**Riesgos:**
- Diferentes pantallas usan formatos distintos → auditoría de formato en cada release.
- Cédulas o teléfonos usan punto como miles → no mezclar con formato de tasas.

---

### F-05 · Multi-tasa simultáneo

**Objetivo:** Comparar BCV, USDT, Euro y "mi tasa" al mismo tiempo.

**Pantalla principal (Calculadora + Multi-tasa):**
```
┌─────────────────────────────────┐
│  Calculadora                    │
│                                 │
│  $  ______________   📋          │
│     1.00                        │
│                                 │
│  Bs  ______________   📋        │
│    889,58                       │
│                                 │
│  [ BCV  889,58 ] [ USDT 995,92 ]│
│  [ Euro 991,25 ] [ Mi tasa 1,00 ]│
│                                 │
│  [ Escáner ]   [ Tasas ]         │
└─────────────────────────────────┘
```
- Tocar una tasa de la fila inferior → cambia la tasa de cálculo de la calculadora principal.
- "Mi tasa" se guarda en `shared_preferences` o Drift `settings`.

**Riesgos:**
- Cambiar tasa pierde el monto escrito → mantener el monto al cambiar tasa (bug histórico del clon, evitarlo).
- Demasiadas tasas en pantalla pequeña → máximo 4, scroll horizontal si es necesario.

---

## 10. Roadmap de desarrollo (5 semanas)

### Semana 1 · Prototipo de ciclo crítico (sin backend)

| Día | Acción | Entregable |
|:----|:-------|:-----------|
| Lunes | Leer documento único, definir 5 features (M1–M5) | Lista de features clara |
| Martes | Crear proyecto Flutter, pantalla Splash sin anuncios | App abre en < 1 s |
| Miércoles | Pantalla Calculadora con cálculo hardcodeado | `$ 1.00 = Bs 889,58` |
| Jueves | Formateador es-VE (coma decimal, sufijo `Bs`) | Formato consistente |
| Viernes | Probar en dispositivo real (tiempo, formato, sin ads) | Checklist de verificación pasado |

**Objetivo:** Prototipo que abre, muestra tasa y calcula en < 1 s, sin backend, sin anuncios.

---

### Semana 2 · Verificación del prototipo

| Día | Acción | Entregable |
|:----|:-------|:-----------|
| Lunes | Medir cold start con cronómetro en teléfono real | < 1 s confirmado |
| Martes | Verificar formato es-VE en 5 pantallas | 0 divergencias |
| Miércoles | Simular modo avión (offline) | Última tasa cacheada visible |
| Jueves | Ajustar prototipo según hallazgos | Prototipo validado |
| Viernes | Decisión: pasar a desarrollo con backend | Go/No-go para Semana 3 |

**Objetivo:** Validar que el prototipo cumple RNF-01, RNF-02, RNF-03, RNF-08 antes de conectar backend.

**Regla:** Si en la Semana 2 el prototipo no pasa la verificación, no pases a la Semana 3. Ajusta el prototipo primero.

---

### Semana 3 · Conectar Supabase y colector de datos

| Día | Acción | Entregable |
|:----|:-------|:-----------|
| Lunes | Crear proyecto Supabase, tablas `rate_snapshots`, `currencies` | Esquema BD listo |
| Martes | Edge Function para scraper BCV + Binance P2P | Tasas reales en BD |
| Miércoles | Conectar Flutter a Supabase (PostgREST) | Tasas reales en la app |
| Jueves | Drift cache local + offline-first | App funciona sin internet |
| Viernes | Verificar frescura BCV (≤ 15 min) y USDT (≤ 1 h) | Datos actualizados |

**Objetivo:** Tasas reales de BCV y USDT en la app, con cache offline.

---

### Semana 4 · Pantallas y pulido del MVP

| Día | Acción | Entregable |
|:----|:-------|:-----------|
| Lunes | Pantalla Tasas BCV (APP-SCR-03) | Lista de tasas con fuente/fecha/estado |
| Martes | Pantalla Tasas USDT (APP-SCR-04) | Compra, venta, promedio |
| Miércoles | Pantalla Configuración (APP-SCR-06) + Información/legal (APP-SCR-11) | Moneda predeterminada + disclaimer legal |
| Jueves | Multi-tasa simultáneo en Calculadora (APP-SCR-09) | 4 tasas visibles |
| Viernes | Compartir texto por WhatsApp (APP-SCR-10) + regresiva APP-FLOW-01 | Mensaje de compartir listo + flujo crítico verificado |

**Objetivo:** Todas las pantallas del MVP funcionando con datos reales.

---

### Semana 5 · Lanzamiento interno y cierre de MVP

| Día | Acción | Entregable |
|:----|:-------|:-----------|
| Lunes | Build Android (APK interno) | App instalable |
| Martes | Pruebas en 2-3 dispositivos reales | Sin crashes |
| Miércoles | Verificar criterios de aceptación M1–M5 | Checklist completo |
| Jueves | Documentar supuestos pendientes [S] | Lista de S-01 a S-06 |
| Viernes | Cierre MVP, pasar a H4 (landing) o Fase 2 | Entregable al cliente |

**Objetivo:** MVP listo para mostrar al cliente (TasaVE C.A.).

---

## 11. Checklist de prototipo (Semanas 1–2)

Usa este checklist para verificar el prototipo **antes** de conectar backend.

### Antes de empezar
- [ ] Documento único leído: `docs-al-cambio/TASAVE_DOCUMENTO_UNIFICADO.md`
- [ ] 5 features M1–M5 identificadas (sección 4 de este documento)
- [ ] Proyecto Flutter creado y compilado en emulador/dispositivo

### Cold start y anuncios (HU-01, F-01)

| # | Prueba | Resultado esperado | Estado |
|:--|:-------|:-------------------|:------:|
| 1 | Abrir app con cronómetro | Pantalla visible en < 1 s | ☐ |
| 2 | Verificar anuncios entre abrir y calcular | 0 anuncios | ☐ |
| 3 | Transición splash → calculadora | Automática, sin interacción | ☐ |
| 4 | Cerrar app y volver a abrir | Sigue siendo < 1 s | ☐ |

### Dato fiable (HU-03, F-02)

| # | Prueba | Resultado esperado | Estado |
|:--|:-------|:-------------------|:------:|
| 1 | Cada tasa muestra fuente | `BCV` o `Binance P2P` | ☐ |
| 2 | Cada tasa muestra fecha/hora | `Lunes, 02/11/26` | ☐ |
| 3 | Cada tasa muestra estado | `al_dia` / `desactualizado` | ☐ |
| 4 | Formato es-VE (coma, `Bs`) | `889,58 Bs` | ☐ |

### Offline real (HU-04, F-03)

| # | Prueba | Resultado esperado | Estado |
|:--|:-------|:-------------------|:------:|
| 1 | Activar modo avión | App abre sin error | ☐ |
| 2 | Ver última tasa cacheada | Tasa del día anterior visible | ☐ |
| 3 | Calcular sin internet | Resultado al instante | ☐ |
| 4 | Banner "sin conexión" | Visible en rojo/amarillo | ☐ |
| 5 | Recuperar internet | App se actualiza sola | ☐ |

### Formato y multi-tasa (HU-05, HU-06, F-04, F-05)

| # | Prueba | Resultado esperado | Estado |
|:--|:-------|:-------------------|:------:|
| 1 | Todas las pantallas usan coma decimal | 0 puntos como decimal | ☐ |
| 2 | Todas llevan sufijo `Bs` | `Bs` visible en cada tasa | ☐ |
| 3 | Test de 5 s | 4/5 personas señalan la tasa | ☐ |
| 4 | 4 tasas visibles a la vez | BCV, USDT, Euro, mi tasa | ☐ |
| 5 | Tocar tasa cambia cálculo | Sin navegar a otra pantalla | ☐ |

### Decisión: ¿pasar a desarrollo?
- Si todas las casillas están marcadas ✅ → pasa a Semana 3 (conectar Supabase).
- Si hay casillas ❌ → ajusta el prototipo en la Semana 2 antes de continuar.

**Fecha de verificación:** _______________  
**Verificado por:** _______________

---

## 12. Qué NO construir en v1 (fuera de alcance)

| Feature | Por qué esperar |
|:--------|:----------------|
| Premium / suscripción | Fase 2 / Fase 4 (ver §18 de este documento) |
| Multi-país (COP, BRL, CLP, PEN) | Fase 3 |
| Widgets, audio TTS, PWA funcional | Fase 3 |
| Regla del siguiente día hábil (F-06) | Fase 2 (v1.1): calendario de feriados BCV con mantenimiento anual y +1 semana de plazo |
| Perfiles de pago | Fase 2 |
| Histórico y gráficas | Fase 2 |
| Escáner de precios | Fase 2 |

---

## 13. Requisitos funcionales (RF)

### Tasas y datos
- **RF-01 Tasas BCV.** Mostrar USD/EUR y otras publicadas con valor (todos los decimales), fuente, fecha/hora de publicación y estado (al día / desactualizado).
- **RF-02 Próxima tasa.** Consultar y aplicar la "próxima tasa" publicada por el BCV. Diferenciada en calendario y gráfica.
- **RF-03 USDT P2P.** Mostrar promedio, compra y venta con variación % y hora. Metodología consultable desde la app.
- **RF-04 Regla siguiente día hábil.** Toggle para aplicar la tasa del siguiente día hábil en fines de semana/feriados (art. 25 Ley de IVA).
- **RF-05 Multi-tasa simultánea.** Panel con BCV + Euro + USDT + "mi tasa" calculando a la vez.
- **RF-06 Histórico y gráficas.** Series por moneda y fuente, rangos 6 h / 7 d / 30 d / 90 d / 6 m / 1 a, sin huecos; marcar próxima tasa.
- **RF-07 Calendario.** Consultar tasas de fechas pasadas y futuras publicadas.

### Calculadora
- **RF-08 Cálculo preciso.** Usar todos los decimales de la fuente; redondear solo al mostrar.
- **RF-09 Bidireccional + múltiples monedas.** Bs ↔ USD/EUR/COP/BRL; entrada flexible (pegar, separadores), botón copiar.
- **RF-10 "Mi tasa".** El usuario puede fijar una tasa personalizada.

### Experiencia y monetización
- **RF-11 Offline.** Calculadora y última tasa disponibles sin conexión.
- **RF-12 Compartir.** Texto de cálculo/tasa (formato historia).
- **RF-13 Alertas (Fase 2).** Notificar cuando una tasa cambie más de X % o llegue a un umbral.
- **RF-14 Perfiles de pago (Fase 2).** Guardar Pago Móvil / Zelle / cuenta y compartir.
- **RF-15 Preferencias.** Tema claro/oscuro, moneda por defecto, fuentes activas.
- **RF-16 Premium.** Suscripción que elimina anuncios; compra/restauración vía store.
- **RF-17 Banner patrocinado.** Banner discreto solo en pantallas secundarias. Cero anuncios en cold start, calculadora y flujo de cálculo.

---

## 14. Requisitos no funcionales (RNF)

| ID | Requisito | Objetivo |
| :--- | :--- | :--- |
| RNF-01 | Cold start | **< 1 s** (p95) |
| RNF-02 | Cálculo | **< 100 ms** |
| RNF-03 | Impacto de anuncios | **0 ms** en flujo de cálculo |
| RNF-04 | Frescura BCV | ≤ 15 min tras publicación |
| RNF-05 | Frescura USDT | ≤ 1 h |
| RNF-06 | Crash-free | **> 99.5 %** |
| RNF-07 | Disponibilidad API | 99.9 % |
| RNF-08 | Offline | 100 % calculadora + última tasa |
| RNF-09 | Tamaño app | < 40 MB (base) |
| RNF-10 | Accesibilidad | Contraste AA, escalado de fuente, TTS (Fase 3) |
| RNF-11 | Seguridad | TLS, tokens cifrados, RLS, sin datos sensibles en logs |
| RNF-12 | Localización | es-VE; preparado para es-CO/es-BR |

---

## 15. Reglas de negocio (BN)

- **BN-01 Precisión:** almacenar y mostrar todos los decimales de la fuente; redondear solo en presentación.
- **BN-02 Día hábil:** si una fecha no es hábil, la tasa aplicable es la de la publicación del siguiente día hábil.
- **BN-03 Brecha:** `brecha % = (tasa_ref / tasa_bcv − 1) × 100`, con hora de cálculo.
- **BN-04 USDT:** promedio estadístico de anuncios P2P; se excluyen outliers; 1 USDT ≠ 1 USD.
- **BN-05 Neutralidad:** el usuario elige fuentes (modo "solo BCV" disponible).
- **BN-06 Estados de dato:** `al_dia`, `desactualizado`, `sin_conexión` (última conocida).

---

## 16. Arquitectura y tecnología

### Stack
- **Cliente móvil:** Flutter (Android + iOS)
- **Arquitectura:** Clean Architecture + Cubit/bloc + GetIt + GoRouter + fpdart
- **BD local:** Drift (SQLite ORM reactivo) + shared_preferences + flutter_secure_storage
- **Backend:** Supabase (Postgres + Auth + Storage), todo lo posible dentro de Supabase
- **API:** REST/PostgREST + RPC (funciones Postgres)
- **Colector de datos:** Edge Function (Deno) + pg_cron. Fuentes: BCV (scrape) + Binance P2P (API pública)
- **Coste de datos:** $0 (ninguna API de pago)
- **Web:** Landing page pública del producto

### Flujo offline-first
Usecase → Repository → lee Drift (resultado instantáneo) → fetch Supabase/API (stale-while-revalidate) → escribe Drift (write-through) → drift.watch() re-emite → Cubit repinta → si falla la red, mantiene local y marca estado "sin_conexión".

### Modelo de datos Supabase
Tablas: `countries`, `currencies`, `sources`, `rate_snapshots`, `rate_series`, `usdt_averages`, `rate_health`, `payment_profiles`, `alert_subscriptions`, `device_tokens`, `articles`, `app_config`, `methodology_docs`.

RLS: lectura pública para catálogos y tasas; escritura solo por service_role (colector); datos de usuario (perfiles, alertas, tokens) aislados por `user_id = auth.uid()`.

### Fuentes de datos
- **BCV:** `bcv.org.ve` (portada, scrape HTML). Gotcha: certificado TLS roto — solución: incluir certificado intermedio en la Edge Function o fallback a puente con TLS válido.
- **Binance P2P:** `p2p.binance.com` (API pública JSON POST), agregando páginas y promediando excluyendo outliers.

---

## 17. Seguridad, privacidad y legal

- **Privacidad:** recolección mínima (preferencias, token push); encriptación en tránsito.
- **Auth:** Supabase Auth (email/anónimo); opcional para perfiles y alertas.
- **Legal (VE):** disclaimer de app informativa, no afiliada a entes oficiales, no fija tasas. Cumple art. 25 Ley de IVA (siguiente día hábil).
- **USDT:** declarar referencia estadística de mercado P2P (1 USDT ≠ 1 USD), con metodología publicada y modo "solo BCV".
- **Store compliance:** sin permisos innecesarios; política de anuncios respetuosa.

---

## 18. Monetización y política de anuncios

- **Premium:** suscripción para eliminar anuncios (RevenueCat / store). Precio de referencia bajo (~$0.99–$5.99).
- **Patrocinio de banner:** de marca local, solo en pantallas secundarias.
- **Ads de red:** solo como fallback y únicamente en pantallas secundarias.
- **Hard requirements:**
  1. Prohibido app-open ads y cualquier anuncio en cold start.
  2. Solo banner en pantallas no críticas (histórico, blog, ajustes).
  3. Nunca sobre el teclado ni en el flujo de cálculo.
  4. Cerrar un anuncio no redirige a la store.
  5. Rewarded solo opcional (nunca bloqueante).
  6. KPI: 0 ms de impacto en el cálculo.

---

## 19. Supuestos pendientes `[S]` (no bloquean la cotización)

| # | Supuesto | Impacto si no se confirma |
| :--- | :--- | :--- |
| S-01 | Tiempo real de apertura y toques (S1: abrir → ver → calcular en segundos). | No se pueden validar RNF-01/RNF-02 sin medir en dispositivo. |
| S-02 | Estados no capturados: sin conexión, error de red, carga, vacío, paywall. | M3 (offline real) queda como requisito a validar en H1. |
| S-03 | Histórico y gráficas: solo se vio el picker de fecha, no el histórico completo. | RF-06 se ejecuta en Fase 2, no bloquea el MVP. |
| S-04 | Flujo completo de creación de perfil de pago (se vio formulario, no confirmación). | RF-14 se difiere a Fase 2. |
| S-05 | Diferencia entre "fecha de publicación" y "fecha de vigencia" en cada tasa. | BN-02 se asume según evidencia web; validar en H1. |
| S-06 | Comportamiento al cambiar de tasa sin perder el monto (bug histórico del clon). | RF-09 incluye este comportamiento por diseño. |

---

## 20. Decisiones de producto pendientes (no bloquean el MVP)

- Nombre y marca definitivos (ahora "TasaVE", provisional).
- Precio final del Premium y proveedor de pago (RevenueCat / store).
- Proveedor de push (FCM / OneSignal) y proveedor de analítica.
- Si el Premium entra en v1 o se difiere a Fase 2 (monetización).

---

## 21. Ámbito de cotización (4 hitos)

| Hito | Qué se entrega | Basado en |
| :--- | :--- | :--- |
| **H1 · Descubrimiento y UX** | Brief cerrado (este documento), wireframes, criterios de aceptación, validación móvil S0–S8 | Evidencia `clon-al-cambio/` + capturas |
| **H2 · Colector + Supabase** | Esquema BD, RLS, Edge Function BCV + Binance P2P, pg_cron, health checks | Sección 16–17 de este documento |
| **H3 · App Flutter MVP** | Calculadora + multi-tasa + offline + sin anuncios en ciclo crítico + compartir texto + configuración + información/legal | Alcance M1–M5 + F-07, F-08, F-12, Sección 2–15 |
| **H4 · Landing + pulido + lanzamiento** | Landing pública, build Android/iOS, release interno | Roadmap Fase 1 |

Precios de cotización: **$0** hasta cerrar el brief (según decisión comercial).

---

## 22. Fuera de alcance (MVP)

MVP v1 cerrado con **8 features**: F-01, F-02, F-03, F-04, F-05 + F-07 (compartir texto), F-08 (configuración) y F-12 (información/legal).

F-06 (regla del siguiente día hábil), F-09 (onboarding), F-10 (escáner) y F-11 (perfiles de pago) quedan en **Fase 2**.

La lista operativa de exclusiones para el equipo de desarrollo está en **§12 Qué NO construir en v1**.

Aspectos de negocio que quedan fuera del MVP v1:
- No somos entidad oficial; no fijamos tasas.
- Sin trading, cripto-custodia, cuentas bancarias ni procesamiento de pagos.
- Premium y patrocinio entran en Fase 2/Fase 4, no en el MVP (salvo que se decida lo contrario).
- Multi-país (COP, BRL, CLP, PEN) entra en Fase 3.
- Widgets, audio TTS y PWA funcional entran en Fase 3.

---

## 23. Regla de oro (DEC-07)

No se copia nombre, logo, textos, ilustraciones, código ni API de la app de referencia. Se copian ideas, flujos y patrones de interacción. Toda la marca, textos y capturas en este documento pertenecen a **TasaVE C.A.** o son evidencia de referencia sin reproducir contenido protegido.

---

## 24. Próximos pasos (comercial en Odoo)

Una vez revisado y aceptado este documento por el cliente:

1. Crear contacto `TasaVE C.A.` en Odoo CRM.
2. Crear oportunidad vinculada al contacto.
3. Generar cotización con los 4 hitos (H1–H4) y precios $0 (pendiente de cierre de brief).
4. Pasar a contrato y facturación tras aceptación.
5. Iniciar desarrollo con H1 (descubrimiento y UX).

---

> **Documento único para lectura del proyecto y arranque de cotización.**  
> Ubicación: `docs-al-cambio/TASAVE_DOCUMENTO_UNIFICADO.md`  
> **Guía de desarrollo:** `docs-al-cambio/PLAN_DE_DESARROLLO.md` (fuente de verdad para el equipo de desarrollo)
