# 2. Database per service para ownership de datos

Date: 2026-09-09

## Status

Accepted

## Context

BANKdragon V2 divide las cuatro épicas de negocio (Gastronomía, Viajes, Eventos, Social Split) más el core financiero y la auditoría en seis microservicios independientes. Si dos o más servicios escriben sobre el mismo motor de base de datos, el bounded context de cada uno deja de estar realmente aislado: un cambio de esquema en un servicio puede romper a otro sin pasar por su API.

## Decision

Cada servicio es dueño exclusivo (single-writer) de su propio almacenamiento:

- `payments-api` → MariaDB `bankpulse` (core financiero).
- `audit-api` → MongoDB `audit` (proyección de auditoría).
- `experiences-api` → MongoDB `experiences`.
- `travel-benefits-api` → MongoDB `travel`.
- `events-api` → PostgreSQL schema `events` + Redis (solo TTL, ver ADR-0003).
- `social-split-api` → PostgreSQL schema `social_split`, guardando únicamente una referencia (`paymentReference`) a `payments-api`, nunca el dato financiero completo.

Ningún servicio consulta ni escribe directamente sobre el schema/base de otro; la integración entre servicios es siempre por REST o eventos. En Codespaces se comparten los motores físicos (Mongo, Postgres) para no exceder el límite de 4 CPU/8 GB, pero el aislamiento lógico (bases/esquemas separados) se mantiene igual. Ver `docs/architecture/DATA-OWNERSHIP.md` para la matriz completa.

## Consequences

Facilita el trabajo por equipos (cada equipo puede migrar el esquema de su servicio sin coordinar con los demás) y hace explícito qué servicio es la fuente de verdad de cada dato. A cambio, cualquier vista que combine datos de varios servicios (p. ej. un resumen de cliente) requiere componerla vía API o proyección, en lugar de un simple JOIN — y esa composición debe declarar si tolera consistencia eventual o no.
