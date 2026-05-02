# Sprint 3 — Classes Schedule (S-18) Redesign Audit

> Read-only investigation. No production files modified.
> Generated 2026-04-28. Source artefacts paste-in-line.

---

## Executive summary

- **One screen to redesign in place:** `lib/UI/dashboard_module/bottom_bar_screen/work_out_bottom_screen.dart` (`WorkOutBottomScreen`). The existing Workout Schedule (month attendance grid + 7 weekday `ExpansionTile`s) becomes a **timeline**: weekly day-strip + vertical class timeline for the selected day with past/live/upcoming states.
- **Mockup file located:** `C:/Users/dell/Desktop/dev/new screens/Sprint3_Visual.html` — frame **S-18 (lines 30–118)**. The file also contains S-19 (class detail), SC-01 (booking confirmed), S-20 (in-class), S-21 (post-class) — out of scope for this audit.
- **No API or route changes needed.** The existing `WorkOutController.getDietPlanDetailsFunc(planId)` already returns `trainerSlots[].slots[]` with all the per-slot fields needed for class name + trainer + time + type. The same `HelpingWidgets.showWorkoutBottomSheet` carries the slot tap action.
- **3 hard data gaps that need a founder decision before build:** (1) intensity-level mapping, (2) attendance count "34 women" for the LIVE card, (3) per-slot "✓ attended" indication for past classes. Each has a "ship now without it" workaround.
- **Estimated effort:** 5–6 hours including the 3 new sub-widgets (DayStrip, TimelineCard, IntensityTag).

---

## Step 1 — Files located

### NEW design
| Field | Value |
|---|---|
| **Path** | `C:/Users/dell/Desktop/dev/new screens/Sprint3_Visual.html` |
| **Modified** | 2026-04-27 13:27 (most recent file in folder) |
| **Size** | 35,302 bytes (438 lines) |
| **Frame for this audit** | **S-18 · Classes home · timeline** (lines 30–118) — labelled `S-18 · locked` ("the anchor screen") |
| Other frames in same file (out of scope) | S-19 class detail (line 121), SC-01 booking confirmed (233), S-20 in-class (298), S-21 post-class (360) |

### OLD implementation
| Field | Value |
|---|---|
| **Path** | `lib/UI/dashboard_module/bottom_bar_screen/work_out_bottom_screen.dart` |
| **Class** | `WorkOutBottomScreen extends StatefulWidget` |
| **Constructor** | `WorkOutBottomScreen({super.key, required this.planId})` |
| **Reached from** | `WorkPlansOfUser` (the Workout tab's plan picker) when user taps a plan card |
| **Back button target** | `Get.back()` → returns to `WorkPlansOfUser` |

Confirmed by grepping `"Workout Schedule"` (the AppBar title string) — single hit at line 81 of this file.

---

## Step 2 — New design extraction (S-18 verbatim)

### Frame structure (full markup, base64 redacted — none in this frame)

```html
<!-- ═══ S-18 · CLASSES HOME (V1 TIMELINE - LOCKED) ═══ -->
<div class="phone"><div class="sc">

  <!-- iOS-style status bar mock -->
  <div class="sb"><span>9:41</span><div class="sbr">…signal + battery svgs…</div></div>

  <!-- Header zone (24/24/16 padding) -->
  <div style="padding:24px 24px 16px;">

    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:18px;">
      <div>
        <div style="font-size:11px;color:#7a8c78;font-weight:700;letter-spacing:.08em;margin-bottom:2px;">YOUR SCHEDULE</div>
        <div style="font-size:24px;font-weight:800;color:#1a3a22;letter-spacing:-.02em;">Friday, 25 April</div>
      </div>
      <div style="display:flex;gap:6px;">
        <div class="icon-btn"><svg…polyline points="15 18 9 12 15 6"/></svg></div>   <!-- left chevron -->
        <div class="icon-btn"><svg…polyline points="9 18 15 12 9 6"/></svg></div>    <!-- right chevron -->
      </div>
    </div>

    <!-- Day strip — 7 equal-flex pills, M T W T F S S with date numbers 21..27 -->
    <div style="display:flex;gap:5px;">
      <div style="flex:1;text-align:center;padding:9px 4px;border-radius:11px;">
        <div style="font-size:9px;color:#7a8c78;font-weight:700;">M</div>
        <div style="font-size:13px;color:#1a3a22;font-weight:800;margin-top:1px;">21</div>
      </div>
      …Tue (22), Wed (23), Thu (24)…
      <!-- ACTIVE day (Friday 25): dark fill, green letter -->
      <div style="flex:1;text-align:center;padding:9px 4px;border-radius:11px;background:#0d2014;">
        <div style="font-size:9px;color:#6DC55A;font-weight:700;">F</div>
        <div style="font-size:13px;color:#fff;font-weight:800;margin-top:1px;">25</div>
      </div>
      …Sat (26), Sun (27)…
    </div>
  </div>

  <!-- Timeline (12/24/30 padding) — 5 cards: past, LIVE, upcoming x 3 -->
  <div style="padding:12px 24px 30px;">

    <!-- 1. PAST card (10:30 AM, completed) -->
    <div style="display:flex;gap:14px;margin-bottom:14px;">
      <div style="width:50px;text-align:right;flex-shrink:0;">
        <div style="font-size:13px;font-weight:800;color:#7a8c78;">10:30</div>
        <div style="font-size:9px;color:#9ab09a;font-weight:600;margin-top:1px;">AM</div>
      </div>
      <div style="position:relative;flex-shrink:0;width:12px;">
        <div style="width:12px;height:12px;border-radius:50%;background:#fff;border:2px solid #6DC55A;margin-top:4px;"></div>
        <div style="position:absolute;top:18px;left:5px;width:2px;height:calc(100% - 10px);background:#C8DEC4;"></div>
      </div>
      <div style="flex:1;background:#fff;border-radius:14px;padding:12px;opacity:.6;">
        <div style="font-size:13px;font-weight:800;color:#1a3a22;margin-bottom:2px;">Hormonal Yoga ✓</div>
        <div style="font-size:11px;color:#7a8c78;">Ayesha · 45m · gentle</div>
      </div>
    </div>

    <!-- 2. LIVE/NOW card (12 min remaining) -->
    <div style="display:flex;gap:14px;margin-bottom:14px;">
      <div style="width:50px;text-align:right;flex-shrink:0;">
        <div style="font-size:13px;font-weight:800;color:#E24B4A;">NOW</div>
        <div style="font-size:9px;color:#E24B4A;font-weight:700;margin-top:1px;">12 min</div>
      </div>
      <div style="position:relative;flex-shrink:0;width:12px;">
        <!-- live-pulse animation = expanding red ring -->
        <div class="live-pulse" style="width:14px;height:14px;border-radius:50%;background:#E24B4A;margin-top:3px;border:2px solid #fff;box-shadow:0 0 0 2px #E24B4A;margin-left:-1px;"></div>
        <div style="position:absolute;top:20px;left:5px;width:2px;height:calc(100% - 12px);background:#C8DEC4;"></div>
      </div>
      <div style="flex:1;background:#0d2014;border-radius:18px;padding:18px;position:relative;overflow:hidden;">
        <!-- Decorative green-glow circle, top-right -->
        <div style="position:absolute;top:-30px;right:-30px;width:120px;height:120px;border-radius:50%;background:rgba(109,197,90,.12);"></div>
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px;position:relative;z-index:2;">
          <div class="live-pulse" style="background:#E24B4A;border-radius:100px;padding:3px 9px;display:flex;align-items:center;gap:5px;">
            <div class="live-dot" style="width:5px;height:5px;border-radius:50%;background:#fff;"></div>
            <span style="font-size:9px;font-weight:800;color:#fff;letter-spacing:.1em;">LIVE</span>
          </div>
          <span style="font-size:11px;color:rgba(255,255,255,.6);font-weight:500;">34 women</span>
        </div>
        <div style="font-size:18px;font-weight:800;color:#fff;letter-spacing:-.01em;line-height:1.1;margin-bottom:3px;position:relative;z-index:2;">Strength Training</div>
        <div style="font-size:11px;color:rgba(255,255,255,.6);margin-bottom:14px;position:relative;z-index:2;">Rania Shah · 38m · intense</div>
        <button style="width:100%;background:#6DC55A;color:#0d2014;border:none;border-radius:12px;padding:12px;font-family:inherit;font-size:13px;font-weight:800;cursor:pointer;position:relative;z-index:2;">Join now</button>
      </div>
    </div>

    <!-- 3. UPCOMING — Core & Pilates (moderate/yellow) -->
    <div style="display:flex;gap:14px;margin-bottom:14px;">
      <div style="width:50px;text-align:right;flex-shrink:0;"><div style="font-size:13px;font-weight:800;color:#1a3a22;">2:00</div><div style="font-size:9px;color:#7a8c78;font-weight:600;margin-top:1px;">PM</div></div>
      <div style="position:relative;flex-shrink:0;width:12px;"><div style="width:12px;height:12px;border-radius:50%;background:#fff;border:2px solid #C8DEC4;margin-top:4px;"></div><div style="position:absolute;top:18px;left:5px;width:2px;height:calc(100% - 10px);background:#C8DEC4;"></div></div>
      <div style="flex:1;background:#fff;border-radius:14px;padding:12px;border-left:3px solid #FAC775;">
        <div style="font-size:13px;font-weight:800;color:#1a3a22;margin-bottom:2px;">Core & Pilates</div>
        <div style="font-size:11px;color:#7a8c78;">Sara · 30m · <span style="color:#FAC775;font-weight:700;">moderate</span></div>
      </div>
    </div>

    <!-- 4. UPCOMING — HIIT for Energy (intense/coral-red) -->
    …same pattern, border-left:3px solid #FF8A8A; intensity span color #FF8A8A…

    <!-- 5. UPCOMING — Wind-down Flow (restorative/green) — last card, no trailing connector -->
    …same pattern, border-left:3px solid #6DC55A; intensity span color #6DC55A…

  </div>

</div></div>
```

### Element-by-element

| Element | Spec |
|---|---|
| **A. Background** | Page background `#E8F4E0` (mint, set on `.phone` in shared CSS at line 9). Flat — **no gradient, no blobs** in this frame. |
| **B. Status bar** | iOS mock with dark `#1a3a22` icons. Flutter handles via `SystemChrome.setSystemUIOverlayStyle(statusBarColor: Color(0xFFE8F4E0), statusBarIconBrightness: Brightness.dark)`. |
| **C. Header section** | "YOUR SCHEDULE" tracking-08 caps `#7A8C78` 11sp w700 + "Friday, 25 April" 24sp w800 `#1A3A22` -.02em. Two right-side **40×40 circle buttons** (`.icon-btn`: white bg, 1px `#C8E8BC` border) with chevron L/R icons. |
| **D. Day strip** | 7 equal-`flex:1` pills, gap 5. Each: padding 9×4, radius 11. Inactive: clear bg, letter `#7A8C78` 9sp w700, number `#1A3A22` 13sp w800. **Active (Friday 25)**: bg `#0D2014` (near-black green), letter `#6DC55A`, number `#FFFFFF`. No horizontal scroll — all 7 fit at flex-1 on 390-wide phone. |
| **E. Class card states** | **Three distinct visual states** — see breakdown below. |
| **F. Timeline indicator** | Per-card vertical structure: 50px right-aligned time block + 12px dot column + flex-1 card. Dot has 12×12 border (white fill + 2px green/grey) and a 2px wide × `calc(100% − 10px)` `#C8DEC4` line absolutely positioned below it. **Last card has NO trailing line** (the dot column is shorter — see line 108 markup). |
| **G. Color codes** | bg mint `#E8F4E0` · active day pill bg `#0D2014` + accent `#6DC55A` · LIVE card bg `#0D2014` · LIVE indicator `#E24B4A` (red) · gentle/restorative `#6DC55A` · moderate `#FAC775` (amber) · intense `#FF8A8A` or `#E24B4A` (the mockup uses both — `#FF8A8A` for "intense" upcoming, `#E24B4A` for the LIVE marker) · text dark `#1A3A22` · muted text `#7A8C78` / `#9AB09A` · grey text on dark `rgba(255,255,255,.6)`. |
| **H. Typography** | **Plus Jakarta Sans** for everything (per `<link>` in head). The "Friday, 25 April" header is **bold sans-serif at 24sp w800**, NOT serif. (No DM Serif Display in this frame.) Time markers: 13sp w800 + 9sp w600 AM/PM. Class names: 13sp w800 (white card) / 18sp w800 (LIVE dark card). Meta line: 11sp w500. |
| **I. Spacing rhythm** | Header padding 24/24/16. Timeline padding 12/24/30. Card-to-card vertical gap: 14. Within card row: gap 14 (time → dot → card). Card internal padding: 12 (white) / 18 (LIVE dark). |

### Class card variants (3 states + intensity colour map)

| State | Spec |
|---|---|
| **PAST** (line 67–70) | White bg, 14r, padding 12, **opacity 0.6** (overall mute). Title with **`✓` checkmark suffix** (Unicode in text). Trainer dot 2px outline `#6DC55A` (filled border). Meta line: `Ayesha · 45m · gentle` — no color span on intensity. |
| **NOW / LIVE** (line 76–85) | Dark `#0D2014` bg, **18r** (slightly bigger), padding **18**. Decorative `rgba(109,197,90,.12)` 120×120 blur circle peeking from top-right corner. Header row: **red animated `LIVE` pill** + ` 34 women` text (rgba white .6). Title: **18sp** w800 white. Meta: white .6. **Full-width green `#6DC55A` "Join now" button** (12sp w800 dark text, 12r, padding 12). Animated dot in timeline column (red, white border, red glow ring). |
| **UPCOMING** (lines 88–112) | White bg, 14r, padding 12. **3px coloured left-border per intensity** (yellow `#FAC775` / coral `#FF8A8A` / green `#6DC55A`). Title 13sp w800 dark. Meta line includes a coloured `<span>` on the intensity word matching the left-border. Plain `#C8DEC4` dot (no fill). |

### Intensity colour map (4 levels)

| Level | Mockup colour | Where it appears |
|---|---|---|
| `gentle` | (no color in past card — muted only) `#6DC55A` would be its "active" colour | Past Hormonal Yoga |
| `moderate` | **`#FAC775`** amber | Core & Pilates (left-border + meta span) |
| `intense` | **`#FF8A8A`** coral on upcoming, **`#E24B4A`** red when active/LIVE | HIIT for Energy (upcoming), Strength Training (LIVE) |
| `restorative` | **`#6DC55A`** green | Wind-down Flow |

> Note: the LIVE card's "intense" word in the meta line is shown in plain rgba-white-.6, NOT in the intensity colour. Only the left-border + the upcoming meta-span use the intensity colour.

---

## Step 3 — Old implementation extraction

### File metadata

| Field | Value |
|---|---|
| Path | `lib/UI/dashboard_module/bottom_bar_screen/work_out_bottom_screen.dart` |
| Lines | 369 |
| Class | `WorkOutBottomScreen extends StatefulWidget` |
| Constructor | `WorkOutBottomScreen({super.key, required this.planId})` — single required `planId` |
| State | `_WorkOutBottomScreenState` |
| Controllers | `HomeController`, `WorkOutController`, `MotivationController` (all `Get.find()`); `AuthController` resolved on demand inside `_loadCyclePhase` |
| Lifecycle | `initState` calls `_loadCyclePhase()` (cycle data → phase → for "Recommended" badge highlighting per Phase 5 work) |
| Side effects on load | (1) cycle-data fetch via `CycleDataRepository.getCycleData()`; (2) inside `motivationController.fetchMotivationStats()` is invoked lazily inside the build closure when stats are null and not already loading |

### `build()` walkthrough (top → bottom)

1. **AppBar** — `HelpingWidgets().appBarWidget(Get.back, text: "Workout Schedule")`. Standard back-arrow appbar.
2. **Body wrapped in `Obx(() …)`** watching `workOutController.workOutPlanDetailsLoad`:
   - **Loading** → `CircularProgress()`
   - **Loaded** → `RefreshIndicator` wrapping a `ListView` with:
     1. Reassurance copy: *"We provide you with flexible timeslots throughout the day so that you can join according to your feasibility"*
     2. **Month attendance grid** — current month, S/M/T/W/T/F/S header, 6×7 grid of date circles (filled `MyColors.buttonColor` if attended). Built inside a `Builder` that lazy-fires `motivationController.fetchMotivationStats()` if not loaded. Has shimmer placeholder.
     3. **`ListView.separated`** of `ExpansionTile`s, one per `trainerSlots[].day`. Today's weekday tile is `initiallyExpanded: true` (`DateFormat('EEEE').format(DateTime.now()) == time.day`).
     4. **Inside each tile**: `ListView.separated` of slot cards. Each card shows:
        - Optional `RecommendedBadge` (when `RecommendationService.isRecommended(slot.type, _currentPhase)` is true — cycle-phase-aware highlighting from Phase 5)
        - `slot.type ?? "N/A"` (class type label)
        - `slot.start - slot.end` (already-formatted "hh:mm a" strings)
        - 12-radius CircleAvatar with `MyImgs.logo` + trainer first/last name on the right side as a row
        - `slot.status ?? ""` text on the right edge
     5. **Tap on slot card** → `HelpingWidgets.showWorkoutBottomSheet(context: context, slot: slot, homeController: homeController)` — opens the join/details bottom sheet. **This is the key preserved action.**

### API call (preserve exactly)

```dart
// Triggered when WorkPlansOfUser tapped a plan card; the response feeds
// workOutController.getUserWorkoutPlanDetailsPlan.trainerSlots[].slots[].
workOutController.getDietPlanDetailsFunc(planId)
```

Misnamed function — fetches **workout** plan details despite "DietPlan" in the name. Returns `GetUserWorkoutPlanDetails { trainerSlots: List<TrainerSlot>, plan: Plan }`.

### Pull-to-refresh

```dart
RefreshIndicator(
  onRefresh: () { workOutController.getDietPlanDetailsFunc(widget.planId); return Future.value(); },
  …
)
```

### Imports list (16)

```dart
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/data/controllers/zoom_controller.dart';
import 'package:fitness_zone_2/data/Repos/cycle_repo/cycle_data_repository.dart';
import 'package:fitness_zone_2/data/services/cycle_engine.dart';
import 'package:fitness_zone_2/data/services/recommendation_service.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/recommended_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../data/models/get_user_plan/get_workout_user_plan_details.dart';
import '../../../helper/custom_print.dart';
import '../../../values/constants.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/review_bottom_sheet.dart';
import '../../../widgets/toasts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:fitness_zone_2/data/controllers/motivation_controller/motivation_controller.dart';
```

Many will become unused after rewrite (zoom_controller, url_launcher, permission_handler, review_bottom_sheet, custom_print, my_imgs, my_colors, recommended_badge if we drop the badge, etc.). Trim during build.

---

## Step 4 — Diff + preservation table

### VISUAL / UX CHANGES (apply)

| Element | OLD | NEW (S-18) | Change Type |
|---|---|---|---|
| Background | white | mint `#E8F4E0` flat | VISUAL |
| Status bar | inherited | `#E8F4E0` + dark icons | BEHAVIOURAL |
| Top chrome | `HelpingWidgets.appBarWidget` with back arrow + title `Workout Schedule` | "YOUR SCHEDULE / Friday, 25 April" header + 2 chevron buttons (L/R) on right. **No system back arrow shown** — see Q-OPEN below | COMPONENT |
| Sub-copy | *"We provide flexible timeslots…"* | (none in new design) | REMOVE |
| Date selection | full-month attendance grid (6×7 of date circles) — read-only display, NOT a date picker | horizontal 7-pill day strip showing current week, tap to select | COMPONENT |
| Day display | Stack of 7 ExpansionTile sections (one per weekday, today auto-expanded) | Vertical timeline of selected day's class cards only | COMPONENT |
| Class card layout | Bordered Container 90h, row of `[type, start-end, trainer avatar+name] | status` | Time-on-left + dot column + variable-state card. Three variants: past / live / upcoming | COMPONENT |
| LIVE state | (no special handling — slot.status text only) | Dedicated dark card `#0D2014` 18r with red `LIVE` pill, "N women" attendance, prominent green Join Now button | NEW UI STATE |
| Past state | (no past/future awareness) | Muted card opacity 0.6 with `✓` suffix | NEW UI STATE |
| Upcoming intensity | `slot.level` text shown only via RecommendedBadge | 3px coloured left-border + coloured `level` word in meta line, mapped to `gentle / moderate / intense / restorative` | NEW |
| Recommended badge (Phase 5) | Shown on slots matching cycle phase | **Drop in V2** — the new design uses intensity color instead. (Or preserve in addition — see Q-OPEN) | VISUAL |
| Month attendance grid | Always shown above class list | **Removed** in new design. Attendance can move to a separate "stats" surface later | REMOVE |
| Pull-to-refresh | `RefreshIndicator` re-fires `getDietPlanDetailsFunc(planId)` | **Preserve** | NO CHANGE |
| Empty state | (current code assumes data exists; would crash on `.length` if `trainerSlots` is empty) | Need a "No classes today" state when selected day has no slots | NEW |

### PRESERVE EXACTLY

| Item | Verified location | Why |
|---|---|---|
| Class name `WorkOutBottomScreen` | `work_out_bottom_screen.dart:27` | Imported from `WorkPlansOfUser` (line 74) when a plan card is tapped |
| Constructor `WorkOutBottomScreen({super.key, required this.planId})` | `work_out_bottom_screen.dart:28` | Caller passes `planId: plan.id.toString()` |
| API call `workOutController.getDietPlanDetailsFunc(widget.planId)` | called from `WorkPlansOfUser` BEFORE navigation, and from this screen's `RefreshIndicator` | Server contract preserved |
| Slot tap action `HelpingWidgets.showWorkoutBottomSheet(context, slot, homeController)` | `work_out_bottom_screen.dart:276` | The booking / join flow lives inside this bottom sheet — **DO NOT bypass** |
| `_loadCyclePhase` + `RecommendationService.isRecommended(slot.type, _currentPhase)` | lines 49–71, 294–299 | Cycle-phase recommendation logic from Phase 5 (decision: keep or drop — see Q-OPEN) |
| `motivationController.fetchMotivationStats()` lazy fetch | lines 102–105 | Was driving the month attendance grid. If grid is removed, this fetch can also be removed — but only if no other screen depends on the cached stats. **Need cross-check** |
| Pull-to-refresh re-fetch | line 86–89 | UX expectation |
| Back navigation `Get.back()` | line 80 (the appbar back arrow) | If we remove the appbar, the back behaviour needs a replacement — see Q-OPEN |
| Imports for `WorkOutController`, `HomeController`, `HelpingWidgets`, `Get`, `flutter_screenutil`, `intl` | various | Carry forward unchanged |

---

## Step 5 — Data mapping (CRITICAL)

`WorkOutController.getUserWorkoutPlanDetailsPlan.trainerSlots[].slots[]` is the source. Each `Slot` has these fields (per `lib/data/models/get_user_plan/get_workout_user_plan_details.dart`):

```dart
class Slot {
  int id;
  String start;            // pre-formatted "hh:mm a" (e.g., "08:00 AM")
  String end;              // same format
  String? trainerLink;
  ClientUser? trainer;     // .firstName, .lastName, etc.
  String? type;            // class type label (e.g., "Strength Training")
  String? level;           // intensity label — FREE-FORM STRING, value space unknown
  String? description;
  int? joinedUserUID;      // SINGULAR uid (the joined user), NOT a count
  String? token;
  String? status;          // free-form (e.g., "Upcoming Class", maybe "Live", maybe blank)
  bool? isTrainerJoined;   // whether the trainer has joined the call
}

class TrainerSlot { int id; String day; List<Slot> slots; }   // day = "Monday".."Sunday"
```

### Mapping new design fields → existing data

| New design needs | Source | Status |
|---|---|---|
| Time slot label (`10:30 AM`) | `slot.start` | ✅ ready (already formatted "hh:mm a") |
| Time of day in mockup format (`10:30` + `AM` on 2 lines) | parse `slot.start` → split on space | ✅ trivial client-side split |
| Class name (`Strength Training`) | `slot.type` | ✅ ready |
| Instructor (`Rania Shah`) | `slot.trainer?.firstName + " " + slot.trainer?.lastName` | ✅ ready |
| Duration (`38m`) | compute `slot.end − slot.start` | ⚠️ client-side compute — straightforward (parse two "hh:mm a" strings, diff in minutes) |
| **Intensity (`gentle/moderate/intense/restorative`)** | `slot.level` | 🔴 **GAP — see below** |
| **Status (past / now / upcoming)** | compute from `slot.start/end` vs `DateTime.now()` against the SELECTED date | ⚠️ client-side compute. Easy when selected date == today; for other dates, all slots are either all-past or all-upcoming relative to today |
| **Time remaining (`12 min`)** for the LIVE card | compute `slot.end − DateTime.now()` | ⚠️ requires periodic refresh (every 60s `setState`) to keep accurate |
| **Attendance count (`34 women`)** for LIVE | `slot.joinedUserUID` is a single int (the joined-user UID), **NOT a count** | 🔴 **GAP — not in API** |
| **`✓` checkmark on past class** (user attended this specific slot) | `motivationController.attendanceHistory[date].attended == 1` is **per-date**, not per-slot. Would mark ALL past slots ✓ on any attended date | 🔴 **GAP — wrong granularity** |
| LIVE state detection | — | derived: `slot.status == "Live"` OR `slot.isTrainerJoined == true` OR (today + now within [start, end]). Need confirmation of which of these is the canonical truth |
| "Join now" tap action | `HelpingWidgets.showWorkoutBottomSheet(context, slot, homeController)` | ✅ preserve (same call as the existing slot card tap) |
| Day strip date numbers (21, 22, …) | compute current week's Monday-Sunday dates from `DateTime.now()` | ⚠️ pure client-side. Map weekday name → date for display. |
| Header date label (`Friday, 25 April`) | format selected date with `DateFormat('EEEE, d MMMM')` | ✅ trivial |
| Empty state when `trainerSlots[].day == selectedWeekday` returns no slots | branch in render | ⚠️ new state to design — copy TBD |

### The 3 hard gaps + workarounds

#### Gap 1 — Intensity mapping
Mockup uses **4 fixed levels** (`gentle / moderate / intense / restorative`). `Slot.level` is a free-form `String?`. We don't know the actual values in production data without sampling — likely `"Beginner"`, `"Intermediate"`, `"Advanced"` or similar trainer-typed strings.

**Three options:**
- **(a) Backend addition:** add an `intensity` enum column to slots, populate via admin UI; show in V2 with the colour-coded UI. *Cleanest, requires backend + admin work.*
- **(b) Client-side mapping table:** keep current `slot.level` strings, define a Dart `Map<String, IntensityLevel>` translating known values, default to `moderate` if unknown. *Ships now without backend changes; risks stale mappings.*
- **(c) Reuse `RecommendationService.intensity` from Phase 5:** the existing service already maps `slot.type` → `high/medium/low` based on class-type keywords. Translate `high → intense`, `medium → moderate`, `low → restorative/gentle`. *Free-of-charge — leverages existing wiring. Doesn't require knowing what `slot.level` contains.*

Recommend **(c)** for the build, with **(a)** as a follow-up cleanup.

#### Gap 2 — Attendance count "34 women"
Not in current API. Three options:
- **(a) Backend addition:** new endpoint `GET /slots/:id/attendance_count` OR extend the workout-plan-details response to include `joinedCount` per slot. *Requires backend.*
- **(b) Hide the count** in the LIVE card. Show only the red `LIVE` pill. *Ships without backend; loses social-proof element.*
- **(c) Mock with a placeholder** (e.g., a static random number 20–50). *Dishonest and cheap — not recommended.*

Recommend **(b)** for the build, **(a)** as a follow-up.

#### Gap 3 — Per-slot `✓` checkmark
`motivationController.attendanceHistory` is keyed by date only — we know "user attended a class on Apr 25", not which specific slot. Three options:
- **(a) Backend track per slot** by populating `ClassAttendances.slot_id` consistently. The column exists (nullable). Then expose per-slot attendance in the workout-plan-details response. *Requires backend + admin/cron work to populate.*
- **(b) Show all past-of-today slots as muted-without-✓.** Simpler — the mute already conveys "can't join, in the past". Just drop the ✓ semantic. *Ships without backend.*
- **(c) Show ✓ only when ANY class was attended that date** (apply uniformly to every past slot of that day). *Misleading — implies the user did all of them.*

Recommend **(b)** for the build, **(a)** as a follow-up.

---

## Step 6 — Implementation proposal

### File path & scope
- **Replace** `lib/UI/dashboard_module/bottom_bar_screen/work_out_bottom_screen.dart` in place.
- Class signature, constructor, all preserved-list items locked.
- **No other files touched** in this PR.
- **No backend changes** in this PR (all 3 gaps use the "ship without it" workarounds; backend tracked separately).

### New widgets (inline private classes, single file)

| Widget | Role |
|---|---|
| `_DayStrip` | Stateful — current week's 7 dates as flex-1 pills. Active state indicator. Tap → `setState(_selectedDate = …)` |
| `_TimelineCard` | Stateless — variants for `past / live / upcoming`. Owns the time column, dot+line column, and the right-side card body |
| `_IntensityTag` | Stateless — colour-coded text span based on `IntensityLevel` enum |
| `_LiveSlotBody` | Stateless — the dark `#0D2014` card content for the LIVE state (LIVE pill + attendance + name + meta + Join now button) |
| `_emptyDayState()` | Local builder — "No classes today" placeholder when selected weekday has zero slots |

### Color tokens (inline V2 hex pattern, matches Welcome V3 / Sign In S-02 family)

```dart
static const Color _bg = Color(0xFFE8F4E0);       // page bg
static const Color _textDark = Color(0xFF1A3A22); // primary text
static const Color _textMuted = Color(0xFF7A8C78); // labels, meta
static const Color _textHint = Color(0xFF9AB09A);
static const Color _connector = Color(0xFFC8DEC4); // timeline line + inactive dots
static const Color _liveBgDark = Color(0xFF0D2014); // active day pill + LIVE card bg
static const Color _accent = Color(0xFF6DC55A);   // primary green (Join now, gentle/restorative, active letter)
static const Color _liveRed = Color(0xFFE24B4A);  // LIVE pill + animated dot
static const Color _moderate = Color(0xFFFAC775); // amber
static const Color _intense = Color(0xFFFF8A8A);  // coral
```

### Fonts
- Use existing `google_fonts` setup. The mockup uses **Plus Jakarta Sans only** for this frame — load via `GoogleFonts.plusJakartaSans()`. The existing app uses Poppins; both look acceptable, but switching to Plus Jakarta keeps fidelity to the mockup. Trade-off Q-OPEN below.
- No DM Serif Display in this frame.

### Live-state refresh strategy
- Need a `Timer.periodic(Duration(seconds: 60), (_) => setState(...))` to update the `12 min` countdown on the LIVE card. Cancel in `dispose`. Trivial addition.

### Estimated effort
**5–6 hours** (40% UI rewrite, 25% data computation/mapping, 20% timer + state for LIVE, 15% testing all preserved flows).

### Test plan (Phase 2 device test)
- Workout tab → tap a plan card → new V2 timeline renders for today's weekday by default
- Day strip: tap M/T/W/T/F/S/S → timeline updates to that weekday's slots
- Header date label updates to selected date in `EEEE, d MMMM` format
- Past class cards (where applicable) render muted
- LIVE class card (when current time is within a slot's start–end) renders dark with red LIVE pill + Join Now button
- Tap any slot card / Join Now → existing `HelpingWidgets.showWorkoutBottomSheet` opens (same UX as today)
- Empty day → "No classes today" placeholder
- Pull-to-refresh re-fires `getDietPlanDetailsFunc(planId)`
- Back gesture/button returns to `WorkPlansOfUser`
- Status bar dark icons on mint background

### Rollback plan
`git revert` the single-file commit. No DB/backend/pubspec changes to undo.

---

## Open questions for founder

🔴 **Q1 — Intensity mapping (Gap 1).** Pick one:
- (a) Backend adds `intensity` enum + admin UI (clean, multi-week)
- **(b) Client-side string→enum mapping** (ship-now, brittle)
- **(c) Reuse `RecommendationService.intensity(slot.type)` from Phase 5** (ship-now, repurposes existing wiring) ← my recommendation

🔴 **Q2 — Attendance count "34 women" (Gap 2).** Pick one:
- (a) Backend adds `joinedCount` per slot (clean)
- **(b) Hide the "N women" line entirely** (ship-now, less social proof) ← my recommendation
- (c) Mock the number (dishonest)

🔴 **Q3 — `✓` checkmark on past classes (Gap 3).** Pick one:
- (a) Backend populates `ClassAttendances.slot_id` + endpoint exposes per-slot attendance (clean)
- **(b) Drop the ✓; just mute past cards** (ship-now) ← my recommendation
- (c) Show ✓ on every past slot of any attended date (misleading)

🟠 **Q4 — Cycle-phase RecommendedBadge from Phase 5.** Old screen showed a small "Recommended" badge on slots matching the user's current cycle phase. New design has no such marker — it uses intensity colour instead. Two paths:
- **(a) Drop the badge** in V2. Cleaner mockup fidelity.
- (b) Keep it as a small ribbon on the upcoming card.
- (c) Use it to override intensity colour (e.g., recommended slots always render in the active accent green).
Recommend **(a)** — the intensity colour already conveys "good fit" semantics.

🟠 **Q5 — Top chrome / back navigation.** The mockup has no back button — only the L/R chevrons on the right. The current screen reaches the user via `WorkPlansOfUser → tap plan card`, so they need a way back. Three options:
- (a) Add a 40×40 white-circle back button in the top-left corner of the header (matches the chevron style on the right). Calls `Get.back()`.
- (b) Drop the visual back button; rely on Android system back / iOS swipe-back. Slightly hostile UX.
- (c) Repurpose the L chevron as "back to plans" instead of "previous week".
Recommend **(a)** — adds explicit back affordance without breaking the mockup's aesthetic.

🟠 **Q6 — L/R chevron behaviour.** What do they do?
- **(a) Navigate week ←/→** (move the day strip to last/next week's dates, keep selection on same weekday).
- (b) Navigate day ←/→ within the current week (move selection to prev/next pill).
- (c) Both nothing (decorative — not built yet).
Recommend **(a)** — biggest UX value, lets users plan ahead.

🟢 **Q7 — Month attendance grid.** Old screen has a calendar attendance grid above the slot list. New design doesn't. Confirm OK to drop entirely (and remove the `motivationController.fetchMotivationStats()` lazy fetch from this screen). Stats are still accessible from elsewhere if other screens use them — need cross-check.

🟢 **Q8 — Sub-copy *"We provide flexible timeslots…"*.** New design has no subhead. Confirm OK to drop.

🟢 **Q9 — Font choice.** Mockup uses Plus Jakarta Sans. App currently uses Poppins everywhere. Three options:
- (a) Render this screen in Plus Jakarta Sans via google_fonts (mockup fidelity, mixed font family in app)
- **(b) Render in Poppins** (consistency with app, slight visual drift from mockup — letter shapes differ but weights match) ← my recommendation
- (c) Switch the entire app to Plus Jakarta Sans (out of scope)

🟢 **Q10 — `12 min remaining` countdown refresh interval.** 60 seconds is enough granularity but flickers ~once a minute. Confirm OK or want 30s.

---

## What I need from you to start Phase 2

Required:
- [ ] **Q1, Q2, Q3** — pick one each (Gap workarounds for intensity, attendance, ✓)
- [ ] **Q4** — drop or keep RecommendedBadge
- [ ] **Q5, Q6** — back button placement + L/R chevron behaviour
- [ ] **Q7, Q8** — drop month grid + drop subcopy (default yes)
- [ ] **Q9** — Poppins or Plus Jakarta Sans
- [ ] **Q10** — 60s or 30s countdown

If all defaults to my recommendations, reply "Approved as recommended" and I'll proceed.

Holding here. PR Sprint 1 / Sprint 2 work untouched. No production files modified in this audit.
