---
name: flutter-code-style
description: Dart and Flutter implementation style for readable, maintainable code in this platform. Use when writing or refactoring methods, widgets, Cubits, models, error handling, async flows, or tests while preserving the repository's explicit handwritten-model and no-unnecessary-abstraction conventions.
---

# Flutter Code Style

## General

- Prefer descriptive names and flat control flow.
- Use `const` when it expresses immutability clearly.
- Avoid abbreviations, magic values, production `print`, and comments that repeat code.
- Keep public methods before private helpers and group related behavior.
- Extract code only for reuse, meaningful naming, or reduced cognitive load.

## Widgets

- Prefer `StatelessWidget` unless lifecycle/local state requires otherwise.
- Split by visible responsibility, not tiny fragments.
- Keep build methods focused on rendering.
- Keep mutable business state out of widgets; keep Flutter lifecycle objects out of domain contracts.

## Async and failures

- Await persistence and state-changing work when ordering matters.
- Propagate cancellation and protect against stale completions.
- Return typed results at package boundaries.
- Log through the redacted logger; never log credentials or tokens.

## Handwritten models

Follow `docs/architecture/adr-001-foundation-contracts.md`. Do not introduce Freezed, json_serializable, or model code generation.

## Completion

Run formatting, analyzer and relevant tests. Report only commands actually run.
