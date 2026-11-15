## 1. Dominio y datos

- [ ] 1.1 Crear `default_currency.dart` con `fallback`, `supported` e `isValid`; verificar con tabla `USD`, `EUR`, `USDT`, `GBP`, `''`
- [ ] 1.2 Implementar `settings_local_data_source.dart` sobre `SharedPreferencesWithCache` con `cambiami.default_currency.v1`; verificar lectura, escritura y ausencia de clave
- [ ] 1.3 Implementar `SettingsRepositoryImpl` traduciendo excepciones a `CacheFailure`; verificar que un valor inválido se normaliza a `USD` y se reescribe
- [ ] 1.4 Implementar `GetDefaultCurrency` y `SetDefaultCurrency`; verificar que `setDefaultCurrency('GBP')` no persiste y devuelve `Failure`

## 2. Cubit

- [ ] 2.1 Implementar `settings_state.dart` con `SettingsLoaded` y `SettingsSaving`; verificar igualdad con `Equatable`
- [ ] 2.2 Implementar `SettingsCubit` con `load` y `select`; verificar con `blocTest` la secuencia `SettingsSaving → SettingsLoaded` y el estado inicial `USD`
- [ ] 2.3 Verificar que un fallo de escritura emite `SettingsLoaded` con el valor anterior y no deja la UI en `Saving`

## 3. Pantalla Configuración (07)

- [ ] 3.1 Implementar `currency_selector.dart` con las tres monedas, marca de activa y el helper `Esta moneda se mostrará en la calculadora al abrir la app.`; verificar con golden test
- [ ] 3.2 Implementar `settings_page.dart` con la sección `Moneda predeterminada`, la entrada `Información` y el pie; verificar que no hay botón de volver y que la barra inferior está presente
- [ ] 3.3 Verificar que el pie muestra `TasaVE C.A. · v1.0` leyendo `PackageInfo` y recortando a mayor.menor (`1.0.0` → `1.0`), con fallback a `v1.0` (D7)
- [ ] 3.4 Verificar que `Información` navega a `/informacion` y que la barra inferior desaparece

## 4. Pantalla Información (08)

- [ ] 4.1 Implementar `info_page.dart` como `StatelessWidget` con el legal completo desde el ARB; verificar que no crea cubit ni hace red
- [ ] 4.2 Verificar que el párrafo coincide carácter por carácter con `DESIGN_SYSTEM.md` §13.6
- [ ] 4.3 Verificar `Volver` y `‹` con `pop` desde Configuración y desde el icono `info` de Tasas
- [ ] 4.4 Verificar que la pantalla no muestra barra inferior ni emojis, y que los iconos son Lucide

## 5. Cableado y verificación

- [ ] 5.1 Registrar datasource, repositorio, usecases y `SettingsCubit` (`@lazySingleton`) en DI; verificar con `make gen` y el test de humo
- [ ] 5.2 Cablear `AppShell` para resolver `SettingsCubit`, llamar a `load()` antes del primer frame de la calculadora y pasar `defaultCurrency` (D4)
- [ ] 5.3 Verificar que cambiar la moneda en Configuración no altera la calculadora abierta y que se aplica al reabrir la app
- [ ] 5.4 Verificar que `features/settings/` no importa `features/rates/` ni `features/calculator/`
- [ ] 5.5 Correr `flutter analyze` y confirmar 0 warnings
- [ ] 5.6 Correr `flutter test` y confirmar verdes los tests de entidad, repositorio, cubit, páginas y navegación
- [ ] 5.7 Revisar el copy completo: marca `Cambiami`, pie `TasaVE C.A. · v1.0`, cero emojis y cero literales fuera del ARB
- [ ] 5.8 Registrar en el reporte las desviaciones y los `TODO` pendientes

## Trazabilidad

| Req | Tareas | Test |
|---|---|---|
| REQ-SET-001 | 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 3.1, 5.2, 5.3 | `default_currency_test`, `settings_repository_test`, `settings_cubit_test` |
| REQ-SET-002 | 4.1, 4.2, 4.3, 3.4 | `info_page_test` |
| REQ-SET-003 | 3.2, 3.3, 5.7 | `settings_page_test` |
| REQ-SET-004 | 4.4, 5.7 | revisión de copy + `flutter test` |
