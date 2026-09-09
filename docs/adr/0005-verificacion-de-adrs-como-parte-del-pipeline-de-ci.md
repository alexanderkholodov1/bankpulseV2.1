# 5. Verificacion de ADRs como parte del pipeline de CI

Date: 2026-09-09

## Status

Accepted

## Context

Un ADR solo cumple su función (justificar por qué se tomó una decisión de arquitectura) si de verdad se escribe cuando la decisión se toma, y si mantiene una estructura mínima que cualquiera pueda leer. Dejarlo como buena intención sin ningún control automático hace que se olvide, sobre todo bajo la presión de una entrega.

## Decision

Se agrega el job `adr-check` a `.github/workflows/ci.yml` (usando [adr-tools](https://github.com/npryce/adr-tools) de Nat Pryce), con dos verificaciones:

1. **Estructura:** todo archivo `docs/adr/NNNN-*.md` debe tener las secciones `## Status`, `## Context`, `## Decision` y `## Consequences`; si falta alguna, el job falla señalando el archivo.
2. **Cobertura en Pull Requests:** si un PR modifica algo bajo `services/` o `docs/architecture/` (código o documentación de arquitectura) sin agregar ni tocar ningún archivo en `docs/adr/`, el job falla pidiendo explícitamente el ADR correspondiente.

El job también corre `adr list` para dejar en el log de CI el índice de decisiones vigentes.

## Consequences

Un cambio de arquitectura sin ADR no puede llegar a `main` en verde, lo que fuerza a documentar la decisión en el mismo Pull Request donde se implementa (no "después"). El costo es un falso positivo ocasional: un cambio en `services/` que sea puramente técnico (una dependencia, un fix) y no una decisión de arquitectura también dispara la verificación, y el equipo tiene que crear un ADR breve o, si de verdad no aplica, ajustar la regla de rutas del job.
