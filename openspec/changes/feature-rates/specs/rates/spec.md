## Purpose

Convierte la vista `rates_latest` en el catálogo que ve el usuario y en la tasa
con la que calcula: lectura con cache primero, agrupación por mercado, procedencia
y frescura visibles, selección persistente y tasa manual local.

## ADDED Requirements

### Requirement: Catálogo disponible al abrir (REQ-CAT-001)

El módulo SHALL mostrar el catálogo desde el cache local antes de cualquier
respuesta de red, SHALL refrescarlo en segundo plano y SHALL conservar el catálogo
visible si el refresco falla.

#### Scenario: Arranque con cache
- **WHEN** la app arranca con `cambiami.rates.v1` escrito
- **THEN** el catálogo se pinta con esas filas y el estado de frescura se calcula sobre `published_at`

#### Scenario: Arranque sin cache
- **WHEN** la app arranca sin `cambiami.rates.v1`
- **THEN** el catálogo muestra el skeleton de carga y no bloquea el arranque

#### Scenario: Refresco exitoso
- **WHEN** la consulta a `rates_latest` responde con filas válidas
- **THEN** el catálogo se reemplaza y el cache se reescribe con `savedAt` y `rows`

#### Scenario: Refresco fallido con cache
- **WHEN** la consulta falla y existe cache
- **THEN** se conservan las filas cacheadas y el estado pasa a `sinConexion`

### Requirement: Catálogo agrupado por mercado (REQ-CAT-002)

El catálogo SHALL agruparse por mercado —`Oficial` y `Mercado P2P`— a partir del
campo `official`, SHALL mostrar una ficha por moneda y tipo, y SHALL calcular la
brecha en la interfaz sin pedirla al backend.

#### Scenario: Dos grupos visibles
- **WHEN** la vista devuelve filas `oficial` y `p2p_*`
- **THEN** la pantalla muestra el grupo `Oficial` y el grupo `Mercado P2P`, en ese orden

#### Scenario: Ficha P2P
- **WHEN** existen `p2p_avg`, `p2p_buy` y `p2p_sell` para USDT
- **THEN** la ficha P2P muestra el promedio como valor y la etiqueta `Brecha BCV ↔ USDT`

#### Scenario: Brecha sin promedio
- **WHEN** falta la fila `p2p_avg`
- **THEN** no se muestra la brecha ni se inventa un promedio

#### Scenario: Moneda sin fila
- **WHEN** una moneda del catálogo no tiene fila en `rates_latest`
- **THEN** no se muestra tarjeta para esa moneda y no se escribe copy nuevo

### Requirement: Procedencia y frescura visibles (REQ-CAT-003)

Cada ficha SHALL mostrar fuente, fecha de publicación y fecha de vigencia, y la
pantalla SHALL mostrar una franja de frescura con el estado derivado de la vista.

#### Scenario: Ficha con procedencia
- **WHEN** se muestra una tasa del BCV
- **THEN** la ficha indica `Publicado`, `Vigente desde`, la fuente `BCV` y el enlace `bcv.org.ve`

#### Scenario: Estado desactualizado
- **WHEN** la edad del dato supera el umbral de su tipo y la red respondió
- **THEN** el pill dice `desactualizado` y aparece el banner `Tasa de ayer · se actualiza a las 5:00 p. m.`

#### Scenario: Estado sin conexión
- **WHEN** la última consulta de red falló
- **THEN** el pill dice `sin conexión` y el banner dice `Sin conexión · mostrando la tasa del <fecha>`

#### Scenario: Franja con fecha del cache
- **WHEN** se muestra el catálogo desde cache
- **THEN** la franja usa `fetched_at` con el formato `Actualizado hoy · 9:41 a. m.`

### Requirement: Carga, vacío y error del catálogo (REQ-CAT-004)

La pantalla SHALL dibujar un skeleton durante la carga, SHALL mostrar
`No hay tasas publicadas.` con `Reintentar` cuando la vista responda sin filas y
SHALL ofrecer `Reintentar` cuando no haya datos ni cache.

#### Scenario: Carga visible
- **WHEN** el catálogo está en `RatesLoading`
- **THEN** se dibujan el título, dos `SectionHeader` y tres fichas en skeleton, y el lector de pantalla anuncia `Actualizando tasas`

#### Scenario: Vista vacía
- **WHEN** la red responde correctamente con cero filas
- **THEN** se muestra `No hay tasas publicadas.` con `Reintentar`, sin tasas inventadas y sin cache escrito

#### Scenario: Moneda sin fila
- **WHEN** una moneda del catálogo no tiene fila en `rates_latest`
- **THEN** no se dibuja su tarjeta y, si es la tasa seleccionada, la selección cae a `USD`/`oficial` como en REQ-CAT-005

#### Scenario: Error sin cache
- **WHEN** la consulta falla y no hay cache
- **THEN** se muestra `No pudimos actualizar las tasas.` con el botón `Reintentar`

#### Scenario: Reintento exitoso
- **WHEN** el usuario toca `Reintentar` y la consulta responde
- **THEN** el catálogo se pinta y el botón desaparece

### Requirement: Selección de tasa persistente (REQ-CAT-005)

El módulo SHALL permitir elegir una tasa del catálogo, SHALL persistirla en
`cambiami.selected_rate.v1` y SHALL publicarla a la calculadora sin que esta
importe el módulo `rates`.

#### Scenario: Aplicar una tasa
- **WHEN** el usuario toca una fila del sheet `Monedas` y confirma `Aplicar`
- **THEN** la selección queda guardada y la calculadora recalcula con esa tasa conservando el monto

#### Scenario: Fila activa
- **WHEN** el sheet `Monedas` se abre
- **THEN** la tasa en uso muestra el indicador `En calculadora` y las demás no

#### Scenario: Selección tras reiniciar
- **WHEN** la app se cierra y se vuelve a abrir
- **THEN** la selección guardada es la que usa la calculadora

#### Scenario: Selección huérfana
- **WHEN** la selección apunta a una moneda y tipo que ya no están en el catálogo
- **THEN** se usa la tasa por defecto (`USD`, `oficial`), se reescribe la preferencia y se registra en el log

### Requirement: Tasa manual Mi tasa (REQ-CAT-006)

El módulo SHALL permitir definir una tasa manual en bolívares, SHALL guardarla solo
en `shared_preferences` y SHALL excluirla del catálogo de Tasas y del backend.

#### Scenario: Guardar Mi tasa
- **WHEN** el usuario escribe `1.000,00` en el sheet `Mi tasa` y toca `Guardar`
- **THEN** la tasa se guarda en `cambiami.custom_rate.v1`, el sheet se cierra y la calculadora la ofrece

#### Scenario: Quitar Mi tasa
- **WHEN** el usuario deja el campo vacío o escribe `0` y toca `Guardar`
- **THEN** la tasa se borra, la fila de `Monedas` vuelve a `Definir` y la calculadora deja de ofrecerla

#### Scenario: Mi tasa fuera del catálogo
- **WHEN** existe una tasa manual guardada
- **THEN** no aparece en la pantalla `Tasas` ni se escribe en `cambiami.rates.v1`

#### Scenario: Persistencia
- **WHEN** la app se reinicia con una tasa manual guardada
- **THEN** el sheet `Mi tasa` muestra el valor guardado y la calculadora lo conserva

### Requirement: Filas inválidas y cache corrupto (REQ-CAT-007)

El módulo SHALL descartar cualquier fila con `rate_value <= 0` y SHALL tratar un
cache ilegible como cache ausente, sin propagar la excepción a la interfaz.

#### Scenario: Fila con tasa no positiva
- **WHEN** la vista devuelve una fila con `rate_value` igual a `0` o negativo
- **THEN** la fila se descarta antes de llegar al estado y no se escribe en el cache

#### Scenario: JSON corrupto
- **WHEN** `cambiami.rates.v1` contiene JSON inválido o sin la clave `rows`
- **THEN** el catálogo arranca como si no hubiera cache y el error queda en el log

#### Scenario: Cache de versión anterior
- **WHEN** solo existe `cambiami.rates.v0`
- **THEN** la versión vieja se ignora y no se migra en v1

#### Scenario: Dato sin fecha de publicación
- **WHEN** una fila trae `published_at` nulo
- **THEN** la edad se calcula sobre `fetched_at` y la ficha omite la línea de publicación
