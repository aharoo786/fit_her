# Sprint 1 · Screen 1 — Welcome / Get Started Audit

> Read-only investigation. No production files modified.
> Generated 2026-04-26. Source artefacts paste-in-line (no summarisation).

---

## Executive summary

- **One screen to redesign in place:** `lib/UI/auth_module/walt_through/walk_through_screenn.dart` (the "Get Started + Log In" landing).
- **Three call sites to redirect** away from the 3-slide swipe walkthrough (`welcom_screen.dart`) so cold-launch users land on the new screen directly: `splash.dart:71`, `app_link_handler.dart:46`, `app_link_handler.dart:55`.
- **Migration risk: low.** Existing logged-in users never hit either welcome screen — they bypass via `AuthController.login` from `splash.dart`. Only first-launch + deep-link entry points are affected. Verdict: **safe to direct replace, no feature flag.**
- **No new assets required.** The new design uses the existing `MyImgs.fitHerLogo` (already used by splash) and a programmatic mint-bg-with-circles background that mirrors the splash's `_buildCircles` pattern. No `pubspec.yaml` change.
- **Tech debt found** (flagged, not fixed in this work): ~7 unused imports, two large blocks of commented-out code, folder/file typos (`walt_through/`, `walk_through_screenn.dart`), and a misnamed `fromWelcomeScreen` parameter on `ProfileScreen` that actually means "from WalkThroughScreen".

---

## STEP 1 — New design extraction (SA-00 frame)

**Source:** `C:/Users/dell/Desktop/dev/new screens/Sprint1_WithLogo, starting,login.html`, lines 76–106.

### A. Full SA-00 markup (verbatim)

```html
<!-- ═══ SA-00 · WELCOME / SPLASH ═══ -->
<div class="col">
<div class="vtag">SA-00</div>
<div class="vname">Welcome / Splash</div>
<div class="vdesc">First app open. Logo + tagline + sign up or sign in choice.</div>
<div class="phone">
  <div style="background:#E8F4E0;flex:1;display:flex;flex-direction:column;padding:100px 32px 40px;position:relative;overflow:hidden;">
    <div class="circ-1"></div>
    <div class="circ-2"></div>
    <div class="circ-3"></div>
    <div class="status-bar">
      <span>9:41</span>
      <div class="status-right">…signal + battery svgs…</div>
    </div>

    <div style="flex:1;display:flex;flex-direction:column;justify-content:center;align-items:center;position:relative;z-index:5;">
      <img src="" class="logo-img-large logo-target" style="margin-bottom:32px;">
      <div style="font-size:30px;font-weight:800;color:#1a3a22;line-height:1.15;letter-spacing:-.01em;text-align:center;margin-bottom:12px;">Built for every<br>phase of you.</div>
      <div style="font-size:15px;color:#5a7258;line-height:1.6;text-align:center;max-width:300px;font-weight:400;">The first fitness platform designed around your hormonal cycle — live classes, nutrition, and AI insights.</div>
    </div>

    <div style="position:relative;z-index:5;">
      <button class="btn-primary" style="margin-bottom:12px;">Get started</button>
      <button class="btn-ghost">I already have an account</button>
    </div>
  </div>
</div>
</div>
```

### Supporting CSS (verbatim from same file)

```css
/* line 27 */ .logo-img-large{height:54px;width:auto;max-width:280px;display:block;margin:0 auto;object-fit:contain;}

/* line 41 */ .btn-primary{width:100%;background:#6DC55A;color:#fff;border:none;border-radius:14px;padding:16px;font-family:'Plus Jakarta Sans',sans-serif;font-size:15px;font-weight:700;cursor:pointer;}
/* line 42 */ .btn-ghost{width:100%;background:#fff;color:#1a3a22;border:1.5px solid #C8E8BC;border-radius:14px;padding:15px;font-family:'Plus Jakarta Sans',sans-serif;font-size:14px;font-weight:600;cursor:pointer;}

/* line 52 */ .status-bar{position:absolute;top:0;left:0;right:0;padding:16px 28px 0;display:flex;justify-content:space-between;align-items:center;font-size:15px;font-weight:600;color:#1a3a22;z-index:10;}

/* circles, lines around 22–24 */
.circ-1{position:absolute;top:-80px;right:-60px;width:300px;height:300px;border-radius:50%;background:#C8E8BC;opacity:.65;}
.circ-2{position:absolute;bottom:-50px;left:-40px;width:180px;height:180px;border-radius:50%;background:#D4EBC4;opacity:.55;}
.circ-3{position:absolute;top:40%;left:30%;width:120px;height:120px;border-radius:50%;background:#C8E8BC;opacity:.3;}
```

### B–M. Element-by-element

| Aspect | Value |
|---|---|
| **B. Background colour** | `#E8F4E0` (mint) |
| **C. Background pattern** | 3 absolute-positioned soft circles: top-right 300px `#C8E8BC` @ 65%; bottom-left 180px `#D4EBC4` @ 55%; centre 120px `#C8E8BC` @ 30%. Implemented programmatically — no image asset. |
| **D. Logo placement** | Centred horizontally, in the **vertically-centred hero block**. `margin-bottom: 32px` separating it from the headline. |
| **E. Logo wordmark format** | The mockup uses `<img src="" class="logo-img-large logo-target">` — empty src placeholder. Designer intent: drop in the FitHer wordmark. **Reuse `MyImgs.fitHerLogo`** (the same asset the splash already uses). Render at ~54px height. |
| **F. Headline** | `Built for every<br>phase of you.` — the `<br>` is intentional, line-break between "every" and "phase". 30px / w800 / `#1a3a22` (deep green) / line-height 1.15 / letter-spacing −0.01em / text-align centre. |
| **G. Sub-copy** | `The first fitness platform designed around your hormonal cycle — live classes, nutrition, and AI insights.` — 15px / w400 / `#5a7258` / line-height 1.6 / centred / `max-width: 300px` so it wraps to ~3 lines on a 390-wide phone. |
| **H. Get Started button** | Text: `Get started`. Bg `#6DC55A`. Text white. No border. Radius 14. Padding 16. Full width. Font-size 15, weight 700. `margin-bottom: 12px` between this and the next button. |
| **I. Log In control** | Text: `I already have an account`. Bg `#fff`. Text `#1a3a22`. **Border 1.5px solid `#C8E8BC`** (not the green primary — softer mint border). Radius 14. Padding 15. Full width. Font-size 14, weight 600. |
| **J. Decorative elements** | The three soft circles only. No illustration asset, no icons, no dots, no progress indicator. |
| **K. Spacing rhythm** | Outer container padding `100px 32px 40px` (top–sides–bottom). 32px between logo and headline. 12px between headline and sub-copy. 12px between Get Started and Ghost buttons. Hero centre block uses `flex:1` to vertically centre between status bar and button stack. |
| **L. Typography** | Mockup uses `Plus Jakarta Sans` 300/400/500/600/700/800 (Google font). **Flutter app uses Poppins** (already loaded as the app font). Recommendation: render in Poppins — visually close enough; weight rendering matches; avoids new font asset. |
| **M. Status bar / safe area** | The mockup has a fake iOS status bar (9:41 + signal + battery icons) at top with `padding: 16px 28px 0`. **Flutter handles status bar via `SystemChrome` + `SafeArea`** — set `statusBarColor: #E8F4E0`, `statusBarIconBrightness: dark`. Wrap content in `SafeArea`. The 100px top padding in mockup → with SafeArea active, ~36px additional top space is plenty. |

---

## STEP 2 — Old implementation extraction

**File:** `lib/UI/auth_module/walt_through/walk_through_screenn.dart`
**Line count:** 141
**Class:** `WalkThroughScreen extends StatelessWidget` — `const WalkThroughScreen({Key? key})`

### Full source (verbatim)

```dart
import 'package:fitness_zone_2/UI/auth_module/login/login.dart';
import 'package:fitness_zone_2/UI/auth_module/questionair_screen.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/sign_up_screen.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/signup_screen_user.dart';
import 'package:flutter/material.dart';

import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/constants.dart';
import '../../../values/my_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../values/my_imgs.dart';
import '../../../widgets/custom_button.dart';
import '../../dashboard_module/profile_screen/profile_screen.dart';
import '../choose_any_one/choose_any_one.dart';

class WalkThroughScreen extends StatelessWidget {
  const WalkThroughScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  MyImgs.walkThroughBack2,
                ),
                fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50.h),
            Image.asset(MyImgs.logo3, scale: 3),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.1),
                    /* …8 more opacity stops 0.2 → 0.9… */
                  ])),
              child: Column(
                children: [
                  const SizedBox(height: 230),
                  Text("Welcome To FitHer!",
                      style: textTheme.titleLarge!.copyWith(
                          fontSize: 28.sp,
                          color: MyColors.textColor3,
                          fontWeight: FontWeight.w600)),
                  Text("Unleash your Inner Strength with us",
                      style: textTheme.titleLarge!.copyWith(
                          fontSize: 18.sp,
                          color: MyColors.textColor3,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 10.h),
                  CustomButton(
                      text: "Get Started",
                      onPressed: () { Get.to(() => SignUpNewUser()); }),
                  SizedBox(height: 20.h),
                  CustomButton(
                      text: "Log In",
                      onPressed: () { Get.to(() => Login()); }),
                  // …~25 lines of commented-out code (PCOS button + RichText "Already have an account?" link)…
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Element-by-element (matches Step 1 layout)

| Aspect | Value |
|---|---|
| **C. Class structure** | `StatelessWidget`, no internal state, no lifecycle. |
| **D. Background colour** | None — full-screen image asset (`MyImgs.walkThroughBack2`) covers the background. Asset is presumably a fitness photo (couldn't verify — read-only audit). |
| **E. Background imagery** | Full-bleed `DecorationImage` with `BoxFit.cover`. The 10-stop white opacity gradient over the bottom half is layered on top to fade the photo into a white surface where the buttons sit. |
| **F. Logo** | `MyImgs.logo3`, `Image.asset(..., scale: 3)`. Placed near the top after a 50.h spacer. |
| **G. Headline** | `"Welcome To FitHer!"` — 28sp / w600 / `MyColors.textColor3` / using `textTheme.titleLarge` base. |
| **H. Sub-copy** | `"Unleash your Inner Strength with us"` — 18sp / w500 / `MyColors.textColor3`. |
| **I. "Get Started" button** | `CustomButton(text: "Get Started", onPressed: () { Get.to(() => SignUpNewUser()); })`. Full width. Default `CustomButton` style (green gradient per the architecture audit). |
| **J. "Log In" link** | `CustomButton(text: "Log In", onPressed: () { Get.to(() => Login()); })`. Same `CustomButton` widget — looks visually identical to Get Started. No ghost/outlined variant in use. |
| **K. Navigation** | Get Started → `SignUpNewUser()`. Log In → `Login()`. No params, no preconditions. |
| **L. Lifecycle** | None — no `initState`, no `dispose`, no async work. Pure UI. |
| **M. State management** | None. Pure StatelessWidget, no controllers referenced at runtime. |
| **N. Side effects** | **Zero.** No analytics events, no SharedPreferences writes, no API calls, no permission requests. Confirmed by reading the full source. |
| **O. Imports** | 13 imports total. Only **5 are referenced in active code**: `login.dart`, `signup_screen_user.dart`, `material.dart`, `flutter_screenutil`, `get`, `my_colors.dart`, `my_imgs.dart`, `custom_button.dart`. The other 6 (`questionair_screen.dart`, `sign_up_screen.dart`, `auth_controller.dart`, `constants.dart`, `profile_screen.dart`, `choose_any_one.dart`) are referenced **only inside commented-out code blocks**. |

---

## STEP 3 — Diff table

| Element | NEW (SA-00) | OLD (walk_through_screenn) | Change Type |
|---|---|---|---|
| Background colour | `#E8F4E0` mint, programmatic | Background image (`MyImgs.walkThroughBack2`) | **VISUAL + ASSET** (image dropped) |
| Background pattern | 3 soft circles (mint, programmatic) | Photo + 10-stop white gradient overlay | **VISUAL** |
| Logo asset | Reuse `MyImgs.fitHerLogo` (same as splash) | `MyImgs.logo3` | **ASSET** |
| Logo position | Centre of hero block, above headline | Top of screen, separated from button block by `Spacer` | **VISUAL** |
| Logo size | ~54px height | `Image.asset(..., scale: 3)` (size depends on asset px) | **VISUAL** |
| Headline text | `Built for every\nphase of you.` | `Welcome To FitHer!` | **COPY** |
| Headline style | 30 / w800 / `#1a3a22` / lh 1.15 | 28sp / w600 / `MyColors.textColor3` | **VISUAL + COPY** |
| Sub-copy text | `The first fitness platform designed around your hormonal cycle — live classes, nutrition, and AI insights.` | `Unleash your Inner Strength with us` | **COPY** |
| Sub-copy style | 15 / w400 / `#5a7258` / lh 1.6 / max-width 300 | 18sp / w500 / `MyColors.textColor3` | **VISUAL + COPY** |
| Get Started button | `#6DC55A` solid, white text, radius 14, full-width, 16px padding | `CustomButton` (green gradient default) | **VISUAL** |
| Get Started copy | `Get started` (lowercase 's') | `Get Started` (Title case) | **COPY** (minor) |
| Log In control | **Ghost button:** white bg, `#1a3a22` text, 1.5px `#C8E8BC` border, full-width | `CustomButton` (same green gradient) — visually identical to primary | **COMPONENT + VISUAL** (needs new variant or inline) |
| Log In copy | `I already have an account` | `Log In` | **COPY** |
| Spacing rhythm | 100/32/40 outer; 32 logo→headline; 12 headline→sub; 12 between buttons | 50.h top, Spacer, 230 fixed, 10.h, 20.h between buttons | **VISUAL** |
| Typography family | Plus Jakarta Sans (mockup) → Poppins (Flutter app font) | Poppins | **VISUAL** (no font swap needed) |
| Vertical layout | Hero centred, buttons pinned bottom | Bottom-anchored Column with internal 230px spacer | **VISUAL** (structural) |
| Status bar | Light bg requires `Brightness.dark` icons + `#E8F4E0` bg | Default (image edge-to-edge) | **BEHAVIORAL** (`SystemChrome` call) |
| Navigation — Get Started | (inferred, mockup wires `.btn-primary` to sign-up) | `Get.to(() => SignUpNewUser())` | **NO CHANGE** |
| Navigation — Log In | (inferred, mockup wires `.btn-ghost` to sign-in) | `Get.to(() => Login())` | **NO CHANGE** |

### Summary

| Metric | Value |
|---|---|
| Total elements compared | 17 |
| Total changes | 16 (only navigation handlers stay identical) |
| Changes by type | VISUAL × 11 · COPY × 6 · ASSET × 2 · COMPONENT × 1 · BEHAVIORAL × 1 (some elements counted in multiple buckets) |

**Top 3 most impactful changes**

1. **Background swap from photo to programmatic mint + circles** — eliminates `MyImgs.walkThroughBack2` asset dependency and gives the screen a far lighter, more brand-consistent feel. Also removes the 10-stop opacity gradient hack.
2. **Two-button hierarchy (primary green vs ghost outlined)** — the old screen treats both actions as equally weighted (both green gradient `CustomButton`s). The new design clearly elevates "Get started" and demotes "I already have an account" — meaningful UX shift for new-user funnel.
3. **Headline + sub-copy rewrite** — moves from generic fitness pep-talk (`Welcome To FitHer! / Unleash your Inner Strength`) to product-positioning (`Built for every phase of you / The first fitness platform designed around your hormonal cycle`). This is the brand-voice shift; copy review is worth a separate sign-off before build.

---

## STEP 4 — Flow redirection audit

### Q1. Where is `WelcomeScreen` (the 3-slide swipe walkthrough) currently invoked?

Three call sites import or invoke `WelcomeScreen`:

| File | Line | Code | Context |
|---|---:|---|---|
| `lib/UI/auth_module/splash.dart` | 2 (import), **71** | `Get.offAll(() => WelcomeScreen());` | Cold-launch when no token in SharedPreferences |
| `lib/data/api_provider/app_link_handler.dart` | 7 (import), **46** | `Get.offAll(() => WelcomeScreen());` | Trial deep-link handler (after `validateTrialToken`) |
| `lib/data/api_provider/app_link_handler.dart` | **55** | `Get.offAll(() => WelcomeScreen());` | Default deep-link fallback |

`welcom_screen.dart` itself contains two `Get.offAll(() => const WalkThroughScreen())` calls (lines 45, 160) for its own Skip + Finish buttons — these become unreachable once the redirects are flipped, but the file stays in place per founder instruction.

### Q2. Current navigation flow (new user, no token)

```
App launch
  └── SplashScreen (3-second timer + auth animations)
      └── _SplashScreenState.initState fires Timer
          └── share.getString(email|password|loginAsa) ALL null?
              ├── YES → Get.offAll(() => WelcomeScreen())   ← line 71
              │         └── 3-page swipe (Know Your Body / Move With Your Rhythm / Eat What Your Body Needs)
              │             └── Skip OR Finish → Get.offAll(() => WalkThroughScreen())
              │                 └── Get Started → SignUpNewUser
              │                 └── Log In → Login
              └── NO → AuthController.login() / signInUsingGoogle()
                       └── BottomBarScreen (home) — never sees welcome
```

### Q3. Proposed new flow

```
App launch
  └── SplashScreen
      └── share.getString(email|password|loginAsa) ALL null?
          ├── YES → Get.offAll(() => WalkThroughScreen())   ← redesigned
          │         └── Get Started → SignUpNewUser
          │         └── Log In → Login
          └── NO → AuthController.login() / signInUsingGoogle() → home
```

Slides removed from the path entirely. One fewer screen between cold launch and signup.

### Q4. Exact file + line where the redirect happens

**Primary:** `lib/UI/auth_module/splash.dart:71`
- Change `Get.offAll(() => WelcomeScreen());` → `Get.offAll(() => const WalkThroughScreen());`
- Replace import on line 2: `import 'package:fitness_zone_2/UI/auth_module/welcom_screen.dart';` → `import 'package:fitness_zone_2/UI/auth_module/walt_through/walk_through_screenn.dart';`

### Q5. Other places routing to `WelcomeScreen`?

Yes — **two more, both in `app_link_handler.dart`**:

- Line 46 (trial token branch): `Get.offAll(() => WelcomeScreen());` → `Get.offAll(() => const WalkThroughScreen());`
- Line 55 (default fallback): same change
- Replace import on line 7: `import '../../UI/auth_module/welcom_screen.dart';` → `import '../../UI/auth_module/walt_through/walk_through_screenn.dart';`

After these 3 redirects flip, `WelcomeScreen` is **fully orphaned** in production code paths — its file stays as a rollback artifact per scope.

### Q6. What does `WalkThroughScreen` route to after Get Started / Log In?

| Button | Current | After redesign |
|---|---|---|
| Get Started | `Get.to(() => SignUpNewUser())` (line 91) | **No change** — same target, same nav method |
| Log In | `Get.to(() => Login())` (line 100) | **No change** — same target |

Downstream sign-up / login flows are entirely untouched.

---

## STEP 5 — Migration safety

### Q1. Who currently sees `WalkThroughScreen`?

Confirmed from `splash.dart:65–94`: only when **all three** of `Constants.email`, `Constants.password`, `Constants.loginAsa` are missing from SharedPreferences. That's the cold-launch / first-install / post-logout state.

Logged-in users (any of those three present) trigger `AuthController.login()` or `signInUsingGoogle()` and go straight to home. They never see `WalkThroughScreen` in the normal flow.

There are also two AuthController paths that route to `WalkThroughScreen` directly (without going through Splash):
- `auth_controller.dart:192` — failed login (after a server `status:"0"` response with email present)
- `auth_controller.dart:636` — after account deletion (clears SharedPreferences then routes)

These are **existing paths** that already point to `WalkThroughScreen` — they keep working unchanged after the redesign.

### Q2. Side effects when shown

**Zero.** The current `WalkThroughScreen` has no `initState`, no controllers, no analytics, no SharedPreferences writes, no API calls, no permission requests. The redesign should preserve this — keep it pure UI.

### Q3. Per-cohort impact analysis

| Cohort | Today | After redesign + flow change | Risk |
|---|---|---|---|
| Existing logged-in users | Splash → home (skip welcome) | Splash → home (skip welcome) | **None** — path unchanged |
| Existing logged-out users (cold launch) | Splash → 3 slides → WalkThroughScreen | Splash → new WalkThroughScreen | None — visual change only |
| Brand-new install | Splash → 3 slides → WalkThroughScreen → SignUp | Splash → new WalkThroughScreen → SignUp | None — fewer screens |
| User mid-walkthrough at deploy time | On slide 2 of 3 with app foregrounded | On next cold launch goes to new WalkThroughScreen. State is **not persisted between slides** — no resume to recover. | None |
| Trial deep-link unauth | App link → 3 slides | App link → new WalkThroughScreen | None — visual change |
| Custom support deep-link | App link → SignUpNewUser(supporterId) | Unchanged | None |
| Just-deleted account | AuthController → existing WalkThroughScreen | AuthController → new WalkThroughScreen | None |
| Failed-login retry | AuthController → existing WalkThroughScreen | AuthController → new WalkThroughScreen | None |

### Q4. Mid-walkthrough users at deploy time?

`welcom_screen.dart` keeps no SharedPreferences progress state. A user on slide 2 with the app open at deploy time:
- If app stays in memory: continues seeing the OLD slides (binary already loaded — Flutter doesn't hot-swap on Play Store update). They can swipe to the end and hit Skip/Finish → land on new `WalkThroughScreen`.
- If app is killed/relaunched: cold launch → splash → new `WalkThroughScreen` directly.

Either path lands them safely.

### Q5. Migration verdict

**(a) Safe to direct replace.** No feature flag needed.

Reasoning:
- `WalkThroughScreen` has zero side effects today; the redesign should also have zero side effects. There's no behavioural change to A/B test.
- Only 3 redirect points to flip; all are in the auth-pre-login surface where a visual regression is recoverable via cold-launch + git revert without affecting any user data.
- Logged-in users are completely unaffected (separate code path).
- The `welcom_screen.dart` file stays in place as a rollback artifact.

**Rollback recipe if needed:** `git revert` the redirect commit. The `welcom_screen.dart` widget is intact, slides will reappear, and the new `WalkThroughScreen` is still callable from the post-slide navigation.

---

## STEP 6 — Technical debt flags (NOT to fix in this work)

In `walk_through_screenn.dart`:

| # | Item | Severity |
|---|---|---|
| 1 | **6 unused imports** — `questionair_screen.dart`, `sign_up_screen.dart`, `auth_controller.dart`, `constants.dart`, `profile_screen.dart`, `choose_any_one.dart` (referenced only in commented-out blocks) | low |
| 2 | **Two large blocks of commented-out code** (lines 102–126: PCOS button + RichText "Already have an account?" link) — should be removed in cleanup sprint | low |
| 3 | **Folder typo:** `walt_through/` should be `walk_through/` | low (rename later) |
| 4 | **File typo:** `walk_through_screenn.dart` (double `n`) | low |
| 5 | **Magic numbers:** `230` (fixed SizedBox), `50.h`, `10.h`, `20.h`, `28.sp`, `18.sp` — should reference theme tokens once Phase 3 lands | medium |
| 6 | **Hardcoded asset name** `MyImgs.walkThroughBack2` — the `2` suffix implies an unused `walkThroughBack` (or `1`) sibling | low |
| 7 | **No `Semantics` labels** on either button — accessibility gap | medium |
| 8 | **10-stop opacity gradient** is over-engineered (could be a single `Container` with `BoxDecoration` color stop) | low |
| 9 | **`CustomButton` used for both primary and secondary** — no ghost/outlined variant exists in the design system. Phase 2 theme work added one in `app_components.dart` but it's not wired here. | medium |

In other files (related to this audit, NOT in scope to fix):

| # | File | Issue |
|---|---|---|
| 10 | `lib/UI/dashboard_module/profile_screen/profile_screen.dart:26-27` | Parameter named `fromWelcomeScreen` but the import (line 18) is for **WalkThroughScreen**, not WelcomeScreen. Misleading name; rename to `fromWalkThroughScreen` later. Used 6 times in the file. |
| 11 | `splash.dart:71` and `app_link_handler.dart:46,55` | Routing references `WelcomeScreen` (the 3-slide swipe). After this redesign these become orphaned; flip them as part of this work. |
| 12 | `welcom_screen.dart` | File preserved for rollback per scope, but becomes dead code after redirects flip. Mark for deletion in a future cleanup. |

---

## STEP 7 — Implementation proposal

### 1. File path strategy

**Replace `walk_through_screenn.dart` in place.** Same path, same class name `WalkThroughScreen`, same constructor signature `const WalkThroughScreen({Key? key})`. Internal widget tree fully rewritten.

Keeps existing call sites working without touching them:
- `auth_controller.dart:192` (failed login) — keeps working
- `auth_controller.dart:636` (account deletion) — keeps working
- New routes from splash + app_link_handler (added in this sprint) — pick up the new design automatically

### 2. Flow change — exact edits

**3 files, 5 edits total.**

`lib/UI/auth_module/splash.dart`
- Line 2: replace import
  - **From:** `import 'package:fitness_zone_2/UI/auth_module/welcom_screen.dart';`
  - **To:** `import 'package:fitness_zone_2/UI/auth_module/walt_through/walk_through_screenn.dart';`
- Line 71: replace navigation
  - **From:** `Get.offAll(() => WelcomeScreen());`
  - **To:** `Get.offAll(() => const WalkThroughScreen());`

`lib/data/api_provider/app_link_handler.dart`
- Line 7: replace import
  - **From:** `import '../../UI/auth_module/welcom_screen.dart';`
  - **To:** `import '../../UI/auth_module/walt_through/walk_through_screenn.dart';`
- Line 46: replace navigation
  - **From:** `Get.offAll(() => WelcomeScreen());`
  - **To:** `Get.offAll(() => const WalkThroughScreen());`
- Line 55: replace navigation
  - **From:** `Get.offAll(() => WelcomeScreen());`
  - **To:** `Get.offAll(() => const WalkThroughScreen());`

`lib/UI/auth_module/welcom_screen.dart` — **untouched, preserved for rollback per scope.**

### 3. New assets needed

**None.** Specifically:
- **Logo:** reuse `MyImgs.fitHerLogo` (already used by `splash.dart:316` for the splash logo).
- **Background:** programmatic — `Stack` with positioned `Container`s for the 3 mint circles, mirroring the pattern in `splash.dart`'s `_buildCircles()`.
- **Font:** keep Poppins. Plus Jakarta Sans (mockup font) maps cleanly — no new asset needed.
- **`pubspec.yaml`:** **no changes.**
- **No new images, no new icons, no new fonts.**

### 4. Code change summary

| File | Change | Approx. lines touched |
|---|---|---|
| `walk_through_screenn.dart` | Full widget rewrite (preserve class signature + nav handlers) | ~140 → ~200 |
| `splash.dart` | 1 import swap + 1 line at line 71 | 2 |
| `app_link_handler.dart` | 1 import swap + 2 lines at 46, 55 | 3 |
| `welcom_screen.dart` | **No change** (preserved for rollback) | 0 |
| `pubspec.yaml` | **No change** | 0 |

### 5. Estimated effort

| Task | Time |
|---|---|
| `walk_through_screenn.dart` widget rewrite (mint bg + circles + Poppins, 2-button stack) | ~2.5 h |
| 3 routing edits | ~10 min |
| Manual smoke test (cold launch, deep link, logout, deletion) | ~30 min |
| **Total** | **~3 h** |

### 6. Test plan

- [ ] **Cold launch on fresh install** (uninstall app first to clear SharedPreferences) → new `WalkThroughScreen` appears (mint bg, "Built for every phase of you.", green Get Started + outlined "I already have an account"). NO 3-slide swipe should appear.
- [ ] **Existing logged-in user** (simulator with prior session) → goes straight to `BottomBarScreen` / home, never sees welcome.
- [ ] **Tap "Get started"** → navigates to `SignUpNewUser`. Existing flow.
- [ ] **Tap "I already have an account"** → navigates to `Login`. Existing flow.
- [ ] **System back button from `WalkThroughScreen`** → app exits (Android). iOS: no system back, expected.
- [ ] **Trial deep-link** without auth (e.g. `https://…/trial?token=…`) → new `WalkThroughScreen`, NOT slides. Trial token validation still fires (HomeController.validateTrialToken).
- [ ] **Custom-support deep-link** → still routes to `SignUpNewUser(supporterId: …)`, unchanged.
- [ ] **Manual logout** from settings → AuthController.deleteUser() path → new `WalkThroughScreen`. (Existing path, no flow change, but verify it still renders.)
- [ ] **Failed login** with valid email but wrong password → AuthController response `status:"0"` → new `WalkThroughScreen`. (Existing path, verify rendering.)
- [ ] **Status bar:** dark icons on light mint bg, no white-on-white text.
- [ ] **Small phone (e.g. iPhone SE / 5.5" Android):** hero block doesn't get squeezed under the status bar; buttons don't crowd the bottom-safe-area inset.
- [ ] **Large phone (e.g. iPhone Pro Max):** hero block stays vertically centred, buttons stay close to bottom (don't float into the middle).

### 7. Rollback plan

- **Code:** `git revert` the commit. `welcom_screen.dart` is intact and route-reachable again.
- **Suggested commit split** to make rollback granular:
  - **Commit 1** — `walk_through_screenn.dart` rewrite only. Visual change. No flow change yet (`welcom_screen.dart` slides still in flow → users still see slides → then new `WalkThroughScreen`). Lets you review the visual without touching routing.
  - **Commit 2** — flip the 3 redirects in `splash.dart` + `app_link_handler.dart`. Pure routing change, easy to revert in isolation if you decide to keep the slides longer.
- **No DB / no backend / no SharedPreferences key changes** — rollback is purely a code revert. Zero migration work either direction.

---

## File location note

This audit lives at `lib/docs/sprint1_welcome_audit.md` per your instruction. The existing project-level audits (architecture, screen-map, design-system, phase-tracker) live at the project-root `docs/` folder. If you want a single home for audits, consider moving this to `docs/` later — `lib/docs/` is non-standard for a Flutter project (`lib/` is conventionally Dart code only).
