# Create a V2 App

## 1. Generate only the target platforms

From the repository root:

```powershell
flutter create --empty --no-pub --platforms=android,ios,web,windows --org com.example apps/my_app
```

Use the real organization identifier before shipping. The generated identifiers are app-owned.

## 2. Admit the app to the workspace

Add `apps/my_app` to the root `workspace` list. In the app pubspec, pin the admitted SDK range and opt into only the required packages:

```yaml
environment:
  sdk: ">=3.12.1 <3.13.0"
  flutter: ">=3.44.1 <3.45.0"

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  platform_foundation: ^0.1.0
  design_system: ^0.1.0
```

Add `networking` or `storage` only when the app uses them. Never copy dependencies from `minimal_app` blindly.

## 3. Own composition and configuration

Create one app composition root. Construct infrastructure there, pass interfaces through constructors, and dispose resources in reverse order. Apps own endpoints, DTO adapters, routes, localization, platform configuration, identifiers, assets, and branding.

Do not import `core`, `shared`, `get_it`, Dio, or storage plugins from presentation code. A service locator is permitted only behind the app composition root when constructor wiring becomes genuinely unwieldy.

## 4. Admission gates

Run from the root:

```powershell
flutter pub get
dart run tool/workspace.dart verify
dart analyze tool
dart run tool/check_architecture.dart
```

Extend `tool/check_architecture.dart` with the new app and its allowed local edges. Add applicable Android, iOS, Web, and Windows CI builds. A compile pass does not establish runtime support for plugins; update the capability matrix only with matching evidence.
