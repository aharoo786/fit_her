# FitHer — Full Notification System Audit (Frontend + Backend)

Date: 2026-08-10
Scope: `fit_her-main` (Flutter client, including `web/`) + `partner_backend` (Node/Express/Sequelize + Firebase Admin SDK + Bull/Redis + Socket.IO), every notification-related code path on both sides.

This supersedes/extends the notification section of `lib/docs/test_audit_report.md` (2026-07-21) — that pass covered client-side classification/scheduling and confirmed the classifier-duplication fix. This pass goes deeper on both sides, and is the first to cover the backend send pipeline, cron jobs, queue worker, and credential handling in detail. Every finding below was independently verified by direct file reads and, for the highest-severity backend items, by running `git ls-files` / `grep` against the actual repo — this is not just a description of what the code is supposed to do.

---

## How to read this

Findings are grouped by area, each tagged with a severity:

- 🔴 **Broken / silent data loss** — a notification the product clearly intends to send never reaches anyone, with no error surfaced anywhere.
- 🟠 **Real bug, narrower blast radius** — wrong behavior in a specific, less-common path.
- 🟡 **Gap / inconsistency** — works today but is fragile, incomplete, or contradicts a stated intent (e.g. a "quiet hours" toggle that's UI-only).
- ⚪ **Cleanup** — dead code, stale comments, no functional impact.

---

## Part 1 — Backend (`partner_backend`)

### 1.1 🔴 Firebase Admin service-account private key is committed to git

`helper/notification.js:5` — `const serviceAccount = require('../fither-e7a36-2145b07b5e5a.json');`, re-loaded again in `controllers/FrontSite/appNotifyController.js:9`.

Verified directly:

```
git ls-files | grep fither-e7a36   →  fither-e7a36-2145b07b5e5a.json   (tracked)
cat .gitignore                     →  node_modules/   (only entry)
```

This is a live Google service-account key — `project_id: fither-e7a36`, a real `client_email`/`private_key_id`/RSA private key, not a placeholder. Anyone with read access to the repo (including its git history — deleting the file now wouldn't remove it from history) has standing credentials to send arbitrary FCM pushes as the app, and potentially reach other GCP resources under that project depending on the service account's IAM bindings. `.gitignore` was never set up to exclude it, so regenerating it under the same filename would re-commit it again.

**Fix**: rotate the key in Firebase console, load the new one from an environment variable or a file outside the repo (or a secrets manager), add `*.json` service-account patterns (or the specific filename) to `.gitignore`, and scrub it from git history (`git filter-repo` / BFG) since it's a live credential, not just a config mistake.

This is the direct backend equivalent of the hardcoded Firebase key already flagged on the Flutter side in `chat_api_provider.dart` (from the earlier full-app audit) — both should be fixed together.

### 1.2 🔴 Three class-lifecycle notification paths are silently broken

All three intend to notify users about workout-class events and, today, notify **nobody** whose app isn't already open on the right screen:

**a) `updateLink` — `controllers/Admin/AdminController.js:2690-2710`** (verified directly):

```js
io.emit("slotUpdate", data);
await notificationQueue.add({
  title: "Class Link Added",
  body: "Class is starting soon",
  data: data
});
```

No `deviceTokens` field on the queued job. `notificationWorker.js:24,64-67` requires it — `const tokens = job.data.deviceTokens || [];` then bails with `console.log("No device tokens found.")` if empty. The old fallback code that looked up all workout-plan users' tokens is commented out (`notificationWorker.js:26-54`). **Every "Class Link Added" push is silently dropped**; only currently-connected sockets get anything via the unscoped `io.emit`.

**b) `updateTrainerJoin` — `AdminController.js:2716-2769`**: same missing-`deviceTokens` bug, and this one has **no socket emit either** — checked the full function body, there's no `io.emit` call anywhere in it. "Trainer has Joined" reaches nobody, open app or closed.

**c) `update_slot_status` — `AdminController.js:849-910`**: builds full title/body strings for `"Class Cancelled"`, `"Sweat Now, Selfies Later"`, `"Class Link Added"` (lines 882-891) — then **never uses them**. The function only does `io.emit("slotUpdate", data)` where `data = { upcomingSlot, trainer }` — no title, no body, and no call to `sendNotification`/`notificationQueue.add` at all. Class cancellations and status flips produce zero pushes and a socket payload that doesn't even carry the message the code went to the trouble of computing.

**Fix**: thread `deviceTokens` (looked up from the affected users' `UserPlan`/class roster) into (a) and (b)'s queue payloads, and add an actual `sendNotification`/`notificationQueue.add` call to (c) using the title/body it already builds.

### 1.3 🔴 `notificationWorker.js` — the Bull queue consumer — has no confirmed startup path

`package.json` scripts only define `start`/`dev` → `nodemon app.js`. Grepped the entire backend (excluding `node_modules`) for `notificationWorker` — the only hit is a comment in `helper/escalation.js:77` referencing it by name; it is never `require()`'d or spawned from anywhere in the checked-in code, and there's no `ecosystem.config.js`/PM2 config in the repo pinning it as a second process.

If ops isn't separately running `node notificationWorker.js` as its own process (outside what's tracked in this repo), **every** job pushed onto `notificationQueue` — class-prep/class-start reminders from the `*/3 * * * *` cron, and every escalation queued via `helper/escalation.js` — piles up unprocessed in Redis and is never delivered. This needs to be verified against the actual production process list; the code alone gives no guarantee.

**Fix**: add a `worker` script to `package.json` and confirm (or add) a process-manager entry that actually runs it in production.

### 1.4 🟠 No stale/invalid FCM token cleanup — failures retry forever

`sendNotification` (`helper/notification.js:96-247`) uses `admin.messaging().sendEachForMulticast()` and correctly inspects per-recipient `response.responses[i].success`/`.error.code`, logging failures to `UserNotification` with `deliveryStatus: 'failed'`. But nothing ever reads those failures back to clear `User.deviceToken`. A `messaging/registration-token-not-registered` error (uninstalled app, cleared data, etc.) gets logged and then retried on every subsequent notification, forever — no code path anywhere nulls out a dead token.

Also relevant: `User` has a single `deviceToken` STRING column (not a device table), so logging in on a second device silently overwrites the first — the old device stops receiving pushes with no notice to the user, and `update_device_token` (`userController.js:813-842`) actively steals the token from any other user row holding the same value first.

**Fix**: on a definitive "token not registered"/"invalid argument" error, null out that user's `deviceToken` inside the same step-5 write.

### 1.5 🟠 Non-atomic dedup (TOCTOU race) in two cron jobs

`crownjobfunction.js:17-25` (`alreadyNotified`) and `missedSessionRecovery.js:15-22` (`alreadySent`) both do:

```js
const exists = await redis.get(key);
if (exists) return true;
await redis.set(key, "1", "EX", ttlSeconds);
return false;
```

`GET` then `SET` is two round trips, not atomic — under either a slow-iterating cron tick overlapping the next tick, or (more concerning) a clustered/PM2 multi-instance deployment where every instance runs every `node-cron` job independently, two concurrent checks can both pass `GET` before either finishes `SET`, producing duplicate class-reminder pushes. `package.json` lists `pm2` as a dependency, which is suggestive of cluster-mode deployment, but there's no `ecosystem.config.js` in the repo to confirm either way.

**Fix**: replace with an atomic `SET key val NX EX ttl` (single Redis command, only succeeds if the key didn't already exist).

### 1.6 🟡 Quiet hours are evaluated in a hardcoded timezone, not the user's own

`helper/notification.js:16` hardcodes `DEFAULT_TZ = "Asia/Karachi"` for the quiet-hours window check, even though `User.timeZone` exists and is used elsewhere (slot scheduling) for exactly this kind of per-user localization. A user physically outside Pakistan gets their quiet hours evaluated against PKT, not their actual local time.

### 1.7 🟡 Preference/quiet-hours gate only covers ~6 of ~25 notification types

`PREF_BY_TYPE` (`helper/notification.js:54-84`) marks most transactional types (`dietPlanUpdated`, `paymentApproved`, `bookingAdded`, `escalation`, `announcement`, etc.) as ungated by design ("Transactional — no preference gate, always deliver" per the code's own comment) — reasonable for genuinely transactional pushes, but it means the "quiet hours" feature product-wise only applies to class-related and re-engagement nudges, not the majority of admin-triggered pushes.

Separately: type resolution (`TYPE_BY_TITLE`, lines 20-50) is fragile exact-string matching on notification titles. Any call site whose title string isn't in that map, and that doesn't pass an explicit `data.type`, resolves to `type = null` → no preference/quiet-hours check runs at all → **defaults to sending regardless of quiet hours**, rather than failing closed. A typo'd title anywhere silently exits the preference system.

### 1.8 🟡 In-app notification inbox (`UserNotification`) has incomplete coverage

The inbox itself is real and working — `GET /users/notifications` / `POST /users/notifications/read` (`userController.js:844-891`) — but rows are only written from inside `sendNotification`'s step 5. Missed entirely:

- `appNotifyController.js`'s CRM support-reply webhook calls `admin.messaging().send()` directly, bypassing the helper — support replies never appear in the in-app inbox.
- All three broken paths in §1.2 — since they either drop the notification or bypass the helper, there's no inbox trace even though the underlying admin action succeeded.
- Quiet-hours-suppressed sends — `sendNotification` returns early (line 167-170) before the DB write, so there's no "attempted but suppressed" record; a support ticket asking "why didn't I get notified" is unanswerable from the DB alone.

### 1.9 🟡 `io.emit("slotUpdate", ...)` is an unscoped global broadcast

`AdminController.js:902` and `:2697` — every connected socket gets every slot update, not just the affected user/class, via a plain `io.emit` rather than a room. Besides being wasteful, the payload includes trainer/user identifying data (per `AdminController.js:682-687`), so any authenticated connected user can observe other users' class/trainer assignment data broadcast to them. `postsController.js`'s community-feed events correctly use scoped rooms (`io.to('community')`, `io.to('post_'+id)`) — this is the established, available pattern; `slotUpdate` just doesn't use it.

### 1.10 ⚪ Dead dependency

`fcm-node` is listed in `package.json` but never `require()`'d anywhere in `partner_backend`'s own source (only inside its own `node_modules/fcm-node/example.js`) — leftover from an earlier implementation, fully superseded by `firebase-admin`.

---

## Part 2 — Frontend (Flutter, `fit_her-main`)

### 2.1 🟡 Six of nine notification-preference controls have no client-side effect

`notification_settings_screen.dart` exposes 6 toggles (`morningNudge`, `classPrep`, `classStart`, `missedRecovery`, `trainerCancelled`, `weeklyCheckin`) + `quietStart`/`quietEnd` + a `timeBlock` selector. Traced each one end-to-end:

| Control | Wired client-side? |
|---|---|
| `morningNudge` | ✅ flows into `NotificationScheduler.rescheduleAll` → schedules/cancels local notification id `1001` |
| `weeklyCheckin` | ✅ same path, id `6001` |
| `timeBlock` | ✅ written straight to SharedPreferences (`notification_settings_screen.dart:101`), read by `SocketController._isInPreferredTimeBlock` on every `slotUpdate` — the one control that's instantly effective |
| `classPrep`, `classStart`, `missedRecovery`, `trainerCancelled` | ❌ POSTed to the backend and nothing else. No code path anywhere in `lib/` reads them back to suppress an incoming FCM push or local notification |
| `quietStart`, `quietEnd` | ❌ collected, persisted, passed into `rescheduleAll`'s `prefs` map — but `rescheduleAll` never reads those two keys (see 2.3) |

Cross-referencing with the backend audit (§1.7): the backend *does* enforce quiet hours and the 6 preference toggles for the ~6 notification types that are gated — so this isn't a dead feature end-to-end, but from the Flutter code alone, flipping most of these switches has **zero observable client effect**; whether the notification actually stops is entirely a backend question. Worth knowing if debugging a "I turned this off and still got notified" report — check the backend gate for that specific type in `PREF_BY_TYPE`, not the client.

A second, narrower notification-preference UI also exists at `lib/UI/free_trail/trial_journey_screen.dart` (its own local `_classStart` toggle) — a second surface touching the same `classStart` preference key, not fully traced to confirm it POSTs to the identical endpoint.

### 2.2 🟡 `isQuietHours` is entirely dead code on the client

Defined and unit-tested (`notification_scheduler.dart:96-112`, `test/notifications/notification_scheduler_test.dart`), but never called from any production code path. Confirmed by exhaustive grep. The two things that *are* scheduled locally (morning nudge, weekly check-in) don't check it, and neither does the socket-triggered local notification in `SocketController`.

### 2.3 🟡 `rescheduleAll` silently ignores 7 of the 9 keys in the `prefs` map it's handed

```dart
static Future<void> rescheduleAll({required Map<String, dynamic> prefs, required bool weeklyCheckinDone}) async {
  final morningEnabled = prefs['morningNudge'] == 1;
  final weeklyEnabled = prefs['weeklyCheckin'] == 1;
  ...
}
```

Both call sites pass the full preferences map (including `classPrep`, `quietStart`, `timeBlock`, etc.), but only 2 keys are ever read. Not wrong, exactly — those other categories genuinely aren't locally-scheduled — but the function signature reads as "reschedule based on current preferences" when it really only acts on 2 of 9.

### 2.4 🟠 `_rescheduleNotifications()` only runs once per `BottomBarScreen` mount, not on every app resume

Triggered from `BottomBarScreen.initState()` (line ~145-149), gated to regular users only (trainers/dietitians/admins never get it called at all). Since Flutter keeps the widget tree alive across backgrounding, `initState()` doesn't re-run just because the app was backgrounded and resumed — there's no `WidgetsBindingObserver`/`didChangeAppLifecycleState` hook wired to re-trigger it. If server-side state relevant to scheduling changes (e.g. a weekly check-in submitted from another device) while the app is merely resumed rather than freshly (re)opened, the stale local schedule persists until the next full remount. The existing code comment claims this runs "on every app open," which is true only in the narrower sense of "every time the bottom bar widget is constructed."

Also: nothing cancels scheduled local notifications (ids `1001`/`6001`) on logout — a logout-then-different-account-login on the same device leaves the previous account's schedule live until the new session's `BottomBarScreen` mount overwrites it (same fixed IDs, so no leak of stale content, just a window where the wrong account's notification could fire).

### 2.5 🟡 Web push (`web/firebase-messaging-sw.js`) has none of the mobile app's classification or routing

Full file is 35 lines. `messaging.onBackgroundMessage` reads only `payload.notification.title`/`.body` and calls `showNotification` — it never inspects `payload.data` at all, so `isAnnouncementMessage`/`isClassUpdateMessage`/`hasClassPayload` have no web equivalent; every background-tab push renders as a generic, undifferentiated browser notification. There's also no `notificationclick` handler at all (clicking does nothing beyond the browser default — no deep-navigation to the relevant screen), and no notification icon configured (commented out). Foreground web notifications *do* get the full classifier treatment since that's shared Dart code — it's specifically the closed/backgrounded-tab case that's this thin, which on web is the more common state than on mobile. If web is a real supported surface, this is the single biggest gap in the whole system.

### 2.6 🟡 Notification-permission denial is a dead end

`requestNotificationPermission()` (`notification_services.dart:132-144`) logs `'User denied notification permissions.'` on denial and otherwise does nothing — no UI feedback, no "enable later in Settings" messaging, no `openAppSettings()` call. By contrast, the photo/camera permission flow in `permissions.dart` does have a proper permanently-denied → settings-deep-link path via `permission_handler`. There's no later re-prompt or recovery path anywhere in the notification code for a user who denies once.

### 2.7 🟡 Class-notification title string has drifted into two independently-maintained copies

`notification_message_classifier.dart:41` hardcodes `'Sweat Now, Selfies Later'` (no emoji) in its title-fallback matching list; `socket_time_block.dart:63`'s `classReminderTitleForStatus` returns `'Sweat Now, Selfies Later 💪'` (with emoji) for the socket-triggered local notification. Two copies of conceptually the same string, already diverged. If a backend FCM payload for the same event ever sends the emoji variant without also setting `data.type`, the classifier's title-fallback match would silently miss it.

### 2.8 🟠 `HomeController.onInit()` unread-dot bug (carried over from the prior audit, confirmed still present)

```dart
if (sharedPreferences.getBool("showDotHome") == null) {
  showDotHome.value = false;
} else if (sharedPreferences.getBool("showDotHome") == true) {
  showDotHome.value = false;   // both branches set false
}
```

A push arriving while the app is fully closed sets the persisted flag `true`; the next cold open resets the home unread-dot to `false` anyway. Display bug, not a delivery bug — the notification itself still arrives — but it undermines the unread-indicator half of the UX.

### 2.9 ⚪ Assorted dead/duplicated code (lower severity, no functional impact)

- `onNotificationGet` (`notification_services.dart:319`) — empty no-op, called on every single foreground FCM message for zero effect.
- The "persist announcement to SharedPreferences for the popup dialog" block is implemented three times near-identically: `addAnnouncementPopUp` (used by the foreground path), inlined again inside `handleNotificationTap`, and inlined again inside `main.dart`'s background handler. Only the *classification* is shared via the classifier module (§ verified genuinely fixed, see below); the *action taken* once classified is still copy-pasted three times.
- `main.dart:51` — commented-out reference to a renamed/removed function (`_firebaseMessagingBackgroundHandler`, no longer exists).
- `notification_services.dart:335-343` — stale commented-out duplicate token-fetch implementation.
- `firebase-messaging-sw.js:16-18, 24` — stale commented-out duplicate handler and commented-out icon config.

### 2.10 ✅ Confirmed still fixed: FCM message classification is genuinely shared

Verified line-by-line that both `NotificationServices._isAnnouncement/_isClassUpdate/_hasClassPayload` (foreground) and `main.dart`'s `firebaseMessagingBackgroundHandler` (background/terminated) delegate to the same `notification_message_classifier.dart` functions rather than reimplementing the checks — this was fixed in the prior audit pass and holds up under fresh inspection. Both are covered by `test/notifications/notification_message_classifier_test.dart`.

What is **not** fully unified: two extra foreground-only side-effect checks (`"Trainer has Joined"` title, and `data["type"] == "planActivated"`/`"Congratulations!"`) live only in `_handleForegroundMessage` and have no background-handler equivalent — narrower than the original duplication bug, but the same pattern (foreground/background drift), on logic that was added after the original fix.

---

## Part 3 — Cross-stack issues (require coordinated fixes)

### 3.1 🟠 Client/server "night" time-block windows don't match

Client (`socket_time_block.dart` header comment, confirmed current): night = 20:00–23:00, no midnight wrap.
Backend (`crownjobfunction.js`'s `TIME_BLOCK_HOURS`, per the backend audit): night = 21:00→05:00, **with** a midnight wrap.

A class at, say, 11:30 PM with "night" selected as the user's preferred block could be correctly queued server-side but never shown by the client's own `SocketController` gate, since neither "23:00-24:00" nor "00:00-05:00" match the client's definition of night at all. Needs one shared definition — recommend moving the canonical window table to a single source (e.g. have the client fetch it from the backend, or hardcode identical constants with an explicit comment on both sides pointing at each other so future edits can't drift again the way this one already has).

### 3.2 🟡 "Turning off a notification type" is a two-repo feature with only half wired on the client

Per 2.1 and 1.7: the backend genuinely gates ~6 notification types on the corresponding `NotificationPreference` toggle, so the feature does work end-to-end for those types — but the Flutter client has no independent belief about whether a given toggle is "working," since it never consumes its own preference state to suppress anything except `timeBlock`. This is fine as an architecture (server-side gating is arguably more correct than client-side, since it also saves the wasted FCM send), but it means any *client-side* symptom of "this toggle doesn't do anything" should be diagnosed by checking `PREF_BY_TYPE` on the backend, not by looking for a bug in the Flutter settings screen — worth documenting explicitly since it's not obvious from either codebase in isolation.

---

## Priority fix order (suggested)

1. **1.1** — rotate + stop committing the Firebase service-account key. Security, not just correctness.
2. **1.3** — confirm/fix `notificationWorker.js`'s production startup. If it's genuinely not running, this alone silently disables class reminders and escalations.
3. **1.2** — fix the three broken class-lifecycle notification paths (missing `deviceTokens`, missing send call entirely).
4. **1.4** — stale FCM token cleanup, to stop wasted/forever-retried sends.
5. **1.5** — atomic Redis dedup (`SET NX`) to remove the double-send race.
6. **2.4** — reschedule-on-resume (add a lifecycle observer), since it's a real (if intermittent) staleness bug affecting every regular user.
7. Everything else (🟡/⚪) — lower urgency, mostly consistency/cleanup; happy to batch these once the above are confirmed fixed.

---

## Files read in full or in relevant part

**Flutter**: `lib/main.dart`, `lib/helper/notification_services.dart`, `lib/helper/notification_message_classifier.dart`, `lib/data/services/notification_scheduler.dart`, `lib/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart`, `lib/UI/dashboard_module/profile_screen/notification_settings_screen.dart`, `lib/data/controllers/socket_controller.dart`, `lib/data/controllers/socket_time_block.dart`, `web/firebase-messaging-sw.js`, `lib/UI/auth_module/splash.dart`, `lib/UI/auth_module/notification_screen.dart`, `lib/helper/permissions.dart`, `lib/firebase_options.dart`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `lib/data/controllers/auth_controller/auth_controller.dart`, `lib/data/controllers/home_controller/home_controller.dart`, `lib/values/constants.dart`, `pubspec.yaml`.

**Backend**: `helper/notification.js`, `helper/escalation.js`, `helper/crownjobfunction.js`, `helper/missedSessionRecovery.js`, `helper/notifications/*.js`, `notificationWorker.js`, `socket.js`, `app.js` (cron registration), `controllers/Admin/AdminController.js` (notification-related sections), `controllers/FrontSite/appointmentController.js`, `controllers/FrontSite/appNotifyController.js`, `controllers/FrontSite/userController.js`, `controllers/FrontSite/postsController.js`, `helper/planFreezeController.js`, `helper/applyPlanApproval.js`, `services/dietPlanService.js`, `models/User.js`, `models/UserNotification.js`, `models/NotificationPreference.js`, `package.json`, `.gitignore`, git history for the committed key file (independently verified via `git ls-files`).
