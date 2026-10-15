---
name: flutter-architecture
description: Pragmatic Flutter architecture guidance for screens, Cubits, repositories, ports, adapters, routing, lifecycle, and feature structure in this platform. Use when designing or refactoring Flutter behavior, deciding between lightweight and structured flows, or reviewing framework and capability boundaries.
---

# Flutter Architecture

Read `AGENTS.md` and the relevant ADR before changing a public boundary.

## Choose the smallest valid structure

Use `UI -> Cubit -> Repository` for a simple feature when it has no reusable domain policy or multi-service orchestration.

Introduce framework-neutral ports/use cases when at least one is true:

- business rules must be independently tested;
- multiple repositories/services are coordinated;
- platform, backend, storage, transport, or UI implementations must be replaceable;
- the capability is shared by multiple apps.

Do not create use cases that only forward one repository call.

## Responsibilities

- Widgets render and own Flutter lifecycle objects when required.
- Cubits coordinate presentation state and receive validated values.
- Do not put `TextEditingController`, `GlobalKey`, clients, plugins, or transports in framework-neutral contracts.
- Repositories/adapters map external data and failures.
- Apps own composition, routing destinations and backend DTOs.
- External resources expose explicit disposal/cancellation.

## State and lifecycle

- Prefer immutable states with explicit loading/success/empty/error meaning.
- Protect against late async results after disposal, logout, cancellation, or generation changes.
- Define replay, retry, cancellation and idempotency rather than relying on happy paths.
- Keep background entry points independent of foreground DI assumptions.

## Review test

Before adding a class or layer, verify that it improves ownership, testing, replacement, or readability. If none applies, keep the simpler structure.
