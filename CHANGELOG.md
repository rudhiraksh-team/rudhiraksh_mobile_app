# Changelog

All notable changes to the Rudhiraksh app will be documented in this file.

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