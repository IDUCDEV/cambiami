## 1. Dominio

- [ ] 1.1 Crear `conversion.dart` con `ConversionDirection` y `Conversion`; verificar con un test que `converted` y `rate` se conservan en la igualdad
- [ ] 1.2 Implementar `ParseAmount` con coma, punto, un solo separador y máximo 12 dígitos; verificar con tabla de 8 casos (`1.234,5`, `1,234.5`, `abc`, `1,,2`, `0`, ``, `1234567890123`, `1,`)
- [ ] 1.3 Implementar `ConvertAmount` en ambos sentidos; verificar `1 × 889,5754 = 889,5754`, `889,5754 ÷ 889,5754 = 1` y que `rate <= 0` devuelve `Failure`
- [ ] 1.4 Verificar que la conversión no redondea el valor interno: el resultado se guarda completo y el redondeo a 2 decimales ocurre solo al formatear

## 2. Compartir

- [ ] 2.1 Implementar `core/share/share_text_builder.dart` con el bloque literal de `DESIGN_SYSTEM.md` §13.5; verificar igualdad carácter por carácter en un test
- [ ] 2.2 Implementar `BuildShareText` como adaptador del builder; verificar que usa la tasa y la fecha recibidas, no valores globales
- [ ] 2.3 Verificar el formato dentro del texto: `$ 1,00`, `889,58 Bs`, `Lunes, 02/11/26` y `https://cambiami.app`, sin emojis

## 3. Cubit

- [ ] 3.1 Implementar `calculator_state.dart` con los tres estados y `Equatable`; verificar que `CalculatorReady` expone `amount`, `direction`, `converted`, `rate`, `status` y `fetchedAt`
- [ ] 3.2 Implementar `CalculatorCubit` con `AmountChanged`, `DirectionToggled`, `SelectedRateChanged`, `Retry` y `ShareTapped`; verificar la secuencia `CalculatorInitial → CalculatorReady` con `blocTest`
- [ ] 3.3 Verificar que `AmountChanged` conserva el monto al recibir `SelectedRateChanged` y que `DirectionToggled` invierte la entrada sin perder el valor
- [ ] 3.4 Verificar que una tasa `<= 0` emite `CalculatorError` y deshabilita el resultado
- [ ] 3.5 Verificar que `ShareTapped` sin tasa no produce texto y que con tasa produce el bloque esperado

## 4. Interfaz

- [ ] 4.1 Implementar `AmountField` con `AmountCard` de §7.1, botón copiar de 48×48 y controlador propio; configurar `numberWithOptions(decimal: true)` sin `signed` y filtrar a un solo separador (D12); verificar que escribir `1,` no borra la coma, que un segundo separador se ignora y que las etiquetas `Dólares`/`Euros`/`Bolívares`/`USDT` salen de §13.2
- [ ] 4.2 Implementar `CalculatorBody` con cabecera, franja, ficha compacta, dos montos y CTA `Compartir cálculo`; verificar con golden test a 390 px
- [ ] 4.3 Verificar que la ficha compacta abre el sheet `Monedas` y que el teclado abierto oculta la ficha y conserva la franja
- [ ] 4.4 Implementar `ShareSheet` con `WhatsApp` y `Copiar texto`; verificar que copiar deja el texto en el portapapeles y muestra confirmación breve
- [ ] 4.5 Verificar el fallback de `whatsapp://` a `https://wa.me/?text=` con un `UrlLauncherPlatform` falso
- [ ] 4.6 Implementar los estados visuales `al_dia`, `desactualizado` y `sin_conexion` de la calculadora; verificar que el banner no tapa el resultado y que la franja se mantiene
- [ ] 4.7 Verificar que no hay animación de entrada y que el primer frame pinta monto y resultado

## 5. Cableado y verificación

- [ ] 5.1 Registrar `CalculatorCubit` como `@injectable` y sus usecases en DI; verificar con `make gen` y el test de humo
- [ ] 5.2 Cablear `AppShell` para emitir `SelectedRateChanged` desde `SelectionCubit` y `RatesCubit`; verificar que el monto se conserva al cambiar de tasa
- [ ] 5.3 Cablear la moneda inicial desde `SettingsCubit` al construir la página; verificar que el campo de entrada corresponde a la preferencia
- [ ] 5.4 Verificar que `features/calculator/` no importa `features/rates/` ni `features/settings/`
- [ ] 5.5 Correr `flutter analyze` y confirmar 0 warnings
- [ ] 5.6 Correr `flutter test` y confirmar verdes los tests de parseo, conversión, cubit, texto de compartir y widgets
- [ ] 5.7 Medir en dispositivo: resultado en el primer frame y actualización por debajo de 100 ms al escribir
- [ ] 5.8 Probar en modo avión con cache y sin cache; confirmar que no hay bloqueo ni pérdida de monto
- [ ] 5.9 Registrar en el reporte las desviaciones y los `TODO` pendientes

## Trazabilidad

| Req | Tareas | Test |
|---|---|---|
| REQ-CAL-001 | 1.1, 1.3, 3.2, 4.1, 4.2 | `convert_amount_test`, `calculator_cubit_test` |
| REQ-CAL-002 | 1.2, 4.1 | `parse_amount_test` |
| REQ-CAL-003 | 1.3, 3.3, 3.4, 5.2 | `calculator_cubit_test` |
| REQ-CAL-004 | 4.6, 5.2, 5.8 | `calculator_page_test` |
| REQ-CAL-005 | 2.1, 2.2, 2.3, 3.5, 4.4, 4.5 | `share_text_builder_test`, `share_sheet_test` |
| REQ-CAL-006 | 4.7, 5.3, 5.7 | `calculator_page_test`, medición en dispositivo |
