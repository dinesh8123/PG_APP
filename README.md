# PG App

Reconstructed from the 28 code blocks supplied in Pasted text(3).txt, with original pubspec.yaml and assets/logo.png.

Run `flutter pub get` then `flutter run`.

This project has not been compiled in this environment.

## Changes in this version
- Data (tenants, rooms, beds, rent, meter readings, complaints) is saved on the phone and survives closing the app. It is removed only if the app is uninstalled or its storage is cleared.
- The login is remembered until the user taps "Log out".
- "Replay Splash" button removed.
- Light/dark theme follows the phone's setting; the manual toggle button is removed.
- All spinners replaced with an Instagram-style loader (`lib/core/insta_loader.dart`).
