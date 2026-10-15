# minimal_app

The smallest executable reference for the admitted V2 platform. It demonstrates an app-owned composition root, constructor injection, lifecycle disposal, typed persistent state, typed authentication, serialized unauthorized recovery, generated routes, protected deep-link restoration, networking configuration, and the brand-neutral design system.

It deliberately contains no Firebase, notifications, realtime, socket, chat, `core`, `shared`, or service locator dependency. Its auth backend is an in-memory reference adapter, not a production backend.

Run from this directory with `flutter run`. Use any syntactically valid email and a password of at least eight characters, then open `/protected/<id>?tab=<name>` to exercise protected routing.
