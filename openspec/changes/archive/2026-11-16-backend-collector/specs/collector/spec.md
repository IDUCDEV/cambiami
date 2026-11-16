## Purpose

Obtiene las tasas del BCV y del mercado P2P de Binance de forma programada,
las publica de manera idempotente en el backend y registra la salud de cada
corrida, sin exponer la clave de escritura al cliente.

## ADDED Requirements

### Requirement: Ejecución programada

El colector SHALL ejecutarse automáticamente cada 30 minutos y SHALL poder
invocarse de forma manual para diagnóstico, sin cambiar el resultado de una
corrida ya publicada.

#### Scenario: Corrida programada
- **WHEN** el reloj del programador alcanza un múltiplo de 30 minutos
- **THEN** el colector se ejecuta y deja una corrida registrada por cada fuente consultada

#### Scenario: Invocación manual
- **WHEN** un operador invoca el colector con el secreto correcto
- **THEN** la corrida se ejecuta igual que la programada y queda registrada

#### Scenario: Reintento en la misma fecha de vigencia
- **WHEN** el colector vuelve a publicar la tasa oficial del BCV para una fecha valor ya registrada
- **THEN** no se crea un snapshot duplicado y la corrida termina sin error

### Requirement: Publicación de tasas oficiales

El colector SHALL publicar las tasas de `USD` y `EUR` del BCV con la fecha valor
de la fuente como `effective_from`, y SHALL validar la cadena TLS aunque el
servidor no envíe el certificado intermedio.

#### Scenario: BCV responde
- **WHEN** el BCV devuelve las tasas de dólar y euro
- **THEN** se publican dos snapshots `oficial` con la fecha valor del BCV

#### Scenario: Cadena TLS incompleta
- **WHEN** el BCV presenta su certificado sin el intermedio de la cadena
- **THEN** el colector completa la cadena con el bundle incluido y publica la tasa

#### Scenario: BCV no responde
- **WHEN** el BCV falla, tarda más del tiempo límite o devuelve un valor no positivo
- **THEN** no se publica ninguna tasa oficial y la corrida queda en estado de error con la causa

#### Scenario: Fecha de publicación desconocida
- **WHEN** el BCV informa la fecha valor pero no la hora de publicación
- **THEN** `published_at` se iguala a `effective_from` y la decisión queda documentada

### Requirement: Publicación de tasas P2P

El colector SHALL publicar para `USDT` los tipos `p2p_buy` y `p2p_sell` a partir
de los anuncios de Binance, y SHALL publicar `p2p_avg` solo cuando existan ambos
lados.

#### Scenario: Ambos lados disponibles
- **WHEN** Binance devuelve anuncios de compra y de venta de USDT
- **THEN** se publican `p2p_buy`, `p2p_sell` y `p2p_avg` como el promedio de los dos

#### Scenario: Falta un lado
- **WHEN** Binance devuelve anuncios de un solo lado o uno de los promedios no es positivo
- **THEN** se publica solo el lado disponible y no se calcula `p2p_avg`

#### Scenario: Binance no responde
- **WHEN** Binance falla o devuelve una respuesta sin anuncios válidos
- **THEN** no se publican tasas P2P y la corrida queda en estado de error con la causa

### Requirement: Registro de ejecuciones

El colector SHALL registrar cada corrida con fuente, inicio, fin, estado, filas
escritas y mensaje de diagnóstico, y SHALL dejar el estado `running` mientras la
corrida no haya terminado.

#### Scenario: Corrida exitosa
- **WHEN** el colector termina sin errores
- **THEN** la corrida queda en `ok` con hora de fin y la cantidad de filas insertadas

#### Scenario: Corrida parcial
- **WHEN** una fuente publica y otra falla
- **THEN** las corridas exitosas quedan en `ok`, la fallida en `error` y la fila escrita se conserva

#### Scenario: Corrida en curso
- **WHEN** el colector comienza y todavía no terminó
- **THEN** existe una corrida con estado `running` y sin hora de fin

### Requirement: Retención de datos

El sistema SHALL purgar diariamente los snapshots con más de 90 días y las
corridas con más de 30 días, y SHALL conservar siempre la publicación más
reciente de cada moneda y tipo aunque supere el corte.

#### Scenario: Purga de snapshots viejos
- **WHEN** un snapshot supera los 90 días y existe una publicación más nueva del mismo tipo
- **THEN** el snapshot viejo se borra

#### Scenario: Última publicación vieja
- **WHEN** la única publicación de una moneda y tipo supera los 90 días
- **THEN** se conserva por ser la vigente

#### Scenario: Purga de corridas
- **WHEN** una corrida del colector supera los 30 días
- **THEN** se borra

### Requirement: Secreto del colector

El colector SHALL exigir un secreto compartido para ejecutarse y SHALL mantener
la clave de escritura fuera del cliente y del repositorio.

#### Scenario: Sin secreto
- **WHEN** una petición llega sin el secreto o con uno incorrecto
- **THEN** el colector responde no autorizado y no escribe nada

#### Scenario: Secreto correcto
- **WHEN** una petición llega con el secreto configurado
- **THEN** el colector ejecuta la corrida

#### Scenario: Secreto en el repositorio
- **WHEN** se revisa el código y la configuración versionada
- **THEN** no aparece la clave de escritura ni el secreto del colector
