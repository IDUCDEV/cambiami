# ADR 0006 · Kernel de dominio compartido

- **Estado:** aceptada
- **Fecha:** 2026-11-14
- **Decisores:** IDUCDEV
- **Relacionados:** `docs/DOMINIO.md` §7, ADR 0002, `docs/FEATURES.md`

## Contexto

`Rate` no pertenece a una sola feature: la pantalla Tasas la lista, la Calculadora
la usa para convertir, Configuración la usa para elegir la moneda por defecto y el
sheet Monedas la selecciona.

Si `Rate` vive en `features/rates/domain/`, entonces `calculator` y `settings`
importan el dominio de `rates`. Eso crea acoplamiento entre features y hace que
borrar o mover `rates` rompa las otras dos.

Duplicar la entidad en cada feature garantiza que se desincronicen.

## Decisión

Crear un **kernel de dominio compartido** en `lib/core/domain/` con **solo** los
tipos usados por dos o más features:

```
lib/core/domain/
├── entities/
│   ├── rate.dart              Rate
│   └── selected_rate.dart     SelectedRate (sealed)
├── enums/
│   ├── rate_type.dart         RateType
│   └── rate_status.dart       RateStatus
└── rate_status_resolver.dart  RateStatusResolver
```

Reglas:

1. **`core/domain` no depende de Flutter, Supabase, `shared_preferences` ni de
   ninguna feature.** Solo `equatable` y `dart:core`.
2. **Solo entra un tipo si lo usan dos o más features.** Si lo usa una sola, se
   queda en `features/<f>/domain/`.
3. **El kernel no contiene lógica de negocio de una feature.** `RateStatusResolver`
   es una función pura de frescura, no una regla de la calculadora.
4. **Las features dependen del kernel, nunca al revés.** `core` no importa
   `features/`.

## Alternativas descartadas

| Alternativa | Por qué no |
|---|---|
| `Rate` dentro de `features/rates` | `calculator` y `settings` importan otra feature; mover `rates` rompe todo |
| Duplicar `Rate` por feature | Tres definiciones que se desincronizan en el primer cambio de campo |
| Paquete separado (`packages/domain`) | Un repo, un equipo, cinco tipos: la ceremonia de un paquete no se paga |
| Todo el dominio en `core` | `core` se vuelve un cajón; la regla de "dos o más features" lo evita |

## Consecuencias

### Positivas

- Las features se pueden borrar o reordenar sin tocar las otras.
- Una sola definición de `Rate` y de `SelectedRate`.
- El kernel es testeable sin Flutter ni red.

### Negativas / costo

- `core` deja de ser solo infraestructura y pasa a tener dominio. Hay que vigilar
  que no crezca por comodidad.
- La regla "dos o más features" exige disciplina en cada revisión: si un tipo
  nuevo se promueve antes de tiempo, el kernel se contamina.

## Verificación

- `core/domain` no importa `package:cambiami/features/...` ni `supabase_flutter`.
- Un test de arquitectura (o un grep en CI) falla si aparece ese import.
- `Rate` se usa en al menos dos features; si no, se baja a la feature.

## Cuándo revisar

- Si el kernel supera los ~10 tipos.
- Si aparece un segundo consumidor externo (web) que justifique un paquete.
- Si una regla de negocio necesita estado o servicios: entonces no va en el kernel.
