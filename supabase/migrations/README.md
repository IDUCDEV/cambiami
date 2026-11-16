# Migraciones

Contrato de las migraciones de Cambiami. La CLI de Supabase solo aplica archivos
`.sql` de esta carpeta; este `README.md` se ignora.

## Nombre

```
NNNNN_nombre_en_snake_case.sql
```

- Cinco dígitos, con ceros a la izquierda: `00001_rates.sql`, `00002_...`.
- Un archivo = un cambio lógico de esquema.
- El orden de aplicación es el orden alfabético del nombre.

## Flujo

1. Crear el archivo con `supabase migration new <nombre>` o a mano.
2. `supabase db reset` — recrea la base local aplicando todas las migraciones y
   después `seed.sql`.
3. `supabase test db` — corre los tests pgTAP de `supabase/tests/`.
4. `supabase db push` — solo cuando exista proyecto remoto.

## Reglas

- **Una migración aplicada no se edita.** Si hay un error, se corrige con una
  migración nueva. En local se puede editar y resetear mientras el change no esté
  cerrado; después, no.
- **RLS en la misma migración que crea la tabla.** Una tabla sin RLS no se
  commitea, ni siquiera en local (ADR 0005).
- **Sin datos en las migraciones.** El catálogo vive en `seed.sql`; las tasas las
  escribe el colector, nunca el repo.
- **Funciones:** `security definer` + `set search_path = ''`, y siempre
  `revoke execute ... from public, anon, authenticated` antes del `grant` a
  `service_role`.
- **Toda tabla o vista nueva entra con test pgTAP** en `supabase/tests/`.
- **Sin `drop` destructivo** en v1: el esquema se recrea con `db reset`.

## Verificación mínima antes de cerrar un change

```bash
supabase db reset && supabase test db
```
