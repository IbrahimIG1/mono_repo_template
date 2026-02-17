## Flutter Start Template (Monorepo)

This repository is a reusable Flutter monorepo template intended as a starting point for multiple apps. It includes an `apps/` workspace (each app is a normal Flutter app), plus `core/` and `shared/` packages for DI, networking, widgets, models, and styles.

Use this template as a base for cloning new apps and accelerating project setup.

## Project Overview

- Purpose: provide a production-ready starting point that teams can clone and customize to ship new Flutter apps quickly.
- Flavors: includes two entry points: `apps/sandwich_app/lib/main_development.dart` and `apps/sandwich_app/lib/main_production.dart` (dev/pro flavors are wired via the `.vscode/launch.json` and typical Flutter `--flavor` usage).
- Architecture: feature-based app layout under `apps/`, with `core/` (DI + networking + helpers) and `shared/` (widgets, models, styles). The codebase uses `flutter_bloc` (Cubit style) + repository/service layers and `get_it` for DI.

## Quick index (what's in this repo)

Top-level files and directories you'll commonly use:

```
/
apps/
  sandwich_app/           # Example app (full Flutter project)
    android/
    ios/
    macos/
    linux/
    windows/
    web/
    lib/
      main_development.dart
      main_production.dart
      features/            # Feature modules (login, register, onboarding, etc.)
      generated/           # Generated localization and other generated sources
      l10n/
      routing/
    assets/
    test/
    pubspec.yaml
    pubspec.lock
core/                      # Core package (DI, networking, helpers, storage)
  lib/
    di/
    network/
    helper/
    local/
shared/                    # Shared package (widgets, models, styles)
  lib/
    widgets/
    models/
    styles/
.vscode/
README.md
```

Key files to know:
- `apps/sandwich_app/lib/main_development.dart` and `apps/sandwich_app/lib/main_production.dart` - flavor entry points.
- `core/lib/di/` - dependency injection base setup (uses `get_it`).
- `core/lib/network/` - `dio` factory, API service wrappers and error handling.
- `shared/lib/widgets/` - shared widgets (buttons, headers, toast helpers using `fluttertoast`).
- `apps/sandwich_app/lib/features/` - feature-first structure containing UI, logic (Cubits), models, and repos.

## Monorepo structure (what goes where)

- `apps/<app_name>/` - a normal Flutter app (platform folders, assets, `lib/`, `test/`).
- `apps/<app_name>/lib/features/` - app-specific feature modules (UI, cubits, repos).
- `apps/<app_name>/lib/routing/` - app routes and screens names.
- `core/` - shared app-agnostic logic (DI base setup, networking, helpers, local storage).
- `shared/` - shared UI and data (widgets, models, styles) used across apps.

## Create a new app in `apps/`

From the repo root:

```powershell
flutter create apps/my_app
```

Optional (set package id):

```powershell
flutter create --org com.example apps/my_app
```

Then add the monorepo packages to `apps/my_app/pubspec.yaml`:

```yaml
dependencies:
  core:
    path: ../../core
  shared:
    path: ../../shared
```

After that:
- Update imports to use `package:core/...` and `package:shared/...`.
- Create app DI wiring similar to `apps/sandwich_app/lib/di/` and call it from your `main_*` entry points.

## Packages & Dependencies (from `pubspec.yaml`)

The project includes the following packages. Short purpose explanation for each:

| Package | Version (declared) | Purpose |
|---|---:|---|
| `conditional_builder_null_safety` | ^0.0.6 | Small utility for conditional widget building.
| `cupertino_icons` | ^1.0.8 | iOS-style icons used by Flutter.
| `dartz` | ^0.10.1 | Functional programming helpers (Either, Option) if used in business logic.
| `dio` | ^5.8.0+1 | HTTP client used for networking; configured via `core/lib/network`.
| `firebase_core` | ^3.14.0 | Firebase core package (initialization for Firebase features).
| `firebase_messaging` | ^15.2.7 | Push notifications handling.
| `flutter` | SDK | Flutter framework.
| `flutter_bloc` | ^9.1.1 | State management; project uses Cubit/BLoC patterns.
| `flutter_dotenv` | ^5.2.1 | Load environment variables from `.env` files.
| `flutter_localization` | ^0.3.3 | Helper for localization configuration.
| `flutter_localizations` | sdk: flutter | Flutter official localization support.
| `flutter_native_splash` | ^2.4.6 | Generates native splash screens for each platform.
| `flutter_screenutil` | ^5.9.3 | Responsive sizing helpers for multiple screen sizes.
| `flutter_secure_storage` | ^9.2.4 | Secure storage for tokens/credentials.
| `flutter_svg` | ^2.2.0 | Load and display SVG assets.
| `fluttertoast` | ^8.2.12 | Simple toast UI; used in `shared/lib/widgets/toast`.
| `get_it` | ^8.0.3 | Service locator / dependency injection container.
| `intl` | ^0.20.2 | Internationalization and number/date formatting.
| `intl_phone_number_input` | ^0.7.4 | Phone number input widget with parsing/validation.
| `intl_utils` | ^2.8.10 | i18n codegen helpers (for `.arb` -> Dart generation).
| `introduction_screen` | ^3.1.17 | Onboarding screens helper.
| `lottie` | ^3.3.1 | Lottie animations.
| `pin_code_fields` | ^8.0.1 | Pin/OTP input fields.
| `pretty_dio_logger` | ^1.4.0 | Helpful Dio request/response logging during development.
| `shared_preferences` | ^2.5.3 | Local key-value storage for non-sensitive data.
| `flutter_launcher_icons` | ^0.14.4 | Tool to generate launcher icons.

Dev dependencies:
- `flutter_lints` (^5.0.0) — recommended lint rules.
- `flutter_test` — unit & widget tests.

Note: some packages require platform setup (e.g., Firebase, notifications). See their package docs for details.

## Setup Instructions

Note: replace `sandwich_app` with your app folder (for example `user_app`) when needed.

1. Clone the repository:

```powershell
git clone <repo-url> my_app
cd my_app
```

2. Install app dependencies (path packages are resolved automatically):

```powershell
cd apps/sandwich_app
flutter pub get
```

3. (Optional) Create a fresh repo for your new app:

```powershell
rm -rf .git
git init
git add .
git commit -m "Initial commit from flutter_start_template"
```

4. Rename the app (package identifiers and app name):
- Update `apps/sandwich_app/pubspec.yaml` -> `name:` and `description`.
- Android package: update package name under `apps/sandwich_app/android/app/src/main/kotlin/.../MainActivity.kt` and `apps/sandwich_app/android/app/src/main/AndroidManifest.xml`. Also update `apps/sandwich_app/android/app/build.gradle.kts` if necessary.
- iOS bundle id: update `apps/sandwich_app/ios/Runner/Info.plist` and Xcode project settings.
- macOS bundle id: `apps/sandwich_app/macos/Runner/Configs/AppInfo.xcconfig`.

Tip: For an automated rename you can use search-and-replace tools (e.g. ripgrep + sed) but please verify Android/iOS project files manually.

5. Configure flavors and environment files:
- This template includes `.env_dev` and `.env_pro` in `apps/sandwich_app/assets/`. Copy and update them with API keys and flags.
- Launch dev flavor locally:

```powershell
cd apps/sandwich_app
flutter run --flavor dev -t lib/main_development.dart
```

Or build an APK (verbose, from `apps/sandwich_app`):

```powershell
cd apps/sandwich_app
flutter build apk --flavor dev -t lib/main_development.dart -v
```

6. Platform-specific: set up Firebase, notification entitlements, Android SDK, and signing for release builds according to those services' docs.

## Development Notes

- State management: this project uses `flutter_bloc` (Cubit) with repositories and service layers under `apps/sandwich_app/lib/features/*/logic` and `core/lib/network`.
- Dependency injection: `core/lib/di/` wires `get_it` instances for repositories, services, and cubits.
- Networking: `dio` + `pretty_dio_logger` via `core/lib/network/dio_factory.dart`.
- Naming conventions:
	- Feature folders should be named `snake_case` (e.g., `login_screen`).
	- Cubit/state files follow `feature_logic_*` (see existing examples under `apps/sandwich_app/lib/features/*/logic`).
	- Widgets that are reusable live under `shared/lib/widgets`.
 - Code style & linting: `flutter_lints` is configured; run `dart analyze` and `flutter test` regularly.
 - Localization: ARB files live under `apps/sandwich_app/lib/l10n` and generated code under `apps/sandwich_app/lib/generated` using `intl_utils`.

Edge cases & checks
- Empty or missing `.env` keys — guard network calls and show clear logging.
- Long-running network calls — use timeouts, handle Dio exceptions in `core/lib/network/error`.
- Token refresh — `refresh_token_model.dart` and repo wiring exist; ensure refresh flows are tested.

## Usage Example - Starting a new project from this template

1. Clone and prepare a new repo (example):

```powershell
git clone https://github.com/IbrahimIG1/flutter_start_template.git my_new_app
cd my_new_app
rm -rf .git
git init
cd apps/sandwich_app
flutter pub get
```

2. Replace the app name and package id (manual steps described above).

3. Run the dev flavor locally:

```powershell
cd apps/sandwich_app
flutter run --flavor dev -t lib/main_development.dart
```

## Author & License

- Author: IbrahimIG1
- Recommended license: MIT — if you want to publish this template, add a `LICENSE` file with the MIT text and a header in source files.

If you want, I can add a `LICENSE` file (MIT) and open a small PR for it.

---

If you want this README to include more specifics (detailed rename scripts, CI/CD examples, or a CONTRIBUTING.md), tell me which sections to expand and I will update the file.







