---
name: monorepo
description: Reuse-first placement and dependency workflow for this Flutter monorepo. Use before creating or moving packages, widgets, helpers, models, repositories, services, adapters, or utilities, and when checking workspace admission, optional dependency leakage, compatibility facades, or sibling-app reuse.
---

# Monorepo Workflow

Read `AGENTS.md` and `docs/migration/v2-goal-1-audit.md` before structural work.

## Search order

1. Search the capability package that should own the behavior.
2. Search the current app/feature.
3. Search sibling apps.
4. Search legacy `core/` and `shared/` compatibility code.
5. Create code only when reuse or adaptation is not semantically correct.

Report what was searched, what was found, and why the selected owner is correct.

## Placement rules

- Keep endpoints, DTO adapters, routes, localization, branding and platform configuration app-owned.
- Put framework-neutral capability contracts in capability core packages.
- Put plugins/transports in optional adapter packages.
- Keep feature-specific code local until real reuse exists.
- Never make a minimal app pull Firebase, realtime, chat, or legacy code transitively.
- Avoid package creation for a single class or hypothetical future reuse.

## Migration rules

- Preserve current `core/` and `shared/` paths as facades until consumers migrate.
- New packages must not import legacy packages.
- Check Dart imports, pubspecs, generated files, native setup and scripts before removal.
- Apply the workspace admission rules in the Goal 1 audit.
- Record breaking changes and migration instructions.

## Verification

- Inspect the local dependency graph for cycles and forbidden edges.
- Confirm optional adapters disappear from resolution when the app omits them.
- Confirm analyzer/tests for affected packages and apps.
- Do not claim runtime support from compilation alone.
