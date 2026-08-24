# Changelog

All notable changes to the Rudhiraksh app will be documented in this file.

## [1.2.7+14] - 2026-08-24

### Customer release notes

**For everyone**
- Icons throughout the app now display correctly — a bug in a third-party icon library was causing many icons to render blank.
- Added a clear "No Internet Connection" screen with a Try Again button, shown automatically whenever your device loses connectivity, instead of the app appearing to hang or misbehave.
- Upgraded to the latest Flutter platform release under the hood, for better stability and future compatibility.

### Dev release notes

**Flutter/Android platform upgrade**
- Flutter SDK was already on the latest stable (3.47.1 / Dart 3.13.1); ran `flutter pub upgrade --major-versions` to bring all dependencies current, including major bumps: `file_picker` 8→12, `fl_chart` 0.69→1.2, `flutter_dotenv` 5→6, `flutter_local_notifications` 19→22, `google_fonts` 6→8, `in_app_update` 4→5, plus transitive/minor bumps across Firebase, `connectivity_plus`, `intl`, etc.
- `lib/data/services/push_notification_service.dart`: `flutter_local_notifications` v22 made `initialize()`'s `settings` param and `show()`'s `id` param named/required — updated both call sites.
- `lib/screens/doctor/widgets/upload_document_sheet.dart`, `lib/screens/patient_lab_requests/upload_lab_report_sheet.dart`: `file_picker` v12 removed `FilePicker.platform.pickFiles()` (and the `FilePickerResult.files.single` wrapper); switched to the new single-file `FilePicker.pickFile()` API.
- `android/`: bumped Gradle 8.14→9.3.1, AGP 8.11.1→9.1.0, Kotlin Gradle Plugin 2.2.20→2.4.0, `google-services` plugin 4.4.2→4.5.0, `firebase-crashlytics` plugin 3.0.5→3.0.8 — matched to what a fresh Flutter 3.47.1 template ships, since the previous Gradle version couldn't run on the JDK 25 bundled with current Android Studio. Migrated the deprecated `kotlinOptions {}` DSL to `kotlin { compilerOptions {} }`. (AGP 9's built-in-Kotlin migration was attempted and reverted — its bundled Kotlin Gradle Plugin version was older than Flutter's minimum, so the app keeps the explicit `kotlin-android` plugin for now.)

**Bug: most icons across the app rendered blank**
- Root cause: `solar_icon_pack` 0.3.0 (pulled in by the major-version upgrade) has a packaging bug — its generated icon data references font families as `'solar_bold_icons'`/`'solar_linear_icons'`, but its own `pubspec.yaml` registers them as `'SolarBoldIcons'`/`'SolarLinearIcons'`. Flutter font-family lookups are case-sensitive, so every icon from the package silently failed to resolve. The prior version, 0.2.1, doesn't have this bug but no longer compiles against the current Flutter SDK (it extends `IconData`, which is now a `final` class).
- Fix: replaced `solar_icon_pack` with `solar_icons` (^0.1.0), a differently-maintained wrapper of the same Solar icon set with correctly-registered fonts (`SolarIconsOutline`, `SolarIconsBold`, `SolarIconsBroken`). 61 of the app's 65 used icon names matched 1:1; 4 were remapped (`buildings2`→`buildings_2`, `logout2`→`logout_2`, `magnifer`→`magnifier`, `checkRead`→`checkCircle`). Updated imports and icon references across all 43 files that used the old package.

**New: app-wide "no internet" screen**
- `lib/controllers/connectivity_controller.dart`: new `ConnectivityController` (GetX) wrapping `connectivity_plus`'s connectivity stream into a reactive `isOnline` flag, with a `retry()` for manual re-checks.
- `lib/screens/no_internet/no_internet_screen.dart`: new `NoInternetScreen` — icon, message, and a "Try Again" button styled with the app's existing `AppThemeColors`/`CustomElevatedButton` conventions.
- `lib/app.dart`: `GetMaterialApp.builder` now swaps in `NoInternetScreen` whenever `ConnectivityController.isOnline` is false, and restores whatever route was active the instant connectivity returns — no per-screen changes needed, navigation state is untouched.
- `lib/main.dart`: registers `ConnectivityController` alongside the other app-wide controllers at startup.

## [1.2.6+13] - 2026-05-29

### Customer release notes

**For patients, doctors & blood banks**
- When a blood bank updates its logo, the new logo now shows up on the dashboard after a pull-to-refresh — previously the old logo stayed until you reopened the app.

### Dev release notes

**Bug: blood bank logo didn't refresh on the dashboard for either role**
- Root cause: pull-to-refresh on either dashboard never re-synced the blood bank logo.
  - Doctor: `DoctorDashboardController.refreshData()` only re-fetched the assigned-patients list (`fetchAssignedPatients`); it never refreshed `DoctorProfileController`, which holds `bloodBankLogo` (`profileData['bloodBank']?['logo_url']`) rendered in the dashboard header.
  - Patient: `SplashController.refreshAllData()` → `_fetchBackgroundData()` refreshed `globalProfile.bloodBankData` but not the profile. The header reads `DashboardController.bloodBankPhoto`, which is only copied across by `profile_review_screen`'s post-frame callback — and that callback's `Obx` is keyed on `globalProfile.profileData`, which the refresh never touched. So the header logo stayed stale.
- Fix:
  - `lib/controllers/doctor_dashboard_controller.dart`: `refreshData()` now runs `fetchAssignedPatients()` and `DoctorProfileController.fetchProfile()` together via `Future.wait` (guarded by `Get.isRegistered<DoctorProfileController>()`). Also covers the doctor path of `refreshAllData()`, which routes through `refreshData()`.
  - `lib/controllers/splash_controller.dart`: the patient branch of `refreshAllData()` now awaits `_fetchProfileInBackground(token)` alongside `_fetchBackgroundData(...)`, then pushes the latest values straight into `DashboardController.setProfileAndBloodBankData(...)` (guarded by `Get.isRegistered<DashboardController>()`) rather than relying on the profile-tab callback.

## [1.2.5+12] - 2026-05-27

### Customer release notes

**For everyone**
- Say hello to the new **AI Assistant** — tap the ✨ button on your dashboard to start a chat. It only sees your own data and remembers your conversation between app launches.

**For patients**
- Ask about your transfusions, hemoglobin, upcoming visits, or anything about thalassemia. The assistant can only see your own records — always confirm decisions with your care team.

**For doctors & blood banks**
- Ask about patient management — overdue transfusions, low-hemoglobin counts, or a specific patient by id (e.g. "summarize patient 42"). It's decision-support, not a diagnosis.

### Dev release notes

**New role-aware AI chatbot**
- `lib/data/models/chat_models.dart`: new `ChatMessage` (chat `role` `'user'`/`'assistant'`, `content`, optional `provider` of `'gemini'`/`'groq'`/`'rules'`, plus UI-only `pending`/`error` flags) and `ChatReply` (`conversationId`, `reply`, `generatedBy`) models mirroring the `/api/chatbot` responses.
- `lib/data/services/chatbot_service.dart`: new `ChatbotService` talking to the role-aware `/chatbot` endpoints — `createConversation()` (POST `/chatbot/conversations`), `sendMessage(id, message)` (POST `/chatbot/conversations/:id/messages` → `ChatReply`), and `fetchMessages(id)` (GET `/chatbot/conversations/:id`). Bearer-token auth from `get_storage`; all calls logged via `ApiLogger`. Reply grounding is decided server-side by the caller's role, so the client persists nothing beyond the conversation id.
- `lib/controllers/chatbot_controller.dart`: new `ChatbotController` (GetX). Lazily creates the conversation on the first message, optimistically appends a pending assistant bubble, and persists the active thread id under `chat_conversation_id` in `GetStorage` so the conversation survives restarts. `_restore()` reloads the persisted thread on init and silently drops a stored id that no longer resolves (e.g. after switching accounts). `newChat()` clears the thread.
- `lib/screens/chatbot/chat_screen.dart`: new `ChatScreen` rendering the conversation with a role-specific welcome message, pending/error bubbles, and auto-scroll to the latest reply.
- `lib/routes/app_routes.dart`: registered `AppRoutes.chatbot` (`/chatbot`) → `ChatScreen`.
- `lib/data/helper function/navigation_helper.dart`: added `NavigationHelper.goToChatbot()`.
- `lib/screens/dashboard/dashboard_screen.dart`: added an `auto_awesome` `FloatingActionButton` ("AI Assistant") routing to the chatbot via `NavigationHelper.goToChatbot`.
- `lib/screens/doctor/doctor_dashboard_screen.dart`: added the same FAB, wrapped in `DoctorThemeWrapper` so the assistant keeps the doctor's green theme.

## [1.2.4+11] - 2026-05-25