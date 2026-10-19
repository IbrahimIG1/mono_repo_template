# V2 Goal 6 — Showcase bootstrap/configuration slice

Status: complete for slices 1–3; routing is next

## Scope

This slice creates `apps/showcase_app` from the admitted V2 packages. It proves
that a new app can own its bootstrap and environment configuration without
importing `user_app`, `admin_app`, `core`, or `shared`. Authentication, routing,
localization, assets, and feature screens remain deferred to their ordered
slices.

## Legacy behavior inventory

| Concern | Current `user_app` owner | Consumers/configuration | Slice disposition |
|---|---|---|---|
| Flutter startup | `lib/main_development.dart`, `lib/main_production.dart` | Android/iOS entrypoints and launch commands | Record parity now; do not alter legacy |
| Environment selection | `flutter_dotenv` files `assets/.env_dev` and `assets/.env_pro` | dependency setup and API services | Deferred to app-owned typed config; no endpoint copied |
| Dependency composition | `core/di/app_dependencies.dart` and three setup files | all legacy screens/repositories | Deferred until networking/auth slices |
| Theme/branding | inline `ThemeData`, legacy assets/fonts | every legacy screen | Deferred to design-system slice; assets stay app-owned |
| Localization | generated `lib/generated`, `lib/l10n` | `MaterialApp` delegates and screens | Deferred to localization slice |
| Navigation | `core/routing`, `app_navigation.dart` | every named route/deep link consumer | Deferred to routing slice |

The legacy implementation remains authoritative for `user_app` during this
slice. No legacy file is removed or redirected. Compatibility exports remain
available until the relevant parity tests pass in a later slice.

## New ownership

- `showcase_app` owns `ShowcaseConfig` and the composition root.
- `platform_foundation` supplies the injected logger contract.
- `design_system` supplies the neutral theme.
- `showcase_app` supplies the product seed color through `ShowcaseTheme`; the
  shared package does not absorb legacy singleton branding state.
- Localization is app-owned through a typed delegate with an explicit English
  support boundary; legacy generated localization remains untouched.
- API endpoints, Firebase files, localization content, routes, and product
  assets remain app-owned and are intentionally absent from this bootstrap.

## Parity and acceptance checks

- `ShowcaseConfig` has typed development/staging/production values and does not
  invent a default endpoint.
- The app renders the selected environment through a widget test.
- The workspace dependency graph contains no legacy, Firebase, notification,
  realtime, networking, auth, or router dependency for this slice.
- `minimal_app` remains unchanged and its existing gates continue to pass.
- Android and iOS platform folders are generated for the new app; Web and
  Windows remain paused and are not added to validation.
