# 3. Redis con TTL para holds efimeros de events-api

Date: 2026-09-09

## Status

Accepted

## Context

La épica de Eventos necesita reservar temporalmente un asiento (`hold`) mientras el usuario completa el pago, y liberarlo automáticamente si no confirma a tiempo, incluso ante picos de concurrencia (varios usuarios intentando el mismo asiento a la vez).

## Decision

`events-api` usa Redis (`SETNX` vía `setIfAbsent` + TTL, ver `SeatHoldService`) para el hold temporal de un asiento. Redis nunca es la fuente de verdad del negocio: el catálogo de eventos, venues y disponibilidad vive en el schema `events` de PostgreSQL. Redis solo modela un estado efímero que expira solo si nadie lo confirma ni libera antes del TTL configurado (`bankpulse.events.hold-ttl-seconds`, 300s por defecto).

## Consequences

`SETNX` da atomicidad "primero en llegar, primero en reservar" sin necesitar locks explícitos, y el TTL evita asientos bloqueados para siempre por un cliente que abandona el flujo. El costo es que el hold no sobrevive a un `FLUSHALL`/reinicio de Redis sin persistencia, así que ningún estado financiero ni de disponibilidad definitiva puede depender solo de esa clave — la confirmación real de la reserva debe quedar registrada en PostgreSQL y/o en `payments-api`.
