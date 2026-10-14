# Debug Prompt

Use for a bug, regression, runtime issue, broken build or unexpected state flow.

## Before implementation

- State the user-visible symptom.
- Record reproduction steps or the missing evidence.
- Identify the actual cause with file/command evidence.
- Define the smallest safe fix, preserved behavior and risk.
- Add or identify a regression test that fails before the fix.
- Check whether the issue belongs to an app, a capability contract, an adapter, or legacy compatibility code.

## During implementation

- Keep the change within the bug boundary.
- Do not broaden a bug fix into an unrelated refactor.
- Do not change public contracts unless the bug cannot be corrected safely without it.
- Preserve cancellation, lifecycle and platform behavior.

## Completion report

- Root cause.
- Fix applied.
- Behavior preserved.
- Regression test added.
- Commands actually run and their results.
- Platforms not validated.

Use `$monorepo` for ownership/reuse issues, `$flutter-architecture` for state/lifecycle issues and `$flutter-code-style` for implementation clarity.
