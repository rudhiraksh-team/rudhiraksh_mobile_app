# Changelog

All notable changes to the Rudhiraksh app will be documented in this file.

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
