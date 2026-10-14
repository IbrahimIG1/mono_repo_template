# Refactor Prompt

Use to improve maintainability without changing agreed behavior.

## Before implementation

- Explain the measurable maintenance problem.
- Show evidence of duplication, coupling, size, unsafe lifecycle, or unclear ownership.
- Define behavior, API, storage, route and UI invariants.
- Decide whether no change is the better outcome.
- Define a narrow migration and rollback boundary.

## Rules

- Do not refactor to reduce line count or imitate an architecture diagram.
- Do not create layers or packages without real responsibility boundaries.
- Preserve public contracts unless explicitly approved.
- Keep legacy compatibility until consumers and parity checks pass.
- Remove dead code only after checking Dart, platform, build and configuration consumers.

## Completion report

- Problem removed and why the new structure is better.
- Behavior/contracts preserved.
- Breaking changes and migration path, if approved.
- Tests, analyzer and builds actually run.
- Remaining risks.

Use `$flutter-architecture`, `$flutter-code-style`, `$monorepo` and `$documentation` as applicable.
