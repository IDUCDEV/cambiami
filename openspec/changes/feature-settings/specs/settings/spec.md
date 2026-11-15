## Purpose

Guarda la moneda con la que abre la calculadora y muestra el texto legal completo,
con la identidad de Cambiami y sin ningún emoji.

## ADDED Requirements

### Requirement: Moneda predeterminada persistente (REQ-SET-001)

El módulo SHALL persistir la moneda predeterminada en
`cambiami.default_currency.v1`, SHALL aceptar solo `USD`, `EUR` y `USDT` y SHALL
usar `USD` cuando no haya valor guardado o el guardado sea inválido.

#### Scenario: Cambiar la moneda
- **WHEN** el usuario elige `EUR` en `Configuración`
- **THEN** la preferencia se guarda y la opción queda marcada como activa

#### Scenario: Reabrir la app
- **WHEN** la app se cierra y se vuelve a abrir con `EUR` guardado
- **THEN** la calculadora abre con la tasa del euro como ficha y el campo de entrada corresponde a esa moneda

#### Scenario: Valor inválido en el cache
- **WHEN** `cambiami.default_currency.v1` contiene `GBP` o una cadena vacía
- **THEN** se usa `USD` y la preferencia se reescribe con el valor válido

#### Scenario: Aplicación al abrir, no en caliente
- **WHEN** el usuario cambia la moneda mientras la calculadora está abierta
- **THEN** la calculadora actual no cambia y la preferencia se aplica en la próxima apertura

### Requirement: Información legal completa (REQ-SET-002)

La app SHALL mostrar el texto legal de `DESIGN_SYSTEM.md` §13.6 completo, sin
resumir ni repartir, en la pantalla `Información`, accesible desde Configuración y
desde el icono `info` de Tasas.

#### Scenario: Abrir desde Configuración
- **WHEN** el usuario toca `Información` en Configuración
- **THEN** se abre la pantalla `Información` sin barra inferior y con `Volver`

#### Scenario: Abrir desde Tasas
- **WHEN** el usuario toca el icono `info` en Tasas
- **THEN** se abre la misma pantalla y `Volver` hace `pop` a Tasas

#### Scenario: Texto íntegro
- **WHEN** se muestra la pantalla `Información`
- **THEN** el párrafo legal aparece completo, con las menciones al BCV, a Binance y a que `1 USDT` no equivale a `1 USD`

#### Scenario: Página estática
- **WHEN** la pantalla `Información` se construye
- **THEN** no crea cubit ni hace peticiones de red y todo el texto viene del ARB

### Requirement: Identidad y versión en el pie (REQ-SET-003)

Configuración SHALL mostrar `TasaVE C.A. · v1.0` como pie y la marca visible SHALL
ser Cambiami en todas las pantallas.

#### Scenario: Pie de Configuración
- **WHEN** el usuario llega al final de `Configuración`
- **THEN** ve `TasaVE C.A. · v1.0` como entidad legal, sin RIF en pantalla

#### Scenario: Marca visible
- **WHEN** se revisa cualquier título, splash o texto de la app
- **THEN** la marca es `Cambiami` y `TasaVE C.A.` solo aparece como entidad legal

### Requirement: Copy localizado y sin emojis (REQ-SET-004)

Todo el texto de ambas pantallas SHALL venir de los archivos ARB y SHALL estar
libre de emojis; los únicos símbolos gráficos SHALL ser iconos Lucide.

#### Scenario: Revisión de copy
- **WHEN** se recorre Configuración e Información
- **THEN** no aparece ningún emoji y los iconos son de Lucide

#### Scenario: Cambio de texto
- **WHEN** se modifica una cadena del ARB
- **THEN** la pantalla muestra el texto nuevo sin tocar Dart

#### Scenario: Formato dentro del copy
- **WHEN** el copy menciona una cifra o una fecha
- **THEN** usa el formato es-VE y `EsVeFormatter`, no un literal escrito a mano
