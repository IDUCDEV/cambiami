# ADR 0002 · Inyección de dependencias y generación de código

- **Estado:** aceptada
- **Fecha:** 2026-11-14
- **Decisores:** IDUCDEV
- **Relacionados:** `PROMPT-POR-FASES/03-fase-3-core-flutter.md` §3.14, ADR 0003

## Contexto

El proyecto usa Clean Architecture con tres capas por feature. Hay que resolver
dos cosas juntas porque se afectan: cómo se construyen los objetos y cuánto código
se genera.

El scaffold propuesto trae GetIt + `injectable` y `build_runner` para dos cosas:
el grafo de DI y los esquemas de Isar. Con el cache resuelto sin Isar (ADR 0003),
el generador queda con una sola responsabilidad.

## Decisión

- **GetIt + `injectable`** como contenedor. Un `ServiceLocator` en
  `lib/core/di/service_locator.dart`, un módulo externo
  (`external_module.dart`) para lo que no se puede anotar: `SupabaseClient`,
  `SharedPreferencesWithCache`, `http.Client` y `PackageInfo`.
- **`build_runner` genera solo el archivo de DI** (`injectable_generator`). No se
  usa `freezed`, `json_serializable` ni generadores de cache.
- **`fromJson`/`toJson` explícitos** en cada modelo. Son cinco campos por modelo,
  no vale la pena un generador.
- **`Equatable`** para igualdad en entidades y estados. Sin `copyWith` generado:
  se escribe a mano donde haga falta.
- **Scopes explícitos por ciclo de vida.**
  - `@lazySingleton` para repositorios, datasources, servicios y los cubits de
    estado compartido: `RatesCubit`, `SelectionCubit` y `SettingsCubit`. Su
    estado sobrevive a la navegación y varios widgets lo escuchan.
  - `@injectable` para los cubits de pantalla: `CalculatorCubit` y
    `CustomRateCubit`. Se crean al entrar y se descartan al salir.
  - `@singleton` solo para `CacheManager` y el cliente HTTP.
- **El grafo se verifica en `make gen`.** Si falta un registro, el build falla; no
  se descubre en runtime.

## Alternativas descartadas

| Alternativa | Por qué no |
|---|---|
| Riverpod como estado y DI | Resuelve lo mismo con un segundo sistema de estado; el equipo ya definió Cubit |
| `provider` para DI | No valida el grafo en compilación y escala mal con tres capas |
| Service locator manual | Cero generación, pero cada feature nueva edita un archivo central y se olvidan registros |
| `freezed` para estados | Los estados son `sealed` + `Equatable`; el generador agrega build time sin evitar errores |
| `json_serializable` | Cinco modelos con campos estables; el generador cuesta más de lo que ahorra |
| Isar con su generador | Descartado en ADR 0003 |

## Consecuencias

### Positivas

- Un solo `.config.dart` generado, reproducible y descartable.
- Sin `part`/`part of` de codegen en el dominio.
- El `pubspec` no arrastra generadores atados a versiones viejas de `analyzer`,
  que es lo que hoy impide subir Flutter sin fricción.

### Negativas / costo

- `copyWith` y `fromJson` son código manual: hay que mantenerlos cuando cambia un
  campo. Mitigación: los tests de modelo cubren ida y vuelta.
- `injectable` obliga a importar `injectable` en la capa de datos y en DI. Es una
  dependencia de infraestructura, aceptada.

## Verificación

- `make gen` produce un único archivo `.config.dart` y no ensucia el árbol.
- `flutter analyze` con 0 warnings.
- Un test de humo resuelve `RatesRepository` desde el `ServiceLocator` y falla si
  falta un registro.
- Un test verifica los scopes: dos resoluciones de `RatesCubit` devuelven la misma
  instancia y dos de `CalculatorCubit` devuelven instancias distintas.

## Cuándo revisar

- Si el grafo supera las ~40 dependencias y el archivo generado se vuelve ilegible.
- Si aparece una feature que necesita un scope por sesión de usuario (Fase 2).
