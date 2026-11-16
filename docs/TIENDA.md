# Cambiami · checklist de tienda (H4)

Material necesario para publicar en Google Play y App Store. **No forma parte
del MVP v1**: se ejecuta en H4, cuando el cliente confirme marca, cuentas de
desarrollador y textos legales.

Los enlaces de tienda que aparecen en la ficha legal (§13.6 de
`DESIGN_SYSTEM.md`) se completan cuando existan las fichas publicadas. Hasta
entonces, la ficha legal no muestra enlaces.

---

## 1. Identidad

- [ ] Nombre visible definitivo: **Cambiami** (entidad legal: TasaVE C.A.).
- [ ] Icono de app 1024×1024 sin transparencia (emblema opción A, plano).
- [ ] Splash con emblema glossy sobre `#29243D` (≥160 px).
- [ ] Nombre de paquete Android (`app.cambiami`) y bundle iOS
      (`app.cambiami`) confirmados.
- [ ] Versión `1.0.0` y código de build `1`.

## 2. Fichas

- [ ] Título corto (≤30 caracteres) y descripción corta (≤80).
- [ ] Descripción larga (≤4000): qué hace, fuentes (BCV y Binance P2P), que no
      da consejo financiero y que no representa al BCV.
- [ ] Categoría: Finanzas. Clasificación de contenido: apta para todo público.
- [ ] Palabras clave: tasa BCV, dólar hoy, euro, USDT, bolívares.
- [ ] Capturas de teléfono (mínimo 4): Calculadora, Tasas, Monedas, Información.
      Sin emojis ni datos inventados; usar tasas reales del momento de la captura.
- [ ] Gráfico de cabecera de Play Store (1024×500).

## 3. Legal y soporte

- [ ] Política de privacidad publicada en una URL estable. Debe decir que la app
      es anónima, que no recoge datos personales y que no usa cuentas.
- [ ] Texto legal completo con razón social **TasaVE C.A.** y RIF.
- [ ] Correo de soporte y URL de soporte.
- [ ] Aviso de fuentes: BCV (`bcv.org.ve`) y Binance P2P (`p2p.binance.com`).
- [ ] Aviso de no afiliación: Cambiami no es una publicación oficial del BCV.
- [ ] Enlaces de tienda en la ficha legal (se completan al publicar).

## 4. Formularios de tienda

- [ ] **Data safety** (Play): sin recolección ni compartición de datos; sin
      ubicación, contactos ni identificadores.
- [ ] **App Privacy** (App Store): "Data Not Collected".
- [ ] Declaración de permisos: solo internet. Sin cámara, ubicación ni
      notificaciones en v1.
- [ ] Declaración de cifrado: la app usa HTTPS; no requiere export compliance
      adicional más allá de la exención estándar.

## 5. Cuentas y publicación

- [ ] Cuenta de Google Play Console y Apple Developer del cliente.
- [ ] Build firmado (keystore de release / certificado y perfil de iOS).
- [ ] Canal interno de pruebas con el build de release.
- [ ] Dominio vivo (`cambiami.app`) con la política de privacidad.
- [ ] Revisión de la ficha por el cliente antes de enviar a revisión.

## 6. Fuera de alcance

- Landing pública, blog y analítica: H4, no v1.
- Notificaciones push: Fase 2.
- Enlaces profundos y campañas: Fase 2.
