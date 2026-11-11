# Condiciones de la cotización — TasaVE C.A.

| | |
|:---|:---|
| **Cliente** | TasaVE C.A. · RIF J-30452819-5 · Caracas, Distrito Capital, Venezuela |
| **Proveedor** | IDUCDEV · RIF V245896863 |
| **Proyecto** | App móvil TasaVE — consulta de tasa BCV/USDT y calculadora USD/VES |
| **Referencia** | Cotización emitida el 08/11/2026 · Validez hasta el 22/12/2026 |

---

## 1. Objeto

Diseño y desarrollo de una aplicación móvil para consultar las tasas de cambio en Venezuela (BCV oficial y USDT P2P) y calcular montos entre dólares y bolívares, con funcionamiento sin conexión, sin publicidad en el ciclo crítico y con trazabilidad del dato (fuente, fecha y estado de cada tasa). La aplicación se publica bajo la marca **TasaVE**, propiedad del cliente.

## 2. Alcance del MVP (versión 1)

El alcance queda cerrado en **8 funcionalidades**:

| ID | Funcionalidad | Descripción |
|:---|:--------------|:------------|
| F-01 | Arranque sin anuncios | Apertura directa a la calculadora, sin bloqueos ni publicidad |
| F-02 | Dato con fuente, fecha y estado | Cada tasa muestra origen, hora de actualización y estado (actualizada / desactualizada) |
| F-03 | Funcionamiento sin conexión | Última tasa cacheada disponible y editable sin red |
| F-04 | Formato numérico único es-VE | Un solo formato de cifras en toda la app (miles, decimales, símbolos) |
| F-05 | Multi-tasa simultáneo | BCV y USDT visibles y convertibles a la vez |
| F-07 | Compartir cálculo | Envío del resultado como texto por WhatsApp y otras apps |
| F-08 | Configuración | Moneda predeterminada y preferencias de visualización |
| F-12 | Información y legal | Origen de los datos, avisos legales y descargo de responsabilidad |

## 3. Entregables por hito

| Hito | Entregable | Criterio de cierre |
|:-----|:-----------|:-------------------|
| **H1 · Descubrimiento y UX** | Documento de especificación cerrado, wireframes y criterios de aceptación | Validación del flujo principal en dispositivo |
| **H2 · Colector de datos + Supabase** | Esquema de base de datos, políticas de acceso, funciones de recolección BCV y USDT P2P, tareas programadas y monitoreo | Tasas actualizadas de forma automática y verificable |
| **H3 · App Flutter (MVP)** | Calculadora, multi-tasa, modo sin conexión, compartir, configuración e información legal | Las 8 funcionalidades del punto 2 aceptadas |
| **H4 · Landing y lanzamiento** | Página pública, compilación Android/iOS y versión de release para pruebas | Build instalable y publicado en canal interno |

## 4. Fuera de alcance

Quedan expresamente excluidos del MVP y se evalúan como fase 2 o posterior:

- Regla del siguiente día hábil con calendario de feriados BCV (F-06).
- Onboarding guiado (F-09), escáner de precios con cámara (F-10) y perfiles de pago (F-11).
- Histórico y gráficas avanzadas, notificaciones push y planes premium o patrocinio.
- Multi-país (COP, BRL, CLP, PEN), widgets, lectura por voz (TTS) y versión web instalable (PWA).
- Custodia de criptoactivos, operaciones de trading, cuentas bancarias o procesamiento de pagos.

El proveedor **no es una entidad oficial** y no fija ni certifica tasas de cambio: solo consulta y muestra las fuentes públicas indicadas.

## 5. Supuestos

El desarrollo de H1 valida y, si hace falta, ajusta los siguientes puntos. Ninguno bloquea la aceptación de esta cotización:

1. Tiempos de apertura y de cálculo se miden en dispositivo real.
2. Los estados de error, carga y vacío se definen durante H1.
3. La diferencia entre fecha de publicación y fecha de vigencia de cada tasa se confirma con las fuentes en H1.
4. Nombre y marca definitivos, así como proveedores de notificaciones y analítica, los define el cliente antes de H4.

## 6. Precio y forma de pago

- Los precios indicados corresponden al alcance descrito en los puntos 2 y 3. Cualquier ajuste se documenta y se aprueba por escrito antes de facturar.
- La facturación se emite por hito entregado y aceptado, en dólares estadounidenses (USD), con el IVA que corresponda según la alícuota vigente.
- El pago se realiza dentro de los plazos indicados en la cotización, contra presentación de factura fiscal.

## 7. Plazos y cambios de alcance

- El plazo estimado del MVP completo es de **6 a 8 semanas** desde la aprobación del alcance en H1.
- Cualquier funcionalidad no listada en el punto 2 se considera un cambio de alcance: se documenta, se estima y se aprueba por escrito antes de ejecutarse.
- Los retrasos por información, accesos o aprobaciones pendientes del cliente ajustan el calendario en la misma proporción.

## 8. Propiedad intelectual y confidencialidad

- El código, los diseños, los textos y la marca de la aplicación son propiedad del cliente una vez pagado el hito correspondiente.
- El proveedor conserva el derecho de reutilizar componentes técnicos genéricos, librerías y conocimiento acumulado no vinculados a la identidad del cliente.
- No se reproduce nombre, logotipo, textos, ilustraciones, código ni interfaz de terceros. La app se construye con marca, textos y diseño propios de TasaVE.
- Ambas partes mantienen confidencialidad sobre la información técnica y comercial intercambiada durante el proyecto.

## 9. Aceptación

La aceptación de esta cotización implica la conformidad con el alcance, los entregables, las exclusiones y las condiciones descritas. Las condiciones comerciales definitivas de precio y plazos se confirman al cierre de H1.

## 10. Firma

La aceptación se formaliza mediante **firma electrónica en DocuSign**. El sobre se envía a `contacto@tasave.com` y a la dirección que indique el proveedor. La fecha registrada por DocuSign es la fecha de aceptación del documento.

<table style="width:100%; border-collapse:collapse; margin-top:22px;">
<tbody>
<tr>
<td style="width:46%; vertical-align:top; padding:0 3% 0 0; border:none;">
<p style="margin:0;"><strong>Por el cliente — TasaVE C.A.</strong></p>
<p style="margin:0; color:#666;">RIF J-30452819-5</p>
<div style="height:64px;"></div>
<p style="margin:0; border-top:1px solid #444; padding-top:5px;">Nombre y apellido</p>
<p style="margin:0; color:#777;">Cargo · Fecha de firma</p>
</td>
<td style="width:46%; vertical-align:top; padding:0 0 0 3%; border:none;">
<p style="margin:0;"><strong>Por el proveedor — IDUCDEV</strong></p>
<p style="margin:0; color:#666;">RIF V245896863</p>
<div style="height:64px;"></div>
<p style="margin:0; border-top:1px solid #444; padding-top:5px;">Nombre y apellido</p>
<p style="margin:0; color:#777;">Cargo · Fecha de firma</p>
</td>
</tr>
</tbody>
</table>

<p style="margin-top:18px; color:#555;">Firma electrónica tramitada por DocuSign · Sobre N° ____________________</p>
<p style="color:#555;">Firma válida conforme a la Ley sobre Mensajes de Datos y Firmas Electrónicas.</p>

---

*Documento de condiciones para la cotización de TasaVE C.A. · IDUCDEV · 08/11/2026*
