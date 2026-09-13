# Diet System — Full Audit (Frontend + Backend)

Scope: every "diet" surface in the app — the legacy diet/appointment/PDF-upload system and the newer "Diet Plan v2" AI-generated meal plan system — across both the Flutter client (`fit_her-main`) and the Node/Express/Sequelize backend (`partner_backend`). ~55 files read in full (models, controllers, routes, migrations, screens, repos).

Two files referenced in the original request path did not exist on disk and could not be audited: `scripts/test_diet_plan_endpoint.js` and `scripts/verify_diet_plan_schema.js`.

---

## The headline finding: the safety-escalation pipeline is disconnected end-to-end

This is the single biggest thing to fix, because it spans both audits and touches patient-safety territory (severe side effects, pain, PCOS-related flags):

- **Backend**: when a Day 7 review is flagged (severe side effects, pain, low adherence), an `EscalationTicket` is created — but nothing ever writes back to `DietPlan.status`. The plan stays `active`. There is no `escalated`/`flagged` status in the `DietPlan` enum at all. A user can keep logging meals against a plan that's already been flagged as a problem, with nothing in the API response distinguishing it from a healthy plan.
- **Frontend**: `Day7ReviewScreen` (the check-in that would flag a plan) and `FlaggedReviewsScreen` (the dietitian's queue for reviewing flagged clients) are both **fully built but never navigated to from anywhere in the app**. A `grep` across the entire `lib/` tree finds no call site for either screen outside their own constructors. `ClientConsultationScreen`, reachable only from `FlaggedReviewsScreen`, is therefore also unreachable.
- On top of that, the dietitian-side screens that *do* reference "Day 7 review" (`ClientConsultationScreen`, `FlaggedReviewsScreen`) use a completely different, older `Day7Review` model and controller (`DietitianDashboardController` / legacy `EscalationTicket` system) than the one the live Diet Plan v2 flow actually uses (`diet_plan_v2/day7_review_model.dart`). Two classes, same name, different backend contract, living in the same `dietitian_v2/` folder.
- Even the ticket resolution step is a dead end: resolving an `EscalationTicket` never clears the underlying `Day7Review.flagged` field and never notifies the user or dietitian that anything happened.

**Net effect: right now, if a user reports a genuinely concerning symptom through the day-7 check-in, there is no way for her to actually submit that check-in from the app, and if a flag were somehow created, no dietitian has a working screen to see it, and resolving it wouldn't clear the flag or tell anyone.** This needs to be treated as a priority-zero item, not a routine bug — it's currently a safety feature that only exists in the code, not in the product.

---

## Critical issues

### Backend

1. **Consultation-booking endpoints have almost no authentication.** `POST /appointment` (create), `PUT /appointment/:id` (update/change status), `DELETE /appointment/:id`, `GET /appointment/:id`, `GET /appointment/dietAppointments/:id`, and `GET /appointment/status` all run with zero auth middleware (only `/no-show` and `/review` are protected). Concretely: anyone can book or spam any dietitian's calendar as any user, flip any appointment's status (including marking one "completed" with a fabricated actor), hard-delete any appointment, and pull every appointment for every dietitian — including each client's name and email — with no login at all. This is a full read/write/delete hole plus a PII leak, in the file `controllers/FrontSite/appointmentController.js` / `routes/FrontSite/appointmentRoutes.js`.

2. **Double-booking race condition.** `appointmentController.js::createAppointment` checks "is this slot already booked" and then creates the appointment as two separate, un-transacted queries with no row lock. Two near-simultaneous booking requests for the same slot can both pass the check and both get created. Notably, `dietController.js::addOrUpdateDaySlot` in the *same file set* already has the correct fix pattern (transaction + row lock, with a code comment referencing "Bug 10 fix") — it was just never applied to the actual booking path.

3. **No ownership check on publishing a diet plan.** `dietPlanService.js::activateDietPlan` never calls the `assertCanMutate` ownership guard that every other mutating function in the same service uses (`updateMealInPlan`, `cancelDietPlan` both call it). Any account that passes the admin/dietitian auth middleware can activate — and push-notify the end user about — a draft plan written by a *different* dietitian for a *different* dietitian's client.

4. **Escalation never touches plan status** (detailed above) — a flagged plan is indistinguishable from a healthy one anywhere the API surfaces plan data.

### Frontend

5. **A blocking loading dialog that can never be dismissed.** `DietController.addDaySlots` shows a non-dismissible `CircularProgressIndicator` dialog, then checks whether `daySlotsOfDietModel` is null *after* the dialog is already on screen. If a dietitian taps Save before the initial slot fetch has resolved (plausible on a slow connection, since the button isn't gated on the loading flag), the function returns early without ever calling `Get.back()`. The app appears completely frozen and needs a force-kill.

6. **Force-unwrap crash on the "add slot" button.** `day_slots_screen.dart`'s AppBar "+" action calls `dietController.daySlotsOfDietModel!.slots.add(...)` and is tappable the instant the screen renders — it isn't gated behind the same loading flag the rest of the screen uses. Since the previous screen navigates immediately after triggering the fetch, a fast tap on "+" crashes the app with a null-unwrap.

7. **`diet_bottom_bar.dart` (941 lines) turned out to be dead code, not the live diet tab.** This was the file flagged as the one to scrutinize most closely going in — but a full-tree `grep` shows nothing instantiates `DietBottomBarScreen` anywhere. The real diet tab is `DietPlansOfUser`, which was switched over in what its own doc comment calls "Phase F.1," leaving the old file orphaned. This isn't dangerous on its own, but it means: (a) 941 lines of legacy booking UI are sitting in the codebase as a trap for a future edit, and (b) the actual live tab renders almost nothing itself — see next finding.

8. **The real diet tab has no loading or error state.** `DietPlansOfUser.build()` is just `Column([V2DietHero(...), V2TodayMealsSection()])` with no `Obx` on the controller's `isLoading` or `errorMessage`. "Still loading," "genuinely no plan," and "the fetch failed" all render identically (whatever `V2DietHero`'s default empty state is), with no visible retry or error messaging at this level.

9. **Day7ReviewScreen and FlaggedReviewsScreen are unreachable** (detailed in the headline finding above).

---

## High-severity issues

**Backend**
- `availibiltyController.js`'s update/delete endpoints have no auth and don't check that the caller owns the `teamMemberId` they're editing — anyone who can guess an id can reassign or delete another dietitian's availability. Currently harmless only because the router isn't mounted in `app.js` (it's dead code) — but it ships broken and would need fixing before ever being wired up.
- Three separate, overlapping "availability" systems exist in the backend: a dead `Availability`/`avalibilityRoutes.js` model, the one actually driving bookings (`TimeDietition`/`SlotDiet`), and a third (`DietTime`/`Diet`) written only from the admin controller and never read by any front-facing diet controller. A future developer extending "availability" has a two-in-three chance of touching the wrong or dead model.
- `PdfDiet` (the diet plan PDF a dietitian uploads after a consultation) has no foreign key back to the `Appointment` it's supposed to follow. Nothing stops a plan being uploaded with no completed consultation, and nothing surfaces "consultation done, plan not yet delivered" as a trackable gap anywhere, including the dashboard.
- `mealLogController.upsertMealLog` accepts a client-supplied `dietPlanMealId` with no check that it exists, belongs to the calling user, or belongs to their *current* (non-cancelled) plan.
- Cancelling a plan mid-cycle and activating a replacement corrupts the day-7/day-15/day-30 cycle anchors (`stampPlanDeliveryAnchors` only checks "has cycle 1 ever started," not "did cycle 1 finish naturally"), permanently mis-numbering whatever check-in logic keys off those anchors.
- `day7ReviewController.submitReview` has no timing gate (a review can be submitted on day 1 or day 40) and no duplicate guard (the same cycle's review can be submitted repeatedly, each one opening a fresh escalation ticket).
- Escalation tickets are hard-coded to `dietitianId: null` even though the assigned dietitian is derivable the same way another endpoint in the same controller already does it — a flagged medical/pain issue routes only to a generic admin queue, never to the client's actual dietitian.
- No `DietPlan.status = 'completed'` transition is ever implemented based on elapsed plan days; the *only* other "is this plan done" signal is `UserPlan.planStatus`, written by a completely separate subscription-expiry job with no relationship to `DietPlan.status` — two independent, unsynced answers to "is this plan still current."

**Frontend**
- Two screens (`new_appointment_request.dart`, `rescheduleRequestScreen.dart`) call `updateAppointmentStatus` with parameters that mean the success path never actually removes/updates the item from the list the screen renders. The API call succeeds, a success toast fires, but the appointment shows the old status until the screen is fully closed and reopened — inviting a double-action on something already handled.
- `Cliet.fromJson`'s null-safety fallback for `buyingDate`/`expireDate` (`json["buyingDate"] ?? DateTime.now()`) passes a `DateTime` into `DateTime.parse()`, which requires a `String` — the fallback crashes exactly when it's supposed to protect against a missing field, taking down the entire client list parse (not just the one row).
- Two model files (`get_diet_plan_details.dart`, `get_all_diet_plans_of_user.dart`) parse nested objects with no null guards, while sibling models in the same codebase were clearly hardened after real incidents (comments explain why). A missing key in either backend response throws inside a `.then()` callback with no surfaced error — the screen just sits on its spinner forever.
- `ClientDetailsScreen`'s "History" panel and progress chart are 100% hardcoded fake data — "Medical History: PCOS, lactose intolerant" repeated verbatim for every single client, a static progress chart with no connection to any API. In a PCOS-focused wellness app, a dietitian could reasonably mistake this for that client's real medical record.
- Pull-to-refresh on the dietitian home screen dismisses immediately regardless of whether the underlying fetch has actually completed (`getAppointmentsOfDiets()` isn't awaited), giving false confidence the list is current.
- No per-meal in-flight guard in `DietPlanUserController.logMeal()` — tapping "Followed" then quickly "Skipped" on the same meal fires two concurrent requests, and whichever resolves last silently wins, with no error shown either way.

---

## Medium-severity issues

- Every mutating method in the legacy `DietController` (booking, PDF upload, calorie photo upload, status updates, deleting an appointment, saving slots) has an async gap before its blocking dialog appears, with no button-disable/debounce guard anywhere — a fast double-tap can fire two concurrent requests for any of these actions.
- The exact same unguarded time-string parsing logic (`"Start Time"` sentinel / AM-PM substring check / epoch-ms parse) is copy-pasted across three different model files. A null `start`/`end` from any one backend endpoint throws uncaught and silently kills that whole response parse, with the affected screen stuck on its loading spinner and no toast.
- Two parallel, incompatible "availability" shapes exist on the frontend too (the legacy day-of-week template vs. the newer date+slot model used by the calendar picker), mirroring the backend duplication. `ClientDetailsScreen` puts the legacy single-PDF-upload button directly next to the v2 "Generate Plan" / "Plan History" buttons with no indication of precedence, so a dietitian could use both against the same client with unclear resulting state.
- A live Spoonacular API key is hardcoded in the Flutter source and called directly from the client, bypassing the backend entirely (no quota protection, trivially extractable from the built app). The backend independently hardcodes its own Nutritionix and Spoonacular keys in source — the Nutritionix pair is for a provider the backend code doesn't even call anymore, so those credentials are exposed for nothing.
- `preConsultationController`/`preConsultationAdminController` let any non-User staff role (Trainer included, not just Dietitian/Gynecologist) read and edit a client's full medical intake — pregnancy/menstrual status, surgeries, medications, allergies — with no narrower role- or field-level restriction. Worth confirming this is the intended care model.
- `updateAppointment` on the backend has no status allow-list — a caller can jump straight from "pending" to "completed," or revive a cancelled appointment, and an unrecognized status string quietly skews the dietitian dashboard's counters instead of being rejected.
- `deleteAppointment` is a hard, unguarded, unaudited `destroy()` — deleting a completed appointment that already has a review silently drops that review from all dashboard reporting instead of erroring, and (unlike the status-update path) sends no cancellation notification to the user.
- A dietitian can edit individual meals on an already-published ("active") plan with no distinct warning, and the user's app has no mechanism to learn the plan changed underneath her short of a manual pull-to-refresh.
- `mealLogController.js` hardcodes its own list of valid meal types instead of importing the shared constant that the plan/meal models use — a future change to one won't propagate to the other.
- A validation-error detail channel exists on the admin repository (`_expectOk` parses field-level errors) but not on the user-facing repository, so if the day-7 submission endpoint ever returns field-specific validation errors, the user only ever sees a generic message.
- `getDietPlanDetailsFunc` awaits a function that doesn't actually return a `Future`, so the "wait for the PDF to load before marking details as loaded" intent silently doesn't happen (currently masked because the PDF field is itself reactive, but the actual behavior doesn't match what the code reads as intending).
- A "success" (green) toast is shown when a dietitian tries to upload a diet PDF without selecting a file first — the validation correctly blocks the upload, but tells the user it worked.
- Several genuinely user-facing strings are missing `.tr` localization wrapping in files that use `.tr` consistently elsewhere in the same file (both `add_user_diet.dart` and `track_calerories.dart`), meaning localization will visibly miss those specific strings.

---

## Low-severity / hygiene items

- Several sizable files are entirely commented out and unreferenced (`diet_plan_food_details.dart`, `assign_workout_diet_plan.dart`, `add_plan_diet.dart`, plus a ~225-line dead block inside `add_user_diet.dart`), left over from an earlier per-meal diet-editing UI that was replaced by the current single-PDF-upload flow. Harmless today, but decoy code for the next person who greps the codebase.
- `lib/UI/dev_test/diet_plan_api_test.dart` is a debug scratch screen whose own doc comment says "remove the route before shipping" — it was never wired into navigation, so it's dead weight rather than a live risk. Safe to delete.
- A data model (`MealOfUser`) owns four `TextEditingController` fields with no `dispose()` — currently unreachable since it's only used by the dead code above, but an anti-pattern that would leak controllers the moment that flow is revived.
- Minor naming/typo residue consistent with a pattern already seen elsewhere in this codebase: `app.js` requires the appointment routes file twice under two variable names (one unused, typo'd); the diet routes file is mounted at `/dietTimes` even though it also handles client listing, image upload, and nutrition lookup; a `DietitianAvailabilitySlot` model shares a name with an unrelated, older `Day7Review` model in a different folder.
- A shared exception class is defined inside the admin repository file and imported into the user repository file — works fine, but couples two files that are otherwise meant to be a clean admin/user split.

---

## Architecture: two parallel diet systems that never fully merged

Every one of the four people who looked at a piece of this independently flagged the same underlying story, which is worth stating plainly rather than leaving scattered across the findings above: **this app has a legacy diet/consultation system (appointment booking → PDF upload) and a newer "Diet Plan v2" AI-generated meal-plan system, and the migration between them was never finished.**

Concretely: two different `UserPlan` model shapes exist on the frontend with inconsistent null-handling for the same concept. Two different `Day7Review` models/controllers exist with the same name but incompatible backend contracts, living in the same folder. Three different backend models represent dietitian "availability." The actual live diet tab was swapped to the v2 system, but the 941-line legacy tab screen was left in the codebase instead of deleted. The legacy PDF-upload button sits next to the v2 AI-generation buttons on the same screen with no guidance on which to use. And the escalation/flagging feature was apparently built once for the legacy consultation flow and never rewired for v2 — see the headline finding above.

None of this is unusual for a fast-moving startup mid-migration, but it's the highest-leverage thing to clean up: most of the critical and high findings above are downstream symptoms of two systems coexisting rather than one being fully retired.

---

## What was checked and found solid

Worth stating so this doesn't read as purely negative — real, working engineering exists here:

- `dietController.js::addOrUpdateDaySlot` (backend) is the best-hardened function in the whole audit: transaction-wrapped, row-locked, validates overlaps and formats, and refuses to delete a slot that has live appointments. It should be the template the rest of the booking code follows.
- `dietitianDashboardController.js`, `consultationBookingController.js`, and `preConsultationController.js` (backend) are clean: single aggregate queries instead of N+1s, correct ownership checks, sensible whitelisting.
- `saveDraftDietPlan` (backend v2) correctly wraps the plan + all days + all meals in one transaction — no partial-write risk. Composite unique constraints are enforced at the database level, not just in application code. Foreign-key cascade/set-null behavior is sensible throughout.
- `PlanReviewEditScreen` (frontend v2) correctly locks out editing for completed/cancelled plans and correctly branches its action bar by plan status — the one part of the lifecycle that is fully solid end to end.
- Double-submit protection is done correctly in the v2 controllers (`activateCurrentPlan`, `cancelCurrentPlan`, plan generation, day-7 submit) — all properly gated on in-flight flags, unlike the legacy controller.
- `dietitian_calendar_picker.dart` (frontend) is well-defended — proper null handling, correct use of `orElse`, no issues found.

---

## Suggested priority order

1. Fix the escalation pipeline end-to-end: wire `Day7ReviewScreen` and `FlaggedReviewsScreen` into actual navigation, add an `escalated`/`flagged` status to `DietPlan` that the API surfaces, and make ticket resolution actually clear the flag and notify someone.
2. Add auth middleware to every appointment endpoint and add the ownership check to plan activation — these are open read/write/delete holes right now.
3. Fix the two frozen/crashing frontend states in the dietitian's slot-management flow (the stuck dialog and the force-unwrap), since those make the dietitian's own app unusable.
4. Decide which diet system is canonical going forward and schedule the cleanup: delete `diet_bottom_bar.dart` and the other dead legacy screens, or explicitly document why they're being kept.
5. Everything else in the high/medium lists can be worked through as a normal backlog — none of it is silently making data wrong today the way items 1–3 are, but each one is a plausible future incident.
