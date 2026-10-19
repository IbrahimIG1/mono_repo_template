# Mobile notifications setup

Goal 5 supports Android and iOS only. Runtime push receipt, notification taps,
and notification-triggered deep links remain `Manual-validation-required` until
the device checklist below is recorded. Firebase files and credentials are
app-owned and must never be copied into `notifications_fcm`.

## App composition

An app that opts in adds `notifications_core` and `notifications_fcm`, initializes
its own Firebase app, then constructs `FcmPushNotificationClient` in its
composition root. Request permission from an explicit user-facing flow. The
request covers the Android 13+ runtime notification permission and the iOS
notification authorization flow; handle `deniedPermanently` by explaining how
to use system settings rather than prompting repeatedly.

Register `mobileFcmBackgroundHandler` before `runApp`. The provided handler is a
top-level entry point, creates its payload decoder locally, and does not access
foreground DI. If the product must persist background data, replace it with an
app-owned top-level handler that constructs only isolate-safe dependencies. Do
not navigate or assume a foreground router from the background isolate.

## Android

1. Put the app's `google-services.json` under the app's Android module using the
   project's secret/configuration delivery process; do not commit production
   credentials to this template.
2. Apply the Firebase/Google Services Gradle configuration in that app only.
3. Confirm the app targets an Android SDK that supports the Android 13 runtime
   notification permission.
4. Exercise authorized, denied, and permanently-denied permission outcomes on a
   real Android 13+ device.

## iOS and APNs

The Firebase packages resolved by the pinned Goal 5 lockfile declare iOS 15.0
as their minimum deployment target. Set the app target to iOS 15.0 or newer;
CocoaPods apps must set the Podfile platform as well. Re-verify this constraint
whenever Firebase dependencies change; do not assume a future release keeps the
same minimum.

1. Enable Push Notifications and the Background Modes / Remote notifications
   capability for the app target in Xcode.
2. Register the exact bundle identifier in the Firebase project and deliver the
   app-owned `GoogleService-Info.plist` outside this template.
3. Upload the APNs authentication key (or the selected certificate) to the
   Firebase project. The private key is never stored in this repository.
4. Confirm signing, provisioning, and the `aps-environment` entitlement for the
   intended build configuration.
5. Validate permission and token/registration behavior on a physical iOS device;
   the simulator and a no-codesign build are not evidence of push delivery.

## Manual device record

For each mobile platform record the app build SHA, OS/device, permission result,
foreground receipt, background receipt, terminated-state tap, duplicate tap,
protected destination through sign-in, denied destination after re-authorization,
and token/registration rotation. Only then may the matrix claim be reconsidered.
