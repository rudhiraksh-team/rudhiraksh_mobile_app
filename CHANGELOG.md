# Changelog

All notable changes to the Rudhiraksh app will be documented in this file.

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

### Customer release notes

**For patients**
- Your **Thalassemia ID** now appears on your profile and on each transfusion record, so it's easy to find and share.
- The dashboard now shows a **Recent Weight** stat, pulled from your most recent transfusion record.

**For doctors**
- A patient's **Thalassemia ID** is now shown in the patient detail header alongside their other key details.

### Dev release notes

**Surface Thalassemia ID across patient & doctor screens**
- `lib/data/models/doctor_models.dart`: added `thalassemiaPatientId` to `AssignedPatient` (field + constructor) and parsed it in `fromJson`, accepting any of `thalassemia_user_id` / `thalassemiaUserId` / `thalassemia_patient_id` / `thalassemiaPatientId` from the API.
- `lib/controllers/profile_review_controller.dart`: added `thalassemiaIdController`, populated from `patient.thalassemiaPatientId` on load and disposed in `onClose`.
- `lib/screens/user profile/widgets/personal_info_section.dart`: renders the Thalassemia ID on the patient profile.
- `lib/screens/.../transfusion_record_detail_screen.dart`: shows the Thalassemia ID on the transfusion record detail.
- `lib/screens/doctor/doctor_patient_detail_screen.dart`: shows the Thalassemia ID in the doctor's patient detail header.

**Recent Weight stat on the patient dashboard**
- `lib/screens/dashboard/dashboard_screen.dart`: `_DashboardStatsRow` now derives `weightValue` from `controller.doneTransfusions.first.patientWeightKg` (latest done transfusion) and renders a new `Recent Weight` `_StatCard` (unit `kg`, `AppColors.brandRose`, scale icon). Weight was already captured/shown on the transfusion detail; this just promotes it to the dashboard.

## [1.2.3+10] - 2026-05-14

### Customer release notes

**For doctors**
- Push notifications now deliver reliably right after a fresh login — previously the very first sign-in on a device could miss pushes until the next app launch.

**Under the hood**
- The app now talks to the production Rudhiraksh API host. No action needed from you; everything you see is now backed by the live system instead of the staging server.

### Dev release notes

**Production API cut-over + .env-driven config**
- `lib/core/utils/api_constant.dart`: `baseUrl` is now `dotenv.maybeGet('BASE_URL') ?? 'https://admin.rudhiraksh.com/api'`. Old hard-coded fallback was the Railway staging host (`rudhiraksh-api-production.up.railway.app`).
- `lib/firebase_options.dart`: every field on `android` / `ios` `FirebaseOptions` reads from `.env` with the previous hard-coded value as fallback (`FIREBASE_ANDROID_API_KEY`, `FIREBASE_IOS_APP_ID`, etc.). Lets us swap Firebase projects per environment without touching code.
- `lib/main.dart`: `dotenv.load(fileName: '.env')` runs before `Firebase.initializeApp()`. `Firebase.initializeApp` now passes `options: DefaultFirebaseOptions.currentPlatform` so the dotenv-resolved options are actually used.
- `pubspec.yaml`: added `flutter_dotenv: ^5.1.0` and registered `.env` under flutter assets so it's bundled into the build.

**Bug: doctor push notifications dropped on first login**
- Root cause: `LoginController._postLogin` called `PushNotificationService.ensureTokenSynced()` **before** writing `userRole` to storage. `ensureTokenSynced` reads `userRole` to choose the profile endpoint to POST the FCM token to — with an empty role it defaulted to `/patients/profile`, so a doctor's `users.fcmToken` row was never populated and server-side push delivery silently no-op'd until the next login (when the role was already in storage).
- Fix: persist `userRole` immediately after the `/auth/me` response and *before* the FCM sync block.
- Files: `lib/controllers/login_controller.dart:204`.

**Central API logger**
- New `lib/core/utils/api_logger.dart` — `ApiLogger.req / res / err / info`. Tags lines with `[API]`, emits via both `dart:developer.log` (DevTools / IDE) and `print` (`flutter run` / `adb logcat`), silent in release (`kDebugMode` gated), truncates large bodies. Replaces the ad-hoc `debugPrint` / `dart:developer.log` calls that were scattered across every service.
- Migrated to `ApiLogger`: `articles_service.dart`, `bloodbank_service.dart`, `doctor_service.dart`, `document_upload_service.dart`, `login_service.dart`, `notification_inbox_service.dart`, `patient_lab_request_service.dart`, `patient_portal_service.dart`, `profile_photo_service.dart`, `profile_service.dart`, `profile_update_service.dart`, `transfusion_list_service.dart`. Net effect: every outbound request/response/error now has a uniform `→ METHOD url`, `← METHOD url status=… body=…`, `✕ METHOD url error=…` line, and the inline `_log()` helper inside `articles_service.dart` is gone.
- `login_service.dart`: also masks the password field in the request log (`body: {'email': ..., 'password': '***'}`).

**Articles — like button on detail screen, follow-up hardening**
- `ArticlesController.toggleLike` now derives its "source of truth" from whichever of `articles[index]` / `selectedArticle.value` is present instead of bailing out when the list is empty. Covers the deep-link-into-detail-without-list case that the 1.2.2+9 fix still missed if the user toggled twice before `fetchArticles` returned.
- Files: `lib/controllers/articles_controller.dart:35`.

## [1.2.2+9] - 2026-05-08

### Customer release notes

**For patients and doctors**
- The **like button on the article detail page** now actually fills the heart and updates the count when you tap it.
- The app will now **prompt you to update** the moment a new version is available on the Play Store — no more checking manually. Critical updates apply automatically; routine updates download in the background and ask you to restart when ready.

### Dev release notes

**Articles — like button on detail page was a no-op**
- Root cause: `ArticlesController.toggleLike` only mutated the `articles` list, but `ArticleDetailScreen` binds to `selectedArticle.value`. Tapping the heart on the detail page silently updated the (off-screen) list entry while the on-screen heart never changed. Worse, deep-linking into the detail page (or hot-restarting on it) meant the article wasn't in the list at all, so the early `if (index == -1) return;` made the tap a complete no-op.
- Fix: `toggleLike` now optimistically updates whichever sources are present — `articles[index]` and/or `selectedArticle.value` — rolls both back on server failure, and refetches detail (in addition to the list) on success.
- Files: `lib/controllers/articles_controller.dart:35`.

**In-app updates via Google Play (Android)**
- Added `in_app_update: ^4.2.3` (resolves to 4.2.5).
- New `lib/data/services/app_update_service.dart`:
  - Single entry point `AppUpdateService.checkForUpdate()`. Fire-and-forget; never throws (non-Play installs throw inside the plugin and we swallow + report to Crashlytics).
  - 30-minute debounce so quick foreground/background toggles don't hammer the Play update API.
  - Branches on Play Console **in-app update priority**: `>= 4` → `performImmediateUpdate()` (full-screen blocking force-update sheet); `< 4` and `flexibleUpdateAllowed` → `startFlexibleUpdate()` (background download), then a `Get.snackbar` with a **RESTART** action wired to `completeFlexibleUpdate()`.
- Hooks in `lib/app.dart`:
  - `initState` schedules a check via `addPostFrameCallback` so it never blocks startup paint.
  - `didChangeAppLifecycleState` re-checks on `resumed` (alongside the existing FCM token sync).
- Operational: Force-update is controlled per-release in Play Console under **In-app update priority** on the release page. Set 4 or 5 for breaking releases. The plugin is a no-op on debug, sideloaded, and emulator builds — verify on Internal Testing track.

## [1.2.0+7] - 2026-05-07

### Customer release notes

**For patients**
- Edit your **address** and **emergency contacts** directly from your profile. Each editor opens on its own screen with a sticky **Save** button — no more inline forms that closed when the keyboard appeared.
- Each emergency contact now supports a **relationship** field (e.g., Father, Spouse) and a **country code picker** (defaults to +91) on the phone number.
- New **"Mark all as read"** action on the notifications screen — appears whenever you have unread items, taps to clear them in one go.
- The **like button** on articles now actually fills the heart, persists across sessions, and updates the count instantly when you tap.

**For doctors**
- Same notifications and articles improvements as patients.

**Fixes**
- Fixed a bug where the Emergency Contacts edit form snapped back to read-only the moment you started typing into an existing phone number.
- The Articles screen now shows a clear error message and a **Retry** button when the feed can't load, instead of silently displaying "No articles yet" for every failure.

### Dev release notes

**Profile editing refactor**
- Editing moved off the review screen onto dedicated routes: `/profile/edit-address` and `/profile/edit-emergency-contacts`, registered in `app_routes.dart` with helpers in `navigation_helper.dart`.
- New per-form mini-controllers: `EditAddressController`, `EditEmergencyContactsController`. Each owns its text controllers, debounced validation, country dial codes, and `save()` (validate → diff → `ProfileUpdateService.updateProfile` → push response into `GlobalProfileController` → `Get.back()`). Auto-disposed on pop.
- `profile_review_controller.dart`: **430 → 76 LOC**. Now read-only display state only.
- `profile_glass_card.dart`: **498 → 30 LOC**. Pure composition.
- New section widgets: `personal_info_section.dart`, `contact_info_section.dart`, `address_section.dart`, `emergency_contacts_section.dart`, plus shared `profile_section_card.dart` chrome.
- Deleted unused `save_button.dart` (referenced the now-removed `saveProfile`).

**Bug: Emergency Contacts edit form collapsed mid-typing**
- Root cause: `ProfileGlassCard` was a `StatelessWidget` with `RxBool isAddressEditing = false.obs` / `isEmergencyEditing` as fields. Soft-keyboard appearance flips `MediaQuery.viewInsets.bottom` → `ProfileReviewScreen` rebuilds → `ProfileGlassCard` re-instantiated → fresh `false` `RxBool`s → edit mode collapsed. Fix landed earlier in this branch by promoting it to a `StatefulWidget`; this release moves the editing concern off the widget entirely so the bug class can't recur.

**Emergency contact relationship**
- Mobile: `patient_model.dart` adds `emergencyContactRelationship` (required, default `''`) and `emergencyContactRelationship2` (nullable). Edit controller, diff, and UI updated.
- API: `patients.validation.ts` adds optional `emergencyContactRelationship` / `emergencyContactRelationship2`. DB columns already existed (`patients.schema.ts:45,48`). OpenAPI doc (`patients.router.ts`) updated.

**Country code support on emergency phones**
- Integrated `intl_phone_field` ^3.2.0 (default country `IN`).
- Edit controller sends `+CC<digits>` as `emergencyContactPhone` / `emergencyContactPhone2`. The existing API `optionalPhone` helper strips the prefix and stores the 10-digit national number — DB schema unchanged.
- Limitation: country code is not persisted; on next load it defaults back to `+91`. Persisting requires a new column on `patients`.

**Notifications**
- `NotificationAppBar` adds a "Mark all as read" action in the `actions` slot. Reactive — only renders when `controller.notifications.any((n) => !n.isRead)`. Calls existing `controller.markAllAsRead()` (which already mirrors to the server via `NotificationInboxService.markAllRead`).

**Articles — like button works**
- Root cause: API never emitted `isLikedByMe`; `Article.fromJson` always defaulted it to `false`, so the heart never appeared filled even though the DB write succeeded.
- API: `articles.service.ts` `list()` and `getById()` now accept `userId` and compute `isLikedByMe: article.likes.some((l) => l.userId === userId)`. Wired through `articles.controller.ts`.
- Mobile: `Article.copyWith({likesCount, isLikedByMe})` added. `ArticlesController.toggleLike` does an **optimistic toggle** (heart + count flip on tap) → server call → on success refetch to reconcile, on failure roll back to the original article.

**Articles — error surfacing**
- `ArticlesService.fetchArticles` returns `ArticlesFetchResult { articles, error }` instead of silently returning `[]`. Distinguishes 401 / 403 / 5xx / `SocketException` / parse failures, pulls `message` out of the JSON error body when present, reports each to `ErrorReportingService` (Crashlytics in prod).
- `ArticlesController.error` (`RxnString`) populated from the result.
- `articles_screen.dart`: split into three discrete states — loading, error (`_ArticlesErrorState` with retry), empty (`_ArticlesEmptyState`), list.
- Diagnostic logs prefixed `[ARTICLES]` (URL, status, response body preview) emitted via `dart:developer.log` and `print` so they show up in both `flutter run` and `adb logcat -s flutter`.

**Platform permissions audit**
- `AndroidManifest.xml`: added `<uses-permission android:name="android.permission.CAMERA" />` (required by `image_picker` when launching `ImageSource.camera` — without it the camera intent silently no-ops on most devices). Used by profile avatar capture, doctor document upload, and patient lab-report upload.
- `AndroidManifest.xml`: added `<uses-feature android:name="android.hardware.camera" required="false" />` and `<uses-feature android:name="android.hardware.camera.autofocus" required="false" />` so the app remains installable on cameraless devices (tablets, Chromebooks).
- `ios/Runner/Info.plist`: added `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` purpose strings. iOS hard-crashes on the first camera / photo-library access without these, so previous builds would have abended the moment a user tapped "Take photo" or "Choose from gallery".
- Confirmed NOT required (deliberately not added): `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES` on Android — `image_picker` 1.x uses Android Photo Picker and `file_picker` uses the Storage Access Framework, both of which are permission-free. Adding storage permissions would trigger a Play Store policy review.

## [1.1.1+6] - 2026-05-06

- API response handling updates and minor optimizations.

## [1.1.0+5] - 2026-05-05

### Customer release notes

**For patients**
- New **Lab Requests** card on the home dashboard — see pending tests your doctor has ordered, upload reports, and track review status in one place.
- Refreshed app branding: the official Rudhiraksh logo now appears on the splash screen and the login welcome screen.

**For doctors**
- Create transfusion records directly from a patient's profile.
- New **Ferritin**, **Chelation**, and **Images** tabs in the patient detail screen for richer clinical context.
- Upload documents on a patient's behalf with document type and notes.
- Tap any patient document or lab report to choose **View** (preview inside the app) or **Download** (save through the browser).
- Push notification registration is now more reliable across app launches.

**Fixes**
- Fixed a bug where viewing patient-uploaded documents did nothing on Android 11+.
- Fixed the "Mark as reviewed" button on the lab requests tab so the label is no longer clipped.

### Dev release notes

**Features**
- Patient lab-requests feature: new `PatientLabRequestsController`, `patient_lab_request_service.dart`, `lib/screens/patient_lab_requests/`, and dashboard entry card. Wired through `app_routes.dart` and `navigation_helper.dart`.
- Doctor patient-detail expansion: new `chelation_tab.dart`, `ferritin_tab.dart`, `images_tab.dart`, `upload_document_sheet.dart`, and `create_transfusion_screen.dart`. Backed by additions to `doctor_service.dart` (+~227 LOC), `doctor_patient_detail_controller.dart` (+~161 LOC), and new model classes (`PatientDocument`, `LabRequest`, image record) in `doctor_models.dart`.
- New shared `FileViewerHelper` (`lib/data/helper function/file_viewer_helper.dart`) — bottom sheet exposing **View** (`LaunchMode.inAppBrowserView`) and **Download** (`LaunchMode.externalApplication`) actions for any remote URL. Used by both `documents_tab.dart` and `lab_requests_tab.dart`.
- Branding refresh: registered `assets/logo/svg/` and added `flutter_svg` usage in `splash_logo.dart` and `login_screen.dart` (white mono variant inside existing brand-gradient containers).

**Platform / build**
- `AndroidManifest.xml`: added `<queries>` entries for `https`/`http` VIEW intents. Without these, `canLaunchUrl()` returns `false` on Android 11+, which was the root cause of the silent document-open failure.
- `pubspec.yaml`: registered `assets/logo/svg/` under flutter assets.
- `pubspec.lock`: refreshed to pick up `flutter_svg` and transitive deps.

**Infra**
- `push_notification_service.dart`: registration flow updated (+~85 LOC) for more deterministic token handoff.
- `openapi.json`: checked in for backend contract reference.

**UI fixes**
- `lab_requests_tab.dart`: removed hard-coded `height: 40` on the "Mark as reviewed" button (was clipping icon + label); now sizes via `vertical: 12` padding.

## [1.0.2+4] - 2026-05-02

- Updated target audience to 18+ only and enabled Google Play minor-access restriction to comply with Families Policy. No functional changes; resubmission build for Play review.

## [1.0.2+3] - 2026-04-29

- Release update.

## [1.0.1+2] - 2026-04-29

- Release update.

## [1.0.0+1]

- Initial release.
