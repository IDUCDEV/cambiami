# Plan de Desarrollo — TasaVE (MVP v1)

> Documento único de desarrollo. Guía mental para el desarrollador: personas, historias de usuario, criterios de aceptación, features, flujos, roadmap y checklist de prototipo.
> Fuente de verdad del brief y cotización: `docs-al-cambio/TASAVE_DOCUMENTO_UNIFICADO.md`.
> Fuente de verdad para el equipo de desarrollo: este documento (PLAN_DE_DESARROLLO.md).
>
> **Regla de oro:** no construyas nada que no esté en este plan. Si no está aquí, no entra en el MVP.

---

## 1. Personas de usuario

| Persona | Necesidad principal | Contexto de uso |
|:--------|:--------------------|:----------------|
| **Comerciante** | Cobrar bien, cumplir la ley (art. 25 IVA) | Caja del negocio, necesita la tasa rápido y sin errores |
| **Receptor de remesas** | Saber cuánto recibe en bolívares | Casa, teléfono, convierte dólares/USDT a Bs |
| **Fronterizo** | Manejar pesos/reales y bolívares | Frontera, conversión cruzada rápida |
| **Consulta rápida** | Precio en segundos | Cualquier momento, abre y cierra la app rápido |
| **Sin conexión** | Trabajar con mala señal | Zona con poco internet, usa la última tasa cacheada |

---

## 2. Historias de usuario

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

### HU-11 · Consultar las tasas en detalle
> **Como** usuario, **quiero** ver de cada tasa cuándo se publicó, desde cuándo rige, de qué fuente sale y cuándo la consulté, **para** decidir si el dato es de fiar antes de operar.

**Criterios de aceptación:**
- Cada tasa muestra `published_at` (`Publicado`) y `effective_from` (`Vigente desde`) dentro de la tarjeta, y `fetched_at` (`Actualizado…`) en la franja de la vista.
- El estado (`al día` / `desactualizado` / `sin conexión`) es visible en todas las vistas, sin depender del color: punto + palabra.
- 05 y 06 se alternan con el selector `BCV | USDT`; el tab `Tasas` mantiene su estado activo en ambas.
- La brecha de 06 muestra el porcentaje, la fórmula `(USDT promedio − BCV) ÷ BCV` y los dos valores usados.
- Cada tarjeta enlaza a su fuente (`bcv.org.ve`, `binance.com`) y el bloque "Cómo se calcula" explica la metodología.
- Carga y error están dibujados: skeleton de dos tarjetas y error con `Reintentar`.
- No se muestra ningún dato que no exista en `rate_snapshots` (sin histórico, sin mín/máx, sin nº de anuncios).

**Mapeo:** F-02 · APP-SCR-03 Tasas BCV, APP-SCR-04 Tasas USDT

---

## 3. Features críticas (M1–M5) mapeadas a historias

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

## 4. Features no críticas (fuera de alcance MVP)

| ID | Feature | Historia asociada | Por qué esperar |
|:---|:--------|:------------------|:----------------|
| F-06 | Regla siguiente día hábil | HU-09 | Requiere calendario de feriados BCV versionado (+1,5–2,5 d) y añade +1 semana al plazo. Riesgo legal si el calendario falla. Fase 2 (v1.1). |
| F-09 | Onboarding | — | Puede ir en segunda versión. |
| F-10 | Escáner de precios | — | Requiere cámara y OCR. Fase 2. |
| F-11 | Perfiles de pago | — | Requiere backend de usuarios. Fase 2. |


---

## 5. Flujos de usuario

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

## 6. Especificaciones técnicas por feature

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

## 7. Roadmap de desarrollo (5 semanas)

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

## 8. Checklist de prototipo (Semanas 1–2)

Usa este checklist para verificar el prototipo **antes** de conectar backend.

### Antes de empezar
- [ ] Documento único leído: `docs-al-cambio/TASAVE_DOCUMENTO_UNIFICADO.md`
- [ ] 5 features M1–M5 identificadas (sección 3 de este archivo)
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

## 9. Qué NO construir en v1 (fuera de alcance)

| Feature | Por qué esperar |
|:--------|:----------------|
| Premium / suscripción | Fase 2 / Fase 4 (documento único, sección 15) |
| Multi-país (COP, BRL, CLP, PEN) | Fase 3 |
| Widgets, audio TTS, PWA funcional | Fase 3 |
| Regla del siguiente día hábil (F-06) | Fase 2 (v1.1): calendario de feriados BCV con mantenimiento anual y +1 semana de plazo |
| Perfiles de pago | Fase 2 |
| Histórico y gráficas | Fase 2 |
| Escáner de precios | Fase 2 |

---

> **Orden de ejecución:** Semana 1 → Semana 2 → Semana 3 → Semana 4 → Semana 5.  
> **Documento fuente:** `docs-al-cambio/TASAVE_DOCUMENTO_UNIFICADO.md` (especificación del cliente y cotización).
