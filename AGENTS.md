# CheckMe for Codex

This file is the primary project context for Codex when working in this repository.

## Project Summary

CheckMe is a Flutter app for health monitoring through recurring check-ins.

- The user confirms they are okay by pressing a check-in button.
- If a check-in is missed, emergency contacts are notified by email.
- Two timing modes are supported: fixed daily time or rolling interval.
- After a missed deadline, a configurable grace period begins.
- Notifications are sent through Firebase Cloud Functions using Resend.

Package: `de.mydigits.checkme`
Primary platform: Android

## Stack

- Flutter / Dart 3.10+
- Riverpod 2.x with `AsyncNotifier`
- GoRouter
- Firebase Auth, Firestore, Cloud Functions
- Resend API for email delivery
- Workmanager for Android background execution
- SharedPreferences for config cache / fallback
- `json_serializable` with `build_runner`

## Architecture

The project uses a simplified layered architecture:

`presentation -> data -> Firebase / SharedPreferences`

`domain` contains pure Dart entities and utilities.

### Layer Rules

- `domain/` must not import Flutter or Firebase.
- Firestore access belongs in services under `data/`.
- Providers call services directly; there is no use-case layer.
- Dependency injection is done with Riverpod providers in `lib/presentation/providers/service_providers.dart`.
- Avoid hardcoded collection names and repeated app strings. Use constants.

## Important Paths

- `lib/main.dart`: app startup, Firebase init, logger init
- `lib/core/constants/`: app and Firestore constants
- `lib/core/router/app_router.dart`: app routes
- `lib/core/utils/time_utils.dart`: deadline and status logic
- `lib/core/utils/app_logger.dart`: logging wrapper
- `lib/domain/entities/`: pure domain types
- `lib/data/`: Firestore services and serializable models
- `lib/presentation/providers/`: Riverpod notifiers and DI
- `lib/presentation/pages/`: UI pages and widgets
- `lib/background/background_service.dart`: Android Workmanager logic
- `functions/src/index.ts`: Firebase Cloud Functions

## Data Model

Main config entity: `CheckInConfig`

- `timingMode`: `fixedTime` or `interval`
- `checkInHour`
- `checkInMinute`
- `intervalMinutes`
- `gracePeriodMinutes`
- `maxNotifications`
- `isActive`

Status values from `time_utils.dart`:

- `ok`
- `grace`
- `overdue`

## Firestore Layout

```text
users/{uid}/
|- check_ins/{id}
|- config/user_config
|- contacts/{id}
`- notification_logs/{id}

overdue_triggers/{id}
users/{uid}/background_logs/{id}
```

Background flow on Android:

1. Workmanager runs every 15 minutes.
2. It checks overdue state from the latest check-in and config.
3. If overdue, it writes an `overdue_triggers` document.
4. The Cloud Function sends emails and removes the trigger.

## Working Rules for Codex

### Do

- Use `package:checkme/core/utils/app_logger.dart` instead of importing `dart:developer` directly.
- When adding config fields, update `CheckInConfig`, the matching model, serialization, and tests.
- Add new Firestore collection or document names in `FirestoreConstants`.
- Add reusable app strings in `AppConstants` when appropriate.
- Prefer focused tests for new behavior.

### Do Not

- Do not call Firebase directly from `domain/`.
- Do not add Flutter imports in `lib/domain/entities/`.
- Do not introduce another state-management approach.
- Do not manually edit generated `.g.dart` files unless there is a strong reason and regeneration is handled immediately after.
- Do not commit `lib/firebase_options.dart` if it is environment-specific.

## Build and Test

Install dependencies:

```bash
flutter pub get
```

Regenerate serializable code after model changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run tests:

```bash
flutter test test/
flutter test integration_test/
```

Run the app:

```bash
flutter run
```

## Firebase Notes

- Anonymous auth is intentional; there is no full login flow.
- Android background checks are implemented; iOS background behavior is not.
- Functions expect a `functions/.env` with `RESEND_API_KEY`.

## Existing Claude Files

`CLAUDE.md` and `.claude/` are legacy project artifacts from the original setup. Treat `AGENTS.md` as the authoritative Codex instruction source.
