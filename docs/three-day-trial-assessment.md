# Fit Her 3-Day Trial

## Implementation Assessment

Date: March 20, 2026

Project: `fit_her` Flutter app

Reference specification: `FitHer_Development_Spec.docx`

## Purpose

This document evaluates whether the Fit Her 3-Day Transformation Trial described in the specification can be implemented in the current codebase, what can be reused, what must be built, and what risks or difficulties should be expected.

## Short Answer

Yes, the 3-day trial funnel is implementable, but it is not a small feature addition.

The current app already contains:
- Flutter mobile foundation
- GetX state management and routing
- Firebase initialization and FCM notifications
- Zoom/session entry integration
- existing free-trial related screens and APIs
- slot and trainer-related data structures

However, the specification describes a broader product funnel than the current implementation. It requires coordinated work across:
- mobile app
- backend
- database
- deep links
- push orchestration
- attendance tracking
- referral logic
- conversion/paywall flow

This should be treated as a new funnel implementation built on top of the current app, not as a simple extension of the current free-trial feature.

## Current Codebase Readout

### Relevant Existing App Areas

The following parts already exist and are relevant to a 3-day trial implementation:

- App bootstrap and DI:
  - `lib/main.dart`
  - `lib/helper/get_di.dart`
- Deep links:
  - `lib/data/api_provider/app_link_handler.dart`
- Notifications:
  - `lib/helper/notification_services.dart`
- Existing free-trial screens:
  - `lib/UI/free_trail/free_trail_question.dart`
  - `lib/UI/free_trail/free_trial_slots.dart`
- Existing free-trial related controllers:
  - `lib/data/controllers/home_controller/home_controller.dart`
  - `lib/data/controllers/workout_controller/work_out_controller.dart`
- Existing API/repo surface:
  - `lib/data/Repos/home_repo/home_repo.dart`
  - `lib/values/constants.dart`
- Zoom/session entry:
  - `lib/zoom_meeting.dart`
  - `lib/widgets/app_bar_widget.dart`

### What Exists Today

From the current codebase:

- The app already supports free-trial related flows.
- There are APIs for assigning and updating free-trial data.
- There is slot selection UI.
- There is notification infrastructure via Firebase Messaging.
- There is a Zoom/native meeting bridge.
- There are analytics helper hooks for free-trial events.

### What Does Not Yet Match the Spec

The current implementation does not match the requested funnel in several critical ways:

- Deep linking currently does not support token-based trial onboarding.
- The current free-trial flow looks like an in-app flow for an existing user, not a WhatsApp-to-install acquisition funnel.
- The current slot flow asks the user to select two slots early, while the spec requires Day 1 booking first and Day 2/Day 3 progression after attendance.
- No visible magic-link auth flow exists yet.
- No visible referral lifecycle exists yet.
- No visible trial state machine exists yet.
- No visible backend-driven reservation lifecycle exists yet.

## Feasibility

## Can It Be Implemented?

Yes.

This codebase is a workable starting point for the 3-day trial product because the app already has:
- authentication support
- session support
- notifications
- slot concepts
- free-trial concepts
- user role concepts

The limiting factor is not Flutter capability. The limiting factor is product orchestration and backend support.

## Feasibility Rating by Area

- Mobile app UI and flow: feasible
- Deep-link onboarding: feasible
- Push notification flow: feasible
- Zoom/session integration: feasible, but requires careful validation
- Referral flow: feasible
- Trial lifecycle tracking: feasible
- Attendance-based automation: feasible, but moderately difficult
- Android uninstall intercept: uncertain and should be treated as experimental

## Pros

Implementing this funnel has several strong advantages.

### Product Pros

- The offer is clear and easier to communicate than a generic free trial.
- A 3-day structure gives users a visible beginning, middle, and end.
- The funnel is designed to maximize activation, attendance, and conversion.
- The privacy/safe-space positioning is strong and differentiated.
- The document defines concrete behavioral touchpoints instead of vague onboarding.

### Business Pros

- The funnel is measurable from acquisition to conversion.
- Referral reward logic can reduce paid acquisition dependency.
- Structured retention steps can improve completion rates.
- Trial-to-paid conversion can be measured day-by-day.

### Technical Pros

- The app already contains reusable free-trial and slot components.
- FCM and session primitives are already present.
- Existing analytics helper code can be extended rather than introduced from zero.
- Existing trainer/slot domain models reduce the amount of new modeling required.

## Cons

This funnel also introduces meaningful tradeoffs.

### Product/Operational Cons

- The system becomes operationally heavier because classes, trainers, attendance, and push timing must all work reliably.
- Strict sequential flows can create drop-off if recovery states are weak.
- The privacy promise raises the quality bar on session behavior and moderation.
- The trial experience depends on trainer availability and slot inventory, not only app behavior.

### Technical Cons

- This is not a single-module change. It cuts across many app layers.
- The current free-trial flow will likely need redesign, not just patching.
- Backend scheduling and event correctness become critical.
- There are more states to keep in sync across app, backend, CRM, and notification systems.

## Main Difficulties

## 1. Backend Is the Critical Path

The specification assumes major backend support that is not visible in the Flutter codebase today.

Examples:
- token generation and expiry
- token validation and single-use enforcement
- reservation lifecycle
- attendance event processing
- referral attribution
- reward granting
- push scheduling tied to slot start times
- churn pipeline state transitions

Without backend support, the app can only fake the funnel visually.

## 2. Trial State Management Will Become Complex

The trial is not a boolean flag. It is a staged lifecycle.

Suggested backend state model:
- qualified
- token_sent
- installed
- trial_started
- day1_booked
- day1_attended
- day2_booked
- day2_attended
- day3_booked
- day3_attended
- referred
- converted
- churned

If this is not modeled clearly, the app will accumulate fragile conditional logic.

## 3. Deep-Link Magic Login Is New Work

The document requires:
- pre-install magic link
- app install detection/deep link continuation
- first-open token validation
- auto-account creation or matching
- session establishment
- failure handling for expired or used tokens

The current deep-link handling is too limited for this and will need redesign.

## 4. Attendance Tracking Is Harder Than It Looks

The specification depends on the `class_attended` event for downstream actions.

That event controls:
- review prompt
- Day 2 prompt
- referral reward trigger
- Day 3 conversion timing

If attendance is based only on app open or meeting join tap, the funnel will be inaccurate. The app and backend need a trustworthy method for detecting actual session participation and minimum duration.

## 5. Existing Free-Trial Flow Conflicts with the New Funnel

The current app suggests:
- select two slots
- personalize
- assign free trial

The specification requires:
- qualify outside the app
- install with token
- onboard
- request push permission
- book Day 1
- progress after attendance

This means parts of the current free-trial flow may need replacement or branching logic instead of reuse as-is.

## 6. Push Scheduling Must Be Backend-Led

The specification defines timed pushes relative to class start times and trial states.

This should not rely only on local device scheduling because:
- users may reinstall
- users may log in on another device
- bookings may be changed or cancelled
- timing must remain correct server-side

The mobile app should receive and handle notifications, but backend should own scheduling and cancellation.

## 7. Referral Logic Is Cross-Cutting

Referral implementation touches:
- link generation
- install attribution
- trial token linkage
- friend attendance tracking
- reward application
- subscription extension
- share UX

This is feasible, but it should not be bundled into the first MVP unless the core trial flow is already stable.

## 8. The Android Uninstall Intercept Is a Risky Requirement

The document presents it as zero-cost and straightforward. That should not be assumed.

This requirement is the least reliable part of the spec because:
- Android behavior varies by version and OEM
- launcher and uninstall entry points differ
- the interception window is narrow
- user experience risks are high

Recommendation:
- treat this as an optional experiment
- do not include it in the core delivery scope

## Recommended Delivery Strategy

The correct approach is phased delivery, not full-spec implementation in one release.

## Phase 1: Core Trial MVP

Goal: deliver the minimum viable 3-day trial that works end-to-end.

Scope:
- token-based deep-link entry
- token validation
- account creation or login
- onboarding flow
- push permission prompt
- Day 1 slot booking
- pre-class push sequence
- waiting room entry
- attendance capture
- Day 1 review
- Day 2 booking prompt
- Day 2 and Day 3 repetition
- paywall after Day 3

Success criteria:
- users can start from link and reach Day 3 completion
- backend can track each stage correctly
- push reminders are reliable

## Phase 2: Recovery and Optimization

Scope:
- missed-class rescue
- rescheduling flows
- richer analytics dashboards
- real-time seat indicators
- waitlist logic
- review re-prompt

Success criteria:
- drop-off is reduced
- missed sessions can be recovered cleanly

## Phase 3: Growth Features

Scope:
- referral flow
- reward automation
- churn win-back
- post-subscribe referral touchpoint

Success criteria:
- referral attribution is correct
- reward granting is auditable

## Phase 4: Experimental Features

Scope:
- Android uninstall intercept

Success criteria:
- validated across supported Android versions
- does not create regressions or policy risk

## What Can Be Reused

The following can likely be reused or adapted:

- FCM notification setup in `lib/main.dart`
- notification handling in `lib/helper/notification_services.dart`
- Zoom/native meeting bridge in `lib/zoom_meeting.dart`
- some slot listing and trainer data structures
- analytics helper event patterns
- existing repositories/controllers for free-trial and workout slots

## What Needs New Implementation

The following likely needs to be built new or heavily redesigned:

- tokenized deep-link trial onboarding
- pre-install landing page
- token validation screens and invalid-token recovery
- trial state machine
- reservations model and APIs
- Day 1/2/3 progression UI
- attendance verification flow
- referral generation and reward lifecycle
- conversion/paywall sequencing tied to trial completion
- backend job scheduling for notifications and churn automation

## Mobile App Risks Specific to This Codebase

The current codebase also contains some implementation quality issues that may slow this work unless cleaned up during delivery.

Observed examples:
- many runtime packages are placed under `dev_dependencies` in `pubspec.yaml`
- deep-link handling is currently narrow and not token-ready
- some global security and configuration practices are weak, including hardcoded secrets and permissive certificate handling
- there are architectural signs of mixed responsibilities in controllers and views

These do not block the feature completely, but they will increase implementation and QA cost if left untouched.

## Recommended Scope Decision

The full document should not be accepted as a single engineering task.

Recommended decision:
- approve the 3-day trial as a multi-phase initiative
- define backend and mobile contracts before UI implementation
- ship MVP first
- defer referral, win-back, and uninstall intercept until the core funnel is stable

## Final Recommendation

The 3-day trial is achievable with the current project, but only if it is treated as a structured funnel initiative rather than a quick feature.

Best practical path:
- reuse the current Flutter foundation
- redesign the free-trial flow around tokenized onboarding and day-based progression
- make backend the source of truth for trial state, booking state, and push scheduling
- keep referral and uninstall interception out of the first release

If executed in phases, this can be implemented well.

If attempted all at once, the main risks are:
- delayed delivery
- inconsistent user states
- unreliable attendance logic
- broken push timing
- conversion funnel bugs that are difficult to debug

## Suggested Next Step

Create a technical implementation plan with:
- required backend tables and endpoints
- app screens to add or replace
- event/state definitions
- MVP vs deferred scope
- QA scenarios by trial day and failure path
