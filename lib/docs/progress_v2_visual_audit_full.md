# Progress Hub V2 — full visual audit (Flutter vs HTML mockup)

**Audit date:** 2026-04-28
**Reference (HTML):** `docs/Progress_v1_AsBuildable.html` (30,241 bytes, 2026-04-27 12:43)
**Implementation (Flutter):** `lib/UI/dashboard_module/bottom_bar_screen/progress_screen_v2.dart` + `lib/widgets/progress_v2/*.dart`
**Mode:** read-only, no production files modified.

---

## 1. Executive summary — top 5 visual gaps

These are the issues that move the needle most for the HBL demo. Detailed table in §5; per-element analysis in §3 + §4.

1. **Glance ring secondary text is missing** — the design's 4 rings each show TWO lines of text inside the ring (e.g. `16` + `/20`, `6.5h` + `sleep`). Flutter's `GoalRing` only renders one center string. Visual rhythm of the "at a glance" card is flattened. Compounded by the colored %/status text below each ring (`80%` green / `81%` dark mint / `62%` amber / `On track` green) being collapsed to a single muted grey tone in Flutter.
2. **Hydration card lost its headline water tile** — the design's prominent mint inset with 26 px "1.6L" big number + amber "62% · drink more" pill + 5 px amber progress bar is replaced by a flat `TrendBar` widget. The whole hierarchy of the hydration card is gone.
3. **Symptom bars are the wrong colour** — design uses `#FF8A8A` red for bloating + cramps and `#6DC55A` green for energy + mood (information density: bar colour conveys "lower is better" semantics at a glance). Flutter shipped with all-green default but was patched in a CF5 fix to be per-symptom — verify on device that the patch actually rendered.
4. **Card titles use the wrong typography** — design uses uppercase 9 px sage letter-spaced "small caps" labels (the `.lbl` class) for every card title (`WEIGHT TREND`, `HYDRATION · MONTHLY AVG`, `SYMPTOMS THIS MONTH`, etc.). Flutter uses 14 px weight-600 `_kTextPrimary` mixed-case titles (`"Weight trend"`, `"Hydration"`, etc.) — completely different visual register.
5. **Weight chart is much taller and busier** — design SVG is 90 px tall, no axes, in-chart phase-letter labels (M / Follicular / O / Luteal), area-fill gradient under the line, "Today" text label above the dot, **phase legend strip below the chart**. Flutter's `PhaseSegmentedChart` is 220 px Syncfusion with axis labels, no in-chart phase labels, no area-fill, no Today label, no phase legend. Reads more "data dashboard" than the design's "delicate magazine spread".

---

## 2. Files located

### HTML reference
| Path | Size | Modified | Role |
|---|---|---|---|
| `docs/Progress_v1_AsBuildable.html` | 30,241 B | 2026-04-27 12:43 | **source of truth** — single phone-frame mockup with the buildable scope baked in |

No `progress_v2*.html`, `Progress_v2*.html`, or `*builder*.html` exists anywhere in the repo. The "AsBuildable" file is the design contract — confirmed by `docs/FitHer_Progress_Developer_Brief_v2.md:5` (`Visual ref: Progress_v1_AsBuildable.html`).

### Flutter implementation
| File | Lines | Purpose |
|---|---|---|
| `lib/UI/dashboard_module/bottom_bar_screen/progress_screen_v2.dart` | ~1700 | Screen-level composition; all 7 cards inline-defined as private widgets |
| `lib/widgets/progress_v2/goal_ring.dart` | 175 | C1 — `SfRadialGauge` ring primitive |
| `lib/widgets/progress_v2/trend_bar.dart` | 197 | C2 — pure-Flutter intensity bar primitive |
| `lib/widgets/progress_v2/expandable_card.dart` | 183 | C3 — single-open coordinated expand/collapse |
| `lib/widgets/progress_v2/period_chip_selector.dart` | 176 | C4 — 5-chip period selector |
| `lib/widgets/progress_v2/phase_segmented_chart.dart` | 286 | C5 — Syncfusion chart with phase tints |
| `lib/widgets/progress_v2/progress_beta_toggle.dart` | 162 | E2 — Profile beta toggle (no longer mounted post-paid-gating) |
| `lib/data/controllers/progress_v2/progress_controller_v2.dart` | 7,488 B | Reactive state per card |
| `lib/data/Repos/progress_v2/progress_repository.dart` | 5,592 B | 6 endpoint methods |
| `lib/data/models/progress_v2/progress_models.dart` | 16,204 B | Typed response models |

---

## 3. HTML reference spec (verbatim CSS pasted)

### 3.0 Global / shell

```css
/* docs/Progress_v1_AsBuildable.html — head <style> block, lines 7-45 */
body { background:#050a06; font-family:"Plus Jakarta Sans",sans-serif; }
.phone { width:375px; height:812px; border-radius:54px; background:#EAF7E4; }
.sc { background:#EAF7E4; }                                    /* scroll body */
.card { background:#fff; border-radius:20px; border:1px solid #D8EDD4;
        padding:15px 17px; margin-bottom:9px;
        box-shadow:0 2px 12px rgba(22,50,32,.05); }
.lbl  { font-size:9px; font-weight:700; color:#9ab09a;
        text-transform:uppercase; letter-spacing:.08em; margin-bottom:9px; }
.soonpill { background:rgba(250,199,117,.18);
            border:1px solid rgba(250,199,117,.35);
            border-radius:10px; padding:3px 8px;
            font-size:9px; font-weight:700; color:#b38a00;
            letter-spacing:.04em; text-transform:uppercase; }
```

**Tokens used throughout:**
- Phone bg `#EAF7E4` (mint cream) — applied to `.phone` and `.sc`
- Card bg `#FFFFFF`, border `#D8EDD4`, radius `20px`
- Card title (".lbl") — 9 px / weight 700 / uppercase / letter-spacing 0.08em / color `#9AB09A` (muted sage)
- Hero bg `#163220` (dark forest green)
- Phase accent green `#6DC55A`
- Streak amber `#FAC775`
- Sleep mint `#A8F0C0`
- Bloating/cramps red `#FF8A8A`
- Ovulation mint `#5ECFB0`
- Sage muted text `#9AB09A`
- Hydration amber-text `#B38A00`
- Sleep mint-text `#5A9A8A`
- Plus Jakarta Sans typography family throughout

### 3.1 Hero (lines 64-134)

```html
<!-- HERO container (line 65) -->
<div style="background:radial-gradient(ellipse 140% 90% at 105% -5%,
            rgba(60,120,50,.45) 0%, transparent 55%), #163220;
            border-radius:0 0 36px 36px;
            border-bottom:1.5px solid rgba(109,197,90,.3);
            border-left:1.5px solid rgba(109,197,90,.18);
            border-right:1.5px solid rgba(109,197,90,.18);">

<!-- decorative ring (line 67) -->
<div style="position:absolute; width:240px; height:240px;
            border-radius:50%; border:1px solid rgba(109,197,90,.07);
            top:-80px; right:-60px;"></div>

<!-- status row (lines 70-76) -->
<span style="font-size:11px; font-weight:500; color:rgba(255,255,255,.35);">9:41</span>
<!-- bell button: 30×30 circle, bg rgba(255,255,255,.07), 🔔 13px -->
<!-- avatar: 30×30 circle, bg #6DC55A, "S" 11/800 white -->

<!-- heading (line 80) -->
<div style="font-size:11px; color:rgba(255,255,255,.22);
            font-weight:300; margin-bottom:12px;">Progress · Shaista 🌿</div>

<!-- goal block (lines 83-95) -->
<div style="font-size:11px; color:rgba(255,255,255,.3);">Goal · −5 kg by June</div>
<span style="font-size:36px; font-weight:800; color:#fff; letter-spacing:-1px; line-height:1;">
  −2.1<span style="font-size:18px; font-weight:300; color:rgba(255,255,255,.5);"> kg</span>
</span>
<!-- pace pill: bg rgba(109,197,90,.15) + 5×5 dot #6DC55A
     + 10/700 #6DC55A "3 wks ahead of schedule" -->

<!-- ring (lines 96-101) -->
<svg width="82" height="82">
  <circle r="33" stroke="rgba(255,255,255,.08)" stroke-width="6"/>          <!-- track -->
  <circle r="33" stroke="#6DC55A" stroke-width="6"
          stroke-dasharray="87 120" stroke-dashoffset="52"
          stroke-linecap="round"/>                                          <!-- progress -->
  <text font-size="16" font-weight="800" fill="#fff">42%</text>             <!-- center -->
  <text font-size="9" fill="rgba(255,255,255,.4)">to goal</text>            <!-- sub -->
</svg>

<!-- 4 stat tiles (lines 105-122): grid-template-columns:repeat(4,1fr); gap:6px;
     each tile: bg rgba(255,255,255,.07); border-radius:12px; padding:9px 6px;
     label 9px white-30%; value 17px weight 800 -->
Classes : 16     (white)
Streak  : 8🔥    (#FAC775 amber, flame INSIDE the value)
Sleep   : 6.5h   (#A8F0C0 mint)
Energy  : 7.2/10 (white, /10 in 10px white-40%)

<!-- period selector (lines 126-132): horizontally scrollable
     active:   padding 6/16; border-radius:20; bg #6DC55A; color #163220; weight 700
     inactive: bg rgba(255,255,255,.06); color rgba(255,255,255,.4); weight 500
     labels: "Week" / "Month" / "3 Months" / "6 Months" / "1 Year" -->
```

### 3.2 Weight trend (lines 140-183)

```html
<div class="card">
  <div style="display:flex; align-items:baseline; justify-content:space-between;
              margin-bottom:14px;">
    <div>
      <div class="lbl" style="margin-bottom:5px;">Weight trend</div>
      <div style="display:flex; align-items:baseline; gap:8px;">
        <span style="font-size:24px; font-weight:800; color:#163220;
                     letter-spacing:-.5px;">−2.1 kg</span>
        <span style="font-size:11px; font-weight:700; color:#6DC55A;">↓ toward goal</span>
      </div>
    </div>
    <span style="font-size:10px; color:#9ab09a;">Apr 2026</span>
  </div>

  <svg height="90" viewBox="0 0 310 90">
    <!-- 4 phase background bands: red (M), green (Follicular), mint (O), amber (Luteal),
         opacity .07-.08, rounded rx=3 -->
    <rect x="0"   width="54"  fill="#FF8A8A" opacity=".07" rx="3"/>
    <rect x="56"  width="76"  fill="#6DC55A" opacity=".07" rx="3"/>
    <rect x="134" width="44"  fill="#A8F0C0" opacity=".08" rx="3"/>
    <rect x="180" width="130" fill="#FAC775" opacity=".07" rx="3"/>
    <!-- in-chart phase letter labels at y=82 -->
    <text x="27"  y="82" font-size="8" fill="#FF8A8A" opacity=".7">M</text>
    <text x="94"  y="82" font-size="8" fill="#6DC55A" opacity=".8">Follicular</text>
    <text x="156" y="82" font-size="8" fill="#5ECFB0" opacity=".7">O</text>
    <text x="245" y="82" font-size="8" fill="#FAC775" opacity=".7">Luteal</text>
    <!-- full-span dashed projection line behind the actuals -->
    <path stroke="#D8EDD4" stroke-width="1" stroke-dasharray="4 3" .../>
    <!-- solid actuals (smooth cubic bezier) -->
    <path stroke="#6DC55A" stroke-width="2.5" stroke-linecap="round" .../>
    <!-- area-fill gradient under actuals: linearGradient #6DC55A 20% → 0% top-to-bottom -->
    <path fill="url(#wg)" opacity=".7" .../>
    <!-- Today dot 5px solid + 9px 15%-alpha halo + "Today" 8/700 above -->
    <circle cx="200" cy="21" r="5"  fill="#6DC55A"/>
    <circle cx="200" cy="21" r="9"  fill="#6DC55A" opacity=".15"/>
    <text   x="200" y="14"  font-size="8" font-weight="700" fill="#6DC55A">Today</text>
    <!-- bolder dashed continuation right of Today (forward projection) -->
    <path stroke="#D8EDD4" stroke-width="2" stroke-dasharray="4 3"
          stroke-linecap="round" .../>
  </svg>

  <!-- phase legend below chart (lines 177-182) -->
  <div style="display:flex; gap:10px; margin-top:10px;">
    <div><div bg="#FF8A8A" 7×7 rounded-2 .75>Menstrual  9px sage</div></div>
    <div><div bg="#6DC55A" 7×7 rounded-2 .8>Follicular  9px sage</div></div>
    <div><div bg="#A8F0C0" 7×7 rounded-2>Ovulation     9px sage</div></div>
    <div><div bg="#FAC775" 7×7 rounded-2 .9>Luteal      9px sage</div></div>
  </div>
</div>
```

**Critical traits:** no Y-axis labels, no X-axis labels, no gridlines, in-chart phase-letter labels, area-fill gradient, smooth bezier line, "Today" label, phase legend strip below.

### 3.3 At a glance (lines 185-235)

```html
<div class="card">
  <div class="lbl">This month at a glance</div>            <!-- title with scope -->
  <div style="display:grid; grid-template-columns:repeat(4,1fr); gap:0;">
    <!-- Each ring: 68×68 SVG, stroke-width 5.5,
         track #EAF7E4 (mint cream) and progress arc per metric color.
         Center has TWO text lines: value (13/800) + denominator/unit (8 sage).
         Below the SVG: label (9 sage) + colored % (10/700). -->

    <svg width="100%" height="68"><!-- Classes -->
      <circle stroke="#EAF7E4" stroke-width="5.5"/>           <!-- track -->
      <circle stroke="#6DC55A" stroke-width="5.5"
              stroke-dasharray="110 60" .../>                  <!-- 80% arc -->
      <text font-size="13" font-weight="800" fill="#163220">16</text>
      <text font-size="8" fill="#9ab09a">/20</text>
    </svg>
    <div style="font-size:9px;color:#9ab09a;">Classes</div>
    <div style="font-size:10px;font-weight:700;color:#6DC55A;">80%</div>

    <!-- Sleep ring stroke #A8F0C0 mint, value "6.5h" + sub "sleep",
         status "81%" in #5a9a8a dark mint -->
    <!-- Water ring stroke #FAC775 amber, value "1.6L" + sub "water",
         status "62%" in #b38a00 amber-text -->
    <!-- Goal ring stroke #6DC55A, value "42%" + sub "goal",
         status "On track" in #6DC55A green -->
  </div>
</div>
```

**Per-ring stroke + status colour map** — the 4 rings each have their own colour identity:

| Metric | Ring stroke | Status text colour |
|---|---|---|
| Classes | `#6DC55A` accent green | `#6DC55A` accent green |
| Sleep | `#A8F0C0` mint | `#5A9A8A` dark mint |
| Water | `#FAC775` amber | `#B38A00` amber-text |
| Goal | `#6DC55A` accent green | `#6DC55A` accent green |

### 3.4 Hydration (lines 237-274)

```html
<div class="card">
  <div class="lbl">Hydration · monthly avg</div>            <!-- "· monthly avg" suffix -->

  <!-- BIG WATER TILE — full width inside the card -->
  <div style="background:#EAF7E4; border-radius:14px; padding:14px 15px;">
    <!-- top row: "💧 Water" left + "62% · drink more" right (#B38A00 amber) -->
    <div style="display:flex; align-items:baseline; justify-content:space-between;">
      <div style="font-size:10px; color:#9ab09a;">💧 Water</div>
      <div style="font-size:11px; font-weight:700; color:#b38a00;">62% · drink more</div>
    </div>
    <!-- big number row: "1.6L" 26/800 dark + " / 2.5L target" 12px sage -->
    <span style="font-size:26px; font-weight:800; color:#163220;
                 letter-spacing:-.5px;">1.6L</span>
    <span style="font-size:12px; color:#9ab09a;">/ 2.5L target</span>
    <!-- 5px progress bar: track #D8EDD4, fill amber #FAC775 at 62% -->
  </div>

  <!-- PHASE TIP — green-tinted box w/ green border -->
  <div style="background:rgba(109,197,90,.08); border:1px solid rgba(109,197,90,.18);
              border-radius:12px; padding:11px 13px;">
    <div style="font-size:11px; color:#163220;">
      💡 <strong>Follicular phase:</strong> protein-rich meals support muscle recovery
      — your body absorbs amino acids better in this phase.
    </div>
  </div>

  <!-- DASHED-TOP-BORDER FOOTER -->
  <div style="display:flex; align-items:center; justify-content:space-between;
              padding-top:8px; border-top:1px dashed #D8EDD4;">
    <span>🍽️</span>
    <div>
      <div style="font-size:11px; font-weight:700; color:#163220;">
        Meals · calories · macros</div>
      <div style="font-size:9px; color:#9ab09a;">Full meal logging</div>
    </div>
    <span class="soonpill">Coming soon</span>                <!-- amber soonpill -->
  </div>
</div>
```

### 3.5 Symptoms (lines 277-301)

```html
<div class="card">
  <div class="lbl">Symptoms this month</div>                <!-- "this month" suffix -->
  <!-- 4 rows, each: label 12/600 dark fixed-72px-width
                   + bar flex 5px thick track #EAF7E4
                   + delta text fixed-36px-right "↓ N%" or "↑ N%" 10/700 #6DC55A -->
  Bloating | bar fill #FF8A8A red 35% | ↓ 40%
  Energy   | bar fill #6DC55A green 78% | ↑ 60%
  Mood     | bar fill #6DC55A green 68% | ↑ 45%
  Cramps   | bar fill #FF8A8A red 22% | ↓ 60%
</div>
```

**Bar fill colour by symptom semantic:** lower-is-better (bloating, cramps) → `#FF8A8A` red; higher-is-better (energy, mood) → `#6DC55A` green.

### 3.6 AI Insights (lines 303-362)

```html
<!-- Outer card: dark #163220 bg + green-tinted border + green-tinted shadow -->
<div style="background:#163220; border-radius:20px; padding:15px 16px;
            border:1px solid rgba(109,197,90,.2);
            box-shadow:0 4px 20px rgba(22,50,32,.2);">

  <!-- Header: 28×28 robot icon-tile + "FitHer AI" 12/800 green
               + "3 tips for your phase" 9/white-30% subtitle -->

  <!-- Honesty banner: green-mint dashed-bordered box,
       text "✨ Personalised insights coming soon — phase-based tips for now."
       at rgba(168,240,192,.75) -->

  <!-- 3 expandable tip cards, per-index colour tints: -->
  <!-- Insight 1 — green family: bg rgba(109,197,90,.08), border .15
                  + 💪 emoji in 28×28 rgba(109,197,90,.15) tile
                  + chevron rgba(109,197,90,.6)
                  HEADLINE: "Strength training eases bloating"
                  SUBTITLE: "Tip for your follicular phase" -->
  <!-- Insight 2 — amber family: bg rgba(250,199,117,.07), border .14, 🌙 emoji -->
  <!-- Insight 3 — red family:   bg rgba(255,138,138,.06), border .13, 📉 emoji -->
</div>
```

### 3.7 Share Report (lines 364-375)

```html
<div class="card" style="padding:14px 16px;">
  <!-- Header row: "Share your report" .lbl LEFT + amber "Doctor share · soon" pill RIGHT -->
  <div class="lbl">Share your report</div>
  <span class="soonpill">Doctor share · soon</span>

  <!-- Description: "Export a clinical summary..." 11px #9ab09a -->

  <!-- Two buttons, equal width: -->
  <button style="background:#163220; color:#6DC55A; border:none;
                 border-radius:13px; padding:12px;
                 font-size:12px; font-weight:700;">
    Download PDF
  </button>                              <!-- DARK bg + GREEN text, no icon -->
  <button class="dis" disabled
          style="background:#EAF7E4; color:#163220;
                 border:1.5px solid #C8E8C0; border-radius:13px;
                 padding:12px; font-size:12px; font-weight:700;">
    🔒 Share with doctor
  </button>                              <!-- mint bg + dark text + emoji 🔒 + 0.45 opacity -->
</div>
```

### 3.8 Footer (line 377)

```html
<div style="text-align:center; font-size:11px; color:#9ab09a; padding:4px 0 24px;">
  Based on <strong style="color:#163220;">16 check-ins</strong> this month
</div>
```

Bold inline strong on the count. "this month".

### 3.9 Bottom nav (lines 381-388)
Outside Progress hub scope (BottomBarScreen renders this). Documented for completeness only.

---

## 4. Flutter current state (verbatim code paste)

### 4.0 Screen-level

`lib/UI/dashboard_module/bottom_bar_screen/progress_screen_v2.dart` — `_ProgressScreenV2State.build` returns a `Scaffold` with `backgroundColor: Color(0xFFF5FBF2)`. Body is a `ListView(padding: EdgeInsets.only(bottom:32))` with a non-padded `_HeroCard` first (escapes the gutter via `_GutterPad`-wrapped siblings). 7 cards stacked with `SizedBox(height:14)` separators.

```dart
backgroundColor: const Color(0xFFF5FBF2),                   // <- not #EAF7E4 mint
```

### 4.1 Hero — `_HeroCard` (build lines 215-292)

```dart
return ClipRRect(
  borderRadius: const BorderRadius.only(
    bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36),
  ),
  child: Container(
    color: _kHeroBg,                                         // #163220 ✓
    child: Stack([
      Positioned(top:-80, right:-60,
        child: Container(width:240, height:240,
          decoration: BoxDecoration(shape:BoxShape.circle,
            gradient: RadialGradient(colors:[
              _kHeroAccent.withOpacity(0.25), _kHeroAccent.withOpacity(0.0),
            ]))),                                             // ✓ mimics design line 65 radial
      ),
      Padding(padding: EdgeInsets.fromLTRB(22,18,22,18),
        child: Column(... [
          _heroHeader(state),                                 // single-line "Progress · {name} 🌿"
          // ... goal/stats/period chips
        ])),
    ]),
  ),
);

Text(headerLine,                                              // line 277-283
  style: TextStyle(fontSize:11, fontWeight:FontWeight.w300,
                   color:Colors.white.withOpacity(0.22)));
```

**Status row missing entirely** — no time `9:41`, no notification bell, no avatar circle (lines 70-76 of the design).

```dart
// _goalSummary — line 387
Row([
  Expanded(child: Column([
    Text(goal.label ?? 'Your goal',                           // "65kg by 2026-06-30"
      style: TextStyle(fontSize:11, color: Colors.white.withOpacity(0.30))),
    RichText(TextSpan(                                        // "−2.1 kg" 36/800 white ✓
      style: TextStyle(fontSize:36, fontWeight:FontWeight.w800,
                       color: Colors.white, letterSpacing:-1, height:1),
      children:[
        TextSpan(text: _formatDeltaNumber(goal.currentDeltaKg)),
        TextSpan(text:' kg', style: TextStyle(fontSize:18, fontWeight:FontWeight.w300,
                                              color: Colors.white.withOpacity(0.5))),
      ])),
    if ((goal.paceMessage ?? '').isNotEmpty)
      _HeroPacePill(message: goal.paceMessage!, color: paceColor),   // ✓ green pill
  ])),
  GoalRing(progress: progressPct, color: paceColor,
           centerText: '${(progressPct * 100).round()}%',
           labelText: 'to goal', size: 82,                    // ✓ matches design 82px
           trackColor: Colors.white.withOpacity(0.08),
           centerTextStyle: TextStyle(fontSize:16, fontWeight:FontWeight.w800, color: Colors.white),
           labelTextStyle: TextStyle(fontSize:9, color: Colors.white.withOpacity(0.4))),
]);
```

**Goal label format wrong:** `goal.label` from backend is `"${targetValueKg}kg by ${targetDate}"` (raw `2026-06-30`). Design shows `"Goal · −5 kg by June"`.

**Stat tiles (`_HeroStatTile`)** — render with translucent-white pill bg `Colors.white.withOpacity(0.07)` ✓, 12 px radius ✓, 17/800 value ✓, per-tile valueColor (white / amber / mint / white) ✓. Streak emits `'${streakDays}🔥'` so flame is inside the value ✓.

**Period selector (`PeriodChipSelector`)** — renders 5 chips via `Row(mainAxisAlignment: spaceBetween)`. **Labels are short forms:** `'Week' / 'Month' / '3M' / '6M' / '1Y'` (per `period_chip_selector.dart:78-82`). Design has long forms `'Week' / 'Month' / '3 Months' / '6 Months' / '1 Year'`.

### 4.2 Weight trend — `_WeightTrendCard` (build lines 681-783)

```dart
return _CardShell(child: Obx(() { ...
  Column([
    const Text('Weight trend',                                // ⚠ wrong typography
      style: TextStyle(fontSize:14, fontWeight:FontWeight.w600,
                       color: _kTextPrimary)),
    SizedBox(height:6),
    // ... loading / error / empty branches
    _weightBody(state.data),
  ]);
}));

// _weightBody — line 711
Column([
  Row([
    Text(trend.currentWeightKg != null
         ? '${trend.currentWeightKg!.toStringAsFixed(1)} kg'  // ⚠ "67.4 kg" instead of "−2.1 kg"
         : '—',
      style: TextStyle(fontSize:22, fontWeight:FontWeight.w700,
                       color: _kTextPrimary)),
    SizedBox(width:8),
    if (trend.deltaKg != null)
      Text('${trend.deltaKg! > 0 ? '+' : ''}${trend.deltaKg!.toStringAsFixed(1)} kg',
        style: TextStyle(fontSize:12, fontWeight:FontWeight.w600,
                         color: trend.direction == 'toward_goal' ? _kAccent
                              : trend.direction == 'away_from_goal' ? Color(0xFFE07B7B)
                              : _kTextMuted)),
  ]),
  SizedBox(height:8),
  PhaseSegmentedChart(history:..., phaseSegments:..., projection:...),
]);
```

**Differences vs design:**
- Title `'Weight trend'` 14 / w600 / dark **vs** design's `.lbl` 9 / w700 / uppercase / sage / letter-spaced
- Big number is **current weight** (`67.4 kg`) **vs** design's **period delta** (`−2.1 kg`)
- Sub-text is **delta repeated** (`+0.0 kg`) with green/red colour **vs** design's `↓ toward goal` 11/w700 green directional copy
- **Date label** (`Apr 2026`) on the right is **missing**
- No phase legend strip below

`PhaseSegmentedChart` (`lib/widgets/progress_v2/phase_segmented_chart.dart`):

```dart
SfCartesianChart(
  primaryXAxis: DateTimeAxis(majorGridLines: MajorGridLines(width:0),
                             axisLine: AxisLine(color: gridColor),
                             labelStyle: TextStyle(fontSize:11, color: Color(0xFF6F8B7A))),  // ⚠ visible X axis labels
  primaryYAxis: NumericAxis(majorGridLines: MajorGridLines(width:1, color: gridColor),
                            axisLine: AxisLine(width:0),
                            labelStyle: TextStyle(fontSize:11, color: Color(0xFF6F8B7A)),
                            labelFormat:'{value} kg'),                                       // ⚠ visible Y axis labels
  series: [
    ..._bandSeries(yMin, yMax),       // RangeAreaSeries for each phase  ✓
    LineSeries(..., color: lineColor, width: 2.5),                                           // ⚠ straight line, not bezier
    ScatterSeries([history.last], color: lineColor, markerSettings: ...),                    // ✓ Today dot
    if (hasProjection) LineSeries(..., dashArray: [5,4]),                                    // ✓ dashed projection
  ],
)
// Container height: 220                                                                     // ⚠ design is 90
```

**Differences vs design:**
- Chart height 220 px **vs** design 90 px
- X + Y axis labels visible **vs** design has neither
- Major Y gridlines visible **vs** design has none
- Straight line segments **vs** design's smooth cubic bezier
- No area-fill gradient under actuals **vs** design has 20%→0% green gradient
- No in-chart phase letter labels (M / Follicular / O / Luteal) **vs** design has them at y=82
- No "Today" text label above the dot **vs** design has 8/700 green "Today" label
- No phase legend strip below the chart **vs** design has a 4-square-chip Row at the bottom

### 4.3 At a glance — `_GlanceCard` (build lines 791-841)

```dart
const Text('At a glance',                                     // ⚠ "this month" dropped
  style: TextStyle(fontSize:14, fontWeight:FontWeight.w600,
                   color: _kTextPrimary));                    // ⚠ wrong typography

// per-ring _glanceRing(ring) — line 663
GoalRing(
  progress: pct,
  color: ring.key == 'water' && pct < 0.7 ? Color(0xFFFAC775) : _kAccent,  // ⚠ all-green except water amber
  centerText: formattedValue,                                  // single string only
  size: 78,                                                    // ⚠ design is 68px
);
const SizedBox(height: 6);
Text(ring.label, style: TextStyle(fontSize:11, fontWeight:FontWeight.w600, color: _kTextPrimary));
if (ring.statusLabel != null)
  Text(ring.statusLabel!, style: TextStyle(fontSize:9, color: _kTextMuted));   // ⚠ all muted grey
```

**Differences vs design:**
- Title `'At a glance'` 14 / w600 / dark **vs** design's `.lbl` "This month at a glance"
- Ring size 78 px **vs** design 68 px
- **Single center text** in the ring **vs** design's TWO lines (value + denominator/unit subtext)
- Per-ring stroke colour homogenised to accent green (water → amber when low) **vs** design's per-metric stroke colours (sleep mint, classes/goal accent, water amber)
- Status label below uses muted grey **vs** design's per-metric colour-coded percentage (`80%` green / `81%` dark mint / `62%` amber / `On track` green)

### 4.4 Hydration — `_HydrationCard` (build lines 718-803)

```dart
const Text('Hydration',                                       // ⚠ "· monthly avg" dropped
  style: TextStyle(fontSize:14, fontWeight:FontWeight.w600,
                   color: _kTextPrimary));                    // ⚠ wrong typography

// _hydrationBody — replaces design's headline tile with TrendBar
Container(padding: EdgeInsets.fromLTRB(15,14,15,14),
  decoration: BoxDecoration(color: Color(0xFFEAF7E4),         // ✓ mint inset
                            borderRadius: BorderRadius.circular(14)),
  child: Column([
    Row([
      Expanded(child: Text('💧 Water', style: TextStyle(fontSize:10, color: Color(0xFF9AB09A)))),
      Text('${(pct*100).round()}%${isLow ? ' · drink more' : ''}',
        style: TextStyle(fontSize:11, fontWeight:FontWeight.w700,
                         color: isLow ? amberText : _kAccent)),  // ✓ amber when low
    ]),
    SizedBox(height:8),
    RichText(TextSpan([
      TextSpan(text:'${(data.averageL ?? 0).toStringAsFixed(1)}L',
        style: TextStyle(fontSize:26, fontWeight:FontWeight.w800,
                         color: _kTextPrimary, letterSpacing:-0.5)),       // ✓ 26/800
      TextSpan(text:' / ${(data.targetL ?? 0).toStringAsFixed(1)}L target',
        style: TextStyle(fontSize:12, color: Color(0xFF9AB09A))),
    ])),
    SizedBox(height:10),
    ClipRRect(child: Stack([
      Container(height:5, color: Color(0xFFD8EDD4)),                       // ✓ 5px track
      FractionallySizedBox(widthFactor: pct,
        child: Container(height:5, color: isLow ? amber : _kAccent)),      // ✓ amber when low
    ])),
  ]));

// phase tip — current implementation
Container(padding: EdgeInsets.all(10),
  decoration: BoxDecoration(color: Color(0xFFEDF5EA),                      // ⚠ mint NOT green-tinted
                            borderRadius: BorderRadius.circular(10)),
  child: Row([Text('💡', ...), Text(data.phaseTip!.tip!, ...)]));            // ⚠ no green border, no bold "Follicular phase:"

// meals coming-soon footer
Row([
  Icon(Icons.restaurant_outlined, size:14, color: _kTextMuted),            // ⚠ material icon, design uses 🍽️
  SizedBox(width:6),
  Text(data.mealsCard?.copy ?? 'Meals · coming soon',                      // ⚠ no "calories · macros", no soonpill
    style: TextStyle(fontSize:11, color: _kTextMuted, fontStyle: FontStyle.italic)),
]);
```

**Most of the headline water tile is now correct (after CF6a).** Drift remaining:
- Title scope dropped (`'· monthly avg'`)
- Phase tip lost green-tint background and the bold `**Follicular phase:**` prefix
- Meals footer is much weaker: no dashed top border, no bold title, no "calories · macros" subtext, no amber soonpill

### 4.5 Symptoms — `_SymptomsCard` (build lines 814-870)

```dart
const Text('Symptoms this period',                            // ⚠ "this period" not "this month"
  style: TextStyle(fontSize:14, fontWeight:FontWeight.w600,
                   color: _kTextPrimary));

// per-row body — line 855
TrendBar(
  label: s.label,
  pct: pct,
  color: _symptomBarColor(s.key),                             // ✓ red for bloating/cramps after CF5
  trailingText: s.intensityPct != null ? '${s.intensityPct}%' : '—',   // ⚠ extra text vs design
  deltaPct: s.deltaPct?.toDouble(),
  deltaIsImprovement: s.isImprovement,
);

Color? _symptomBarColor(String key) {
  switch (key.toLowerCase()) {
    case 'bloating': case 'cramps': case 'cramp': return const Color(0xFFFF8A8A);
    case 'energy': case 'mood': return const Color(0xFF6DC55A);
    default: return null;
  }
}
```

**TrendBar internal:** 8 px bar height **vs** design 5 px. Delta rendered as a coloured pill **vs** design plain text.

### 4.6 AI Insights — `_AiInsightsCard` (build lines 905-1003)

```dart
return Container(                                              // ✓ NOT _CardShell — manual dark container
  decoration: BoxDecoration(
    color: _kHeroBg,                                           // ✓ #163220
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _kHeroAccent.withOpacity(0.20)),  // ✓ green border
    boxShadow: [BoxShadow(color: _kHeroBg.withOpacity(0.20),
                          offset: Offset(0,4), blurRadius: 20)],
  ),
  ...
  child: Column([
    _aiHeader(tipCount),                                       // ✓ 🤖 + "FitHer AI" + "{N} tips for your phase"
    if (state.data?.honestyBanner != null) _honestyBanner(...),  // ✓ mint dashed-border (approx — solid border in impl)
    ... per-insight ExpandableCard with _kInsightTints[i % 3] ...
  ]),
);

const List<_InsightTint> _kInsightTints = [
  _InsightTint(background: 0x146DC55A, border: 0x266DC55A, iconBg: 0x266DC55A,
               emoji: '💪', chevron: 0x996DC55A),              // ✓ green family
  _InsightTint(background: 0x12FAC775, border: 0x24FAC775, iconBg: 0x26FAC775,
               emoji: '🌙', chevron: 0x80FAC775),              // ✓ amber family
  _InsightTint(background: 0x0FFF8A8A, border: 0x21FF8A8A, iconBg: 0x26FF8A8A,
               emoji: '📉', chevron: 0x80FF8A8A),              // ✓ red family
];
```

**Largely matches design after CF4.** Remaining drift:
- Honesty banner border is solid (`Border.all`) **vs** design dashed — DottedBorder package not in pubspec, documented inline.
- Insight body comes from `dashboard.insight.body` (backend) — design has bespoke copy. Backend's Phase B `deriveHeadline` may emit `"Day 6"`-style headlines that differ from design's curated tips.

### 4.7 Share Report — `_ShareReportCard` (build lines 998-1106)

```dart
const Text('Share your report',                               // ⚠ wrong typography
  style: TextStyle(fontSize:14, fontWeight:FontWeight.w600, color: _kTextPrimary));
SizedBox(height:4);
const Text('Generate a 2-page PDF for your records or doctor visit.',  // ⚠ shorter copy
  style: TextStyle(fontSize:12, color: _kTextMuted));
// ... no amber "Doctor share · soon" pill in header

// _DownloadPdfButton — line 1115
Container(decoration: BoxDecoration(color: _kHeroBg),         // ✓ dark bg after CF6b
  child: Center(child: Text('Download PDF',                    // ✓ no icon after CF6b
    style: TextStyle(color: _kAccent, fontWeight:FontWeight.w700, fontSize:12))));   // ✓ green text

// _DoctorShareButton — line 1170
Container(decoration: BoxDecoration(
    color: Color(0xFFEAF7E4),                                  // ✓ mint bg
    border: Border.all(color: Color(0xFFC8E8C0), width: 1.5)),  // ⚠ solid border (design dashed)
  child: Opacity(opacity: 0.45, child: Row([                    // ✓ 0.45 opacity after CF6b
    Icon(Icons.lock_outline, ...),                              // ⚠ material icon (design uses 🔒 emoji)
    Text('Share with doctor', ...),
  ])));
```

**After CF6b: dark bg + green text on PDF button ✓. 0.45 opacity on doctor share ✓.** Remaining drift:
- Header missing the amber `Doctor share · soon` soonpill
- Description copy differs
- Doctor button border solid not dashed (DottedBorder not in pubspec)
- Doctor button uses material `Icons.lock_outline` not 🔒 emoji

### 4.8 Footer — `_Footer` (build lines 1207-1248)

```dart
Obx(() {
  final n = controller.symptoms.value.data?.basedOnCheckIns ?? 0;
  return Text(
    n > 0 ? 'Based on $n check-ins this period'                // ⚠ "this period" not "this month"
          : 'Daily check-ins power your trends',
    style: TextStyle(fontSize:11, color: _kTextMuted, fontStyle: FontStyle.italic));   // ⚠ italic, no inline bold
});
SizedBox(height:12);
InkWell(onTap: () => Get.to(() => ProgressScreenV1()),         // EXTRA: not in design
  child: Padding(child: Row([
    Icon(Icons.photo_library_outlined, size:14, color: _kAccent),
    SizedBox(width:6),
    Text('Photos & measurements',
      style: TextStyle(fontSize:12, fontWeight:FontWeight.w600, color: _kAccent)),
    Icon(Icons.chevron_right, size:14, color: _kAccent),
  ])));
```

**Differences:**
- Number not bolded inline; whole line italicised muted
- "this period" not "this month"
- "Photos & measurements →" link is **extra in code** (intentional Phase D6 add)

---

## 5. Diff table

Severity: **CRITICAL** = looks broken / wrong data · **MAJOR** = significant visual gap · **MEDIUM** = noticeable styling drift · **MINOR** = polish only.
Effort: **trivial** = single hex/string · **low** = ~30 min single-file · **medium** = ~2-4 hr multi-file · **high** = ~1+ day structural.

| # | Element | HTML mockup | Flutter current | Type | Severity | Effort |
|---|---|---|---|---|---|---|
| 1 | Screen background | `#EAF7E4` mint cream | `#F5FBF2` slightly different mint | VISUAL | MINOR | trivial |
| 2 | Hero status row (time `9:41` + 🔔 + avatar) | present (lines 70-76) | **missing entirely** | MISSING | MEDIUM | low |
| 3 | Hero greeting weight | 11 / w300 / white-22% | 11 / w300 / white-22% | VISUAL | — | match |
| 4 | Goal subtitle format | `Goal · −5 kg by June` | `goal.label` from backend = `65kg by 2026-06-30` | COPY+DATA | **MAJOR** | low |
| 5 | Hero delta number | `−2.1` 36/w800 white + ` kg` 18/w300 white-50% | matches | VISUAL | — | match |
| 6 | Hero pace pill | bg rgba(green,.15) + 5px green dot + 10/w700 green text | matches | VISUAL | — | match |
| 7 | Hero ring | 82px diameter, `42%` 16/w800 + `to goal` 9 white-40% | 82px, matches center+label styles | VISUAL | — | match |
| 8 | Stat tiles chrome | translucent white pills 12r 9v/6h pad | matches after CF2 | VISUAL | — | match |
| 9 | Stat tile values colour-coding | white/amber/mint/white per tile | matches after CF2 | VISUAL | — | match |
| 10 | Streak `8🔥` (flame inside value) | `8🔥` as one string | `'${streakDays}🔥'` | VISUAL | — | match |
| 11 | Period chip labels | `Week`/`Month`/`3 Months`/`6 Months`/`1 Year` | `Week`/`Month`/`3M`/`6M`/`1Y` | COPY | MEDIUM | trivial |
| 12 | Period chip layout | `display:flex; gap:6px; overflow-x:auto` | `Row(mainAxisAlignment: spaceBetween)` | COMPONENT | MINOR | low |
| 13 | Card title typography | `.lbl` 9/w700 uppercase letter-spaced sage | 14/w600 mixed-case dark | VISUAL | **MAJOR** | low |
| 14 | Card padding | 15v / 17h | `EdgeInsets.all(16)` default | VISUAL | MINOR | trivial |
| 15 | Card border-radius | 20px | 18px (`_kCardRadius`) | VISUAL | MINOR | trivial |
| 16 | Card shadow | `0 2px 12px rgba(22,50,32,.05)` | `offset(0,2) blur(8) color rgba(22,50,32,.04)` | VISUAL | MINOR | trivial |
| 17 | Card-to-card gap | `margin-bottom:9px` | `SizedBox(height:14)` | VISUAL | MINOR | trivial |
| 18 | Weight trend big number | period delta `−2.1 kg` 24/w800 dark | current weight `67.4 kg` 22/w700 dark | DATA | **MAJOR** | low |
| 19 | Weight trend sub-text | `↓ toward goal` 11/w700 green directional | `+0.0 kg` plain coloured delta | COPY+VISUAL | **MAJOR** | low |
| 20 | Weight trend date label | `Apr 2026` 10 sage right-aligned | **missing** | MISSING | MEDIUM | low |
| 21 | Weight chart height | 90 px | 220 px | VISUAL | **MAJOR** | low |
| 22 | Weight chart Y axis labels | hidden | `{value} kg` labels visible | VISUAL | MEDIUM | trivial |
| 23 | Weight chart X axis labels | hidden | dates visible | VISUAL | MEDIUM | trivial |
| 24 | Weight chart gridlines | none | major Y gridlines visible | VISUAL | MINOR | trivial |
| 25 | Weight chart line shape | smooth cubic bezier | straight `LineSeries` | VISUAL | MEDIUM | trivial (`splineType` arg) |
| 26 | Weight chart area fill | gradient `#6DC55A 20% → 0%` under actuals | none | MISSING | MEDIUM | low (`AreaSeries` overlay) |
| 27 | Weight chart phase letter labels | M / Follicular / O / Luteal at y=82 inside bands | none | MISSING | MEDIUM | medium (custom annotation layer) |
| 28 | Today label | 8/w700 green text "Today" above dot | none | MISSING | MEDIUM | low |
| 29 | Phase legend strip below chart | 4-square-chip Row 7px squares 9px sage labels | **missing entirely** | MISSING | **MAJOR** | low |
| 30 | Glance card title | "This month at a glance" `.lbl` style | "At a glance" 14/w600 dark | COPY+VISUAL | MEDIUM | trivial |
| 31 | Glance ring size | 68 px | 78 px | VISUAL | MINOR | trivial |
| 32 | Glance ring center secondary text | 2 lines: value + denominator/unit (e.g. `16` + `/20`) | single center text only | MISSING | **MAJOR** | medium (GoalRing API change) |
| 33 | Glance per-ring stroke colour | sleep mint / classes & goal accent / water amber-when-low | all-accent except water-amber-when-low | DATA | MEDIUM | trivial |
| 34 | Glance status text colour | per-metric: 80% green / 81% dark mint / 62% amber / "On track" green | all `_kTextMuted` grey | VISUAL | **MAJOR** | low |
| 35 | Hydration card title | "Hydration · monthly avg" | "Hydration" | COPY | MEDIUM | trivial |
| 36 | Hydration headline tile | mint inset, 26/w800 big, amber bar when low | matches after CF6a | VISUAL | — | match |
| 37 | Hydration phase tip styling | rgba(green,.08) bg + green border + bold "Follicular phase:" prefix | mint bg, no border, no bold prefix | VISUAL | MEDIUM | low |
| 38 | Hydration meals footer | dashed top border + 🍽️ emoji + bold title + "Full meal logging" sub + amber soonpill | plain mint italic line, material restaurant icon | MISSING | MEDIUM | low |
| 39 | Symptoms card title | "Symptoms this month" `.lbl` style | "Symptoms this period" 14/w600 dark | COPY+VISUAL | MEDIUM | trivial |
| 40 | Symptom bar colour | red for bloating/cramps, green for energy/mood | matches after CF5 (verify on device) | DATA | — | match (verify) |
| 41 | Symptom bar height | 5 px | 8 px | VISUAL | MINOR | trivial |
| 42 | Symptom row layout | label-72px / bar-flex / delta-36px in single row | label+pill+trailing in row 1, bar in row 2 | COMPONENT | MEDIUM | medium |
| 43 | Symptom delta rendering | plain coloured text `↓ N%` | rounded coloured pill | VISUAL | MEDIUM | low |
| 44 | Symptom trailing text | none (intensity conveyed by bar) | `35%` percentage text | EXTRA | MINOR | trivial |
| 45 | AI Insights card bg | `#163220` dark green | matches after CF4 | VISUAL | — | match |
| 46 | AI Insights header | 🤖 28×28 tile + "FitHer AI" 12/w800 green + "3 tips" 9 white-30% | matches after CF4 | VISUAL | — | match |
| 47 | Honesty banner styling | green-mint 8% bg + dashed mint .25 border + ✨ prefix at .75 alpha | matches after CF4 except border solid not dashed | VISUAL | MINOR | medium (DottedBorder dep needed) |
| 48 | AI insight per-card tints | green/amber/red per index | matches after CF4 | VISUAL | — | match |
| 49 | AI insight emoji icons | 💪/🌙/📉 in 28×28 tinted square | matches after CF4 | VISUAL | — | match |
| 50 | AI insight headline copy | curated specific tips (Strength training eases bloating, etc.) | comes from backend `insight.body` (StaticInsights cycleDay templates) | DATA | MEDIUM | low (hardcode 3 strings client-side) |
| 51 | Share Report header | "Share your report" `.lbl` left + amber `Doctor share · soon` pill right | "Share your report" 14/w600 only | MISSING+VISUAL | MEDIUM | low |
| 52 | Share Report description | "Export a clinical summary of your cycle, symptoms..." 11 sage | "Generate a 2-page PDF..." 12 muted | COPY | MINOR | trivial |
| 53 | Download PDF button | dark `#163220` bg + green `#6DC55A` text + no icon | matches after CF6b | VISUAL | — | match |
| 54 | Doctor share button border | `1.5px solid #C8E8C0` … but **dashed** `class="dis"` opacity 0.45 | solid border 1.5px / 0.45 opacity ✓ | VISUAL | MINOR | medium (DottedBorder dep) |
| 55 | Doctor share lock icon | 🔒 emoji prefix | `Icons.lock_outline` material | VISUAL | MINOR | trivial |
| 56 | Footer line | "Based on **16 check-ins** this month" — bold inline + dark | "Based on 16 check-ins this period" — italic muted | COPY+VISUAL | MEDIUM | trivial |
| 57 | "Photos & measurements →" link | absent | present (Phase D6 add) | EXTRA | — | keep |
| 58 | Loading skeletons | absent | present | EXTRA | — | keep |
| 59 | Error rows w/ Retry | absent | present | EXTRA | — | keep |
| 60 | Empty-state copies | absent | present | EXTRA | — | keep |
| 61 | Pull-to-refresh | absent | present | EXTRA | — | keep |
| 62 | Period selector → 6 endpoints refetch | absent | present | EXTRA | — | keep |

---

## 6. Prioritized recommendations

### A. Quick wins (trivial / low effort + MAJOR-MEDIUM impact)

These ship the same day. Heaviest visual ROI per minute spent.

1. **#4 Goal subtitle reformat** (MAJOR · low) — `goal.label` → `Goal · ${signed}kg by ${MonthName}`. Use `intl` (already in pubspec). 1 file, ~15 lines.
2. **#13 Card titles → `.lbl` typography** (MAJOR · low) — single helper widget for all 7 card titles: 9/w700/uppercase/letter-spaced/sage. Replace inline `Text('...', 14/w600)` calls. 1 file, ~7 lines per card title.
3. **#18 Weight trend big number** (MAJOR · low) — switch from `currentWeightKg` to `deltaKg` formatted as `−2.1 kg` 24/w800 dark. 1 file, ~5 lines.
4. **#19 Weight trend sub-text** (MAJOR · low) — `↓ toward goal` derived from `direction` field. 1 file, ~5 lines.
5. **#34 Glance status colours** (MAJOR · low) — colour-code "80%/81%/62%/On track" by ring key. 1 file, ~10 lines.
6. **#29 Phase legend strip below weight chart** (MAJOR · low) — 4-chip Row inside `_WeightTrendCard`'s Column. 1 file, ~25 lines.
7. **#22 + #23 + #24 Hide weight chart axes + gridlines** (MEDIUM · trivial) — `xAxis.isVisible=false; yAxis.isVisible=false; majorGridLines: MajorGridLines(width:0)`. 1 file, ~3 lines.
8. **#11 Period chip labels long form** (MEDIUM · trivial) — change `defaultOptions` const list. 1 file, 1 line.
9. **#56 Footer copy + bold inline** (MEDIUM · trivial) — RichText with bold span on the count, "this month". 1 file, ~10 lines.

**Quick-wins total estimate:** ~3-4 hours of focused work, all in 1-2 files.

### B. Strategic fixes (medium effort + MAJOR severity)

Worth the investment for HBL polish if there's time.

10. **#32 Glance ring secondary text** (MAJOR · medium) — `GoalRing` widget needs to support a sub-line in the ring center. Either extend `GoalRing` API (new optional `centerSubText` + sizing rules) or render center as a 2-line stack. Touches `goal_ring.dart` + `_glanceRing` call site. ~1 hour.
11. **#21 Weight chart height** (MAJOR · low when paired with 22-26) — drop from 220 to ~120-140 (90 px is too short on a Flutter device with the larger axis margins). Single line change, but should be done together with axis-hide + bezier so the chart doesn't look cramped.
12. **#42 Symptom row layout** (MEDIUM · medium) — collapse to single-row `Row(label-72/bar-flex/delta-36)`. Touches `trend_bar.dart` (new compact mode) or duplicates layout in `_SymptomsCard`. ~1 hour.
13. **#2 Hero status row** (MEDIUM · low) — restore the time + bell + avatar row. ~30 min.

### C. Backlog (low severity OR high effort)

Defer unless founder pushes.

14. **#27 In-chart phase letter labels** (MEDIUM · medium) — Syncfusion's `CartesianChartAnnotation` is the right primitive but laying the labels at consistent y=bottom requires custom math. ~2 hours.
15. **#26 Area fill gradient** (MEDIUM · low) — `SplineAreaSeries` overlay below the line series. ~30 min but compounds with bezier change.
16. **#25 Bezier line** (MEDIUM · trivial) — `splineType: SplineType.cardinal` on the line series. Bundle with #26.
17. **#37 Hydration phase tip styling** (MEDIUM · low) — recolour to green-tinted bg + bold prefix split. ~15 min.
18. **#38 Hydration meals footer** (MEDIUM · low) — dashed top border (CSS-equivalent via `Border(top: BorderSide(...))` with hand-drawn dashed via `flutter_svg` or `CustomPainter`) + amber "Coming soon" pill widget + "calories · macros" copy. ~1 hour.
19. **#50 AI insight headline copy** (MEDIUM · low) — hardcode 3 client-side strings keyed off phase. ~20 min.
20. **#51 + #55 + #54 Share Report polish** (MEDIUM · low together) — add soonpill in header, swap material lock for 🔒 emoji, optionally add `dotted_border` package for the dashed border. ~30 min total.
21. **All MINOR items (#1, 12, 14-17, 31, 41, 44)** — pixel-polish. Do as one batch when time permits.

### D. Concerns / blockers requiring founder input

- **`DottedBorder` package** is not in pubspec. Three places need it (#47 honesty banner border, #38 dashed top border on meals footer, #54 doctor button border). Two paths:
  - **Add the dep** (`dotted_border: ^2.1.0` is well-maintained, ~30 KB transitive). Founder approval needed since prior phases enforced "no new deps".
  - **Hand-roll a `DashedBorderPainter`** via `CustomPainter`. ~2 hours, no dep needed, but reinvents a popular library.
- **Backend `goal.label` field contract** — quick win #4 reformats client-side and stops reading `goal.label`. The field stays in the response. Confirm we're OK with this drift (older clients keep working; newer clients ignore the field).
- **Glance ring API change (#32)** — changing `GoalRing.centerText` to support a 2-line stack is a breaking widget API change. The hero ring (single line "42%") and glance rings (two-line "16" + "/20") would need different rendering paths. Either:
  - Add optional `centerSubText` prop (additive, non-breaking)
  - Inline the 2-line widget at the call site, bypassing GoalRing's center-text handling
  Recommend the latter for less risk.
- **Insight body copy (#50)** — backend's `StaticInsights.js` emits 22 cycleDay-keyed templates. Design has 3 phase-keyed curated tips. If we hardcode the design's 3 strings client-side, the backend's 22-template variety is unused. Confirm: hardcode for the demo, plumb the real engine in v2 backlog?

---

## 7. Open questions for the founder

1. **Goal subtitle math** (#4): use `targetDeltaKg = target - start` (static `−5 kg`) or `target - current` (dynamic, drifts toward 0)? Recommend the static form to match the mockup.
2. **Weight trend big number** (#18): show period `deltaKg` (matches design) or current weight (current behaviour)? Recommend match design.
3. **Card title typography** (#13): adopt `.lbl` style globally on every card title? Yes/no.
4. **`DottedBorder` package**: add the dep or hand-roll a painter? (~30 min vs ~2 hours)
5. **Glance ring secondary text** (#32): inline 2-line widget at call site, or extend `GoalRing`'s API with a `centerSubText` prop? Recommend inline.
6. **Insight body copy** (#50): hardcode the design's 3 specific tips client-side for HBL, or keep the backend `StaticInsights.js` 22-template feed?
7. **Period chip labels** (#11): match design's long form (`3 Months / 6 Months / 1 Year`) or keep the compact form (`3M / 6M / 1Y`)?
8. **Footer microcopy** (#56): "this month" (design) or "this period" (current — period-aware)? The design assumes month always; current adapts to selected period.

---

*End of audit. Read-only. No production files modified. Awaiting founder triage of §6 quick-wins / strategic fixes / backlog before any Phase 2 fix work.*
