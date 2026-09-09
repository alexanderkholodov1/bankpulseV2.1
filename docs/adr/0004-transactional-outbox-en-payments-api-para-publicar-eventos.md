# 4. Transactional Outbox en payments-api para publicar eventos

Date: 2026-09-09

## Status

Accepted

## Context

`payments-api` (MariaDB) es la única autoridad financiera, pero `audit-api` (MongoDB) necesita enterarse de cada pago para mantener su proyección de auditoría. Escribir el pago en MariaDB y notificar a `audit-api` por HTTP en la misma operación puede perder el evento si la llamada falla justo después de confirmar el pago (o publicarlo sin haber confirmado la transacción).

## Decision

`payments-api` implementa el patrón Transactional Outbox: al crear un `Payment`, la misma transacción guarda también un `OutboxEvent` (`PAYMENT_CREATED`) en la misma base MariaDB. Un proceso aparte, `OutboxPublisher`, corre en un `@Scheduled` y envía a `audit-api` (`POST /internal/events`) los eventos pendientes (`findTop50ByPublishedFalseOrderByCreatedAtAsc`); si la llamada falla, el evento queda marcado como fallido con su número de intento y se reintenta en el siguiente ciclo, sin bloquear la escritura del pago original.

## Consequences

El pago y el evento de auditoría nunca quedan inconsistentes entre sí (o se guardan ambos, o ninguno, porque están en la misma transacción de MariaDB), y una caída temporal de `audit-api` no afecta la disponibilidad de `payments-api`. A cambio, la auditoría es eventualmente consistente — puede haber un retraso entre el pago y su reflejo en `audit-api` — y hace falta un `OutboxRepository`/tabla adicional y un job periódico que hay que monitorear (eventos que se acumulan como fallidos son una señal de alerta operacional).
