# Capability and Platform Matrix

Allowed states are **Supported**, **Unsupported**, **Experimental**, and **Manual-validation-required**. A successful compile alone never changes a capability to Supported.

| Capability | Android | iOS | Web | Windows | Evidence / limitation |
|---|---|---|---|---|---|
| Foundation contracts and redaction | Supported | Supported | Unsupported | Unsupported | Pure-Dart tests cover the contracts; Web and Windows validation is paused, not deleted |
| Design system primitives | Manual-validation-required | Manual-validation-required | Unsupported | Unsupported | Mobile widget/build evidence exists; Web and Windows validation is paused |
| Dio HTTP adapter | Manual-validation-required | Manual-validation-required | Unsupported | Unsupported | Mobile real-backend/TLS lifecycle remains unverified; Web and Windows validation is paused |
| Shared Preferences adapter | Manual-validation-required | Manual-validation-required | Unsupported | Unsupported | Mobile persistence lifecycle needs device validation; Web and Windows validation is paused |
| Secure storage adapter | Manual-validation-required | Manual-validation-required | Unsupported | Unsupported | Mobile lifecycle needs device validation; prior desktop/browser probes are historical and those targets are now paused |
| Auth contracts and session orchestration | Supported | Supported | Unsupported | Unsupported | Pure-Dart tests cover orchestration; Web and Windows product support is paused |
| Auth secure persistence | Manual-validation-required | Manual-validation-required | Unsupported | Unsupported | Mobile adapter behavior needs device validation; Web and Windows validation is paused |
| Typed routing and auth redirects | Manual-validation-required | Manual-validation-required | Unsupported | Unsupported | Mobile OS launch integration remains manual; Web and Windows validation is paused |
| Push notifications and notification routing | Manual-validation-required | Manual-validation-required | Unsupported | Unsupported | Goal 5 requires recorded device validation; Web and Windows are paused |
| `minimal_app` | Manual-validation-required | Manual-validation-required | Unsupported | Unsupported | Android/iOS builds are automated; release-device smoke validation remains required; Web and Windows are paused |
