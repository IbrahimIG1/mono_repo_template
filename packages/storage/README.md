# storage

Typed local-storage contracts and injected plugin adapters.

- `package:storage/storage.dart`: `KeyValueStore`, `SecureStringStore`, failures, and an in-memory test implementation.
- `package:storage/shared_preferences.dart`: `SharedPreferencesStore`.
- `package:storage/flutter_secure_storage.dart`: `FlutterSecureStringStore`.

All operations return `Result`; no adapter logs values. There is no broad `clear()` API, which prevents one capability from erasing another capability's keys. Apps own key naming and migration. Platform support and secure-storage limitations are documented in the repository capability matrix.
