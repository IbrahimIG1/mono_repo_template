# Capability and Platform Matrix

Allowed states are **Supported**, **Unsupported**, **Experimental**, and **Manual-validation-required**. A successful compile alone never changes a capability to Supported.

| Capability | Android | iOS | Web | Windows | Evidence / limitation |
|---|---|---|---|---|---|
| Foundation contracts and redaction | Supported | Supported | Supported | Supported | Pure-Dart unit tests; no platform API |
| Design system primitives | Manual-validation-required | Manual-validation-required | Manual-validation-required | Manual-validation-required | Widget tests and builds; visual/accessibility review remains manual |
| Dio HTTP adapter | Manual-validation-required | Manual-validation-required | Manual-validation-required | Manual-validation-required | Deterministic adapter tests and builds; real backend/TLS lifecycle not exercised |
| Shared Preferences adapter | Manual-validation-required | Manual-validation-required | Manual-validation-required | Manual-validation-required | Adapter compiles; Goal 3 does not claim per-platform persistence lifecycle validation |
| Secure storage adapter | Manual-validation-required | Manual-validation-required | Experimental | Manual-validation-required | Goal 2 verified Web/Windows round trips; Web plugin behavior is documented experimental; packaged/upgrade lifecycle remains unverified |
| `minimal_app` | Manual-validation-required | Manual-validation-required | Manual-validation-required | Manual-validation-required | Automated builds and widget test; release-device smoke validation remains required |
