# ADR-008: Mobile-First V2 Scope

Status: Accepted for V2 from Goal 4.5 onward.

## Context

Maintaining credible runtime evidence for four platforms exceeds the capacity of
the current small team and delays the Android/iOS capabilities needed by active
projects. Compilation alone is not a support claim.

## Decision

- V2 targets Android and iOS.
- Web and Windows are `Unsupported`; the matrix note records that validation is
  paused. Existing platform folders and code remain in the repository.
- Default development, tests that require a device, and manual runs use an
  Android emulator or iOS simulator. Web/Windows builds and Chrome runs occur
  only when explicitly requested.
- Core contracts remain pure Dart and platform adapters remain isolated so a
  paused target can return without changing dependency direction.
- Android builds remain a regular CI gate. iOS no-codesign builds run for shared
  package/app/platform changes, releases, manual dispatches, and nightly.
- Goal 5 retains mobile push requirements: a top-level background FCM handler
  that does not use foreground DI, Android 13+ notification permission, iOS APNs
  setup documentation, and recorded physical-device validation for push and
  deep links. Those capabilities stay `Manual-validation-required` until the
  evidence is recorded.

No existing test, analyzer, architecture, formatting, generation, or mobile
build gate is weakened by this scope decision.

## Re-entry condition

Web may return only after an approved product need, an owner and budget, and a
new spike covering current dependency resolution, secure persistence, routing,
realtime authentication, runtime lifecycle, and CI. Windows uses the same
decision process with desktop plugin/runtime probes. Matrix states change only
after matching evidence is recorded.

## Consequences

Historical Web/Windows spike results remain historical evidence, not a current
support promise. New work does not add target-specific Web/Windows acceptance
criteria while validation is paused.
