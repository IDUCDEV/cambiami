## Purpose

Provee el cascarón de la aplicación móvil: arranque, navegación principal,
identidad visual, formato numérico, manejo de errores, composición de
dependencias y localización, verificado con un slice descartable.

## ADDED Requirements

### Requirement: Arranque sin bloqueo

La aplicación SHALL mostrar el splash y llegar a la calculadora en menos de un
segundo, sin anuncios, videos ni pantallas de bienvenida.

#### Scenario: Arranque en frío
- **WHEN** la app se abre desde cero
- **THEN** muestra el splash con el emblema y, como máximo 400 ms después, la calculadora

#### Scenario: Arranque sin datos locales
- **WHEN** la app se abre sin cache ni preferencias guardadas
- **THEN** llega a la calculadora con valores por defecto y sin bloquearse

#### Scenario: Arranque con datos locales
- **WHEN** la app se abre con cache y preferencias guardadas
- **THEN** la calculadora muestra esos datos sin esperar a la red

### Requirement: Navegación principal de tres destinos

La aplicación SHALL ofrecer tres destinos —Calculadora, Tasas y Configuración— en
una barra inferior persistente, con la calculadora elevada en el centro.

#### Scenario: Cambio de destino
- **WHEN** el usuario toca Tasas o Configuración
- **THEN** la pantalla cambia y el destino activo se marca con color y peso tipográfico

#### Scenario: Regreso a la calculadora
- **WHEN** el usuario toca el botón central desde otro destino
- **THEN** vuelve a la calculadora conservando su estado

#### Scenario: Pantalla de detalle
- **WHEN** el usuario abre Información desde Configuración o desde Tasas
- **THEN** la barra inferior no se muestra y el botón de volver hace `pop`

### Requirement: Identidad visual por tokens

La aplicación SHALL construir su tema desde tokens de color, tipografía, espaciado
y radio, sin valores hexadecimales sueltos en widgets, y SHALL usar Nunito como
tipografía única.

#### Scenario: Tema aplicado
- **WHEN** se renderiza cualquier pantalla
- **THEN** los colores y las tipografías provienen de los tokens del sistema de diseño

#### Scenario: Contraste mínimo
- **WHEN** se muestra texto normal sobre cualquier superficie del tema claro
- **THEN** el contraste es al menos 4,5:1

#### Scenario: Color de texto prohibido
- **WHEN** un widget necesita texto en ámbar, teal o coral
- **THEN** usa la variante `-ink` correspondiente y no el color de relleno

### Requirement: Formato numérico único es-VE

La aplicación SHALL formatear todos los números a través de un único formateador,
con coma decimal, punto de miles, sufijo `Bs` y signo menos tipográfico.

#### Scenario: Tasa con todos los decimales
- **WHEN** se muestra una tasa de `889.5754`
- **THEN** se muestra `889,5754 Bs`

#### Scenario: Monto en bolívares
- **WHEN** se muestra un monto de `1234.5`
- **THEN** se muestra `1.234,50 Bs`

#### Scenario: Monto en dólares
- **WHEN** se muestra un monto de `1`
- **THEN** se muestra `$ 1,00`

#### Scenario: Variación negativa
- **WHEN** se muestra una variación de `-1.55` y `-0.16`
- **THEN** se muestra `−1,55 Bs (−0,16 %)` con el signo menos tipográfico

#### Scenario: Entrada del usuario
- **WHEN** el usuario escribe `1.234,5` o `1,234.5`
- **THEN** el valor se interpreta como `1234,5` al mostrarse

### Requirement: Errores traducidos y accionables

La aplicación SHALL convertir los fallos de infraestructura en mensajes en español,
sin exponer mensajes del backend, y SHALL indicar si la acción se puede reintentar.

#### Scenario: Fallo de red
- **WHEN** una consulta falla por falta de red
- **THEN** se muestra `No pudimos actualizar las tasas.` con la acción `Reintentar`

#### Scenario: Error del servidor
- **WHEN** una consulta devuelve un error del servidor
- **THEN** se muestra el mismo mensaje genérico y el detalle queda en el log, no en pantalla

#### Scenario: Error de validación
- **WHEN** el usuario ingresa un monto inválido
- **THEN** se muestra `Ingresa un monto válido.` junto al campo

### Requirement: Composición de dependencias verificada

La aplicación SHALL resolver sus dependencias desde un único punto de composición y
SHALL fallar en la generación si falta un registro.

#### Scenario: Resolución en tests
- **WHEN** un test solicita un repositorio al localizador
- **THEN** obtiene una instancia configurada sin tocar la red

#### Scenario: Registro faltante
- **WHEN** se agrega una clase inyectable sin registrarla
- **THEN** `make gen` o el test de humo de DI falla antes de compilar la app

#### Scenario: Widget sin acceso global
- **WHEN** un widget necesita un caso de uso
- **THEN** lo recibe por el cubit, no llama al localizador directamente

### Requirement: Localización preparada

La aplicación SHALL tomar el texto de interfaz de archivos ARB en español y SHALL
generar las localizaciones en cada build.

#### Scenario: Texto desde ARB
- **WHEN** se renderiza un título, botón o etiqueta
- **THEN** el texto proviene del ARB y no está escrito en el widget

#### Scenario: Cambio de copy
- **WHEN** se cambia una cadena en el ARB
- **THEN** la interfaz muestra el nuevo texto sin tocar código Dart

### Requirement: Slice descartable

La aplicación SHALL incluir una feature de ejemplo en memoria que pruebe el
cableado completo y que se pueda borrar sin tocar el resto del proyecto.

#### Scenario: Borrado del slice
- **WHEN** se ejecuta `make drop-feature`
- **THEN** se elimina `features/example/` y la app sigue compilando y navegando

#### Scenario: Slice funcionando
- **WHEN** el usuario abre la feature de ejemplo
- **THEN** puede crear un elemento en memoria y verlo listado

#### Scenario: Dependencia oculta
- **WHEN** el slice se borra y aparece un import roto
- **THEN** el cableado estaba acoplado y el change no se considera terminado
