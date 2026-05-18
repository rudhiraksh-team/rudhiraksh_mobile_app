# Rudhiraksh

Mobile app for the Rudhiraksh thalassemia / blood-transfusion care platform. Built with Flutter, ships to Android via the Google Play Store. Two roles share one binary: **patients** (track transfusions, manage profile, upload lab reports, read articles) and **doctors** (manage patients, create transfusion records, request labs, upload documents).

The companion backend (Node/TypeScript) lives in a separate repo and is consumed via REST at `BASE_URL` (defaults to `https://admin.rudhiraksh.com/api`).

---

## Features

### For patients
- **Dashboard** with upcoming transfusion card and inline calendar.
- **Profile** with dedicated edit screens for address and emergency contacts (relationship + country code on each phone).
- **Lab requests** — see pending tests ordered by your doctor, upload reports, track review status.
- **Medical history** — transfusion records and history view.
- **Articles** — read, like, comment, threaded replies.
- **Notifications** with mark-all-as-read.
- **Bloodbank info** lookup.

### For doctors
- **Patient list** and rich patient detail with tabs: transfusions, growth chart, ferritin, chelation, images, documents, lab requests.
- **Create transfusion record** directly from a patient's profile.
- **Create lab request** and **upload documents** on a patient's behalf.
- View / download any patient document or report (in-app browser or external download).

---

## Tech stack

| Layer            | Choice                                                  |
| ---------------- | ------------------------------------------------------- |
| Framework        | Flutter (Dart SDK ^3.11.1)                              |
| State management | GetX (`get`)                                            |
| Local storage    | `get_storage`                                           |
| Network          | `http`                                                  |
| Auth / API       | Bearer token in `GetStorage`, REST against the backend  |
| Push             | Firebase Messaging + `flutter_local_notifications`      |
| Crash reporting  | Firebase Crashlytics                                    |
| Config           | `flutter_dotenv` (all configurable values, see below)   |
| Charts           | `fl_chart`                                              |
| In-app updates   | `in_app_update` (Google Play priority-driven)           |

---

## Project structure

```
lib/
├── main.dart                  # Entry point: dotenv → Firebase → Crashlytics → GetStorage → push → runApp
├── app.dart                   # MaterialApp, theme, lifecycle hooks (FCM resync + update check on resume)
├── firebase_options.dart      # Firebase config, .env-overridable
├── controllers/               # GetX controllers, one per screen/feature
├── core/
│   ├── constants/             # AppColors, AppStrings
│   ├── theme/                 # Light/dark theme + per-context color resolver
│   └── utils/                 # ApiConstants (baseUrl), ApiLogger
├── data/
│   ├── models/                # JSON-serializable plain Dart classes
│   ├── services/              # Static API services per domain (articles, profile, doctor, ...)
│   └── storage/               # Local persistence (notifications cache, etc.)
├── routes/                    # GetX route table + navigation_helper
└── screens/                   # UI by feature, widgets in nested folders
```

Architectural conventions:
- **Services are stateless statics** — `ArticlesService.fetchArticles()`, `ProfileService.update()`, etc. They own HTTP, error mapping, and Crashlytics reporting.
- **Controllers own UI state** — reactive (`Rx`/`Obx`), call services, surface `error` strings for UI to render.
- **Mini-controllers for forms** — each editable section gets its own controller (`EditAddressController`, `EditEmergencyContactsController`) auto-disposed on `Get.back()`.

---

## Getting started

### Prerequisites
- Flutter SDK matching `pubspec.yaml` (`sdk: ^3.11.1`).
- Android Studio / SDK with API 34+ for Android builds.
- Xcode 15+ for iOS builds (if you need iOS).
- A `.env` file in the repo root (see below).

### First-time setup

```bash
flutter pub get
```

Create `.env` in the repo root:

```env
BASE_URL=https://admin.rudhiraksh.com/api

# Firebase (Android)
FIREBASE_ANDROID_API_KEY=...
FIREBASE_ANDROID_APP_ID=...
FIREBASE_ANDROID_MESSAGING_SENDER_ID=...
FIREBASE_ANDROID_PROJECT_ID=...
FIREBASE_ANDROID_STORAGE_BUCKET=...

# Firebase (iOS)
FIREBASE_IOS_API_KEY=...
FIREBASE_IOS_APP_ID=...
FIREBASE_IOS_MESSAGING_SENDER_ID=...
FIREBASE_IOS_PROJECT_ID=...
FIREBASE_IOS_STORAGE_BUCKET=...
FIREBASE_IOS_BUNDLE_ID=com.rudhiraksh.rudhirakshapp
```

All keys fall back to baked-in defaults in `lib/firebase_options.dart` and `lib/core/utils/api_constant.dart`, so the app still launches without `.env` — but for staging / per-developer overrides, `.env` is the knob.

### Run

```bash
flutter run
```

Debug builds default to `BASE_URL=https://admin.rudhiraksh.com/api`. Override per-developer via `.env`.

---

## Build & release

### Signing

Release signing reads from `key.properties` at the repo root (loaded by `android/app/build.gradle.kts`). Keystore details (alias, passwords, SHA fingerprints) are documented in `jks_config.md`.

### Android release build

```bash
flutter build appbundle --release
```

Upload the `.aab` to Google Play Console. **Bump `version` in `pubspec.yaml` for every release** — the `+N` suffix is Android's `versionCode`, which Play uses to detect updates.

### In-app updates (Android)

The app checks Google Play for a newer version on launch (post-frame, non-blocking) and on every foreground resume (debounced to 30 minutes). Behavior is driven by the **In-app update priority** you set per release in Play Console:

| Priority           | UX                                                                                                  |
| ------------------ | --------------------------------------------------------------------------------------------------- |
| **0–3** (default)  | Background download, snackbar with **RESTART** action when ready (flexible flow).                   |
| **4–5**            | Full-screen blocking Play update sheet — user cannot dismiss without updating (immediate flow).     |

Set priority on the release page in Play Console under **Advanced settings → In-app update priority**, or via the Google Play Publishing API.

**Important caveats:**
- The plugin is a **no-op on debug, sideloaded, and emulator builds**. Play install source is required. To verify the flow works, ship a build to the **Internal Testing** track first, install it, then upload a higher-versionCode build with priority set.
- `versionCode` (the `+N` in `pubspec.yaml`) must strictly increase per release — Play uses it to determine whether an update exists.

### Push notifications

`PushNotificationService` registers FCM, syncs the token with the backend on login + every resume, and routes notification taps to `app_routes.dart` deep links. The high-importance Android notification channel `high_importance_channel` is created on startup.

---

## Versioning

Format: `<semver>+<versionCode>`. Example: `1.2.2+9`.

- **Patch** (`x.y.Z`) — bug fixes, infra additions invisible to users.
- **Minor** (`x.Y.0`) — new user-facing features.
- **Major** (`X.0.0`) — breaking UX changes / large overhauls.

Always increment `+versionCode` on every Play release, regardless of which semver part changed.

See [`CHANGELOG.md`](CHANGELOG.md) for the per-release log (customer-facing notes + dev notes per release).

---

## Useful files

| File                                                 | Purpose                                                       |
| ---------------------------------------------------- | ------------------------------------------------------------- |
| `pubspec.yaml`                                       | App version, dependencies, asset registration.                |
| `.env`                                               | Per-environment overrides for `BASE_URL` and Firebase config. |
| `lib/core/utils/api_constant.dart`                   | Base URL resolution.                                          |
| `lib/data/services/app_update_service.dart`          | Play Store update check.                                      |
| `lib/data/services/push_notification_service.dart`   | FCM + local notification setup.                               |
| `lib/data/services/error_reporting_service.dart`     | Crashlytics wrapper used across services.                     |
| `android/app/build.gradle.kts`                       | Android build config + signing.                               |
| `key.properties`                                     | Keystore credentials (gitignored).                            |
| `jks_config.md`                                      | Keystore reference (alias, fingerprints).                     |
| `CHANGELOG.md`                                       | Per-release notes.                                            |
