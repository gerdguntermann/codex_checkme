# CheckMe

CheckMe is a Flutter app for health monitoring through recurring user check-ins.

If a user misses a configured deadline, the app triggers Firebase-based notification flow so emergency contacts can be informed by email.

## Features

- Manual check-in flow
- Fixed-time and interval-based reminder modes
- Configurable grace period
- Emergency contact management
- Firebase-backed persistence
- Android background overdue detection

## Stack

- Flutter / Dart
- Riverpod
- GoRouter
- Firebase Auth, Firestore, Cloud Functions
- Resend for email delivery
- Workmanager on Android

## Project Notes

- Primary package: `de.mydigits.checkme`
- Primary target: Android
- Codex project instructions live in `AGENTS.md`
- Legacy Claude-specific files are still present but are no longer the primary instruction source

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Tests

```bash
flutter test test/
flutter test integration_test/
```

## Firebase

You need environment-specific Firebase configuration and function secrets:

- `lib/firebase_options.dart`
- `functions/.env` with `RESEND_API_KEY`
