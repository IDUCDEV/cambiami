## Purpose

Expone el catálogo de monedas y las tasas de cambio vigentes en bolívares para
consumo público de solo lectura, con procedencia, fechas y variación, y reserva
la escritura al colector.

## ADDED Requirements

### Requirement: Catálogo de monedas y fuentes

El sistema SHALL mantener un catálogo de monedas (código, nombre, símbolo,
decimales y tipo) y de fuentes (código, nombre, URL y mercado), y SHALL exponerlos
como parte de la lectura pública.

#### Scenario: Monedas del MVP disponibles
- **WHEN** se consulta el catálogo público
- **THEN** existen al menos `USD`, `EUR` y `USDT`, cada una con símbolo, decimales y tipo (`fiat` o `stablecoin`)

#### Scenario: Fuentes del MVP disponibles
- **WHEN** se consulta el catálogo público
- **THEN** existen `bcv` con mercado `oficial` y `binance_p2p` con mercado `p2p`, ambas con URL pública

#### Scenario: Moneda inactiva
- **WHEN** una moneda se marca como inactiva
- **THEN** deja de aparecer en la lectura pública sin borrar su historial

### Requirement: Publicaciones de tasas inmutables e idempotentes

El sistema SHALL almacenar cada publicación como un registro nuevo, identificado
por moneda, tipo y fecha de vigencia, y SHALL rechazar duplicados de esa
combinación.

#### Scenario: Inserción de una publicación nueva
- **WHEN** el colector inserta una tasa con una fecha de vigencia no registrada
- **THEN** el registro queda disponible para lectura con su fuente, `published_at`, `effective_from` y `fetched_at`

#### Scenario: Reintento del colector
- **WHEN** el colector vuelve a insertar la misma moneda, tipo y fecha de vigencia
- **THEN** no se crea un duplicado y la operación termina sin error

#### Scenario: Valor inválido
- **WHEN** el colector intenta insertar una tasa con valor menor o igual a cero
- **THEN** la inserción se rechaza y el valor no queda disponible para lectura

### Requirement: Lectura de la tasa vigente

El sistema SHALL exponer una única tasa vigente por moneda y tipo, eligiendo la
publicación con la fecha de vigencia más reciente que no supere el momento de la
consulta.

#### Scenario: Una fila por moneda y tipo
- **WHEN** existen varias publicaciones para la misma moneda y tipo
- **THEN** la lectura pública devuelve solo la más reciente que ya rige

#### Scenario: Publicación futura
- **WHEN** existe una publicación con fecha de vigencia posterior al momento de la consulta
- **THEN** esa publicación no se devuelve y se sigue mostrando la anterior

#### Scenario: Sin publicaciones
- **WHEN** no existe ninguna publicación para una moneda y tipo
- **THEN** la lectura pública no inventa una fila para esa combinación

### Requirement: Procedencia y mercado en la lectura

La lectura pública SHALL incluir, por cada tasa, el nombre y la URL de la fuente,
el mercado (`oficial` o `p2p`) y la variación respecto de la publicación anterior
del mismo tipo.

#### Scenario: Tasa oficial
- **WHEN** se lee una tasa de `bcv`
- **THEN** la fila indica mercado `oficial`, fuente `BCV` y su URL

#### Scenario: Tasa P2P
- **WHEN** se lee una tasa de `binance_p2p`
- **THEN** la fila indica mercado `p2p`, fuente `Binance P2P` y su URL

#### Scenario: Primera publicación de un tipo
- **WHEN** no existe una publicación anterior del mismo tipo
- **THEN** la variación se devuelve vacía y no se calcula un valor artificial

### Requirement: Lectura pública y escritura restringida

El sistema SHALL permitir la lectura anónima del catálogo y de las tasas, y SHALL
denegar toda escritura a roles anónimos o autenticados.

#### Scenario: Lectura anónima
- **WHEN** un cliente sin sesión consulta el catálogo o las tasas vigentes
- **THEN** recibe las filas permitidas

#### Scenario: Escritura anónima
- **WHEN** un cliente sin sesión intenta insertar, actualizar o borrar una moneda, fuente o tasa
- **THEN** la operación se rechaza

#### Scenario: Escritura del colector
- **WHEN** el colector escribe con el rol de servicio
- **THEN** la operación se permite sin depender de una policy de usuario

### Requirement: Registro de ejecuciones del colector

El sistema SHALL registrar cada ejecución del colector con fuente, inicio, fin,
estado, filas escritas y mensaje de error, para diagnóstico operativo.

#### Scenario: Ejecución exitosa
- **WHEN** el colector termina sin errores
- **THEN** queda un registro con estado `ok`, hora de fin y cantidad de filas escritas

#### Scenario: Ejecución fallida
- **WHEN** el colector no puede obtener o escribir los datos
- **THEN** queda un registro con estado `error` y un mensaje que identifica la causa

#### Scenario: Ejecución en curso
- **WHEN** el colector comienza y todavía no terminó
- **THEN** el registro existe con estado `running` y sin hora de fin
