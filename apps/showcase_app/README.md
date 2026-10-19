# showcase_app

Bootstrap reference app for the Goal 6 strangler migration. This app is built
from the admitted foundation and design-system packages only; feature slices
will be added in order and will not import legacy `user_app` code.

Run from the workspace root:

```powershell
flutter pub get --enforce-lockfile
flutter run -d <android-emulator-or-ios-simulator> --target apps/showcase_app/lib/main.dart
```

The current slice owns typed environment configuration in
`lib/src/bootstrap/showcase_config.dart`. Endpoints, routes, localization,
Firebase configuration, and product assets are intentionally deferred to their
respective slices.

A new Flutter project.
