# FitHer — Free Trial System Audit (Flutter + Node backend)

Date: 2026-08-11
Scope: every code path that grants, tracks, or expires a free trial, across `fit_her-main` and `partner_backend`.

## The headline finding

There are **two independent, non-communicating free-trial systems** live in the backend at the same time:

1. **Legacy system** — `FreeTrailUsers` / `FreeTrailUsersSlots` tables, driven by `AdminController.assignFreePlan` (grants a real "Free Trial" `UserPlan`, sets `User.usedFreeTrial=1`) and `AdminController.createFreeTrialUser` (records the user's trainer/slot preferences). Routes: `/admin/assignFreePlan`, `/admin/createFreeTrialUser`.
2. **Current system** — `TrialJourney` / `TrialToken` tables, driven by `controllers/FrontSite/trialController.js` (token-gated or organic 3-day trial with day-1/2/3 class booking and attendance tracking). Routes: `/trial/start`, `/trial/book-day`, `/trial/me`, `/trial/convert`.

The code itself documents the assumption these don't overlap — a comment in `helper/notifications/trialJourney.js:8-10` reads: *"The TrialJourney system (trialController.js) DOES NOT set usedFreeTrial=1... These two systems are independent — their users never overlap."* That's stated as a fact, but nothing in the code enforces it — neither system checks the other's records before granting a trial.

## What's reachable today (verified via navigation trace)

- The **legacy** self-serve screens (`FreeTrialPersonalizationScreen` in `free_trail_question.dart`, `FreeTrialSlots` in `free_trial_slots.dart`) are **orphaned client-side** — grepped the entire `lib/` tree and neither is ever pushed to from anywhere. `HomeController.addFreeTrial()` (which calls `assignFreePlan`) is only ever called from that orphaned screen, so it's transitively dead too. **No live button in the current app reaches the legacy flow.**
- The **current** flow (`TrialCtaCard` → `showTrialStartDialog()` → `HomeController.startTrial()` → `POST /trial/start`) is the one real users hit today — confirmed live from the unpaid home screen, plus several other entry points (`auth_controller.dart`, `work_out_controller.dart`) that all route to the same dialog/screen.

So today, in practice, users only go through the TrialJourney system — the double-grant risk below is latent, not actively being hit by normal usage. But the legacy endpoints are still fully live on the server (`validateToken` only, no extra gating), reachable by direct API call or any older app build still pointing at them.

## Missing checks

**1. `POST /trial/start` doesn't check the legacy trial flag at all.** It only checks for an existing `TrialJourney` row for that `userId`. It never checks `User.usedFreeTrial` or looks for an existing `FreeTrailUsers` row. If those legacy endpoints are ever hit for a given user (old app build, direct API, or a future admin tool), that same user can *also* start a fresh `TrialJourney` — two separate "free" grants, unrelated systems, neither aware of the other.

**2. `POST /trial/start` doesn't require a trial token at all.** The route comment in `admin.js:460` calls the token system "Reps create shareable deep links that auto-start a 3-day TrialJourney" — implying trials are meant to be attributable/gated via rep-issued tokens. But `startTrial` treats `token` as fully optional (`if (incomingToken.trim())`); with no token it just creates a `TrialJourney` with `trialTokenId: null`. This is also the exact code path the in-app "Start 3-day free trial" button uses. So today, *any* logged-in user can call `/trial/start` and get a trial with zero attribution — which may well be intentional for the organic in-app entry point, but it means the token system provides no actual access control, only optional attribution. Worth confirming with product intent: should self-serve in-app starts be unlimited, or should there also be a per-user cap enforced server-side beyond "one `TrialJourney` row ever" (see #4)?

**3. `createFreeTrialUser` has no duplicate-prevention.** No unique constraint on `FreeTrailUsers.freeTrialUser` in the model, and the controller does no existence check before `create()`. Calling it twice for the same user creates two rows. Low practical risk today since it's unreachable from the live UI, but it's a live, callable endpoint with no guard.

**4. `createFreeTrialUser` doesn't check whether the Free Trial plan is active.** `changeFreeTrialStatus` exists specifically so admins can disable new trial signups (`Plan.status`). `assignFreePlan` correctly respects that flag (`if (freePlan.status) {...}`), but `createFreeTrialUser` never looks at `Plan.status` at all — so disabling free trials from the admin panel doesn't stop this endpoint from still creating trial preference/slot rows.

**5. No slot-capacity check anywhere in the trial flow.** Neither `createFreeTrialUser` nor `trialController.bookDay` checks how many people are already assigned to a given `Slot` before adding another. If real-world classes have a headcount limit, nothing server-side enforces it for trial bookings (this may be shared with the paid drop-in model, which is intentionally uncapped per earlier discussion — but worth confirming trial classes don't need a cap even if paid drop-in doesn't).

**6. No chronological ordering check across day1/day2/day3 slots.** `bookDay` only checks that the *sequence gate* is satisfied (day 2 can't be booked until day 1 is attended, via `computeNextBookableDay`), and that the slot ID exists. It never checks the slot's actual date/time against previously booked days — a user could, in principle, book a Day 1 slot for next week and a Day 2 slot for tomorrow, since both checks are purely about booking/attendance order, not calendar order.

**7. No trainer-facing view of the current trial system's bookings.** The only endpoint that shows a trainer "who's coming to my free-trial slot" is `getFreeTrialUserById`, which queries `FreeTrailUsersSlots` — a table the current `TrialJourney` flow never writes to (it stores `day1SlotId`/`day2SlotId`/`day3SlotId` directly on the `TrialJourney` row instead). Grepped the whole backend — no other endpoint joins `TrialJourney` to `Slot` for a trainer/admin view. Practical effect: trainers have no way to see their free-trial roster today; the existing screen for it always returns empty for anyone who came through the current flow.

## Logical / flow errors

**1. Two free-trial systems that assume mutual exclusivity without enforcing it** (see headline finding above) — the single biggest structural issue. If the legacy endpoints are ever exercised again (old app build in the wild, admin tooling, direct API), a user can end up with both a legacy free `UserPlan` and an independent `TrialJourney`, doubling their free access and confusing every downstream segment/notification query that assumes "these users never overlap."

**2. Dead client code pointing at live, unguarded server endpoints.** `FreeTrialPersonalizationScreen` → `FreeTrialSlots` → `assignFreePlan`/`createFreeTrialUser` is orphaned in the shipped app but the backend routes have no additional protection beyond a valid JWT. This is a maintenance trap as much as a security one: someone could re-link the old screens (or a future feature could reuse `createFreeTrialUser`) without realizing the duplicate-prevention gap in finding #3 above.

**3. Race condition in `trialController.startTrial`.** It does `TrialJourney.findOne(..., lock: transaction.LOCK.UPDATE)` then conditionally `create()`. `LOCK.UPDATE` only protects a row that already exists — on a brand-new user's very first request there's nothing to lock yet, so two near-simultaneous calls (double-tap, or the dialog firing twice) can both pass the `if (!journey)` check before either commits. The DB-level `unique: true` on `TrialJourney.userId` will correctly reject the second `INSERT`, but that failure isn't caught with a friendly message — it would surface as a raw Sequelize error to the user instead of "you already started your trial." Low-frequency edge case, but worth a targeted try/catch around the create.

**4. `changeFreeTrialStatus` is a partial kill-switch.** It only gates `assignFreePlan` (which checks `Plan.status`). It does not gate `createFreeTrialUser` (finding #4 above) and has no equivalent for the current system at all — there's no way to pause new `TrialJourney` starts short of disabling the `/trial/start` route entirely or revoking every outstanding `TrialToken`. If the intent is "admins can turn off free trials," that intent is only half-implemented and only for the system nobody uses anymore.

## What's confirmed working correctly (verified, not just assumed)

- `TrialJourney.userId` has a real DB-level unique constraint — a user cannot end up with two `TrialJourney` rows outside the narrow race in finding #3.
- `TrialToken` reuse is correctly blocked — `getValidTokenOrError` rejects revoked, expired, and already-used tokens.
- Trial expiry (`isTrialExpired`, `bookDay`, `convert`) is enforced server-side, not just client-side — there's an explicit code comment ("Bug 3 fix") confirming this was deliberately hardened after relying on a client-only check.
- `trialJourney.js` and `trialJourneyChurned.js` (re-engagement notifications) both correctly exclude users who already hold a paid `UserPlan` via a live `getPaidPlanUserIds()` check — they don't rely solely on the self-reported `convertedAt` flag, so a user who quietly bought a real plan without ever hitting `/trial/convert` won't keep getting "come back and convert" nudges after already paying.
- The legacy nightly expiry job (`freeTrialExpiry.js`) is defensive and idempotent — wraps each user in its own try/catch, and correctly no-ops on a second run.

## Suggested priority order

1. Decide product intent on the two-system split: either formally retire the legacy `FreeTrailUsers`/`assignFreePlan`/`createFreeTrialUser` path (block the routes, or at minimum make `startTrial` check `usedFreeTrial`/`FreeTrailUsers` before granting), or document why both need to coexist.
2. Give trainers a real "who's coming to my trial class" view against `TrialJourney.day1SlotId`/`day2SlotId`/`day3SlotId` — this is a live operational gap today, not just a hypothetical.
3. Add the missing `Plan.status` check to `createFreeTrialUser` (cheap, closes the admin kill-switch gap) if that endpoint stays alive at all.
4. Wrap `startTrial`'s `create()` in a friendly duplicate-race handler.
5. Everything else (slot capacity, day-ordering, token-requirement policy) — lower urgency, mostly product-decision-dependent rather than pure bugs.
