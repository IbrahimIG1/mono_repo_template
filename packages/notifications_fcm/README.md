# notifications_fcm

Optional Firebase Cloud Messaging adapter for the V2 Android/iOS scope. Apps
own `google-services.json`, `GoogleService-Info.plist`, Firebase initialization,
APNs credentials, payload-to-destination mapping, and handler registration.

Call `requestPermission()` from an app-owned user flow. Firebase Messaging uses
that request for iOS authorization and Android 13+ notification permission; do
not prompt automatically at startup.

Register `mobileFcmBackgroundHandler` before `runApp`. It is a top-level entry
point and creates only a local payload decoder. It does not use foreground DI.
An app needing background persistence should replace it with an app-owned
top-level handler that constructs isolate-safe dependencies locally.

No Firebase configuration or production credentials belong in this package.

The Firebase versions in the pinned Goal 5 lockfile require an iOS 15.0 minimum
deployment target. Apps must set that target in Xcode and, when applicable,
their Podfile, then re-check the constraint when upgrading Firebase dependencies.
