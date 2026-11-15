## Purpose

Convierte un monto entre dólares y bolívares con la tasa seleccionada, recalcula en
cada cambio, funciona con el cache cuando no hay red y produce el texto de
compartir del sistema de diseño.

## ADDED Requirements

### Requirement: Conversión bidireccional sin botón (REQ-CAL-001)

La calculadora SHALL convertir en ambos sentidos mientras el usuario escribe, sin
botón de calcular, y SHALL mostrar el resultado con dos decimales.

#### Scenario: Dólares a bolívares
- **WHEN** el usuario escribe `1,00` en el campo `Dólares` con una tasa de `889,5754`
- **THEN** el campo `Bolívares` muestra `889,58 Bs`

#### Scenario: Bolívares a dólares
- **WHEN** el usuario escribe `889,58` en el campo `Bolívares`
- **THEN** el campo `Dólares` muestra `$ 1,00`

#### Scenario: Monto vacío
- **WHEN** el campo activo queda vacío
- **THEN** el resultado muestra `0,00` y no aparece ningún error

#### Scenario: Cambio de dirección
- **WHEN** el usuario toca el otro campo para escribir en él
- **THEN** el campo tocado pasa a ser el de entrada y el otro el de resultado, conservando los valores

### Requirement: Entrada de monto tolerante (REQ-CAL-002)

La calculadora SHALL aceptar coma o punto como separador decimal, SHALL ignorar
cualquier carácter que no sea dígito o un separador y SHALL limitar la entrada a
12 dígitos.

#### Scenario: Coma decimal
- **WHEN** el usuario escribe `1.234,5`
- **THEN** el monto se interpreta como `1234,5`

#### Scenario: Punto decimal
- **WHEN** el usuario escribe `1,234.5`
- **THEN** el monto se interpreta como `1234,5`

#### Scenario: Carácter inválido
- **WHEN** el usuario escribe una letra o un segundo separador
- **THEN** el carácter se ignora y el monto anterior se conserva

#### Scenario: Límite de dígitos
- **WHEN** el usuario intenta escribir un decimotercer dígito
- **THEN** la entrada se recorta y el valor no cambia

### Requirement: Cambio de tasa conserva el monto (REQ-CAL-003)

La calculadora SHALL recalcular al recibir una tasa nueva y SHALL conservar el monto
escrito; SHALL rechazar tasas no positivas sin romper la pantalla.

#### Scenario: Nueva tasa desde Monedas
- **WHEN** el usuario elige otra tasa en el sheet `Monedas`
- **THEN** el monto se conserva y el resultado se recalcula con la tasa nueva

#### Scenario: Mi tasa
- **WHEN** la selección es `Mi tasa` con `1.000,00` Bs
- **THEN** la ficha muestra `Definida por ti` y la conversión usa ese valor

#### Scenario: Tasa inválida
- **WHEN** la tasa recibida es `0` o negativa
- **THEN** no se calcula, el resultado queda deshabilitado y se muestra `No pudimos actualizar las tasas.`

### Requirement: Cálculo sin red (REQ-CAL-004)

La calculadora SHALL calcular con la tasa cacheada cuando no haya red, SHALL
mostrar el banner de `sin conexión` y SHALL refrescar sola al recuperar la
conexión, sin reiniciar ni perder el monto.

#### Scenario: Modo avión con cache
- **WHEN** el usuario abre la app en modo avión con tasas cacheadas
- **THEN** la calculadora convierte igual y muestra `Sin conexión · mostrando la tasa del <fecha>`

#### Scenario: Modo avión sin cache
- **WHEN** el usuario abre la app en modo avión sin cache
- **THEN** la calculadora aparece con el resultado en `0,00`, sin bloquear el arranque y con `Reintentar` disponible

#### Scenario: Recuperación de red
- **WHEN** la conexión vuelve mientras la calculadora está abierta
- **THEN** las tasas se refrescan y el banner desaparece sin perder el monto ni la selección

### Requirement: Compartir cálculo (REQ-CAL-005)

La calculadora SHALL generar el texto de compartir con el monto y la tasa del
momento, SHALL ofrecer `WhatsApp` y `Copiar texto`, y SHALL usar el mensaje literal
del sistema de diseño.

#### Scenario: Texto por defecto
- **WHEN** el usuario comparte sin editar el monto
- **THEN** el texto es `$ 1,00 = 889,58 Bs` seguido del bloque `Tasa BCV`, `Fecha valor` y `Descarga Cambiami`

#### Scenario: Monto editado
- **WHEN** el usuario comparte con `10,00` en el campo de dólares
- **THEN** el texto usa `$ 10,00` y la tasa vigente en ese instante

#### Scenario: Copiar
- **WHEN** el usuario toca `Copiar texto`
- **THEN** el texto queda en el portapapeles y se muestra una confirmación breve

#### Scenario: WhatsApp no instalado
- **WHEN** el esquema `whatsapp://` no está disponible
- **THEN** se abre `https://wa.me/?text=` en el navegador y el texto no se pierde

#### Scenario: Sin tasa
- **WHEN** no hay ninguna tasa disponible
- **THEN** `Compartir cálculo` está deshabilitado y no se genera texto

### Requirement: Respuesta inmediata y moneda inicial (REQ-CAL-006)

La calculadora SHALL pintar el resultado en el primer frame útil, SHALL recalcular
en menos de 100 ms y SHALL usar la moneda predeterminada como campo de entrada al
abrir.

#### Scenario: Primer frame
- **WHEN** el splash termina y la calculadora aparece
- **THEN** el monto y el resultado ya están pintados, sin animación de entrada

#### Scenario: Cambio de monto
- **WHEN** el usuario escribe un dígito
- **THEN** el resultado se actualiza en menos de 100 ms

#### Scenario: Moneda predeterminada
- **WHEN** la preferencia guardada es `EUR`
- **THEN** la calculadora abre con la tasa del euro como ficha y el campo de entrada corresponde a esa moneda

#### Scenario: Cambio de preferencia
- **WHEN** el usuario cambia la moneda predeterminada en Configuración
- **THEN** la calculadora la aplica al volver a abrirse, no en caliente
