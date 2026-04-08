# CheckMe – AI Context

## 1. Projektüberblick

CheckMe ist eine Flutter-App zur:
- Überwachung des Gesundheits-Status einer Person
- Die Person muss in regelmäßigen Abständen einen Button drücken
- Der Button muss innerhalb eines bestimmten Zeitraums (Uhrzeit start ende) gedrückt werden
- Wird der Button nicht gedrückt, wird eine Meldung an einen oder mehrere Kontakte geschickt
- Der zeitlich Abstand, der Karenzzeitraum, die Anzahl der Meldungen ist konfigurierbar.
- Allgemein soll die App weitgehend konfigurierbar sein.
- Die funktionalen Teile sollen möglichst lose gekoppelt sein, damit spätere Änderung, Erweiterungn möglichst einfach möglich sind
- Zunächste soll die Meldung per E-Mail erfolgen

Technologien:
- Flutter
- Backend für Mailversand, Kontakte: Firebase (Firestore + Cloud Functions + Auth)
- Github repository
- Clean Architecture
---

## 2. Projekt-Struktur

```
Package-Name: de.mydigits.checkme

checkme_flutter/
├── lib/
│   ├── main.dart                          # App-Einstiegspunkt, Firebase-Init
│   ├── firebase_options.dart              # Firebase-Konfiguration (flutterfire configure)
│   ├── injection_container.dart           # GetIt DI-Setup
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart         # Standardwerte, Task-Namen
│   │   │   └── firestore_constants.dart   # Firestore Collection-Namen
│   │   ├── error/
│   │   │   ├── exceptions.dart            # ServerException, CacheException
│   │   │   └── failures.dart              # Failure-Klassen (dartz)
│   │   ├── router/
│   │   │   └── app_router.dart            # GoRouter: /, /config, /contacts
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Material3-Theme (light/dark)
│   │   └── utils/
│   │       └── time_utils.dart            # isWithinWindow, isOverdue, nextDeadline
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── check_in_config.dart       # Konfigurationsparameter
│   │   │   ├── check_in_record.dart       # Check-in Eintrag
│   │   │   ├── contact.dart               # Kontakt (Name, Email)
│   │   │   └── notification_log.dart      # Versandprotokoll
│   │   ├── repositories/
│   │   │   ├── check_in_repository.dart
│   │   │   ├── config_repository.dart
│   │   │   └── contact_repository.dart
│   │   └── usecases/
│   │       ├── perform_check_in.dart
│   │       ├── get_check_in_status.dart
│   │       ├── get_config.dart
│   │       ├── save_config.dart
│   │       ├── get_contacts.dart
│   │       ├── add_contact.dart
│   │       ├── update_contact.dart
│   │       └── delete_contact.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── check_in_config_model.dart  # + .g.dart (json_serializable)
│   │   │   ├── check_in_record_model.dart  # + .g.dart
│   │   │   └── contact_model.dart          # + .g.dart
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   └── config_local_datasource.dart   # SharedPreferences
│   │   │   └── remote/
│   │   │       ├── check_in_remote_datasource.dart  # Firestore
│   │   │       ├── config_remote_datasource.dart    # Firestore
│   │   │       └── contact_remote_datasource.dart   # Firestore
│   │   └── repositories/
│   │       ├── check_in_repository_impl.dart
│   │       ├── config_repository_impl.dart
│   │       └── contact_repository_impl.dart
│   │
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── auth_provider.dart          # Firebase Anonymous Auth
│   │   │   ├── check_in_provider.dart      # CheckInNotifier
│   │   │   ├── config_provider.dart        # ConfigNotifier
│   │   │   └── contact_provider.dart       # ContactsNotifier
│   │   └── pages/
│   │       ├── home/
│   │       │   ├── home_page.dart
│   │       │   └── widgets/
│   │       │       ├── check_in_button.dart    # Großer runder Button
│   │       │       └── status_indicator.dart   # Status-Card mit Countdown
│   │       ├── config/
│   │       │   ├── config_page.dart
│   │       │   └── widgets/
│   │       │       ├── interval_slider.dart
│   │       │       └── time_window_picker.dart
│   │       └── contacts/
│   │           ├── contacts_page.dart
│   │           └── widgets/
│   │               ├── contact_form_dialog.dart
│   │               └── contact_list_tile.dart
│   │
│   └── background/
│       └── background_service.dart         # Workmanager-Task (Android)
│
├── functions/                              # Firebase Cloud Functions (Node.js/TypeScript)
│   └── src/index.ts                        # Email-Versand via nodemailer
│
├── firestore.rules                         # Sicherheitsregeln
├── firestore.indexes.json
└── firebase.json
```

---

## 3. Tech-Stack

```
Plattform:          Flutter (Dart ≥3.10)
State Management:   Riverpod 2.x (flutter_riverpod, AsyncNotifier)
Navigation:         GoRouter
DI:                 GetIt
Backend:            Firebase (Firestore, Auth Anonymous, Cloud Functions)
Notifications:      E-Mail via nodemailer (Firebase Cloud Functions)
Background:         Workmanager (Android periodischer Task, 1h)
Local Storage:      SharedPreferences (Config-Fallback)
Codegen:            json_serializable, build_runner
Funktional:         dartz (Either<Failure, T>), equatable
```

---

## 4. Konfigurationsparameter

| Parameter              | Typ     | Default | Beschreibung                          |
|------------------------|---------|---------|---------------------------------------|
| intervalHours          | int     | 12      | Wie oft muss der Button gedrückt werden |
| timeWindowStartHour    | int     | 8       | Zeitfenster Beginn (Stunde)           |
| timeWindowStartMinute  | int     | 0       | Zeitfenster Beginn (Minute)           |
| timeWindowEndHour      | int     | 22      | Zeitfenster Ende (Stunde)             |
| timeWindowEndMinute    | int     | 0       | Zeitfenster Ende (Minute)             |
| gracePeriodMinutes     | int     | 30      | Karenzzeit nach Intervall-Ablauf      |
| maxNotifications       | int     | 3       | Max. E-Mails pro Tag                  |
| isActive               | bool    | true    | Überwachung ein/aus                   |

Config wird in Firestore (`users/{uid}/config/user_config`) gespeichert
und lokal in SharedPreferences gecacht.

---

## 5. Architektur-Regeln

- **Clean Architecture**: domain ← data ← presentation (keine umgekehrten Abhängigkeiten)
- **Domain-Layer** hat keine Flutter/Firebase-Abhängigkeiten
- **Either<Failure, T>** für alle Repository-Rückgaben (dartz)
- **Loose Coupling**: Repositories gegen Interfaces programmiert, DI via GetIt
- **Firestore-Struktur**:
  - `users/{uid}/check_ins/{id}` – Check-in Einträge
  - `users/{uid}/config/user_config` – Konfiguration
  - `users/{uid}/contacts/{id}` – Notfallkontakte
  - `users/{uid}/notification_logs/{id}` – Versandprotokoll
  - `overdue_triggers/{id}` – Auslöser für Cloud Function
- **Hintergrund-Check** (Workmanager, Android): prüft stündlich ob Check-in überfällig;
  bei Überfälligkeit schreibt er ein Dokument in `overdue_triggers` →
  Cloud Function verschickt E-Mails und löscht das Trigger-Dokument

---

## 6. Setup & Deployment

### Flutter-App
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Firebase einrichten
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=DEIN_FIREBASE_PROJECT_ID
# → generiert lib/firebase_options.dart mit echten Credentials
```

### Cloud Functions konfigurieren
```bash
cd functions
npm install
firebase functions:config:set \
  email.host="smtp.gmail.com" \
  email.port="587" \
  email.user="deine@email.de" \
  email.pass="APP_PASSWORD" \
  email.from="checkme@example.com"
firebase deploy --only functions
```

---

## 9. Agent-Regeln

Wenn ein Coding-Agent verwendet wird:

- Ändere nur Hand-Code
- Führe nach Änderungen aus:
- Zeige nur git diff als Output
- Maximal 10–15 Dateien pro Refactoring-Schritt
