# Fit Her — V2 Design System (Audit)

> Extracted from screens shipped during the Phase B–F rebuild:
> `PaidHomeScreenV2`, `ProgressScreenV2`, `ProfileScreenUser` (rewrite),
> `WorkOutBottomScreen`, plus the supporting widgets in
> `lib/widgets/paid_home_v2/`, `lib/widgets/progress_v2/`, and
> `lib/widgets/new_home/phase_theme.dart`.
>
> This is an **audit** of what's actually in the code — not an
> aspirational style guide. Where screens diverge, the divergence is
> called out.

---

## 1. Where the design system lives in code

| Concept | Source of truth |
|---|---|
| Phase colours (4 phases) | `lib/widgets/new_home/phase_theme.dart` — `PhaseTheme.{follicular, ovulatory, luteal, menstrual}` |
| HTML reference | `docs/Progress_v1_AsBuildable.html` (progress hub), `new screens/Home_All43_Variants.html` (paid home variants H-01 … H-04) |
| Card shells | Inline per screen — **no shared `Card` widget** (drift point) |
| Typography | Inline per widget — Poppins family, no shared text-style constants beyond `lbl` (drift point) |
| Spacing | Inline numeric literals — no shared scale (drift point) |

There is **no central design-system file** that exposes these tokens. The values below were extracted by reading every shipped widget. The tech-debt section at the bottom captures consolidation opportunities.

---

## 2. Colour palette

### 2.1 Surfaces

| Token | Hex | Where used |
|---|---|---|
| `cream-bg` | `#EAF7E4` | PaidHomeV2 Scaffold body, ProfileScreenUser bg |
| `cream-bg-light` | `#F5FBF2` | ProgressScreenV2 Scaffold body — slightly lighter |
| `cream-bg-warm` | `#E8F4E0` | WorkOutBottomScreen bg — slightly darker, slightly different green |
| `card-white` | `#FFFFFF` | All white card surfaces (insight, water, sleep, stats, cycle, nutrition, info, etc.) |
| `card-border` | `#D8EDD4` | Card stroke (1px) on every white card |
| `card-divider` | `#F0F6EE` | Hairline between rows in `_personalInfoCard` |
| `connector-mint` | `#C8DEC4` | WorkOutBottomScreen day-strip connector lines |
| `circle-border-soft` | `#C8E8BC` | WorkOutBottomScreen attendance-circle outline |

> **Drift**: 3 cream variants (`#EAF7E4`, `#F5FBF2`, `#E8F4E0`) coexist. ProgressV2 picked the lightest of the three. Should converge.

### 2.2 Hero / dark surfaces (phase-driven)

| Phase | Hero bg | Accent | Day-pill colour | Emoji |
|---|---|---|---|---|
| Follicular | `#163220` forest green | `#6DC55A` green | `#A8F0C0` mint | `⚡` |
| Ovulatory | `#0A2420` dark teal | `#5ECFB0` teal | `#9FE1CB` light teal | `✨` |
| Luteal | `#1E1208` dark amber | `#FAC775` amber | `#FDE4A0` light amber | `🌙` |
| Menstrual | `#1E0808` dark plum | `#FF8A8A` coral | `#FFB8B8` light coral | `🌺` |

Source: `lib/widgets/new_home/phase_theme.dart:47-93`. These four are the canonical phase colours and **must not be redefined inline**.

### 2.3 Text colours (light surfaces)

| Token | Hex | Use |
|---|---|---|
| `text-primary` | `#163220` | Body copy, big numbers, card values |
| `text-secondary` | `#6F8B7A` | Sub-text, muted body, info-row label |
| `text-sage` | `#9AB09A` | `.lbl` small-caps section labels, "diet plan", "kg/week", footer |
| `text-hint` | `#9AB09A` (alias) | WorkoutScreen aliases this as `_textHint` |
| `text-muted-warm` | `#7A8C78` | WorkoutScreen `_textMuted` — slight drift from `#6F8B7A` |
| `text-dark-warm` | `#1A3A22` | WorkoutScreen `_textDark` — slight drift from `#163220` |

> **Drift**: WorkoutScreen has its own `_textDark`/`_textMuted` slightly off the rest of the V2 palette. Pre-dates the V2 system; should converge.

### 2.4 Semantic colours

| Token | Hex | Meaning |
|---|---|---|
| `live-red` | `#E24B4A` | LIVE pill bg, notification dot |
| `improvement-green` | `#3FA34D` | Trend-bar delta pill (improving) text |
| `regression-red` | `#E07B7B` | Trend-bar delta pill (regressing) text |
| `neutral-grey` | `#9AB09A` | Trend-bar delta pill (unchanged) text |
| `pill-bg-improve` | `#E4F4DC` | Improvement pill background |
| `pill-bg-regress` | `#FCE3E3` | Regression pill background |
| `pill-bg-neutral` | `#EDEFEC` | Neutral pill background |
| `pill-bg-symptom-r` | `#fff0f0` / `#c0392b` text / `#f5c0b8` border | "🔴 Bloating ↓" pill |
| `pill-bg-symptom-g` | `#EAF7E4` / `#1a5c2a` text / `#b8ddb0` border | "🟢 Energy ↑" pill |
| `bar-track` | `#E8F2E5` | TrendBar empty track |
| `bar-progress-track` | `#D8EDD4` | Water/sleep progress-bar track |
| `bar-progress-fill` | linear-gradient `#6DC55A → #A8F0C0` | Water/sleep progress-bar fill |
| `bar-symptom-r` | `#FF8A8A` | Bloating/cramps bar fill (lower = better) |
| `bar-symptom-g` | `#6DC55A` | Energy/mood bar fill (higher = better) |
| `streak-amber` | `#FAC775` | Streak chip & "intensity moderate" tag |
| `intensity-coral` | `#FF8A8A` | High-intensity workout tag |

### 2.5 Anti-pattern: AVOID `#8AD167`

Listed in `lib/theme/app_colors.dart:14` as `AppColors.primary`. **Do not use** in new code. This is the colour that powered the global `AppBarTheme.systemOverlayStyle` mint band that haunted the status-bar saga (see `lib/docs/status_bar_saga.md`). Until `app_theme.dart:60-64` is cleaned up, any `AppBar` constructed anywhere will inherit this colour.

---

## 3. Phase theming pattern

```dart
import '../../widgets/new_home/phase_theme.dart';

final phase = parseCyclePhase(rawPhaseString);   // tolerant; defaults to follicular
final theme = PhaseTheme.forPhase(phase);
// Or, when you have just the string:
final theme = PhaseTheme.forPhaseString(rawPhaseString);

// Use:
theme.heroBackground   // Color — 4 phase-specific dark colours
theme.accent           // Color — 4 phase-specific bright colours
theme.emoji            // String — e.g. '🌙' for luteal
theme.energyLabel      // String — e.g. 'Energy dipping'
theme.phaseLabel       // String — e.g. 'Luteal Phase'
```

### Where phase theming applies

✅ **Always phase-aware** (must change with cycle):
- Hero band background (PaidHomeV2 hero, ProgressV2 hero)
- Hero radial-gradient overlay (uses `theme.accent`)
- Period-chip active state (`theme.accent` bg, `theme.heroBackground` text)
- Cycle-card phase label colour
- Profile hero greeting emoji + day pill
- Status-bar zone (when a phase-themed hero paints there)

❌ **Phase-locked / never changes**:
- Card background (always white)
- Card border (always `#D8EDD4`)
- Body/footer text colours (always `#163220`/`#9AB09A`)
- Insight card surface (always `#163220` dark green — except the accent border + "FitHer AI" text colour, which DO use `theme.accent`)
- Primary action button green (`#6DC55A` always)

---

## 4. Typography

Family: **Poppins**, weights 300 / 400 / 500 / 600 / 700 / 800. Already wired in pubspec assets.

### 4.1 The `.lbl` small-caps style

The single most-reused atomic style. Mirrors the HTML mockups' `.lbl9` class (9 px, weight 700, sage, uppercase, 7 % letter-spacing).

```dart
const TextStyle lblStyle = TextStyle(
  fontSize: 9,                  // sometimes 10 in profile (denser sections)
  fontWeight: FontWeight.w700,
  color: Color(0xFF9AB09A),     // sage
  letterSpacing: 0.07 * 9,      // ~0.63 — the .07em rule
);
```

Used by:
- `_CardTitle` in `progress_screen_v2.dart` ("Weight Trend", "At a Glance", "Hydration")
- Card-header labels in PaidHomeV2 (`PaidFeelSelector`'s "How I feel today")
- Profile `_CardLabel` ("Cycle Phase", "Personal Info")
- Stats-row top label ("🏋️ Workouts", "⚖️ Weight")

### 4.2 Type scale (extracted from shipped widgets)

| Use | Size | Weight | Colour | Example |
|---|---|---|---|---|
| `.lbl` small-caps | 9 / 10 | 700 | `text-sage` | "PERSONAL INFO" |
| Caption / footnote | 9 | 400-600 | sage | "kcal left", "diet plan" |
| Footer / footnote-warm | 11 | 400 / 700 | sage / `text-primary` | "2,400 women joined a class today" |
| Body small | 11-12 | 400-500 | `text-primary`, `text-secondary` | symptom subtitle, info-row value |
| Body | 13 | 600-700 | `text-primary` | TrendBar label, info-row value |
| CTA inline | 11 | 700 | `text-primary` | "Log lunch →" |
| Section headline | 14 | 800 | `text-primary` | "Luteal Phase · Day 21" |
| LIVE pill | 9 | 800 | white | "LIVE" |
| Stat value | 21 | 800 | `text-primary` or `accent` | "4", "−0.4", "322" |
| Stat value (Nutrition) | 26 | 800 | `accent` | "82%" |
| Cycle day | 26 | 800 | `text-primary` | "21" |
| Big numeric (delta) | 24 | 800 | `text-primary` | "−2.1 kg" |
| Live-class title (mixed) | 21 | 800 / 300 | white / .50 white | "Strength Training" |
| Hero phase title | 32 | 300 / 800 | .55 white / white | "Luteal Phase 🌙" |
| Hero greeting | 11 | 300 | .22 white | "Good morning, Shaista" |
| Hero stat chips | 11 / 12 | 600 / 700 | per-phase | "Day 21", "−1.8 kg" |
| Hero stat separator dot | 11 | 400 | .18 white | `·` |
| Join button | 14 | 800 | white | "Join" |
| Coming-up tile name | 11 | 600 | .65 white | "Hormonal Yoga" |
| Coming-up tile time | 10 | 600 | .55-.65 phase tint | "10:30 AM" |

### 4.3 Letter-spacing

| Use | letter-spacing |
|---|---|
| `.lbl` small-caps | `0.07em` (multiply size × 0.07 for Flutter logical px) |
| Hero phase title (32 px) | `-0.5` |
| Live-class title (21 px) | `-0.3` |
| Profile hero name (18 px) | `-0.3` |
| Everything else | `0` |

---

## 5. Spacing scale

Everything in shipped V2 widgets uses these intervals:

```
2  3  4  6  7  8  10  12  14  16  18  22  28
```

There's **no 1-2-4-8-16 doubling system**. The scale is empirical, traced from HTML where 7 px gaps + 8 px gaps coexist deliberately.

### 5.1 Page gutters

- **Body horizontal padding**: `16px` (PaidHomeV2 `EdgeInsets.fromLTRB(16, 12, 16, 16)`, `_GutterPad` in ProgressV2)
- **Hero internal horizontal padding**: `22px` (HTML reference)
- **Hero internal vertical**: `14-22 px` top depending on whether status-bar inset is included; `18-20 px` bottom
- **Hero coming-up row**: `padding 14px 12px 18px`, `gap 7px`

### 5.2 Card stack

- **Card → card vertical gap**: `8px` (PaidHomeV2) or `14px` (ProgressV2 — looser)
- **Inside card section title → content**: `6-8px` (compact) / `10-12px` (comfortable)
- **Inside card row → row**: `12-14px`

### 5.3 Card paddings (drift-prone)

| Pattern | Padding | Use |
|---|---|---|
| `.card` (HTML) | `13px 15px` | Insight, feel selector, nutrition, cycle, profile cards |
| `.compact-stat` | `11px 6px` text-center | Workouts/Weight/Calories stat cells |
| `.compact-h` | `10px 13px` | Water, Sleep |
| `.insight` | `12px 14px` | AI insight dark card |
| `.feel-cell` | `8px 2px` | Selected/unselected emoji cell |

### 5.4 Border radius

| Use | Radius |
|---|---|
| Standard card (.card) | `20` |
| Compact tile (.compact) | `16` |
| Insight card | `18` |
| ProgressV2 `_CardShell` | `18` |
| Profile hero | `24` |
| Hero band (PaidHomeV2 / ProgressV2) | `36` (bottom corners only) |
| Pills (LIVE, period-chip, delta) | `20` |
| Tag-style spill | `20` |
| Period chip | `12` |
| Feel-track outer | `12` |
| Feel-cell selected | `10` |
| Progress bar | `1.5` (height/2) |
| Icon badge in insight card | `8` |
| Notifications icon container | `10` |

---

## 6. Component patterns

### 6.1 Card shell (white)

```
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),       // or 18 in ProgressV2
    border: Border.all(color: Color(0xFFD8EDD4), width: 1),
    boxShadow: [BoxShadow(
      color: Color(0xFF163220).withOpacity(0.05),
      offset: Offset(0, 2),
      blurRadius: 10,
    )],
  ),
  padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),  // .card default
  child: Column(...),
)
```

> **Drift**: ProgressV2 uses `_CardShell` with radius **18** and shadow `0 2px 8px rgba(22,50,32,.04)`. PaidHomeV2 uses inline cards with radius **20** and shadow `0 2px 10px rgba(22,50,32,.05)`. Should converge to ONE shared shell.

### 6.2 Hero band (dark, edge-to-edge)

Single canonical structure, used twice (PaidHomeV2 `PaidHero`, ProgressV2 `_HeroCard`):

```
Obx(() {                                  // reactive — phase changes
  final theme = PhaseTheme.forPhaseString(state.phase);
  return ClipRRect(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(36),
      bottomRight: Radius.circular(36),
    ),
    child: Container(
      color: theme.heroBackground,
      child: Stack(children: [
        // 1. Radial gradient overlay (top-right):
        Positioned(
          top: -80, right: -60,
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                theme.accent.withOpacity(0.25),
                theme.accent.withOpacity(0.0),
              ]),
            ),
          ),
        ),
        // 2. Content with status-bar inset:
        Padding(
          padding: EdgeInsets.fromLTRB(
            22, MediaQuery.of(context).padding.top + 18, 22, 18),
          child: Column(...),
        ),
      ]),
    ),
  );
});
```

Rules:
- **Flat top, rounded bottom**. Always 36 px bottom corners.
- **Edge-to-edge through the status bar.** The hero must paint from y=0 — no SafeArea above it.
- **Internal top padding adds `MediaQuery.padding.top`** so the header text clears the OS clock/icons.
- **Status bar styling** is set via `AnnotatedRegion<SystemUiOverlayStyle>` at the Scaffold level — `Colors.transparent` + `Brightness.light` icons.

### 6.3 Period chips (Progress hub)

`PeriodChipSelector` widget at `lib/widgets/progress_v2/period_chip_selector.dart`. 5 chips: Week / Month / 3-month / 6-month / Year.

- Inactive: bg `Colors.white.withOpacity(0.06)` (translucent on dark hero), text `Colors.white.withOpacity(0.4)`
- Active: bg `theme.accent`, text `theme.heroBackground` (dark phase colour readable on bright accent)
- Padding: `9 horizontal × 4 vertical`
- Radius: `12`
- Gap between chips: `2-5px`

### 6.4 Trend bar

`lib/widgets/progress_v2/trend_bar.dart`. One bar with optional delta pill on the right.

- Bar height: 8 logical px (default), 12 for chunky variants
- Track: `Color(0xFFE8F2E5)`
- Fill: gradient `[barColor.withOpacity(0.85), barColor]`
- Label: 13 / 500 / `text-primary`
- Trailing value: 12 / 600 / `text-primary`
- Delta pill: 11 / 600, bg + text from semantic table above

### 6.5 Goal ring (Syncfusion)

`lib/widgets/progress_v2/goal_ring.dart`. Used for the hero goal ring (82 px), the 4 At-a-glance rings (~80 px), and the 70 px hydration ring.

- Track thickness: `0.18 × radius` (chunky default)
- Start angle: 270° (12 o'clock)
- Fill: `theme.accent` or pace colour
- Track colour: 12 % alpha of fill colour, OR explicit override (hero ring uses `Colors.white.withOpacity(0.08)` for translucent-on-dark)
- Centre label: 22 % of size for the big text, 11 % for the sub-label

### 6.6 Action buttons (profile / paid home)

Three hierarchies:

```dart
// Primary — green bg, white text, glow
Container(
  height: 50,
  decoration: BoxDecoration(
    color: Color(0xFF6DC55A),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: accent.withOpacity(0.30), offset: Offset(0,4), blurRadius: 14)],
  ),
  child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: white)),
)

// Neutral — white bg, sage border
Container(
  height: 48,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFD8EDD4), width: 1),
  ),
  child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF163220))),
)

// Danger — text-only, red
Container(
  height: 44,
  child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFE07B7B))),
)
```

### 6.7 Live class block (paid home)

- Outer padding: `14px 22px 0`
- LIVE pill: bg `#E24B4A`, padding `3px 9px`, radius `20`, dot `5×5`, text `9px / 800`
- Title: 21 px / 800 first word + 21 px / 300 rest words, letter-spacing `-0.3`, line-height 1.0
- Subtitle: 11 px / .26 white
- Join button: bg `theme.accent`, padding `12px 22px`, radius 16, text `14 / 800`, glow `accent.withOpacity(0.33)` blurRadius 16

### 6.8 Insight card (dark green on cream)

- bg `#163220`, radius `18`, padding `12px 14px`
- Border `1 px` accent at 16 % alpha
- Shadow `0 4px 16px rgba(22,50,32,.15)`
- Icon badge: 26×26 radius 8, bg `accent.withOpacity(0.13)`, border `accent.withOpacity(0.20)`
- Header: "FitHer AI" 11 / 800 / accent + "· Today's insight" 10 / .25 white
- Body: 12 / 400 / .62 white, line-height 1.6

---

## 7. Status-bar handling (the lesson from the saga)

See `lib/docs/status_bar_saga.md` for the full incident report. Rules extracted:

1. **`main.dart` enables `SystemUiMode.edgeToEdge` once** at app init. Don't repeat anywhere.
2. **Each top-level screen owns its own status-bar style via `AnnotatedRegion<SystemUiOverlayStyle>`.** Do not call imperative `SystemChrome.setSystemUIOverlayStyle` inside `build()` — it persists at the OS level and pollutes downstream screens.
3. **For dark heroes**: `statusBarColor: Colors.transparent` + `statusBarIconBrightness: Brightness.light` + `statusBarBrightness: Brightness.dark` (iOS naming inverted).
4. **For light cream screens**: `statusBarColor: Colors.transparent` + `statusBarIconBrightness: Brightness.dark` + `statusBarBrightness: Brightness.light`.
5. **Never wrap a child in a Scaffold-with-AppBar** if you don't need an AppBar. AppBars implement `systemOverlayStyle` via their own `AnnotatedRegion`, and Flutter inherits from `AppBarTheme.systemOverlayStyle` (still set to mint `#8AD167` in `app_theme.dart:60-64`). The outer AppBar's region wins over your inner Scaffold's region.
6. **Hero must paint from y=0**. Drop `SafeArea` (or use `top: false`) so the hero's dark colour shows in the status-bar zone. Add `MediaQuery.padding.top` to the hero's internal top padding.

---

## 8. Drift / inconsistencies found

Things that should converge in a follow-up "design-system consolidation" PR:

| # | Drift | Where | Fix |
|---|---|---|---|
| 1 | Three cream backgrounds (`#EAF7E4`, `#F5FBF2`, `#E8F4E0`) | PaidHomeV2 / ProgressV2 / WorkoutScreen | Pick one (`#EAF7E4` is the most-used) |
| 2 | Two text-primary darks (`#163220`, `#1A3A22`) | V2 screens / WorkoutScreen | Standardize on `#163220` |
| 3 | Two text-muted shades (`#6F8B7A`, `#7A8C78`) | V2 screens / WorkoutScreen | Standardize on `#6F8B7A` |
| 4 | Card radius split (18 vs 20) | ProgressV2 `_CardShell` vs PaidHomeV2 inline | Pick 20 |
| 5 | Card shadow split (`0 2px 8px rgba(_,.04)` vs `0 2px 10px rgba(_,.05)`) | ProgressV2 vs PaidHomeV2 | Pick the slightly stronger PaidHomeV2 variant |
| 6 | Card → card gap split (8 vs 14) | PaidHomeV2 vs ProgressV2 | Audit per-section; ProgressV2 gaps may be intentional looser |
| 7 | No shared `AppCard` widget | Every screen redefines the white-card decoration | Extract `AppCard` and `AppCardLabel` to a shared file |
| 8 | No shared text-style constants | Every widget redefines `lbl9` inline | Extract `AppText.lbl`, `AppText.statValue`, etc. |
| 9 | Anti-pattern `#8AD167` still in `app_colors.dart` | Theme | Either remove or rename to `legacy_status_bar_avoid` |
| 10 | Global `AppBarTheme.systemOverlayStyle` mint | `app_theme.dart:60-64` | Remove — let each screen own its overlay |
| 11 | 4 imperative `SystemChrome` calls inside `build()` | login, walk_through, enter_email, work_out_bottom_screen | Migrate all to `AnnotatedRegion` |

Tracked separately as the "post-HBL polish" PR (~3-4h).

---

## 9. Quick-reference — where to put new code

| Adding a... | Reuse | New file location |
|---|---|---|
| Phase colour swatch | `PhaseTheme` | edit `lib/widgets/new_home/phase_theme.dart` |
| Trend bar with delta | `TrendBar` | — |
| Circular progress ring | `GoalRing` | — |
| Period selector | `PeriodChipSelector` | — |
| Phase-tinted chart | `PhaseSegmentedChart` | — |
| White card | inline `_CardShell` per screen (until consolidation) | follow ProgressV2's pattern |
| Dark hero | inline (PaidHomeV2 `PaidHero`, ProgressV2 `_HeroCard`) | follow either, edge-to-edge rules |
| Section label | inline `_CardLabel` / `_CardTitle` (until consolidation) | follow profile's `_CardLabel(text)` |
| Status-bar styling | `AnnotatedRegion<SystemUiOverlayStyle>` at Scaffold root | never `SystemChrome` in `build()` |

---

## 10. References

- `docs/Progress_v1_AsBuildable.html` — Progress hub reference (lines 65, 80, 127-131, 145-148, 153-175, 177-182, 277-301)
- `new screens/Home_All43_Variants.html` — Paid home variants (lines 76-199 shared builders, 227-254 H-01 to H-04)
- `lib/widgets/new_home/phase_theme.dart` — phase colour bundles
- `lib/docs/status_bar_saga.md` — status-bar incident report (companion to §7 above)
- `lib/docs/progress_v2_visual_audit_full.md` — earlier visual-drift audit on ProgressV2
