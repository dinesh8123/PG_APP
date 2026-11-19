<div align="center">

# PG_APP

### PG & Hostel Management Application

A Flutter-based mobile application for managing paying guest (PG) accommodations and hostels through role-based dashboards for **Owners**, **Managers**, and **Tenants**.

**Flutter** · **Dart** · **GetX** · **Material 3** · **Android & iOS**

[Features](#features) · [Getting Started](#getting-started) · [Project Structure](#project-structure) · [Releases](#android-apk-and-releases) · [Limitations](#current-limitations)

</div>

---

## Overview

PG_APP brings day-to-day accommodation operations into a single mobile interface. Owners and managers can review occupancy and financial information, manage tenants and beds, record electricity readings, and track complaints. Tenants have a separate experience for viewing rent and electricity information, raising complaints, and checking the food menu.

The application is built with Flutter and uses GetX for reactive state management and navigation-related application state. It includes light and dark themes, an animated splash screen, and a demo OTP login flow.

> **Project status:** Functional Flutter prototype / demonstration application. It does **not** currently include production authentication, a remote backend, or persistent storage for operational records.

## Features

### Owner & Manager

- **Dashboard:** Review accommodation and financial information.
- **Bed availability:** View rooms, beds, and occupancy status.
- **Tenant management:** Add, edit, and remove tenants; associate tenants with beds.
- **Rent management:** Review rent records, update amounts, and mark payments as paid or unpaid.
- **Electricity readings:** Record and manage room meter readings.
- **Complaint management:** View, update, and resolve tenant complaints.

> In the current source, Owner and Manager use the same staff dashboard and available actions.

### Tenant

- **Rent:** View rent information and payment status.
- **Electricity:** View electricity usage and calculated charges where readings exist.
- **Complaints:** Submit and review maintenance or service complaints.
- **Food menu:** Browse the weekly meal menu.

### Application Experience

- Role-based login and navigation
- Light and dark themes, with theme preference stored using `shared_preferences`
- Animated splash screen and custom app logo
- Material 3 interface and reusable UI components
- Reactive screen updates through GetX

## Technology Stack

| Technology | Purpose |
| --- | --- |
| Flutter / Dart | Cross-platform mobile application |
| GetX (`get`) | Reactive state and controller management |
| `shared_preferences` | Persisting the selected theme |
| `intl` | Dates, months, and currency formatting |
| `image_picker` | Selecting tenant-related document images |
| Material 3 | UI components and theming |
| `flutter_launcher_icons` | Generating Android and iOS launcher icons (when configured) |
| `flutter_native_splash` | Generating native splash screens (when configured) |

## Getting Started

### Prerequisites

- Flutter SDK compatible with the project's `pubspec.yaml`
- Dart SDK (included with Flutter)
- Android Studio and Android SDK for Android development
- macOS with Xcode for iOS development
- Git

Check your installation:

```bash
flutter doctor
```

### Clone the repository

```bash
git clone https://github.com/dinesh8123/PG_APP.git
cd PG_APP
```

### Install dependencies

```bash
flutter pub get
```

### Generate platform folders if needed

If your checkout contains only the Flutter source files and does not include `android/` or `ios/`, generate the platform projects:

```bash
flutter create --platforms=android,ios .
flutter pub get
```

> iOS platform generation and builds require macOS and Xcode. For Android-only development, use `flutter create --platforms=android .`.

### Run the app

```bash
flutter devices
flutter run
```

Choose a connected Android device, Android emulator, or supported iOS simulator.

## Demo Login

The project includes a **demonstration-only** OTP flow:

| Field | Demo value |
| --- | --- |
| Mobile number | `123456789` |
| OTP | `1234` |
| Staff roles | Owner or Manager |

1. Open the application and switch to the **Owner & Manager Portal**.
2. Choose **Owner** or **Manager**.
3. Enter the demo number and request an OTP.
4. Enter the demo OTP to continue.

**Important:** The OTP is checked locally; no real SMS or WhatsApp message is sent. Tenant access depends on a tenant record being available in the current session. Do not use these credentials or this authentication flow in a production deployment.

## Project Structure

```text
lib/
├── main.dart
├── controllers/
│   ├── auth_controller.dart
│   ├── pg_controller.dart
│   └── theme_controller.dart
├── core/
│   ├── theme.dart
│   ├── utils.dart
│   └── widgets.dart
├── data/
│   ├── models.dart
│   └── pg_repository.dart
└── features/
    ├── auth/
    ├── splash/
    ├── shell/
    ├── owner/
    ├── manager/
    ├── staff/
    └── tenant/
assets/
└── logo.png
test/
└── theme_test.dart
pubspec.yaml
```

### Architecture

The application follows a lightweight feature-based structure:

- **Presentation:** Flutter screens and shared Material widgets in `features/` and `core/`.
- **Controllers:** GetX controllers coordinate authentication, theme selection, and PG operations.
- **Models:** Dart data classes represent rooms, beds, tenants, rent records, meter readings, complaints, and menu items.
- **Repository:** `PgRepository` defines data operations. The included `InMemoryPgRepository` implements them using in-memory collections.

This separation provides a starting point for replacing the demo repository with a persistent local database or an authenticated backend.

## Themes and Branding

The app supports light and dark themes. The selected mode is saved through `shared_preferences` and restored at launch.

The project uses `assets/logo.png` for in-app branding. To configure platform launcher icons and a native splash screen, update `pubspec.yaml` with valid image paths and run:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

These commands require the corresponding development dependencies and configuration entries in `pubspec.yaml`.

## Android APK and Releases

Build a release APK:

```bash
flutter pub get
flutter build apk --release
```

The APK is typically generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

To distribute a build through GitHub:

1. Open the repository's **Releases** page.
2. Select **Draft a new release**.
3. Create a version tag such as `v1.0.0`.
4. Attach the APK and publish the release.

**Releases:** https://github.com/dinesh8123/PG_APP/releases

> Before public distribution, configure appropriate Android signing, test the release on physical devices, and replace demo authentication.

## iOS Build

On macOS with Xcode configured:

```bash
flutter pub get
flutter build ios --release
```

For App Store / TestFlight distribution, configure your bundle identifier, signing team, provisioning, and Apple Developer account, then use the appropriate iOS archive / IPA workflow.

## Tests and Quality Checks

Run static analysis and the included theme test:

```bash
flutter analyze
flutter test
```

The repository includes a theme test, but comprehensive widget, integration, and device testing are still recommended.

## Current Limitations

- **In-memory operational data:** The included `InMemoryPgRepository` does not persist tenants, rent records, complaints, or meter readings across app restarts.
- **Demo authentication:** OTP verification uses hard-coded values and is not connected to an SMS provider or identity service.
- **No online synchronization:** There is no cloud backend or multi-device synchronization in the supplied source.
- **Payments:** Rent payment status is tracked within the application; no payment gateway integration is provided.
- **Role access:** Owner and Manager currently share the same staff interface; production-grade authorization is not implemented.
- **Starter room data:** The repository initializes a small example set of rooms and beds for demonstration.

**Do not store real tenant identity documents, sensitive personal data, or production payment information in this prototype.**

## Future Improvements

- Persistent storage using SQLite, Isar, or a backend service
- Secure, server-verified authentication and role-based authorization
- Room and bed administration workflows
- Real-time synchronization and data backups
- Payment gateway integration and receipts
- Notifications and complaint assignment workflows
- Automated testing and CI/CD for Android and iOS

## Contributing

Suggestions, bug reports, and improvements are welcome. Open an issue describing the problem or proposed feature. For code changes, create a branch and submit a pull request with a concise description and relevant testing details.

## License

No open-source license has been specified for this repository. Unless a license is added, all rights remain reserved by the copyright holder. If you intend to accept public reuse or contributions, add a `LICENSE` file with your chosen terms.

---

<div align="center">

**PG_APP** — Built with Flutter for PG and hostel management.

[Repository](https://github.com/dinesh8123/PG_APP) · [Releases](https://github.com/dinesh8123/PG_APP/releases)

</div>
