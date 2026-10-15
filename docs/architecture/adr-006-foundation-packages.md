# ADR-006: Goal 3 Foundation Package Ownership

Status: Accepted and implemented.

## Context

The legacy `core` package combines global networking, global storage, UI helpers, Firebase, Bloc, and service-location concerns. Goal 3 needs a usable base without admitting or changing legacy consumers.

## Decision

The first production workspace admits exactly four packages plus `minimal_app`:

- `platform_foundation` is pure Dart and owns sealed `Result<T>`, extensible `AppFailure`, structured logging, and redaction.
- `networking` is pure Dart and owns HTTP-neutral request/response contracts, typed transport failures, and an injected Dio adapter. Endpoints, auth policy, DTOs, and request replay are excluded.
- `storage` owns typed key-value and secure-string contracts. Shared Preferences and Flutter Secure Storage adapters have separate library entry points; no adapter is global and broad clear operations are intentionally absent.
- `design_system` owns brand-neutral Material theme tokens and presentation primitives. Product colors, fonts, assets, copy, and localization remain app-owned.

`minimal_app` is the only composition root. It constructs lifecycle resources, injects interfaces, and disposes the network client. `core`, `shared`, and both legacy apps remain outside the workspace.

## Public entry points

```text
package:platform_foundation/platform_foundation.dart
package:networking/networking.dart
package:networking/dio.dart
package:storage/storage.dart
package:storage/shared_preferences.dart
package:storage/flutter_secure_storage.dart
package:design_system/design_system.dart
```

Adapter entry points are explicit so source code does not import plugin APIs accidentally. Pub still resolves dependencies at package granularity; split an adapter into another package only when an admitted app has a measured need to omit that dependency from its resolved graph.

## Consequences

- A new app can consume the complete foundation without Firebase, chat, realtime, socket, or legacy dependencies.
- Failure mapping and redaction are shared while backend and product policy stay outside infrastructure.
- The package count remains small for a small team.
- Secure-storage runtime support remains governed by the capability matrix; compilation alone does not upgrade its status.
