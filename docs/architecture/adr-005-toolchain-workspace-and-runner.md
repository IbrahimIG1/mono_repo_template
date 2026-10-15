# ADR-005: Toolchain, Workspace, and Task Runner

Status: Accepted; runner/toolchain evidence remains valid and platform scope is superseded by ADR-008.

## Decision

- Candidate V2 baseline is Flutter `3.44.1` stable with Dart `3.12.1`.
- Pin Flutter exactly in `.fvmrc` and CI. Package constraints use Dart `>=3.12.1 <3.13.0` during admission so an SDK minor upgrade is deliberate.
- Use a Pub Workspace with explicit member paths. Do not use a glob while legacy packages live beside admitted V2 members.
- Keep legacy packages outside until each passes the admission gates. Workspace exclusion is a temporary migration boundary.
- Do not adopt Melos in V2. Use a small Dart runner based on `dart pub workspace list --json` for the required gates.
- Reconsider Melos only if changed-package filtering, dependency-ordered orchestration, or coordinated publish/version workflows become recurring requirements.

## Evidence

See [`Goal 2: Five-Day Technical Spike`](../spikes/goal-2-technical-spike.md).

## Consequences

- The repository has one dependency resolution for admitted members without pulling legacy conflicts into the initial foundation.
- CI and local commands use the same member source: Pub itself.
- The team owns a small amount of runner code instead of a Melos dependency/configuration surface.
- Flutter upgrades require an explicit pin change, dependency resolution, route regeneration, and Android/iOS build runs.
