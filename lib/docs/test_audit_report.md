# FitHer — Full App Audit & Test Suite Report

Date: 2026-07-21
Scope: `fit_her-main` (Flutter client) + `partner_backend` (Node/Express backend), with a full notification-system deep dive as specifically requested.

## 1. What this covers

This was a full-app audit (every screen, controller, repo, model, and service catalogued) plus a dedicated deep dive into the notification system end-to-end: FCM push, local notifications, real-time socket notifications, notification preferences, the in-app notification inbox, and the backend's scheduled notification jobs.

Given the size of this codebase (200+ Dart files, a 1972-line "god controller", a 1132-line "god repo" with ~95 methods, and a backend with 25+ notification types and 10 cron jobs), **full automated coverage of every screen and controller was not realistic in one pass** — that would mean mocking Firebase, sockets, and a 95-method repo for dozens of GetX controllers. Instead, this pass prioritized: (1) making previously-untestable notification logic testable without changing behavior, (2) writing real tests for everything that's pure/deterministic, and (3) documenting exactly what's left, so nothing is silently missed even if it isn't automated yet.

## 2. Refactors made (all behavior-preserving)

Several pieces of notification logic were `private` methods with no test access, or depended on the wall clock in a way that made deterministic testing impossible. All of the following changes are additive/backward-compatible — no existing call site changes behavior:

| File | Change | Why |
|---|---|---|
| `lib/data/controllers/socket_time_block.dart` (new) | Extracted `SocketController`'s time-block matching + notification title/body logic into standalone pure functions | Was `private`, couldn't be tested at all; `SocketController` now just delegates to it |
| `lib/helper/notification_message_classifier.dart` (new) | Extracted FCM message classification (`isAnnouncementMessage`, `isClassUpdateMessage`, `hasClassPayload`) | This exact logic was **duplicated independently** in both `NotificationServices._handleForegroundMessage` (foreground) and `main.dart`'s `firebaseMessagingBackgroundHandler` (background/terminated) — a real drift risk if one copy was edited and the other forgotten. Both now call the same functions. |
| `lib/data/services/notification_scheduler.dart` | `isQuietHours` now accepts an optional `now` param; `_nextOccurrence`/`_nextDayOfWeek` renamed to public `nextOccurrence`/`nextDayOfWeek` with an optional `now` param | Was hardcoded to `DateTime.now()`/`tz.TZDateTime.now()`, so tests couldn't control "now" — same pattern already used by `AppClock` and `currentMealForNow()` elsewhere in this codebase |

## 3. New tests added

```
test/services/cycle_engine_test.dart
test/services/accuracy_service_test.dart
test/services/recommendation_service_test.dart
test/services/progress_service_test.dart
test/services/insight_service_test.dart
test/notifications/notification_scheduler_test.dart
test/notifications/socket_time_block_test.dart
test/notifications/notification_message_classifier_test.dart
test/widgets/meal_status_chip_test.dart
test/controllers/cycle_theme_controller_test.dart
```

(In addition to the `meal_log_test.dart` / `paid_cycle_card_test.dart` / rewritten `widget_test.dart` from the previous session.)

**Notification coverage specifically:** every pure/deterministic piece of notification logic now has tests — quiet-hours math (including midnight-crossing), next-occurrence/next-day-of-week scheduling math (including week-rollover), the morning/afternoon/evening/night time-block matching (including its 12h/24h parsing and fail-open behavior), and FCM message classification (announcement vs. class-update vs. neither, with realistic payload fixtures).

**`cycle_theme_controller_test.dart`** demonstrates the pattern for testing a GetX controller against a real (but in-memory/fake) `SharedPreferences` — no new dependency needed, since `shared_preferences` ships its own test double (`setMockInitialValues`). This is a template for testing the simpler controllers later.

## 4. Run it

```
flutter test
```

I can't run Flutter myself (no Flutter SDK in my environment) — please run this and paste the output. Everything above was written and reviewed carefully but not executed.

## 5. Concrete bugs found during the audit (not fixed — need your decision)

These are separate from the testability refactors above — I flagged them but did **not** change behavior, since each is a product decision:

1. **`HomeController.onInit()` — the "unread notification" home dot never turns on from a cold start.**
   ```dart
   if (sharedPreferences.getBool("showDotHome") == null) {
     showDotHome.value = false;
   } else if (sharedPreferences.getBool("showDotHome") == true) {
     showDotHome.value = false;   // <- looks like it should be `true`
   }
   ```
   Both branches set `false`. If a push notification arrives while the app is closed (setting the persisted flag to `true`), then the user cold-opens the app, the badge dot resets to `false` instead of showing. Looks like a typo, not intentional — want me to fix it?

2. **Client vs. server disagree on `timeBlock` hour windows**, and only the server handles the midnight wrap for "night":
   - Client (`socket_controller.dart`, now `socket_time_block.dart`): morning 6–11, afternoon 11–16, evening 16–20, **night 20–23 (no wrap)**.
   - Backend (`crownjobfunction.js` `TIME_BLOCK_HOURS`): morning 5–12, afternoon 12–17, evening 17–21, **night 21→5 (wraps past midnight)**.
   - Practical effect: a class at 11:30 PM or 2 AM, with "night" selected, gets a server-side reminder queued but the client's own local-notification gate on the `slotUpdate` socket event won't show it (client-side double-gate disagrees with server). Worth reconciling to one set of boundaries.

3. **`NotificationScheduler.isQuietHours` is defined but never called anywhere in the client.** Quiet hours are currently only enforced server-side (in `helper/notification.js`, gating FCM sends). If quiet hours are meant to also suppress local (client-scheduled) notifications, this needs to be wired in; if server-side enforcement is sufficient by design, this function is dead code.

## 6. Security items surfaced (unrelated to testing, but found during the audit — flagging since they're real)

- **`lib/data/api_provider/chat_api_provider.dart`** embeds a full Firebase service-account **private key in plaintext** in the Dart source, used to mint FCM OAuth tokens client-side. Anyone who decompiles the APK gets this key.
- **`lib/data/controllers/zoom_controller.dart`** hardcodes a Zoom SDK key/secret for JWT generation.
- **`lib/data/Repos/**` / DietController** calls the Spoonacular API directly with an embedded API key, bypassing your own backend.

None of these were touched — recommend moving all three server-side (proxy through your backend) when there's time, independent of this testing pass.

## 7. What's covered vs. what still needs manual QA

**Now covered by automated tests (fast, deterministic, run in seconds via `flutter test`):**
- Cycle/insight/accuracy/recommendation/progress math (all pure services)
- Notification quiet-hours, scheduling date math, time-block matching, FCM message classification
- Meal-log time-slot detection, model JSON round-trips
- A few presentational widgets (cycle card, meal status chip)
- One controller end-to-end (`CycleThemeController`)

**NOT automatable in a widget/unit test — needs real-device manual QA:**
- Actual FCM delivery (token registration, foreground/background/terminated push arriving on a real device)
- Actual local notification firing at the scheduled time (requires waiting for the OS to trigger it, or a real device's notification tray)
- Push permission request dialog and its OS-level behavior
- Socket.IO real-time connection/reconnection behavior under real network conditions
- Firestore-backed chat delivery
- The full FCM → in-app-inbox pipeline (`sendNotification` → `UserNotification` row → `GET /notifications` → mark-as-read) — this needs a real or test database, not just Flutter tests

**Manual QA checklist for notifications** (recommend running this on a real device before each release):
1. Fresh install → allow notification permission → confirm device token reaches the backend (`/users/device-token`).
2. Toggle each of the 6 preference switches in Notification Settings individually → confirm each POST succeeds and re-loading the screen shows the persisted value.
3. Set a time-block preference (e.g. "evening") → book/attend a class outside that window → confirm no local notification fires for the "slotUpdate" socket event; inside the window → confirm it does fire.
4. Put the app in background → trigger a class reminder → confirm it arrives and tapping it opens the right screen.
5. Force-close the app (terminated state) → trigger a class reminder → confirm `getInitialMessage()` handling still routes correctly on next open.
6. Trigger an announcement-type push while the app is in foreground → confirm the dialog appears (not just a local notification).
7. Log out and back in on the same device → confirm the device-token collision logic doesn't leave the previous account also receiving this device's notifications.
8. Check the in-app notification inbox (bell icon) reflects server data, "Mark All Read" clears the badge, and swipe-to-dismiss doesn't error.

## 8. Recommended next phase (not done in this pass)

Given the scope, a reasonable follow-up phase (only if useful — this could be a lot of additional work):
- Mock `HomeRepo` (the 95-method shared dependency) once, reusably, then use it to test `MealLogController`, `DietPlanUserController`'s adherence/day-resolution logic, and `PaidHomeController`'s dashboard-loading states.
- Widget/golden tests for the paid home screen's conditional layout (the Cycle/Nutrition/Meals pairing logic we built earlier this session).
- Backend-side tests (Jest or similar) for `crownjobfunction.js`'s `pickClassReminder`/`filterSlotsByTimeBlock` and `helper/notification.js`'s preference-gating + quiet-hours logic — these are pure enough to unit test independent of Sequelize/Redis if the DB calls are mocked.

## 9. Full functionality inventory

For reference, the complete screen/controller/repo/model/service inventory produced during the audit is long-form and was not duplicated here to keep this report readable — ask if you want it written out as a separate reference doc.
