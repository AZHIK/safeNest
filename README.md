# SafeNest

SafeNest is a production-ready Flutter application designed for Gender-Based Violence (GBV) safety. It features secure authentication, real-time map-based discovery of support centers, and encrypted local storage.

## Features

- **Secure Authentication**: Phone-number-based authentication with OTP verification.
- **Emergency SOS**: Quick access to emergency services and support.
- **Safety Map**: Discovery of nearby support centers using Google Maps.
- **Encrypted Storage**: Secure local data management using Drift (SQLite) and Flutter Secure Storage.

## Prerequisites

Before you begin, ensure you have met the following requirements:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version ^3.11.1)
- [Dart SDK](https://dart.dev/get-dart)
- [Git](https://git-scm.com/downloads)

## Getting Started

### 1. Clone the Project

```bash
git clone https://github.com/AZHIK/safeNest.git
cd SafeNest
```

### 2. Install Dependencies

Fetch all necessary packages from pub.dev:

```bash
flutter pub get
```

### 3. Generate Code

SafeNest uses `build_runner` for code generation (Riverpod and Drift). Run the following command to generate the necessary files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Setup Google Maps

To use the map features, you need to provide a Google Maps API Key:
- **Android**: Update `android/app/src/main/AndroidManifest.xml`.
- **iOS**: Update `ios/Runner/AppDelegate.swift`.

## Running the App

Run the project in debug mode on your connected device:

```bash
flutter run
```

To run on a specific platform:

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## Testing

Run unit and widget tests:

```bash
flutter test
```

## Built With

- [Flutter](https://flutter.dev/) - Framework
- [Riverpod](https://riverpod.dev/) - State Management
- [Drift](https://drift.simonbinder.eu/) - Persistence
- [GoRouter](https://pub.dev/packages/go_router) - Navigation
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter) - Maps Integration
