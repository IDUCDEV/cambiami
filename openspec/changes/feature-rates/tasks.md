## 1. Kernel y modelo

- [ ] 1.1 Crear `core/domain/entities/rate.dart` con los campos de la vista en `DOMINIO.md` §5 y el mapeo de §7, y `Equatable`; verificar con un test de igualdad y `copyWith`
- [ ] 1.2 Crear `core/domain/entities/selected_rate.dart` con `CatalogRate` y `CustomRate`; verificar con un test que un `switch` exhaustivo compila sin rama por defecto
- [ ] 1.3 Crear `features/rates/data/models/rate_model.dart` con `fromJson`/`toJson` explícitos, sin `json_serializable`; verificar con el JSON de ejemplo de `DOMINIO.md` §8
- [ ] 1.4 Verificar que `RateModel.fromJson` descarta `rate_value <= 0` y tolera `published_at` y `change_pct` nulos; test de tabla con 4 casos

## 2. Datasources y repositorio

- [ ] 2.1 Implementar `rates_remote_data_source.dart` con `GET /rest/v1/rates_latest`, el `select` y el `order` de `DOMINIO.md` §8; verificar la URL y las cabeceras con un `MockClient`
- [ ] 2.2 Mapear `401`/`403` a `ServerFailure`, `5xx`/timeout a `NetworkFailure` y JSON inválido a `ParseFailure`; verificar que ningún mensaje del backend llega a la interfaz
- [ ] 2.3 Implementar `rates_local_data_source.dart` sobre `SharedPreferencesWithCache` con `cambiami.rates.v1`, `cambiami.selected_rate.v1` y `cambiami.custom_rate.v1`; verificar lectura y escritura con un fake
- [ ] 2.4 Verificar que un JSON corrupto o sin `rows` se trata como cache ausente y no lanza excepción (REQ-CAT-007)
- [ ] 2.5 Implementar `RatesRepositoryImpl` con el `StreamController` en memoria de la selección; verificar que `selectRate`, `saveCustomRate` y `clearCustomRate` emiten un valor nuevo
- [ ] 2.6 Verificar que la selección huérfana cae a `CatalogRate(USD, oficial)` y reescribe la preferencia (D5)

## 3. Usecases

- [ ] 3.1 Implementar `GetCachedRates` y `FetchLatestRates`; verificar que el segundo escribe el cache solo con respuesta válida y no con error
- [ ] 3.2 Implementar `WatchSelectedRate`, `SelectRate`, `SaveCustomRate` y `ClearCustomRate`; verificar que `saveCustomRate(0)` y `saveCustomRate(-1)` equivalen a borrar
- [ ] 3.3 Verificar que `FetchLatestRates` no escribe Mi tasa en `cambiami.rates.v1` ni la devuelve en el catálogo (I-06)

## 4. Cubits

- [ ] 4.1 Implementar `RatesCubit` con `load`, `refresh` y `retry`; verificar con `blocTest` la secuencia `RatesLoading → RatesLoaded` y `RatesLoaded(isRefreshing: true)` en refresco
- [ ] 4.2 Verificar que un refresco fallido con datos en pantalla emite `RatesLoaded` con estado `sinConexion` y conserva las filas (D7)
- [ ] 4.3 Implementar `SelectionCubit` con `select`, `saveCustom` y `clearCustom`; verificar que el estado inicial sale del cache
- [ ] 4.4 Implementar `CustomRateCubit` con `inputChanged` y `save`; verificar `CustomRateEditing.isValid` con coma, punto, vacío y `0`
- [ ] 4.5 Verificar que `RatesCubit` y `SelectionCubit` están registrados como `@lazySingleton` y `CustomRateCubit` como `@injectable` (D6)

## 5. Pantalla Tasas (05)

- [ ] 5.1 Implementar `SectionHeader`, `RateCard` y `MethodNote` con los tokens y medidas de `DESIGN_SYSTEM.md` §7.2, §7.8 y §7.9; verificar con golden test a 390 px
- [ ] 5.2 Implementar `FreshnessStrip` y el `StatusPill` con los tres estados de §3.3; verificar colores y textos con test de widget
- [ ] 5.3 Implementar `RatesPage` agrupando por `official` y ordenando Oficial antes de P2P (REQ-CAT-002); verificar que un grupo vacío no dibuja su cabecera
- [ ] 5.4 Verificar que la ficha P2P usa `p2p_avg` como valor y calcula la brecha con `oficial`; sin `p2p_avg` no dibuja brecha (REQ-CAT-002)
- [ ] 5.5 Implementar los estados `RatesLoading` (skeleton), `RatesEmpty` y `RatesError` con `Reintentar`; verificar los tres con test de widget
- [ ] 5.6 Verificar que el skeleton anuncia `Actualizando tasas` al lector de pantalla y que el botón `Reintentar` vuelve a llamar a `fetchLatestRates`

## 6. Sheets Monedas (09) y Mi tasa (09b)

- [ ] 6.1 Implementar `RateRow` y `coins_sheet.dart` con el patrón de §7.6 (404 px, asa, cabecera `Monedas`, `Aplicar`); verificar que la fila activa muestra `En calculadora`
- [ ] 6.2 Verificar que `Aplicar` persiste la selección y que al reabrir el sheet la fila activa es la misma (REQ-CAT-005)
- [ ] 6.3 Implementar `mi_tasa_sheet.dart` con `AmountCard` activo, helper y `Guardar`; verificar que el alto es 301 y que no lleva barra inferior
- [ ] 6.4 Verificar que guardar `1.000,00` persiste, que vacío o `0` borra, y que la fila de `Monedas` vuelve a `Definir` (REQ-CAT-006)
- [ ] 6.5 Verificar que Mi tasa no aparece en `RatesPage` ni se escribe en `cambiami.rates.v1`

## 7. Cableado y verificación

- [ ] 7.1 Registrar datasources, repositorio, usecases y cubits en `service_locator.dart`; verificar con `make gen` y el test de humo de DI
- [ ] 7.2 Cablear `AppShell` para escuchar `SelectionCubit` y alimentar `CalculatorCubit`; verificar que el monto de la calculadora se conserva al cambiar de tasa
- [ ] 7.3 Verificar que `features/rates/` no importa `features/calculator/` ni `features/settings/`
- [ ] 7.4 Correr `flutter analyze` y confirmar 0 warnings
- [ ] 7.5 Correr `flutter test` y confirmar verdes los tests de modelo, repositorio, cubits, página y sheets
- [ ] 7.6 Probar en dispositivo: arranque con cache, modo avión, selección tras reiniciar y Mi tasa tras reiniciar
- [ ] 7.7 Confirmar cero emojis y cero hex sueltos en la feature
- [ ] 7.8 Registrar en el reporte las desviaciones y los `TODO` pendientes (copy de vacío H1)

## Trazabilidad

| Req | Tareas | Test |
|---|---|---|
| REQ-CAT-001 | 1.1, 1.3, 2.1, 2.5, 3.1, 4.1 | `rates_repository_test`, `rates_cubit_test` |
| REQ-CAT-002 | 1.1, 5.1, 5.3, 5.4 | `rates_page_test` |
| REQ-CAT-003 | 1.1, 5.2, 5.1 | `freshness_strip_test`, `rate_card_test` |
| REQ-CAT-004 | 4.1, 5.5, 5.6 | `rates_page_test` |
| REQ-CAT-005 | 1.2, 2.5, 2.6, 3.2, 4.3, 6.1, 6.2, 7.2 | `selection_cubit_test`, `coins_sheet_test` |
| REQ-CAT-006 | 1.2, 3.2, 3.3, 4.4, 6.3, 6.4, 6.5 | `custom_rate_cubit_test`, `mi_tasa_sheet_test` |
| REQ-CAT-007 | 1.4, 2.2, 2.4, 4.2 | `rate_model_test`, `rates_local_data_source_test` |
