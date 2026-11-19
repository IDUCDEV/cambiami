# Guía de cimiento: de la HU al código en seis etapas

**Método 5D** — Dominio, Decisiones, Descomposición, Definición, Desarrollo.
La sexta etapa, **Guardrails**, no agrega un pilar al método: es la capa que
vuelve ejecutables los gates de las cinco anteriores.

## 0. Para qué sirve, cuándo usarla y cuándo no

Esta guía convierte un brief con HU y un diseño cerrado en un plan de construcción verificable. No enseña a programar ni reemplaza al brief: lo consume. Su unidad de trabajo es el artefacto; su moneda, el gate binario.

Usala cuando haya al menos cinco HU, más de una pantalla, una fuente externa o un backend, y más de una semana de trabajo. También cuando varias personas o agentes toquen el mismo repo y las decisiones deban sobrevivir a la conversación.

No la uses en proyectos de un día, spikes ni prototipos descartables. Si el prototipo se vuelve producto, aplicala antes de la primera migración de datos.

## 1. Mapa de la metodología

```
HU + diseño cerrados
        │
        ▼
┌─────────────────┐
│ 1. DOMINIO      │  ¿qué datos existen y cómo se llaman?
└────────┬────────┘
         ▼
┌─────────────────┐
│ 2. ADRs         │  ¿qué decidimos y por qué?
└────────┬────────┘
         ▼
┌─────────────────┐
│ 3. MAPA         │  ¿cómo se corta en código?
└────────┬────────┘
         ▼
┌─────────────────┐
│ 4. OPENSPEC     │  ¿cuál es la unidad verificable?
└────────┬────────┘
         ▼
┌─────────────────┐
│ 5. BOOTSTRAP    │  ¿cómo se construye?
└────────┬────────┘
         ▼
┌─────────────────┐
│ 6. GUARDRAILS   │  ¿qué impide que el gate se degrade?
└────────┬────────┘
         ▼
      código
         │
         └──► solo se retrocede con un ADR o un cambio de dominio
```

| Etapa | Entrada | Salida | Gate | Esfuerzo |
|---|---|---|---|---|
| 1. Dominio | HU, diseño, fuentes, reglas | `MODELO_DE_DOMINIO.md` | Cada dato visible tiene campo o fórmula | 0,5–2 días |
| 2. ADRs | Dominio, RNF, restricciones, equipo | `ADR-000N-*.md` + índice + abiertas | Toda decisión transversal tiene ADR o está abierta con dueño | 0,5–1 día |
| 3. Mapa | Dominio, HU, pantallas, ADRs | `MAPA_DE_FEATURES.md` | Cada HU, entidad y pantalla tiene un dueño | 0,5 día |
| 4. OpenSpec | Mapa, dominio, ADRs, diseño | `changes/<id>/` completo | Toda requirement tiene tarea y test | 1–3 h por change |
| 5. Bootstrap | ADRs, mapa, scaffold, primer change | Repo + slice + primer change | Build, test y run verdes; slice borrado | 1–3 días + por change |
| 6. Guardrails | ADRs, mapa, changes, repo con primer change | Hooks, CI, comandos, plantilla de PR, bitácora | `make check` verde en CI sobre un PR de prueba y hook que rechaza un mensaje inválido | 0,5–1 día |

El orden no es negociable: cada etapa consume la anterior. Retroceder es válido; hacerlo en silencio, no.

La etapa 6 puede empezar en paralelo con la 5 —de hecho conviene, porque el primer PR necesita CI—, pero debe cerrar antes del segundo change. Un repo sin guardrails produce un gate que se cumple por disciplina; con guardrails, el gate se cumple porque el merge no ocurre de otra forma.

## 2. Reglas transversales

**R1. Una sola fuente de verdad por contrato.** Cada contrato —tabla, campo, ruta, token, error— vive en un solo artefacto normativo; los demás lo citan. Si dos artefactos difieren, el gate falla.

**R2. El artefacto precede al código.** Sin artefacto que gobierne la capa, no se escribe la capa. Un ADR `propuesto` no habilita código; uno `aceptado`, sí.

**R3. No inventar dominio.** Un dato que no está en la fuente, el diseño o una regla no entra al modelo. Si la UI lo sugiere, va a la lista de rechazo con una razón.

**R4. Un gate por etapa, binario.** Cada etapa cierra con sí/no. “Casi” es “no”. Se firma con nombre y fecha.

**R5. Trazabilidad obligatoria.** Toda HU termina en un test; toda tarea referencia una requirement; toda requirement tiene un change. Una fila vacía es un defecto, no una tarea pendiente.

**R6. Nada de decisiones implícitas.** Lo que no está en un ADR ni en las abiertas no se decide en el código; se escribe antes de implementarlo.

**R7. El diseño visual es contrato, no referencia.** Tokens, medidas, estados, microcopy y rutas se implementan como están. Desviarse exige un ADR de diseño, no un hex parecido.

**R8. Contrato no es lo mismo que decisión abierta.** Un contrato obliga a otros artefactos y tests, vive en un ADR aceptado y solo cambia con otro ADR. Una decisión abierta tiene dueño, fecha y default, y se cierra antes de codear. El envelope de error es contrato; la librería de gráficos, una abierta.

## 3. Las seis etapas

Cada etapa se compone de pregunta, entradas, salida, procedimiento, plantilla, gate, errores típicos, esfuerzo y encargo a un agente.

### 3.1 Etapa 1 — Dominio

**Pregunta y fallo que evita.** ¿Qué datos existen, cómo se llaman y qué reglas los gobiernan? Evita que la interfaz invente el modelo: un dato ausente en la fuente se falsifica o reabre el esquema tarde.

**Entradas.** HU con criterios de aceptación; diseño con campos y microcopy; fuentes; esquemas; reglas de negocio.

**Salida.** `docs/dominio/MODELO_DE_DOMINIO.md` con entidades, campos, invariantes, estados, modelos de lectura y lista de rechazo.

**Procedimiento.** 1. Extraé sustantivos de HU y pantallas sin decidir nada. 2. Elegí un nombre canónico por concepto: inglés en código, español en copy. 3. Por entidad: propósito, PK, escritor y ciclo de vida. 4. Por campo: tipo, nulabilidad, origen, unidad y visibilidad. 5. Cerrá los enums de estado y nombrá cada transición. 6. Definí un modelo de lectura por pantalla y marcá derivados. 7. Armá la lista de rechazo y revisá con diseño. 8. Congelá la versión 1.0.

**Plantilla (esqueleto copiable; versión completa en §5.1).**

```markdown
# Modelo de dominio — {{PRODUCTO}}
## Glosario
| Código | UI | Definición | Sinónimos prohibidos |
## Entidades
### {{Entidad}}
- Propósito / PK / clave natural / escritor / ciclo de vida
- Invariantes: {{...}}
- Estados: {{enum cerrado o "sin estados"}}
## Campos
| Entidad.campo | Tipo | Nulo | Origen | Unidad | Visible en |
## Derivados
| Campo | Fórmula | Insumos | Dónde se calcula |
## Lista de rechazo
| Dato que la UI sugiere | Por qué no existe | Alternativa |
## Abiertas
| ID | Pregunta | Dueño | Fecha | Default |
```

**Gate.**
- [ ] Cada dato visible tiene campo o fórmula.
- [ ] Cada entidad tiene PK y un único escritor.
- [ ] Ningún campo carece de tipo, nulabilidad y origen.
- [ ] No hay dos nombres para el mismo concepto.
- [ ] Los estados son enums cerrados con transiciones nombradas.
- [ ] La lista de rechazo está firmada por diseño.

**Errores típicos.** Una entidad por pantalla. Booleanos que esconden estados (`is_down`, `official`). Timestamps sin zona. Dinero en coma flotante sin política. Campos "para después" sin usecase.

**Esfuerzo y quién.** 0,5–2 días. Alguien con conocimiento del negocio; producto valida y diseño revisa.

**Encargo a un agente.**

```text
Leé estas HU y este sistema de diseño. Extraé sustantivos y proponé entidades,
campos con tipo/nulabilidad/origen y una lista de rechazo para lo que la UI
muestra pero la fuente no tiene. No inventes campos. Entregá solo el Markdown
de la plantilla, sin código.
```

### 3.2 Etapa 2 — ADRs

**Pregunta y fallo que evita.** ¿Qué decisiones tomamos, por qué, y cuáles son contratos? Evita lo implícito: cada feature inventa su manejo de errores, su caché o su DI, y una librería aparece en el code review.

**Entradas.** Modelo de dominio; RNF; restricciones de diseño; equipo; despliegue; scaffold.

**Salida.** `docs/adr/ADR-0001-<slug>.md`, el índice `docs/adr/README.md` y `docs/adr/DECISIONES_ABIERTAS.md`.

**Procedimiento.** 1. Listá los puntos de decisión: repo, estado, DI, persistencia, red, errores, auth, tests, observabilidad, release, i18n. 2. Clasificalos en irreversibles, costosos y baratos. 3. Un ADR por irreversible o costoso; los baratos caben en un ADR de defaults. 4. Escribí contexto, decisión, alternativas con al menos una rechazada, consecuencias y estado. 5. Fijá la sección Contrato: nombres, formatos y artefactos que obliga. 6. Mové lo no resuelto a abiertas con dueño, fecha y default. 7. Indexá sin reutilizar números.

**Plantilla (esqueleto copiable; versión completa en §5.2).**

```markdown
# ADR-{{NNNN}} · {{Título en imperativo}}
- Estado: {{propuesto/aceptado/reemplazado/deprecado}}
- Fecha / Decisores / Contratos afectados / Reemplaza a
## Contexto
## Decisión
## Alternativas consideradas
| Alternativa | Por qué se rechazó |
## Consecuencias
- Positivas / Negativas / Riesgos / Cuándo revisar
## Contrato
## Decisiones abiertas derivadas
| ID | Pregunta | Dueño | Fecha | Default |
```

**Gate.**
- [ ] Toda preocupación transversal tiene ADR o está abierta con dueño y fecha.
- [ ] Cada ADR tiene al menos una alternativa rechazada.
- [ ] Cada contrato nombra los artefactos que obliga.
- [ ] Ningún ADR invoca "buena práctica" sin consecuencia concreta.
- [ ] El estado es uno de los cuatro admitidos.
- [ ] La cadena de reemplazo está enlazada en ambos sentidos.

**Errores típicos.** ADR como novela. ADR retroactivo. ADR sin alternativas. "Clean Architecture" es una etiqueta, no una decisión. Contrato y preferencia no se mezclan.

**Esfuerzo y quién.** 0,5–1 día para cinco a ocho ADRs. Los escribe el tech lead aunque esté solo.

**Encargo a un agente.**

```text
A partir del modelo de dominio y los RNF, listá los puntos de decisión.
Redactá un ADR por cada decisión irreversible o costosa, con al menos una
alternativa rechazada. Separá contratos de decisiones abiertas. No propongas
APIs ni versiones: describí capacidades y consecuencias.
```

### 3.3 Etapa 3 — Mapa de features

**Pregunta y fallo que evita.** ¿Cómo se corta el dominio en módulos y en qué orden? Evita el corte horizontal y la feature con forma de pantalla: doce pantallas convertidas en doce features clonan `Rate` y nadie sabe dónde vive un usecase.

**Entradas.** Dominio; HU; pantallas y rutas; ADRs de estructura; equipo; plan de release.

**Salida.** `docs/features/MAPA_DE_FEATURES.md` con capacidades, módulos, contratos entre módulos, kernel, orden de construcción y fuera de alcance.

**Procedimiento.** 1. Definí capacidades como resultados observables, no pantallas. 2. Definí módulos como slices verticales con nombre de sustantivo (`rates`, `calculator`), nunca de capa. 3. Asigná un módulo dueño por entidad; lo compartido e inmutable va al kernel. 4. Asigná usecases verbo + entidad y pantallas; una pantalla puede consumir varios módulos solo por usecases. 5. Fijá dependencias: presentación → aplicación → dominio ← datos. 6. Mantené chico el kernel: tema, formato, errores, router, DI, red. 7. Ordená por riesgo: bootstrap, lectura, escritura, transversal, secundario. 8. Nombrá el change de cada slice.

**Plantilla (esqueleto copiable; versión completa en §5.3).**

```markdown
# Mapa de features — {{PRODUCTO}}
## Capacidades
| ID | Capacidad | Resultado observable | HU | Prioridad |
## Módulos
| ID | Módulo | Contexto | Entidades | Usecases | Pantallas | Depende de |
## Contratos entre módulos
| Desde | Hacia | Qué se expone | Prohibido |
## Kernel compartido
| Elemento | Dueño | Por qué es compartido |
## Orden de construcción
| # | Etapa | Módulo | Change | Riesgo que retira |
## Fuera de alcance
| Elemento | Razón | Fase |
```

**Gate.**
- [ ] Cada HU tiene una feature principal y sus secundarias declaradas.
- [ ] Cada entidad tiene un solo módulo dueño.
- [ ] Cada usecase pertenece a un módulo y se llama verbo + entidad.
- [ ] Ningún módulo importa datos o presentación de otro.
- [ ] Cada pantalla está asignada y cada feature mapea a un change.
- [ ] El orden de construcción no tiene ciclos.

**Errores típicos.** Módulo `utils` o `common` como basurero. Feature por pantalla. Entidad compartida por tres módulos. Usecase `manageRates`. Orden por UI. Se ven en el grafo de imports.

**Esfuerzo y quién.** 0,5 día. Tech lead y producto; en solitario, dos horas.

**Encargo a un agente.**

```text
Con este dominio, estas HU y estas pantallas, proponé módulos verticales con
entidades, usecases y pantallas asignadas. Prohibí módulos por capa y nombres
genéricos. Marcá dependencias, orden de construcción y lo que no mapea.
```

### 3.4 Etapa 4 — OpenSpec

**Pregunta y fallo que evita.** ¿Cuál es la unidad de trabajo verificable? Evita el ticket infinito: "implementar calculadora" sin condición de terminado, criterios en el chat, decisiones tomadas mientras se codea y un PR que nadie puede revisar.

**Entradas.** Mapa; dominio; ADRs; diseño; configuración de OpenSpec; estrategia de tests.

**Salida.** `openspec/changes/<change-id>/` con `proposal.md`, `specs/<capability>/spec.md`, `design.md` y `tasks.md`. El id es kebab-case y empieza con verbo: `add-`, `fix-`, `remove-`.

**Procedimiento.** 1. Elegí un resultado observable; si necesitás dos, partí el change. 2. Proposal: por qué, qué cambia, non-goals, capacidades, impacto, riesgos y rollout. 3. Delta spec en EARS, con ID y al menos un escenario por requirement. 4. Design con contratos —tipos, firmas, flujo, errores, caché, rutas y DI— sin cuerpos. 5. Tareas de máximo dos horas, con requirement y verificación. 6. Validá que no haya huérfanos entre requirements, tareas y tests. 7. Si la spec cambia, actualizá primero el artefacto. 8. Aplicá, marcá tareas, ejecutá tests y archivá.

**EARS.** Fuerza a escribir condición + sujeto + comportamiento observable. Los patrones son cinco: ubicuo ("El sistema debe…"), por evento ("Cuando…"), por estado ("Mientras…"), no deseado ("Si… entonces…") y opcional ("Donde…"). Correcto: "Si la consulta de red falla, el sistema debe mostrar la última tasa cacheada y marcar el estado como `sinConexion`." Incorrecto: "La calculadora debe ser rápida, simple y confiable": sin condición, comportamiento observable ni umbral, no se puede testear.

**Plantilla (esqueleto copiable; juego completo en §5.4).**

```markdown
# Delta spec — {{capability}}
## ADDED Requirements
### R-01 · {{Título}}
Cuando {{condición}}, el sistema debe {{comportamiento observable}}.
#### Scenario: {{nombre}}
- Given {{...}}
- When {{...}}
- Then {{...}}
## MODIFIED Requirements
## REMOVED Requirements
```

**Gate.**
- [ ] El proposal tiene non-goals.
- [ ] Cada requirement tiene ID, patrón EARS y al menos un escenario.
- [ ] Cada escenario tiene resultado observable y umbral cuando aplica.
- [ ] Cada requirement mapea a una tarea y un test.
- [ ] Cada tarea dura dos horas o menos y referencia un requirement.
- [ ] El design usa nombres del glosario y no contiene cuerpos.

**Errores típicos.** Spec en prosa. Requirements sin ID. Design con código. Tareas por capa. Criterios que solo el autor verifica. Change que mezcla refactor y feature. Si no podés escribir el test desde el escenario, está mal.

**Esfuerzo y quién.** 1–3 horas por change con el dominio claro; 30 minutos si es chico. Escribe una persona, revisa el equipo.

**Encargo a un agente.**

```text
Convertí esta feature en un change de OpenSpec. Escribí proposal con non-goals,
spec EARS con IDs y escenarios, design con contratos Dart sin cuerpos, y tasks
de máximo dos horas con verificación. Si algo no mapea al dominio, no lo
inventes: listalo como decisión abierta.
```

### 3.5 Etapa 5 — Bootstrap y código

**Pregunta y fallo que evita.** ¿Cómo se construye sin descubrir el cableado al final? Evita el scaffold a medio adaptar: marca de la plantilla en producción, DI faltante, router que falla fuera de la demo y una primera feature que tarda días por la plomería.

**Entradas.** ADRs; mapa; scaffold; tokens y assets; entornos y secretos; primer change.

**Salida.** Repo con tema aplicado, router, DI, contrato de errores, un slice descartable probado y borrado, y el primer change aplicado. El CI verde se cierra en la etapa 6; acá solo se exige que los comandos corran en local.

**Procedimiento.** 1. Creá la estructura del ADR de monorepo y sumá `docs/`, `design/` y `openspec/`. 2. Aplicá el scaffold sin personalizar; en greenfield, `flutter create` y nada más. 3. Sustituí variables en un solo commit. 4. Reemplazá marca y dominio: tema, fuentes, splash, copy legal, rutas, DI y errores. 5. Borrá ejemplos, demo, assets, tests placeholder y deploy ajeno. 6. Corré formato, análisis, tests, build y ejecución. 7. Construí y verificá el slice descartable en un entorno real. 8. Borralo en el mismo PR, conservá el smoke test de DI y router y aplicá el primer change.

**Tabla de adaptación del scaffold.**

| Categoría | Elemento | Acción | Verificación |
|---|---|---|---|
| Variables | `{{PROJECT_NAME}}`, `{{PACKAGE_ID}}`, `{{ORG}}`, `{{API_URL}}`, `{{SUPABASE_URL}}` | Sustituir en un commit | `grep` de `{{` = 0; ids correctos |
| Marca | nombre, icono, splash, fuentes, tema | Reemplazar por el diseño | Diff visual; sin hex sueltos |
| Dominio | rutas, DI, errores, semilla | Reemplazar por el mapa | Smoke test; clon limpio arranca |
| Persistencia | motor del scaffold (Isar, Drift, Hive) | Quitar si el ADR eligió otro | Sin dependencias del motor descartado |
| Borrado | ejemplos, demo, assets, CI ajeno | Borrar | No queda `example`, `demo` ni `sample` |

**Variante greenfield.** Si el proyecto no parte de un scaffold, la tabla se reduce a las filas de Variables, Marca y Dominio: no hay nada que borrar. El slice descartable y el smoke test siguen siendo obligatorios; son la única prueba de que el cableado existe antes de la primera feature. Cambiami es este caso.

**Slice descartable.** Prueba de cableado, no feature. Recorre entidad → datasource → repositorio → usecase → cubit → pantalla → ruta → DI, con un test por capa. Se borra en el mismo PR; sobrevive el smoke test de DI y router. Si llega al primer change real, es deuda.

**Plantilla (esqueleto copiable; checklist completa en §5.5).**

```markdown
# Bootstrap — {{PRODUCTO}}
## Variables
| Variable | Valor | Archivos | Verificación |
## Marca y dominio
- [ ] Nombre, package id, bundle id
- [ ] Icono, splash, fuentes, tema
- [ ] Copy legal y de tienda
- [ ] Rutas iniciales y DI
## Borrado
- [ ] Feature de ejemplo / pantallas demo / assets / tests / CI ajeno
## Verificación
- [ ] Formato / análisis / tests / build / ejecución
- [ ] grep de tokens de plantilla = 0
- [ ] Slice probado y borrado
- [ ] Smoke test de DI y router permanece
## Firma
{{Nombre}} · {{Fecha}}
```

**Gate.**
- [ ] El build, el análisis y el lint pasan.
- [ ] Los tests pasan y el slice tiene un test por capa.
- [ ] No quedan tokens, nombres, assets ni pantallas de la plantilla.
- [ ] El app id y el bundle id son los definitivos.
- [ ] Ruta, DI y estado de error funcionan en un entorno real.
- [ ] El slice está borrado y el smoke test permanece.
- [ ] El checklist está firmado.

**Errores típicos.** Personalizar antes de sustituir. Conservar el ejemplo "porque sirve". Borrar tests para llegar a verde. Secretos en el repo. Saltear el slice.

**Esfuerzo y quién.** 1–3 días; medio día si el scaffold está maduro. Después, cada change repite la etapa 4.

**Encargo a un agente.**

```text
Aplicá este scaffold y sustituí solo las variables listadas. Reemplazá marca y
dominio, borrá ejemplos. Creá un slice descartable que toque todas las capas,
verificá build/test/run y borralo en el mismo PR dejando un smoke test de DI y
router. No agregues features.
```

### 3.6 Etapa 6 — Guardrails

**Pregunta y fallo que evita.** ¿Qué impide que el gate se degrade cuando el repo crece, el contexto se pierde o entra otra persona? Evita el verde de mentira: tests que solo corren en la máquina del autor, análisis que se saltea con `--no-verify`, un CI que nadie mira porque tarda cuarenta minutos, secretos pegados en un workflow y un `main` que se rompe un viernes. Las etapas 1–5 definen qué es correcto; la 6 hace que lo incorrecto no pueda entrar.

**Entradas.** ADRs de estructura, test y release; mapa; changes; repo con el primer change aplicado; versiones reales del toolchain; decisiones abiertas de tooling.

**Salida.** Cuatro capas ejecutables —hooks, comandos, CI y contrato escrito— más una bitácora. En concreto: `.githooks/`, `Makefile` con `check` y `check-all`, `.github/workflows/ci.yml`, plantilla de PR, `AGENTS.md`, `docs/BITACORA.md` y Dependabot. Todo versionado y reproducible desde un clon limpio.

**Procedimiento.**
1. Inventariá lo que ya existe: comandos reales, versiones, targets del `Makefile`, workflows, hooks, lints y tests. Nada se documenta antes de correrlo.
2. Fijá un solo comando de verdad: `make check`. Si un gate no cabe en un comando, no es un gate.
3. Escribí el hook `commit-msg` y activalo con `git config core.hooksPath .githooks`. El hook valida formato, no contenido; el contenido lo valida el PR.
4. Armá el CI con el mismo comando, `permissions: contents: read` y sin secretos. Si el CI necesita un secreto para pasar, el gate está mal diseñado.
5. Separá lo barato de lo caro: formato, análisis y tests en cada PR; base de datos, build de release y cobertura en `main` o por etiqueta.
6. Versioná acciones por tag al principio y por SHA antes del primer deploy. Fijá Dependabot para que el pin no envejezca.
7. Escribí `AGENTS.md` con los comandos, los invariantes y lo prohibido. Es el contrato que leen los agentes y el recordatorio que lee tu yo de dentro de tres meses.
8. Abrí un PR de prueba que rompa a propósito una regla por capa y confirmá que cada capa lo detiene. Si el PR pasa, la capa no existe.
9. Cerrá con la bitácora: qué se ejecutó, qué se desvió y qué quedó abierto. Sin bitácora, la etapa 6 se re-discute en cada change.

**Las cuatro capas.**

| Capa | Dónde vive | Qué detiene | Qué no detiene |
|---|---|---|---|
| Hook local | `.githooks/commit-msg` | Mensaje fuera de convención | Nada que requiera red o toolchain completo |
| Comando | `Makefile` (`check`, `check-all`) | Deriva entre lo que corre el autor y lo que corre el CI | Que alguien lo ejecute |
| CI | `.github/workflows/ci.yml` | Merge de un PR rojo; regresión en `main` | Un `main` protegido solo por disciplina |
| Contrato | `AGENTS.md`, plantilla de PR, ADR de tooling | Ambigüedad sobre qué comando usar y qué está prohibido | Que se lea; por eso los otros tres existen |

**Decisiones típicas y su default.**

| Decisión | Default recomendado | Alternativa rechazada | Cuándo revisar |
|---|---|---|---|
| Validación de mensajes | Hook propio en shell | commitlint + husky | Si entran varias personas y piden reglas por scope |
| Acciones de CI | Tag ahora, SHA antes del deploy | SHA desde el día uno | Antes del primer workflow con secretos |
| Cobertura | Artefacto publicado, umbral después del kernel | Umbral 80% desde el inicio | Cuando el kernel tenga tests estables |
| Versión del SDK | La del `pubspec.yaml`, sin `.fvmrc` | FVM obligatorio | Si aparece una segunda máquina con otra versión |
| Flavors | Después del package id definitivo | Antes de la primera feature | Al cerrar la decisión de package id |
| CD | Ninguno; deploy manual documentado | Deploy automático a Supabase | Cuando haya entorno de staging |
| Base de datos en CI | `make db-check` (`supabase start` + `db reset` + `test db`) | Solo tests de cliente | Si el CI tarda más de diez minutos |

**Plantilla (esqueleto copiable; versión completa en §5.6).**

```markdown
# Guardrails — {{PRODUCTO}}
## Inventario
| Elemento | Existe | Comando | Versión |
## Comandos
| Comando | Qué corre | Tiempo | Dónde se usa |
## Hooks
| Hook | Regla | Cómo se activa | Cómo se saltea (y por qué no) |
## CI
| Workflow | Disparador | Jobs | Permisos | Secretos |
## Contrato
- [ ] AGENTS.md con comandos e invariantes
- [ ] Plantilla de PR
- [ ] ADR de tooling
## Prueba de fuego
| Capa | PR que la viola | Resultado esperado | Resultado real |
## Firma
{{Nombre}} · {{Fecha}}
```

**Gate.**
- [ ] `make check` corre en un clon limpio sin pasos manuales.
- [ ] El CI ejecuta exactamente ese comando, no una copia.
- [ ] El hook rechaza un mensaje inválido y acepta uno válido.
- [ ] Un PR con formato roto, otro con un warning de análisis y otro con un test fallido se detienen cada uno en su capa.
- [ ] El CI no requiere secretos para pasar.
- [ ] Las acciones están fijadas y Dependabot las actualiza.
- [ ] `AGENTS.md` lista comandos reales, no aspiracionales.
- [ ] La bitácora registra la fecha y el resultado de la prueba de fuego.

**Errores típicos.** CI que duplica el `Makefile` con comandos distintos. Hook que se saltea con `--no-verify` como norma. Umbral de cobertura antes de tener kernel. Workflow con `write-all`. Dependabot sin agrupar: veinte PRs por semana y nadie los mira. `AGENTS.md` que describe un stack que no está instalado. Guardrails agregados después de la feature tres, cuando ya hay deuda que nadie quiere frenar.

**Esfuerzo y quién.** 0,5–1 día. Lo hace quien mantiene el repo; en solitario, una tarde. Se revisa cuando cambia el toolchain, no en cada change.

**Encargo a un agente.**

```text
Inventariá los comandos reales del repo y las versiones instaladas. Proponé un
Makefile con check y check-all, un hook commit-msg, un workflow de CI que use
esos comandos sin secretos, AGENTS.md y una bitácora. No inventes targets que no
existan: si algo falta, listalo como decisión abierta. Después abrí un PR de
prueba que viole una regla por capa y mostrame qué capa lo detuvo.
```

## 4. Matriz de trazabilidad

| HU | Feature | Módulo | Entidad/tabla | Usecase | Pantalla | Change/tarea | Test |
|---|---|---|---|---|---|---|---|
| HU-02 | F-01, F-04 | `calculator` | `rates_latest` (lectura) | `ConvertAmount` | 02 | `feature-calculator` / T-04 | `convert_test.dart` |
| HU-04 | F-03 | `calculator` + `rates` | `shared_preferences` (`cambiami.rates.v1`) | `GetCachedRates` | 02, 03, 04 | `feature-rates` / T-05 | `offline_test.dart` |
| HU-08 | F-12 | `settings` | Ninguna (copy en ARB) | — (página estática) | 08 | `feature-settings` / T-03 | `legal_copy_test.dart` |

**Cómo se mantiene viva.** Los IDs no se renombran. La matriz se actualiza en el mismo PR que cambia una celda; un change con requirements sin fila deja el PR incompleto. Una revisión semanal busca celdas vacías y filas huérfanas.

**Cuando algo no mapea.**
- HU sin feature: el corte de la etapa 3 está mal.
- Feature sin entidad: falta dominio o es alcance inventado.
- Entidad sin pantalla ni usecase: es interna o está muerta.
- Usecase sin test: falta una tarea en la etapa 4.
- Pantalla sin HU: falta una HU o hay deuda de diseño.
- Tarea sin requirement: es alcance nuevo; se rechaza o se convierte en change.

Regla: ninguna celda vacía. `N/A` se permite solo con una razón escrita. Una fila con dos dueños se parte.

## 5. Plantillas completas y copiables

### 5.1 Modelo de dominio

```markdown
# Modelo de dominio — {{PRODUCTO}}
Versión: {{X.Y}} · Fecha: {{AAAA-MM-DD}} · Autor: {{NOMBRE}} · Revisores: {{...}}

## 1. Glosario
| Término canónico (código) | Término UI (es) | Definición | Sinónimos prohibidos |
|---|---|---|---|
| {{entity}} | {{...}} | {{...}} | {{...}} |

## 2. Entidades
### {{Entidad}}
- Propósito: {{...}}
- PK: {{...}}
- Clave natural: {{...}}
- Escritor: {{quién o proceso}}
- Ciclo de vida: {{...}}
- Invariantes:
  - {{...}}
- Estados: {{enum cerrado o "sin estados"}}

## 3. Diccionario de campos
| Entidad.campo | Tipo | Nulo | Origen | Unidad | Ejemplo | Visible en |
|---|---|---|---|---|---|---|
| {{...}} | {{...}} | {{sí/no}} | {{fuente/derivado/usuario}} | {{...}} | {{...}} | {{SCR-XX}} |

## 4. Reglas y derivaciones
| Campo derivado | Fórmula | Insumos | Dónde se calcula |
|---|---|---|---|
| {{...}} | {{...}} | {{...}} | {{cliente/servidor/vista}} |

## 5. Modelos de lectura por pantalla
| Pantalla | Entidades | Campos | Derivados | Notas |
|---|---|---|---|---|
| {{SCR-XX}} | {{...}} | {{...}} | {{...}} | {{...}} |

## 6. Lista de rechazo
| Dato que la UI sugiere | Por qué no existe | Alternativa |
|---|---|---|
| {{...}} | {{...}} | {{...}} |

## 7. Decisiones de dominio abiertas
| ID | Pregunta | Dueño | Fecha límite | Default |
|---|---|---|---|---|
| D-{{NN}} | {{...}} | {{...}} | {{...}} | {{...}} |
```

### 5.2 ADR

```markdown
# ADR-{{NNNN}} · {{Título en imperativo}}
- Estado: {{propuesto/aceptado/reemplazado/deprecado}}
- Fecha: {{AAAA-MM-DD}}
- Decisores: {{...}}
- Contratos afectados: {{...}}
- Reemplaza a: {{ADR-... / ninguno}}

## Contexto
{{Fuerzas, restricciones y qué falla si no se decide.}}

## Decisión
{{Una frase normativa: "Usamos X para Y".}}

## Alternativas consideradas
| Alternativa | Por qué se rechazó |
|---|---|
| {{...}} | {{...}} |

## Consecuencias
- Positivas: {{...}}
- Negativas: {{...}}
- Riesgos: {{...}}
- Cuándo revisar: {{trigger medible}}

## Contrato
{{Qué nombres, formatos, rutas o tipos quedan fijados y qué artefactos deben
obedecerlos. Si no hay contrato, escribir "Ninguno".}}

## Decisiones abiertas derivadas
| ID | Pregunta | Dueño | Fecha | Default |
|---|---|---|---|---|
| {{...}} | {{...}} | {{...}} | {{...}} | {{...}} |
```

### 5.3 Mapa de features

```markdown
# Mapa de features — {{PRODUCTO}}
Versión: {{...}} · Autor: {{...}}

## 1. Capacidades de producto
| ID | Capacidad | Resultado observable | HU | Prioridad |
|---|---|---|---|---|
| F-{{NN}} | {{...}} | {{...}} | {{HU-...}} | {{MVP/Fase 2}} |

## 2. Módulos de código
| ID | Módulo | Contexto | Entidades propias | Usecases | Pantallas | Depende de |
|---|---|---|---|---|---|---|
| MOD-{{...}} | {{...}} | {{...}} | {{...}} | {{...}} | {{...}} | {{kernel / MOD-...}} |

## 3. Contratos entre módulos
| Desde | Hacia | Qué se expone | Prohibido |
|---|---|---|---|
| {{...}} | {{...}} | {{...}} | {{...}} |

## 4. Kernel compartido
| Elemento | Dueño | Por qué es compartido |
|---|---|---|
| {{tema, formateador, errores, router, DI}} | {{kernel}} | {{...}} |

## 5. Orden de construcción
| # | Etapa | Módulo | Change | Riesgo que retira |
|---|---|---|---|---|
| 1 | Bootstrap | {{kernel}} | {{...}} | {{...}} |

## 6. Fuera de alcance
| Elemento | Razón | Fase |
|---|---|---|
| {{...}} | {{...}} | {{...}} |
```

### 5.4 Change de OpenSpec

**`proposal.md`**

```markdown
# Change: {{add-...}}

## Why
{{Problema de usuario o técnico. Una frase.}}

## What changes
- {{...}}
- {{...}}

## Non-goals
- {{...}}

## Affected capabilities
| Capability | Tipo | Spec |
|---|---|---|
| {{...}} | {{nueva/modificada}} | `specs/{{...}}/spec.md` |

## Impact
- Módulos: {{...}}
- Entidades/tablas: {{...}}
- Pantallas/rutas: {{...}}
- ADRs: {{...}}

## Riesgos y mitigación
| Riesgo | Mitigación |
|---|---|
| {{...}} | {{...}} |

## Rollout
{{...}}
```

**`specs/<capability>/spec.md`**

```markdown
# Delta spec — {{capability}}

## ADDED Requirements

### R-01 · {{Título}}
Cuando {{condición}}, el sistema debe {{comportamiento observable}}.

#### Scenario: {{nombre}}
- Given {{...}}
- When {{...}}
- Then {{...}}
- And {{...}}

### R-02 · {{Título}}
Si {{condición no deseada}}, entonces el sistema debe {{comportamiento}}.

#### Scenario: {{nombre}}
- Given {{...}}
- When {{...}}
- Then {{...}}

## MODIFIED Requirements

### R-{{...}} · {{Título}}
{{Nuevo texto completo del requirement.}}

## REMOVED Requirements

### R-{{...}} · {{Título}}
{{Motivo del retiro.}}
```

**`design.md`**

````markdown
# Design — {{change}}

## 1. Flujo
{{Diagrama ASCII o lista de pasos.}}

## 2. Contratos

### 2.1 Tipos de dominio
```dart
{{sealed class / class con campos, sin cuerpos}}
```

### 2.2 Puertos
```dart
abstract interface class {{XRepository}} {
  {{Future<...> {{método}}({{...}});}}
}
```

### 2.3 Errores
| Condición | Error de dominio | Código | Retry | UI |
|---|---|---|---|---|
| {{...}} | {{...}} | {{...}} | {{sí/no}} | {{...}} |

### 2.4 Rutas y DI
| Ruta | Pantalla | Registro |
|---|---|---|
| {{/...}} | {{...}} | {{...}} |

## 3. Persistencia y caché
| Dato | Dónde | Frescura | Invalidación |
|---|---|---|---|
| {{...}} | {{...}} | {{...}} | {{...}} |

## 4. Decisiones locales
| ID | Decisión | Alternativa | Motivo |
|---|---|---|---|
| {{...}} | {{...}} | {{...}} | {{...}} |

## 5. Trazabilidad
| Requirement | Test | Tarea |
|---|---|---|
| R-01 | {{...}} | T-01 |
````

**`tasks.md`**

```markdown
# Tasks — {{change}}

## 1. Contratos y andamiaje
- [ ] T-01 · {{...}} · R-{{...}} · Verificación: {{comando o check}}

## 2. Dominio y datos
- [ ] T-02 · {{...}} · R-{{...}} · Verificación: {{...}}

## 3. Presentación
- [ ] T-03 · {{...}} · R-{{...}} · Verificación: {{...}}

## 4. Verificación
- [ ] T-04 · Ejecutar {{...}} y adjuntar salida
```

### 5.5 Checklist de bootstrap

```markdown
# Bootstrap — {{PRODUCTO}}

## Variables
| Variable | Valor | Archivo(s) | Verificación |
|---|---|---|---|
| {{PROJECT_NAME}} | {{...}} | {{...}} | `grep` = 0 |
| {{PACKAGE_ID}} | {{...}} | {{...}} | App instalada con el id correcto |
| {{ORG}} | {{...}} | {{...}} | {{...}} |
| {{API_URL}} | {{...}} | {{...}} | Llamada de prueba responde |
| {{DEEP_LINK}} | {{...}} | {{...}} | Enlace abre la pantalla correcta |
| {{SUPABASE_URL}} | {{...}} | {{...}} | {{...}} |
| {{ANON_KEY}} | {{...}} | {{...}} | Solo permisos de lectura |

## Marca y dominio
- [ ] Nombre visible y copy de tienda
- [ ] Icono, splash, fuentes y tema
- [ ] Copy legal y de privacidad
- [ ] Rutas iniciales
- [ ] Registro de DI
- [ ] Tipos de error del contrato

## Borrado
- [ ] Feature de ejemplo
- [ ] Pantallas demo
- [ ] Assets de plantilla
- [ ] Tests de ejemplo
- [ ] Configuración de deploy de la plantilla
- [ ] Claves de analítica o crash reporting ajenas
- [ ] Motor de persistencia descartado por el ADR

## Verificación
- [ ] Formato
- [ ] Análisis o lint
- [ ] Tests
- [ ] Build
- [ ] Ejecución en dispositivo o navegador
- [ ] `grep` de tokens de plantilla = 0
- [ ] Slice descartable probado
- [ ] Slice descartable borrado
- [ ] Smoke test de DI y router permanece

## Firma
{{Nombre}} · {{Fecha}}
```

### 5.6 Guardrails

Los archivos de esta plantilla se copian tal cual y se ajustan solo las rutas y versiones. El objetivo es que un clon limpio pase `make check` sin leer nada más.

**`Makefile` (raíz)**

```makefile
SHELL := /bin/bash
.DEFAULT_GOAL := help
MOBILE := apps/mobile

.PHONY: help pub-get check check-all format analyze test coverage commitlint db-start db-reset db-test db-check

help: ## Lista los targets disponibles
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "%-12s %s\n", $$1, $$2}'

check: pub-get format analyze test ## Gate de PR

check-all: check db-check ## Gate completo, incluye base de datos

pub-get: ## Resuelve dependencias
	cd $(MOBILE) && flutter pub get

format: ## Verifica formato sin escribir
	cd $(MOBILE) && dart format --output=none --set-exit-if-changed lib test

analyze: ## Análisis estricto
	cd $(MOBILE) && flutter analyze --fatal-warnings --fatal-infos

test: ## Tests con cobertura
	cd $(MOBILE) && flutter test --coverage

coverage: test ## Cobertura lcov + HTML local
	genhtml $(MOBILE)/coverage/lcov.info -o $(MOBILE)/coverage/html

commitlint: ## Valida el mensaje del último commit
	@git log -1 --pretty=%s | grep -qE \
		'^(feat|fix|refactor|test|docs|chore|ci|build|perf|revert)(\([a-z0-9-]+\))?: [a-záéíóúñ]' \
		|| { echo "commitlint: mensaje inválido"; exit 1; }

db-start: ## Levanta Supabase local
	supabase start

db-reset: ## Reaplica migraciones y semilla
	supabase db reset

db-test: ## Tests de base de datos
	supabase test db

db-check: db-start db-reset db-test ## Gate de base de datos desde cero
```

**`.githooks/commit-msg`**

```bash
#!/usr/bin/env bash
set -euo pipefail

first_line="$(head -n 1 "$1")"
pattern='^(feat|fix|refactor|test|docs|chore|ci|build|perf|revert)(\([a-z0-9-]+\))?: [a-záéíóúñ]'

if [[ ! "$first_line" =~ $pattern ]]; then
  echo "commit-msg: mensaje inválido" >&2
  echo "  formato: tipo(scope): descripción en imperativo" >&2
  echo "  tipos: feat fix refactor test docs chore ci build perf revert" >&2
  exit 1
fi

if (( ${#first_line} > 100 )); then
  echo "commit-msg: la primera línea supera 100 caracteres" >&2
  exit 1
fi
```

Activación, una vez por clon:

```bash
chmod +x .githooks/commit-msg
git config core.hooksPath .githooks
```

El hook valida forma, no contenido: un mensaje correcto puede describir un cambio malo. Eso lo detiene el PR.

**`.github/workflows/ci.yml`**

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  mobile:
    name: Mobile
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.50.0
          channel: stable
          cache: true
      - run: make check
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage
          path: apps/mobile/coverage/lcov.info
          if-no-files-found: ignore

  database:
    name: Database
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: supabase/setup-cli@v1
        with:
          version: latest
      - run: make db-check
```

Notas que evitan dos horas de debugging:

- `flutter-version` debe ser la misma que declara `pubspec.yaml`; si no, el CI resuelve otra y falla por una dependencia que en local existe.
- El job `database` no usa secretos: `supabase start` levanta el stack local con claves de desarrollo. Si un job necesita un secreto para pasar, el gate está mal.
- Las acciones van por tag ahora. Antes del primer workflow que use secretos, se fijan por SHA (`pinact run` o a mano) y Dependabot mantiene el pin.
- El build de APK no va en cada PR: va en `main` o por `workflow_dispatch`, porque agrega minutos sin agregar señal.

**`.github/dependabot.yml`**

```yaml
version: 2
updates:
  - package-ecosystem: pub
    directory: /apps/mobile
    schedule:
      interval: weekly
    groups:
      dart:
        patterns: ["*"]
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    groups:
      actions:
        patterns: ["*"]
```

**`AGENTS.md` (raíz)**

```markdown
# AGENTS

## Comandos
| Comando | Qué hace |
|---|---|
| `make check` | Formato, análisis y tests de la app |
| `make check-all` | `check` + tests de base de datos |
| `make coverage` | Cobertura lcov y HTML en `apps/mobile/coverage/` |
| `make db-reset` | Reaplica migraciones y semilla locales |

## Invariantes
- Dinero y tasas nunca en `double` sin política; el formato es es-VE.
- Ningún texto visible fuera de ARB.
- Ningún secreto en el repo; `.env` está ignorado.
- Las migraciones no se editan después de aplicadas: se agrega una nueva.
- Un change de OpenSpec por PR; no se mezcla refactor y feature.

## Prohibido
- `--no-verify` como norma.
- Añadir dependencias sin ADR o decisión abierta.
- Tocar `main` directamente.
- Copiar código de la app de referencia.
```

**`.github/pull_request_template.md`**

```markdown
## Change
`openspec/changes/{{id}}`

## Requirements cubiertos
- [ ] R-01
- [ ] R-02

## Verificación
- [ ] `make check` en local
- [ ] CI verde
- [ ] Tareas marcadas en `tasks.md`
- [ ] Matriz de trazabilidad actualizada (si cambió una celda)

## Riesgos
{{...}}
```

**`docs/BITACORA.md`**

```markdown
# Bitácora

| Fecha | Etapa | Qué se hizo | Comando o artefacto | Resultado | Desvío |
|---|---|---|---|---|---|
| {{AAAA-MM-DD}} | 6 | Hook de mensajes | `.githooks/commit-msg` | Rechaza `update` | Ninguno |
| {{AAAA-MM-DD}} | 6 | CI móvil | `ci.yml` | Verde en 4 min | Flutter 3.50.0 fijado |
```

La bitácora no es un diario: es la lista de lo que se ejecutó y de lo que se desvió. Sirve para que la etapa 6 se revise con evidencia y no con recuerdos.

## 6. Adaptación a otros proyectos

**Sin backend.** El contrato de datos es el esquema del archivo o seed. El ADR de backend pasa a uno de fuente y actualización. Se omite el colector, no los errores ni la frescura.

**Con autenticación.** Sumá el actor, una máquina de sesión, un ADR de tokens y el mapeo de `401`. El change de auth va antes de toda feature con identidad. La matriz gana “actor”.

**Solo web o solo mobile.** En web, rutas y URLs son contrato público, los tokens son variables CSS, y sumás un ADR de renderizado y accesibilidad. En mobile, sumás tienda, permisos, deep links, release y offline, con tema nativo.

**Monorepo o repo único.** Monorepo si hay más de un deployable o contratos compartidos; repo único si hay una app y un pipeline. El ADR fija carpetas y qué se comparte. Si la web llega después, se crea `apps/web` y se revisa el CI, no antes. Compartí contratos documentados, no código entre lenguajes.

**Equipo de una persona.** Fusioná roles, no gates. Los ADRs pueden tener cinco líneas, pero existen. Un change por semana alcanza. “Artefacto antes que código” te defiende de tu propio olvido.

**Versión express de un día.** Fusioná 1 y 2 en un documento con tres ADRs, y 3 y 4 en un change con cinco tareas. No se omiten los nombres canónicos, el ADR de fuente, EARS del flujo crítico, una fila de trazabilidad ni la verificación del bootstrap.

## 7. Anti-patrones y señales de alarma

| # | Anti-patrón | Síntoma | Corrección |
|---|---|---|---|
| 1 | Modelar en la UI | Campos que solo existen en un widget | Diccionario de campos y lista de rechazo |
| 2 | ADR retroactivo | Se escribe después de codear | ADR `propuesto` antes; `aceptado` para habilitar código |
| 3 | Feature = pantalla | Doce features para ocho capacidades; `Rate` duplicado | Cortar por capacidad y módulo vertical |
| 4 | Change infinito | PR de cuarenta archivos; tareas sin marcar | Un resultado observable; tareas de dos horas |
| 5 | Spec en prosa | “Debe ser rápido y confiable” | Condición, comportamiento observable y umbral |
| 6 | Diseño como referencia | Hex sueltos y medidas “parecidas” | Tokens como contrato; desvío con ADR |
| 7 | Scaffold sin borrar | Queda `example`, `demo` o el package id genérico | Checklist de borrado y `grep` de plantilla |
| 8 | Decisiones implícitas | Cada feature inventa su error o su caché | ADR transversales y tipos compartidos |
| 9 | Trazabilidad decorativa | Matriz que nadie actualiza | Actualizar en el mismo PR; revisión semanal |
| 10 | Dominio inventado por IA | Campos plausibles que la fuente no tiene | Columna “origen” y lista de rechazo firmada |
| 11 | Caché sin política | Datos viejos mostrados como frescos | ADR de caché con umbrales y estado explícito |
| 12 | Gate “casi” | “Falta una cosita, pero pasemos” | Binario: un No detiene la etapa |
| 13 | CI decorativo | El workflow existe, está rojo hace dos semanas y se ignora | `main` protegido; el rojo se arregla el mismo día |
| 14 | Gate fuera del repo | “Corré estos cuatro comandos” dictado en el chat | Un solo `make check`, versionado |
| 15 | Hook salteado | `--no-verify` se volvió costumbre | Hook barato; el PR sigue siendo la red |
| 16 | Secreto en CI | Workflow con `service_role` “para probar” | Stack local; secretos solo en deploy manual |
| 17 | Cobertura como meta | 80% con tests que no afirman nada | Cobertura como diagnóstico; umbral después del kernel |
| 18 | Guardrails tardíos | Se agregan en la feature tres, con deuda encima | Etapa 6 antes del segundo change |

## 8. Checklist final de una página

```text
PROYECTO: ____________________   FECHA: __________   RESPONSABLE: __________

[ ] 1. DOMINIO
    [ ] Cada dato visible tiene campo o fórmula
    [ ] Cada entidad tiene PK y escritor único
    [ ] Glosario sin sinónimos
    [ ] Lista de rechazo firmada por diseño
    [ ] Gate firmado

[ ] 2. ADRs
    [ ] Toda decisión transversal tiene ADR o está abierta con dueño
    [ ] Cada ADR tiene una alternativa rechazada
    [ ] Los contratos están identificados
    [ ] Los ADRs están indexados
    [ ] Gate firmado

[ ] 3. MAPA
    [ ] Cada HU tiene una feature principal
    [ ] Cada entidad tiene un módulo dueño
    [ ] Cada pantalla está asignada
    [ ] El orden no tiene ciclos
    [ ] Gate firmado

[ ] 4. OPENSPEC
    [ ] Proposal con non-goals
    [ ] Requirements EARS con ID y escenario
    [ ] Design con contratos, sin cuerpos
    [ ] Tareas de dos horas con verificación
    [ ] Toda requirement tiene tarea y test
    [ ] Validador pasa
    [ ] Gate firmado

[ ] 5. BOOTSTRAP
    [ ] Variables sustituidas; grep = 0
    [ ] Marca y dominio reemplazados
    [ ] Ejemplos y assets demo borrados
    [ ] Formato, análisis, tests y build verdes
    [ ] Slice descartable probado y borrado
    [ ] Smoke test de DI y router permanece
    [ ] Gate firmado

[ ] 6. GUARDRAILS
    [ ] `make check` corre en un clon limpio
    [ ] El CI usa ese mismo comando
    [ ] El hook rechaza un mensaje inválido
    [ ] Un PR roto se detiene en cada capa
    [ ] El CI no requiere secretos
    [ ] Acciones fijadas y Dependabot configurado
    [ ] AGENTS.md con comandos reales
    [ ] Bitácora con la prueba de fuego
    [ ] Gate firmado

REGLA: si una casilla queda sin marcar, no se pasa a la etapa siguiente.
```

## 9. Ejemplo trabajado: Cambiami

### 9.1 Artefactos

**Dominio.**

| Objeto | Tipo | Campos clave | Nota |
|---|---|---|---|
| `currencies` | tabla | `code` (PK), `name`, `symbol`, `decimals`, `kind`, `is_active`, `created_at` | USD, EUR, USDT; `kind` es `fiat` o `stablecoin` |
| `sources` | tabla | `code` (PK), `name`, `url`, `kind`, `is_active` | `bcv` es `oficial`; `binance_p2p` es `p2p` |
| `rate_snapshots` | tabla | `id`, `currency_code`, `source_code`, `type`, `rate_value`, `effective_from`, `published_at`, `fetched_at`, `change_pct` | Append-only; único por moneda, tipo y vigencia |
| `collector_runs` | tabla | `id`, `source_code`, `started_at`, `finished_at`, `status`, `rows_written`, `error_message` | No la lee la app |
| `rates_latest` | vista | Una fila por `currency_code` + `type`, con `official`, fuente y fechas | `security_invoker = true`; única lectura de la app |

No existen `countries`, `status`, `is_down` ni `official` como columna, tampoco `principal` ni `country_code`. `official` sale de `sources.kind` en la vista, `is_down` del signo de `change_pct`, y estado y edad se calculan en el cliente: la vista no expone `age_minutes`.

**ADRs.**

| ADR | Decisión | Alternativa rechazada | Contrato |
|---|---|---|---|
| 0001 · Monorepo | Un repo con `apps/mobile`, `supabase/`, `docs/`, `design/`, `openspec/`, `tools/` y CI | Polyrepo y `packages/shared`; `apps/web` se difiere a H4 | Carpetas de primer nivel; esquema en `supabase/migrations` |
| 0002 · DI y codegen | GetIt + `injectable`; `build_runner` solo para el archivo de DI | Service locator manual; `freezed`; `json_serializable` | Un `ServiceLocator` y un módulo externo; `fromJson`/`toJson` explícitos |
| 0003 · Caché local | `shared_preferences` con claves versionadas y un JSON por catálogo | Isar, Drift, Hive y `sqflite` | `cambiami.rates.v1` y preferencias `cambiami.*.v1`; sin TTL |
| 0004 · Errores | `Failure` sellada en dominio; `Exception` en datos; `ErrorMapper` único; ARB para copy estático | `Failure` en el estado; mensaje crudo; todo el copy en ARB | `NetworkFailure`, `ServerFailure`, `ParseFailure`, `CacheFailure`, `ValidationFailure` |
| 0005 · Backend | RLS select-only en `currencies`, `sources` y `rate_snapshots`; vista `security_invoker`; escritura solo `service_role` | RPC `security definer`; Edge Function; login para leer | Sin RPC en v1; la clave secreta no sale del servidor |
| 0006 · Kernel | `core/domain` con `Rate`, `SelectedRate`, `RateType`, `RateStatus` y `RateStatusResolver` | `Rate` en `features/rates`; duplicarlo; paquete aparte | Solo entra un tipo si lo usan dos o más features |
| 0007 · Colector | Edge Function + `pg_cron`/`pg_net`; cada 30 min; retención 90/30 días; P2P `buy`/`sell`/`avg`; intermedio TLS de Sectigo embebido | Cron externo; worker en Postgres; fuente puente; promedio ponderado | Secreto en Vault y en `supabase secrets`; escritura solo con `record_rate_snapshot()` |

La frescura se calcula en `RateStatusResolver`: `sinConexion` gana si falló la red; si no, la edad se compara con el umbral. Edad = `now - published_at`, con `fetched_at` como respaldo. Umbrales: **26 h** para `oficial` y **2 h** para `p2p_*`.

**Módulos.**

| Módulo | Entidades | Usecases | Pantallas |
|---|---|---|---|
| `rates` | `Rate`, `SelectedRate` | `GetCachedRates`, `FetchLatestRates`, `WatchSelectedRate`, `SelectRate`, `SaveCustomRate`, `ClearCustomRate` | 05 Tasas, 09 Monedas, 09b Mi tasa |
| `calculator` | `Rate`, `SelectedRate`, `Conversion` | `ParseAmount`, `ConvertAmount`, `BuildShareText` | 02/02b/03/04, 10 Compartir |
| `settings` | `DefaultCurrency` | `GetDefaultCurrency`, `SetDefaultCurrency` | 07 Configuración, 08 Información |

Splash, compartir, formato es-VE y frescura viven en `core`: son transversales, no features. Las páginas de referencia son **05 Tasas**, que consume `rates`, y **02 Calculadora**, que consume `rates`, `calculator` y `settings`. Si la calculadora importara las tripas de `rates`, el corte estaría mal.

**Changes, en orden.**

| # | Change | Contenido | Gate verificable |
|---|---|---|---|
| 1 | `backend-rates` | Cuatro tablas, vista `rates_latest`, RLS select-only, semilla de monedas y fuentes | `anon` lee tablas y vista; no inserta, actualiza ni borra; una fila por moneda y tipo; `effective_from <= now()`; sin RPC |
| 2 | `mobile-shell` | Flutter, tema, router, DI, errores, ARB, splash, slice descartable | Build, análisis y tests verdes; DI resuelve; ruta pinta; sin tokens de plantilla; slice borrado |
| 3 | `feature-rates` | Dominio, datasource, repositorio, caché, `RatesCubit`, 05/09/09b | Cinco filas agrupadas por mercado con fuente, publicación, vigencia y estado; carga y error dibujados; selección persiste; offline usa cache |
| 4 | `feature-calculator` | `ParseAmount`, `ConvertAmount`, `BuildShareText`, `CalculatorCubit`, 02/02b/03/04/10 | Convierte en ambos sentidos en menos de 100 ms; conserva el monto al cambiar de tasa; modo avión calcula; compartir exacto |
| 5 | `feature-settings` | Moneda por defecto, legal desde ARB, pie de versión | La preferencia se aplica al reabrir; legal completo; cero emojis; ningún texto fuera de ARB |

El orden va del contrato al cableado y de ahí a las features: primero la base, después el esqueleto, después lectura, cálculo y preferencias. Cambiami llega a doce pantallas, ocho features, tres módulos y un contrato de datos.

### 9.2 Cronología real

| # | Cuándo | Etapa | Qué se hizo | Evidencia |
|---|---|---|---|---|
| 1 | — | 1 | Cinco entidades y una vista, glosario, derivados y lista de rechazo | `docs/DOMINIO.md` |
| 2 | — | 2 | Siete ADRs con alternativa rechazada y contrato | `docs/adr/ADR-0001…0007` |
| 3 | — | 3 | Ocho features, tres módulos, cinco changes y orden de construcción | `docs/FEATURES.md` |
| 4 | 16 nov 2026 | 4 | `backend-rates` y `backend-collector` propuestos, implementados y archivados | `openspec/specs/rates`, `openspec/specs/collector` |
| 5 | 16 nov 2026 | 5 | Backend verificado: dos migraciones, Edge Function de cinco módulos, seis archivos pgTAP | `supabase/` |
| 6 | 18 nov 2026 | 4/5 | Cuatro issues, board, milestone y dependencias nativas | `IDUCDEV/cambiami` #1–#4 |
| 7 | 18 nov 2026 | 5 | `mobile-shell` bloque 1: app, `pubspec.yaml`, 17 iconos Lucide | 3/23 tareas |
| 8 | 18 nov 2026 | 6 | `repo-guardrails` en redacción | `openspec/changes/repo-guardrails` |

La etapa 4 no se ejecutó una vez: se ejecutó por change. El backend se archivó antes de tocar Flutter; `mobile-shell` sigue abierto mientras se construye. Eso es normal: la etapa 4 es un ciclo, no una parada.

### 9.3 Comandos que se corrieron

| Comando | Resultado verificado |
|---|---|
| `flutter --version` | 3.50.0 · Dart 3.14.0 |
| `flutter create --org org.iducdev --project-name cambiami apps/mobile` | Proyecto con contador de ejemplo |
| `flutter test` | 2/2 en verde |
| `flutter analyze --fatal-warnings --fatal-infos` | 0 issues |
| `dart format --output=none --set-exit-if-changed lib test` | 3 archivos, 0 cambiados |
| `flutter build apk --debug` | OK, 163 MB |
| `flutter build linux --debug` | OK |
| `supabase test db` | Seis archivos pgTAP en verde |
| `openspec validate <change> --strict` | Pasa antes de archivar |
| `gh issue create`, `gh project item-add` | Cuatro issues enlazados al board |

La lista importa porque es el contrato de la etapa 6: `make check` debe reproducir las filas de formato, análisis y tests, no una versión idealizada.

### 9.4 Desvíos y correcciones

| Desvío | Qué pasó | Corrección | Dónde quedó |
|---|---|---|---|
| Scaffold descartado | Very Good CLI generaba estructura y dependencias que el ADR no pedía | `flutter create` + lints propias | Guía §9.4 |
| No había scaffold | La guía asumía uno; Cambiami arrancó greenfield | La etapa 5 usa solo las filas de Variables, Marca y Dominio; el slice sigue siendo obligatorio | §3.5 |
| Package id sin ratificar | `org.iducdev.cambiami` en el código; `com.cambiami.app` y `app.cambiami` en documentos | Se difiere a una decisión cerrada antes del primer release | §11 |
| `build_runner` bloqueado | 2.16.1 no resuelve; 2.17.1 choca con el analyzer | Codegen diferido; `fromJson` explícito | ADR 0002 |
| `material.dart` deprecado | El import clásico emite aviso en Flutter 3.50 | `package:material_ui/material_ui.dart` | Código y `pubspec.yaml` |
| OpenSpec 2.0 estricto | Un change de tooling sin delta no valida | `skip_specs: true` o capability `dev-workflow` | `.openspec.yaml` |
| Falso positivo de secretos | `.env.example` contiene `sb_secret_reemplazar` | Regex real `sb_secret_[A-Za-z0-9_-]{20,}` | Guía §9.4 |
| Sin emulador Android | Solo Linux desktop y Chrome disponibles | APK debug + Linux como verificación; dispositivo real antes del release | §11 |
| Sin CD | El deploy remoto es manual | Runbook y CI sin secretos | `docs/SUPABASE_REMOTO.md` |

Los desvíos no se borran: se registran. Un desvío sin registro se convierte en la próxima decisión implícita.

### 9.5 Estado al cerrar esta versión de la guía

- Etapas 1–4 cerradas para backend; `mobile-shell` en 3/23.
- Backend local verificado; remoto documentado y no ejecutado.
- `repo-guardrails` en redacción: seis bloques, tres PRs.
- Siguiente tarea real: fuente Nunito y `OFL.txt`, declarada en `pubspec.yaml`, con cuatro pesos verificados.
- Nada se commitea sin pedido explícito.

## 10. Extrapolación: otro proyecto con el mismo stack

Esta sección es el atajo para repetir Cambiami en un producto distinto con Flutter, Supabase, GetIt e `injectable`. No reemplaza las etapas: las ordena en el calendario y dice qué se copia, qué se reescribe y qué se descarta.

### 10.1 Qué se copia, qué se reescribe

| Artefacto | Acción | Por qué |
|---|---|---|
| Estructura de carpetas | Copiar | `apps/mobile`, `supabase`, `docs`, `design`, `openspec`, `tools` |
| Plantillas de §5 | Copiar | Dominio, ADR, mapa, change, bootstrap y guardrails son genéricas |
| `Makefile` y `ci.yml` | Copiar y ajustar versiones | Los comandos son del stack, no del producto |
| Hook `commit-msg` | Copiar | La convención no depende del dominio |
| `AGENTS.md` | Reescribir | Los invariantes son del producto |
| Dominio, ADRs y mapa | Reescribir | Es el trabajo real; copiarlos es inventar dominio |
| Specs archivadas | No copiar | Solo sirven como ejemplo de forma |
| Assets, tokens y copy | Reescribir | Vienen del diseño, no del repo anterior |
| Migraciones | Reescribir | El esquema es del producto |

### 10.2 Plan de diez días

| Día | Etapa | Salida | Gate |
|---|---|---|---|
| 1 | 1 | Dominio v1.0 con glosario y lista de rechazo | Cada dato visible tiene campo o fórmula |
| 2 | 2 | Cinco a ocho ADRs y abiertas con dueño | Toda decisión transversal cubierta |
| 3 | 3 | Mapa con módulos, usecases y orden | Cero celdas vacías en la matriz |
| 4 | 4 | `backend-*` y `mobile-shell` en proposal + spec | Validador estricto pasa |
| 5 | 5 | Backend local: migraciones, RLS, vista y pgTAP | `make db-check` verde |
| 6 | 5 | Repo, tema, DI, router, errores, slice borrado | Build, test y run verdes |
| 7 | 5 | Primer change aplicado | Requirements con test |
| 8 | 6 | `make check`, hook y CI | PR de prueba detenido por capa |
| 9 | 4 | Segundo y tercer change | Trazabilidad completa |
| 10 | 6 | Bitácora y revisión de guardrails | Gate firmado |

Un proyecto de una persona puede comprimir 1–2 en un día y 3–4 en medio, pero no puede saltear la lista de rechazo, el ADR de fuente ni la prueba de fuego del CI.

### 10.3 Orden de comandos

```bash
# 1. Repo y documentación
git init && mkdir -p docs/adr docs/features design openspec supabase apps

# 2. App
flutter create --org <org> --project-name <app> apps/mobile
cd apps/mobile && flutter pub get

# 3. Backend local
supabase init
supabase start
supabase db reset

# 4. OpenSpec
openspec init
openspec new change <primer-change>
openspec validate <primer-change> --strict

# 5. Guardrails
make check
git config core.hooksPath .githooks
```

El orden no es casual: el backend local antes de OpenSpec evita especificar tablas que después no existen; los guardrails después del primer change evitan configurar un CI para comandos que todavía no existen.

### 10.4 Trampas del stack

- **Dos fuentes de versión.** `pubspec.yaml` y el workflow deben declarar la misma versión de Flutter. Si divergen, el CI falla por una dependencia que en local resuelve.
- **`build_runner` y el analyzer.** Un paquete nuevo puede bloquear el codegen. Fijá el par `build_runner`/`analyzer` y no actualices uno sin el otro.
- **`shared_preferences` con caché.** Usá `SharedPreferencesWithCache` y `allowList`: sin lista, cualquier clave nueva entra sin revisión.
- **GetIt en tests.** Registrá dobles antes de `configureDependencies`; un singleton real en un widget test contamina el siguiente.
- **Supabase local.** `supabase start` consume RAM; en CI conviene un job separado con timeout y sin secretos.
- **pgTAP.** `supabase test db` necesita `db reset` previo; sin reset, el test corre contra un esquema viejo.
- **Formato es-VE.** El separador decimal es coma y el símbolo va después (`Bs 1.234,56`). No lo dejes al `intl` por defecto.
- **Iconos.** Un paquete de iconos se verifica con un test que recorra los nombres usados; si no, un rename rompe la UI en runtime.
- **OpenSpec 2.0.** Un change sin delta no valida; para tooling usá `skip_specs: true` o una capability real.
- **Secretos.** El placeholder de `.env.example` hace ruido en búsquedas; usá un regex de longitud para el secreto real.

## 11. Decisiones abiertas de esta guía

| ID | Pregunta | Dueño | Fecha | Default |
|---|---|---|---|---|
| G-01 | ¿`org.iducdev.cambiami`, `com.cambiami.app` o `app.cambiami`? | Producto | Antes del primer release | `org.iducdev.cambiami` |
| G-02 | ¿`very_good_analysis` o `flutter_lints` como base? | Tech lead | Antes del bloque 2 | `very_good_analysis` |
| G-03 | ¿`l10n.yaml` con `synthetic-package: false` y ARB en `lib/l10n`? | Tech lead | Bloque 2 | Sí, salida versionada |
| G-04 | ¿Umbral de cobertura y desde qué change? | Tech lead | Después del kernel | Sin umbral; artefacto solamente |
| G-05 | ¿Se fijan las acciones por SHA antes del primer deploy? | Tech lead | Antes de `docs/SUPABASE_REMOTO.md` | Sí, con `pinact` |
| G-06 | ¿La bitácora se actualiza por PR o por semana? | Quien mantiene | Al cerrar la etapa 6 | Por PR |
| G-07 | ¿Flavors antes o después del package id? | Tech lead | Después de G-01 | Después |
| G-08 | ¿La guía renumera secciones al crecer o agrega al final? | Autor | Al publicar v2 | Agregar §10 y §11 sin renumerar |
| G-09 | ¿Qué dispositivo Android real se usa para la verificación previa al release? | Tech lead | Antes del primer release | Un dispositivo físico con Android 12 o superior |

Cada abierta tiene dueño, fecha y default: si nadie la cierra, el default se aplica y se registra. Una abierta sin default es una decisión que se tomará en el peor momento posible.
