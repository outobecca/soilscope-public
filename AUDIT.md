# SoilScope — Full Audit

**Date:** 13 Nov 2026
**Build audited:** `master` @ `0b140f5`, Flutter 3.47.9 / Dart 3.13.7
**Scope:** whole repository — simulation core, state layer, UI, localization, web/PWA packaging, CI, tests, repo hygiene.
**Lens:** mobile and web usability, in that order of emphasis.

---

## 0. TL;DR — the six findings that matter

1. **The app is desktop-first wearing a mobile layout.** There is one breakpoint (600 px) and two 320 px sidebars. Between 600 and 1024 px — every tablet in portrait — the canvas is left with ~128 px. Phones get full-width overlay drawers, but the floating control layer (20+ actions, 28–36 px targets, 8.5–10 px labels) is unchanged.
2. **On web there is no isolate.** `kIsWeb` short-circuits the isolate manager and the entire simulation engine runs in the UI thread on a 200 ms timer (`simulation_isolate.dart:148-155, 188-215`). Combined with `preCalculateTimeline` (720 full engine ticks — **measured at 967 ms on this desktop CPU**, so several seconds on a phone), the "Calculate 30 days" button is a visible freeze on web.
3. **Two state bugs make the scenario flow unreliable.** `loadScenario()` swaps the profile but keeps `timeElapsed`, `plants`, and the old history (`simulation_provider.dart:714`), so starting a second scenario inherits the first one's clock. `hasSavedState()` returns `true` on a fresh install because the default profile is already in `_history` (`:645-650`), so "Resume last session" always looks available.
4. **A repeating `AnimationController` runs forever, on every frame, whether or not the tutorial is open** (`tutorial_overlay_widget.dart:29`, mounted unconditionally at `main.dart:553`). The widget is always in the tree, so the app never idles at the scheduler level — a direct mobile battery cost.
5. **Accessibility is effectively absent.** Zero `Semantics` widgets in 60k LOC, no text-scale support, 8.5 px labels, colour-only state encoding, and the Flame canvas — where the science actually happens — has no accessible equivalent.
6. **Localization is 99 % done and 1 % bypassed.** Both ARB files have exactly 1302 aligned keys, but ~39 hardcoded Finnish strings sit in the most visible places: the timeline header ("AIKAJANA (SIRTOLA)", with three A's — a typo for "REAALIAIKA"), the gamification level badge ("TASO 3"), all four buff labels, and the whole Logic Lab function palette.

The good news is that the foundations are stronger than the UI on top of them: `flutter analyze` is clean, all 84 tests pass, the solvers are cleanly separated, and the scientific vocabulary is coherent. Most of the work below is *interface and packaging*, not a rewrite.

---

## 1. Baseline verified

| Check | Command | Result |
|---|---|---|
| Static analysis | `flutter analyze --no-pub` | **No issues found** (4.3 s) |
| Test suite | `flutter test --no-pub` | **84 tests, all passed** (10 s, 24 files) |
| Code size | `wc -l` on `lib` | 60,126 hand-written LOC; 65,521 incl. generated (199 files) |
| Localization | ARB key diff | 1302 keys in `en` and `fi`, 0 missing, 0 extra, 20 identical values (proper nouns) |
| Generated payload | probe test | 10,133 bytes for a 3-layer profile + 1 plant (history excluded from JSON) |
| Engine cost | probe test | 720 × 1 h ticks = **967 ms** (1.34 ms/tick); 2 s tick = 0.08 ms |
| Web artifact | `du -sh build/web` | **48 MB** total; `main.dart.js` 4.1 MB; `canvaskit/` 42 MB |

The probe test was temporary and has been removed.

---

## 2. Architecture snapshot

```
lib/
  core/        constants, theme, periodic table, CPK colours
  domain/      models (freezed), 18 solvers, logic-lab evaluator, actions
  presentation/
    screens/   5 routes (selection, simulation, science, logic lab, builder)
    widgets/   ~120 widgets; game/ has 90 Flame components
    providers/ 11 Riverpod providers
  l10n/        generated en/fi localizations (1302 keys)
```

Strengths worth preserving:

- Solver boundaries are clean (`hydrology`, `chemistry`, `nutrient`, `gas`, `plant/*`, `aggregation`, `mycorrhiza`, `scoring`).
- `SimulationConstants` centralizes magic numbers — rare and valuable.
- `SimulationActions` gives functional updates instead of scattered mutation.
- Freezed models keep state immutable and JSON-able.
- The hydrology solver already computes an **adaptive sub-step from an explicit-diffusion stability criterion** (`hydrology_solver.dart:29-41`) — that is more rigour than most simulators at this stage.

The main structural liability is that the *screen* grew as one 560-line `Stack` with 10 absolutely positioned layers (`main.dart:380-560`), while state logic sits in an 832-line notifier. Both are doing too many jobs.

---

## 3. Findings

Severity: **P0** = wrong behaviour / blocks the core flow, **P1** = serious usability or performance, **P2** = quality, **P3** = polish.

### A. Correctness

#### A1 — Switching scenarios keeps the previous run's clock and plants · P0
`lib/presentation/providers/simulation_provider.dart:714`

```dart
void loadScenario(Scenario scenario) {
  state = state.copyWith(
    currentScenario: scenario,
    profile: scenario.initialProfile,
  );
  _syncIsolate();
}
```

`timeElapsed`, `plants`, `score`, `precipitation` and `_history` all survive. Consequences: the new scenario starts at "Day 12" of the old one, plants carry over with the previous root system and biomass, and the scrubber can mix the two runs. On the selection screen the user has no indication this happened.

**Fix:** reset the whole simulation on load — build a fresh `BiophysicalState` from the scenario (clock 0, one seedling, empty history), clear `_history`, then `_syncIsolate()`. Add a test that asserts `timeElapsed == 0` after loading a second scenario.

#### A2 — "Resume last session" is always enabled · P0
`simulation_provider.dart:645-650`

```dart
final prefs = await SharedPreferences.getInstance();
return prefs.containsKey(_stateKey) || _history.isNotEmpty;
```

`build()` seeds `_history` with the default profile (lines 188-190), and reading the notifier instantiates it. So on a clean install `_history.isNotEmpty` is `true` before the user has run anything. `loadLastState()` then returns `true` via the same check (`:680`) and navigates to a blank default simulation. The resume card looks functional and isn't.

**Fix:** track an explicit "has a real session" flag (e.g. a `lastSessionAt` timestamp written by `_saveState`), and only fall back to `_history` if `_history.length > 1`. Then the locked state in `scenario_selection_screen.dart` finally means something.

#### A3 — Pre-calculation is fire-and-forget · P0
`scenario_builder_screen.dart:191` calls `preCalculateTimeline(...)` without `await`, then immediately pushes `/simulation`. Meanwhile `preCalculateTimeline` has set `isScrubbing = true`, stopped the isolate and cleared nothing until `compute` returns. On web `compute` executes on the UI thread, so the push happens against a frozen frame, and the simulation screen mounts with `isScrubbing`, possibly empty history and `isRunning = false`. There is no progress indicator, no cancel, and no guard against a second tap.

**Fix:** make the button `async`, show a modal progress state, `await` the pre-calculation, then navigate. Add a cancel token. On web, chunk the loop (`await Future.delayed(Duration.zero)` every N ticks) or precompute on a Worker; `compute` does not give you a background thread on Flutter web.

#### A4 — Isolate init failure leaves a permanent splash · P1
`_initIsolate()` (`simulation_provider.dart:243`) awaits `_isolateManager.init()` with no `try/catch`. If `Isolate.spawn` throws, `isInitializing` is never set to false and `MainSimulationScreen` renders the dark "VALMISTELLAAN SIMULAATIOTA…" screen forever (`main.dart:369`). The only escape is force-quitting.

**Fix:** wrap init in `try/catch/finally`; on failure set `isInitializing = false` and surface a retry snackbar/dialog with the error. Also add a watchdog timeout.

#### A5 — Scenario builder's default description is the wrong string · P2
`scenario_builder_screen.dart:54`

```dart
if (_desc.isEmpty) _desc = l10n.resumeLastSessionDesc;
```

A new scenario is created with the "resume your last session" description. Likely a copy-paste from the resume card. Use a dedicated "custom scenario" description.

#### A6 — Logic Lab mutates state and writes to the simulation during `build()` · P1
`logic_lab_screen.dart:564`

```dart
_graph = LogicEvaluator.evaluate(_graph, simulationState);
for (final node in _graph.nodes) { ... Future.microtask(() => setPrecipitation(node.value)); }
```

A `build()` that (a) reassigns a field and (b) schedules a simulation mutation is a feedback loop waiting to happen: any rebuild from an unrelated provider re-applies irrigation. It also means panning/dragging nodes can silently change the weather. Move evaluation into a provider/`didChangeDependencies` with a debounce, and require an explicit "apply to simulation" action for output nodes.

### B. Mobile usability

#### B1 — Tablets fall into the desktop layout · P1
`app_theme.dart:7` defines a single breakpoint at 600 px; `main.dart:346` uses `width < 600` for mobile. A 768–1024 px tablet therefore gets two fixed 320 px sidebars (`main.dart:128, 202`): 640 px of chrome. In landscape (1024) that is 62 % of the screen. There is no orientation handling anywhere (`OrientationBuilder` count: 0).

**Fix:** three tiers —
- **compact** `<600`: full-screen drawers (as today).
- **medium** `600–1199`: sidebars become overlay drawers or a single bottom sheet; canvas keeps ≥60 % width.
- **expanded** `≥1200`: permanent sidebars (today's behaviour).
Test at 768×1024 and 1024×768.

#### B2 — Bottom controls ignore the safe area · P1
`main.dart:450` (`bottom: 120`) and `:458` (`bottom: 16`) place the timeline and the quick-action bar relative to the physical screen edge, without `SafeArea`. On iPhones with a home indicator and Android gesture-nav devices these sit inside the system gesture region, where swipes are intercepted. Every other overlay in the file is wrapped in `SafeArea`.

**Fix:** wrap both `Positioned` children in `SafeArea(top: false)` or offset by `MediaQuery.viewPadding.bottom`.

#### B3 — Fixed-size dialogs overflow on phones · P1
- `hud_dashboard.dart:150` — `SizedBox(width: 500, height: 600)` inside an `AlertDialog`.
- `flutter_quick_actions.dart:494` — `400 × 500` event log.
- `action_bar.dart:167` — `400 × 500` (file is unreferenced, see F1).

On a 390 px-wide phone the first dialog is wider than the screen before dialog insets; `AlertDialog` will clamp/overflow and the content becomes unreachable. Dialogs must be constraint-driven, not pixel-driven.

**Fix:** `ConstrainedBox(maxWidth: 560)` + `AlertDialog(scrollable: true)` + `MediaQuery.sizeOf(context)` clamp. One shared `AppDialog` helper would remove the duplication.

#### B4 — Logic Lab is unusable on a phone · P1
`logic_lab_screen.dart` positions nodes at absolute coordinates up to `Offset(720, 280)` (`:103`) in a plain `Stack` with no `InteractiveViewer`, no pan, no zoom, and hard-codes a 320 px palette drawer (`:687`). On a 390 px screen more than half of every example is off-screen with no way to reach it.

**Fix:** wrap the graph in an `InteractiveViewer` (pan + pinch-zoom, `constrained: false`), start at `min(1, width / graphWidth)`, and make the palette a bottom sheet on compact screens. This is also the single biggest "wow" improvement available on mobile.

#### B5 — XP bar is sized from the screen, not its parent · P1
`gamification_bar.dart:217`

```dart
width: MediaQuery.of(context).size.width * xpProgress * 0.5,
```

Inside an `Expanded` in the top bar, the available width is roughly screen − 200 px (buttons). At `xpProgress = 1` the bar paints ~195 px on a 390 px phone into a slot of ~100 px, overdrawing the mission button. Use `FractionallySizedBox`/`LinearProgressIndicator` so it is constraint-driven.

#### B6 — The action bar is an inventory problem · P1
`flutter_quick_actions.dart` renders **20 controls** in one horizontally scrolling pill: play, speed, weather, rain, tillage, cover crop, fertilizer, timeline, event log, microscope, science reference, logic lab, observation cycle, flow toggle, schematic toggle, scenario builder, then the element row (N, P, K, Ca, Mg, S, C, O, Fe, periodic table). On a 390 px screen about 7 are visible; the rest are undiscoverable by scroll affordance alone. Targets are 36 px (20 px icon + 8 px padding, `:344`) and element buttons are **28 px** (`:418, :471`) — both below the 48 dp Material minimum. Every one has a tooltip, which is a desktop idiom that does nothing on touch.

**Fix (highest ROI in the app):**
1. Keep 5 primary actions visible: **play/pause, speed, timeline, inspect, more**.
2. Move simulation interventions (rain, tillage, cover crop, fertilizer) into a "Manage" sheet.
3. Move navigation (science reference, logic lab, builder) into the "more" menu or a bottom nav.
4. Element selection belongs with the inspector, not the global toolbar.
5. Make every touch target ≥48 dp and add a pressed state that does not rely on tooltips.

#### B7 — Typography is below mobile legibility thresholds · P1
Labels are set at 8.5, 9 and 10 px throughout (`gamification_bar.dart:719`, `hud_dashboard.dart:233, 520`, `hover_tooltip.dart:126`) inside fixed-width boxes (`SizedBox(width: 52)` for index values). There is no `textScaler` handling and no adaptive sizing, so OS-level font scaling either does nothing (explicit `fontSize` still scales with `textScaleFactor` by default in Flutter, but the fixed boxes do not) or breaks the row.

**Fix:** define a type scale (minimum 12 px for secondary, 14 px for body), replace fixed widths with `Flexible`, and test at 200 % text scale. Minimum body text on mobile should be 14 px.

#### B8 — Onboarding teaches the desktop metaphor on the wrong screen · P1
The tour is a 7-step modal (`tutorial_provider.dart`) that starts only after entering the simulation (`main.dart:100`) and whose spotlight targets are panels. It never teaches the three gestures the canvas actually needs: **drag to pan, pinch to zoom, tap a hotspot to inspect**. A first-time mobile user is dropped into a full-screen canvas with no visible affordance.

**Fix:** a 3-card first-run sheet on the selection screen (what this is → pan/zoom → tap to inspect), then let the existing tour run in context. Make it skippable once, remembered.

### C. Web usability & performance

#### C1 — The web build runs the whole simulation on the UI thread · P0 (web)
`simulation_isolate.dart:148-155`

```dart
Future<void> init() async {
  if (kIsWeb || _initialized) {
    if (kIsWeb) debugPrint('... Running in Web Mode (Main Thread)');
    return;
  }
```

`_runWebLoop` then ticks `SimulationEngine.tick` every 200 ms on the same thread that renders. Measured 0.08 ms per 2 s tick on desktop, so an idle tick is cheap; but `timeScale` up to 10 and 1 h ticks in pre-calculation are not. Any expensive tick is a dropped frame, and nothing protects the frame budget.

**Fix:** on web, either (a) move the engine to a `Worker` (compile-time shared code via `dart:js_interop`), or (b) at minimum run the tick on an idle callback with a budget check and skip/downscale work when `SchedulerBinding.instance.currentFrameTimeStamp` shows we are behind. Also stop pretending the manager is an isolate on web — the naming actively misleads.

#### C2 — 30-day pre-calculation blocks the UI · P0 (web)
Measured **967 ms for 720 ticks** on this machine. Mid-range phones are typically 3–5× slower, and on web it is on the UI thread. The UI offers no progress, no cancel, and the button can be tapped repeatedly.

**Fix:** progress dialog with cancel; chunk the work; cap `days` (180 days ≈ 4,320 ticks ≈ 6 s desktop / 20–30 s phone — probably too much); move to a Worker or precompute scenarios offline and ship them as assets.

#### C3 — The tutorial ticker never stops · P1
`tutorial_overlay_widget.dart:21-29` creates an `AnimationController` and calls `..repeat()` in `initState`. The widget is mounted for the entire life of the simulation screen (`main.dart:553`), and the controller is only *used* when `isVisible`. An active `Ticker` schedules frame callbacks continuously, so the app requests 60 fps forever — on battery, in a paused simulation, on a page the user walked away from.

**Fix:** start/stop `repeat()` in a `ref.listen` on `tutorialState.isVisible` (or `AnimatedBuilder(animation: controller)` only when visible and `controller.stop()` in `didChangeDependencies`). Same for the game: pause the `GameWidget` when `isRunning == false` and the tab is hidden.

#### C4 — `BackdropFilter` blurs on floating panels · P2
`hover_tooltip.dart:53` and `microscope_hud_controller.dart` apply 12–16 px sigma blurs to panels that sit above a continuously animating canvas. Each is a full-screen offscreen pass on some GPUs. This is a known cost on low-end Android; I did not profile on device, so treat it as a risk to measure, not a proven regression.

**Fix:** replace with a translucent solid + 1 px border on compact devices (`Theme.of(context).platform` / `MediaQuery.devicePixelRatio` is a crude proxy), keep blur for wide screens.

#### C5 — Deep links and refresh always land on the selection screen · P2
`main.dart:50-56` uses `initialRoute: '/'` with a named-route table. Flutter web honours `defaultRouteName` only when `initialRoute` is unset, so `/simulation` in the address bar still opens the menu. Users cannot share a scenario link, and a hard refresh during a run loses the screen (the resume path is itself broken — A2).

**Fix:** migrate to `go_router` (or set `initialRoute` from `WidgetsBinding.instance.platformDispatcher.defaultRouteName`) and put the scenario id in the URL. Add `usePathUrlStrategy` only if the host supports SPA fallback; GitHub Pages does not, so hash URLs are the correct choice here — but they need to be *used*.

#### C6 — PWA metadata is still the Flutter template · P2
`web/manifest.json`: name/short_name `soilscope`, description "A new Flutter project.", `background_color`/`theme_color` `#0175C2` (Flutter blue, not the Nordic palette), `orientation: "portrait-primary"`. `web/index.html` `<title>soilscope</title>`. Android `android:label="soilscope"`.

For a landscape-first soil column, locking an installed PWA to portrait is actively harmful. Fix the name casing ("SoilScope"), the description, the theme colour (`#059669`), and either remove the orientation lock or use `"any"`. Add `<meta name="theme-color">`, an OG/Twitter card, and `description` with the real one-liner.

#### C7 — 48 MB web artifact, 4.1 MB JS · P2
`build/web` is 48 MB (42 MB CanvasKit, 4.1 MB `main.dart.js`). CanvasKit is normally fetched from `gstatic` at runtime (and the CSP allows it), so the shipped 42 MB is not necessarily downloaded — but the 4.1 MB JS is, and on a 3G/4G phone that is a multi-second first paint with no loading affordance beyond Flutter's default.

**Fix:** `flutter build web --wasm` evaluation, deferred component loading, and a real `flutter_bootstrap.js` loader with a branded splash and progress. Measure LCP on a throttled profile before/after; don't optimize blind.

#### C8 — Whole-provider watch rebuilds the control panel at 5 Hz · P2
`control_panel_section.dart:19` does `ref.watch(simulationProvider)` — the entire 10 KB state — and rebuilds ~30 `SliderControl`s on every isolate tick (every 200 ms). Sliders the user is dragging are rebuilt from underneath, and `updateLayer` additionally defers through `Future.microtask` (`simulation_provider.dart:454`), so the thumb can lag the finger.

**Fix:** select only the selected layer (`select((s) => s.profile.layers.firstWhere(...))`) and split the panel into leaf consumers. Apply layer updates synchronously (the microtask adds a frame of latency for no benefit).

#### C9 — Debug logging in hot paths · P2
79 `debugPrint` calls, including one **per tick on web** (`simulation_isolate.dart:193`) and several in `FlameSimulationView.build`. `debugPrint` still executes in release builds. At 5 Hz with string interpolation this is measurable noise on low-end devices and floods the browser console.

**Fix:** guard with `if (kDebugMode)`, or use a `Logger` with a level that compiles out. Delete the `[MainSimulationScreen] build:` traces that log on every rebuild.

### D. Accessibility

#### D1 — No semantics at all · P1
`Semantics(` / `MergeSemantics` / `ExcludeSemantics` occurrences across `lib`: **0**. Flutter gives some widgets free labels (buttons with tooltips), but the custom-painted panels, health orbs, index chips and the entire Flame canvas are silent to TalkBack/VoiceOver.

**Fix:** wrap the health meters in `Semantics(label: ..., value: ...)`; give the four index chips a merged label ("Moisture 32 percent, pH 6.4, nitrate 15, temperature 12 degrees"); mark decorative canvas layers `ExcludeSemantics`.

#### D2 — Colour-only encoding · P1
pH, redox state, nutrient status and scenario health are encoded exclusively by colour (`_getpHColor`, `_getTeaStatus`, element CPK colours). Around 8 % of men have a colour-vision deficiency, and this is a *teaching* app where the colour is the message.

**Fix:** pair every colour with an icon, a label, or a pattern (the redox state already has an icon — extend that). Ensure the CPK element circles carry the symbol as text (they do — good) and never rely on hue alone.

#### D3 — Small text and no scaling support · P1
See B7. At 8.5–10 px, even 200 % scaling yields 17–20 px inside fixed-width boxes built for 10 px, so the layout breaks rather than adapting.

#### D4 — The canvas has no accessible equivalent · P2
Everything scientifically interesting happens in `GameWidget`. A screen-reader user gets the surrounding chrome and nothing else. For an educational product this is the largest inclusion gap.

**Fix:** add a "Data view" toggle that renders the same soil profile as a labelled table (layer, depth, θ, pH, N, microbial biomass). It doubles as a print/export view and is cheap to build from the models.

#### D5 — Contrast of the smallest labels · P2
`Colors.grey.shade500` on `#0F172A` is ~5.3:1 — fine at 14 px, marginal at 8.5 px. `Colors.white38` (used for inactive magnification badges) is ~3.3:1, below AA for small text. Re-check the dark-theme secondary text as a set, not case by case.

### E. Localization

#### E1 — 39 hardcoded strings tunnel under a complete l10n layer · P1
The ARB files are exemplary (1302 keys, en/fi in lockstep). Then the most visible strings bypass them:

| Location | String |
|---|---|
| `hud_dashboard.dart:233` | `'AIKAJANA (SIRTOLA)' : 'REAAALIAIKA'` — hardcoded **and** misspelled ("REAALIAIKA") |
| `gamification_bar.dart:719` | `'TASO $currentLevel'` ("LEVEL") |
| `gamification_bar.dart:628` | `"ERINOMAINEN" / "KOHTALAINEN" / "KRIITTINEN"` |
| `gamification_bar.dart:335, 349, 357` | `KUIVUUS`, `PEITEKASVI`, `SYMBIOOSI`, `SADE` (buffs) |
| `flutter_quick_actions.dart` / `gamification_bar.dart` | `'OHJE'` fallbacks |
| `periodic_table_widget.dart:252, 268` | inline `isFi ? ... : ...` ternaries |
| `function_palette.dart:34-68` | entire Logic Lab palette in Finnish only |

So an English user sees a Finnish timeline header, Finnish level badge and Finnish buff chips — in the exact place gamification is supposed to land.

**Fix:** move each to the ARB (5 new keys), fix the typo, and add a CI grep that fails on Finnish characters inside `lib/presentation` outside `l10n`. That guard is ~10 lines and prevents the whole class of regression.

#### E2 — Locale is forced to English on first run · P2
`locale_provider.dart:16` returns `const Locale('en')` and only then loads a persisted choice; the system locale is never consulted. A Finnish student opens a Finnish thesis project in English.

**Fix:** `WidgetsBinding.instance.platformDispatcher.locale`, falling back to `en` when unsupported.

#### E3 — README is Finnish-only and partly stale · P3
It says 75 tests (now 84), and it documents features whose widget files are unreferenced (`organic_plant_painter`, `xai_dashboard_view`, `soil_solver`, `coupling_matrix`). A bilingual README (or an English section up top) would widen the audience the project explicitly asks for ("common ground for scientific debate").

### F. Code health & repository

#### F1 — 21 non-generated files are unreferenced · P2
`action_bar`, `ai_advisor_panel`, `coupling_matrix`, `crosshairs_component`, `diurnal_activity_mixin`, `elements_informatics_view`, `event_notification_component`, `hex_grid_component`, `logic_lab_view`, `magnifier_provider`, `mission_panel`, `organic_plant_painter`, `plant_info_engine`, `recommendation`, `scaling_content_mixin`, `simulation_state_mixin`, `soil_bounds_mixin`, `soil_layer_info_engine`, `soil_solver`, `soil_texture_informatics_view`, `xai_dashboard_view`.

Some may be referenced dynamically through provider names, but `soil_solver` (a whole unused solver), `organic_plant_painter` (a README feature that is never mounted) and `coupling_matrix` are almost certainly dead. Dead code inflates the mental model of a 60k-LOC project more than it costs bytes.

**Fix:** delete or move to `experimental/`; if intentional, document why in a file header.

#### F2 — Three files carry a disproportionate share · P2
`animated_plant_component.dart` 2,405 lines, `hud_dashboard.dart` 918, `simulation_provider.dart` 832, `logic_lab_screen.dart` 812. The plant component mixes growth, rendering, morphing and root drawing; the provider mixes isolate lifecycle, persistence, simulation actions and UI merging. These are the files that make a first contribution hard.

**Fix:** extract the provider's concerns into `SimulationRuntime` (isolate lifecycle), `SimulationPersistence` (secure storage/migration) and `SimulationCommands` (user actions). Extract the plant painter from its animation logic.

#### F3 — Manual state merging is brittle · P2
`_mergeSimulationState` (`simulation_provider.dart:293`) re-implements "which side owns which field" by hand, with a comment saying the main thread is the source of truth. Every new field added to `BiophysicalState` silently defaults to isolate-owned until someone remembers to add it here. That is how A1-type bugs happen.

**Fix:** declare an explicit `controlFields` set, or split the model into `SimulationState` (engine-owned) + `SessionControls` (UI-owned) and compose them for display. A test that asserts every field of `BiophysicalState` is classified would catch drift.

#### F4 — Redundant work on every tick · P3
- `ScoringSolver.solve` is called inside `SimulationEngine.tick` **and again** in the provider with a different `dt` (`simulation_provider.dart:256`). `ScoringSolver` ignores `dt`, so it is pure duplicate work — harmless but confusing, and it implies a time-dependent score that does not exist.
- `history: List.unmodifiable(_history)` copies 500 references on every tick (`:272`), and `displayedSimulationState` linearly scans the list on every read.
- `_validateBiophysicalState` walks every layer and plant after every sub-step.

None is fatal at 3 layers; all three scale badly once the model grows (and the README says the plan is more complexity). Cheap fixes: recompute the score once, keep the history as an immutable `List` swapped only on append, binary-search the scrub time.

#### F5 — Verification is thin where it matters · P2
24 test files for 178 source files: the solvers are reasonably covered (hydrology, chemistry, nutrients, gas, plant), but there is **no** test for the simulation provider's real behaviour — the one present is a placeholder:

```dart
test('Migration from SharedPreferences to FlutterSecureStorage', () async {
  // ... documents the logic here.
  expect(true, isTrue);
});
```

That is the exact area where A1/A2 live. There are also no golden/screenshot tests for a UI this custom.

**Fix:** add tests for (a) scenario switch resets state, (b) resume availability, (c) pre-calculation produces N snapshots, (d) a 200-tick mass-balance invariant (N and water conserved within tolerance). Add one golden per key screen at 390×844 and 1024×768.

#### F6 — CI never runs the analyzer; repo carries 8 MB of scratch · P2
`.github/workflows/deploy_web.yml` runs `flutter test` then builds. `flutter analyze` — the check that actually catches the dead imports and typos in this codebase — is not run. It passes today; a gate keeps it passing.

The root also commits `.mfckt-index.db` (3.9 MB), `.mfckt-index.json` (4.4 MB), `analysis.txt`, `verify.py`, `fix_tests.py`, `patch_magnifier.py`, `verify_duplication.py`, `animation_design.json`, `physics_bindings.json`, `nitrogen_cycle.json`. None are app inputs. This is 8 MB of clone weight and a confusing first impression for an open-source research project.

**Fix:** add `flutter analyze --fatal-infos` to CI, delete the index files, move the scripts to `tool/` or `scripts/` if they still earn their keep.

#### F7 — Packaging metadata is still template · P3
`pubspec.yaml` description: "A new Flutter project."; version `0.1.0+1` with no `repository`/`homepage`/`issue_tracker`; Android label lowercase `soilscope`. For a project inviting scientific collaborators, those are the first things they see.

### G. Scientific model

#### G1 — The adaptive sub-step is good; the step cap can defeat it · P2
`hydrology_solver.dart:29-41` derives a CFL-like `safeDt` and then:

```dart
double subStep = safeDt.clamp(0.1, 30.0);
int steps = (dt / subStep).ceil().clamp(1, 2000);
double actualDt = dt / steps;
```

With `dt = 3600` (pre-calculation) and a wet, conductive soil, `subStep` can legitimately be < 0.1 s; the 2000-step cap then makes `actualDt` *larger* than the stable step, silently violating the criterion the code just computed. There is no warning when this happens. Clamping to `[0.1, 30]` also masks genuinely stiff cases.

**Fix:** compute `steps` first, and if it exceeds the cap, either log/flag reduced accuracy or adapt the cap to a time budget. Add a test with `kSat = 1e-4` at `dt = 3600` asserting mass balance and no oscillation.

#### G2 — Validation exists but is not a gate · P2
`ValidationFramework` (RMSE, MAE, NSE, R², bias, index of agreement) is solid, and `ScienceValidationTab` compares against a reference. But it is a UI feature, not a regression gate — nothing fails if a solver change doubles RMSE. For a project whose stated goal is scientific debate, the validation set should be versioned and asserted in CI.

**Fix:** commit 1–3 reference datasets (measured θ(z,t) and NO₃⁻ profiles), add `test/validation/` that runs the engine and asserts NSE/RMSE thresholds. Print a model-version + parameter-set hash in the validation tab.

#### G3 — Timeline history is thin at high speed · P3
`_history` keeps 500 snapshots, one per 200 ms tick, each advancing `2.0 × timeScale` seconds. At 1× that is ~17 min of sim time; at 10× it is ~2.8 h. The scrubber therefore shows a different depth of history depending on playback speed, with no indication. Store snapshots at fixed sim-time intervals (e.g. every 600 s) instead of fixed tick counts.

#### G4 — Mycorrhiza state is not persisted · P3
`mycorrhizaState` is `@JsonKey(includeFromJson: false, includeToJson: false)` (`biophysical_state.dart:38`). After a resume it is re-initialised, so colonisation resets while the carbon pools it fed do not. Minor today, but it is exactly the kind of silent discontinuity a reviewer will ask about.

---

## 4. Measurements (this machine)

| Metric | Value |
|---|---|
| `flutter analyze` | 0 issues, 4.3 s |
| `flutter test` | 84 passed, 10 s |
| Hand-written LOC | 60,126 (199 files) |
| Sim state JSON | 10,133 B (3 layers, 1 plant, history excluded) |
| Engine tick, 1 h | 1.34 ms |
| Engine tick, 2 s | 0.08 ms |
| 30-day pre-calc (720 ticks) | **967 ms** desktop CPU |
| `main.dart.js` | 4.1 MB |
| `build/web` | 48 MB |
| Finnish string literals in `presentation` (grep, incl. matcher keys) | 39 |
| `Semantics` widgets | 0 |
| Unreferenced files | 21 |
| `debugPrint` calls | 79 |

---

## 5. Recommended roadmap

### Week 1 — correctness and the mobile floor (highest value per hour)
1. A1 scenario reset, A2 resume detection, A3 await/progress/cancel pre-calculation (P0).
2. B1 tablet layout tier, B2 `SafeArea`, B3 dialog constraints, B5 XP bar. (Each is small and independently shippable.)
3. C3 stop the tutorial ticker.
4. E1 move the ~39 strings into ARB, fix "REAAALIAIKA".
5. F6 add `flutter analyze` to CI.

**Expected outcome:** no wrong-state scenario runs, no overflow on tablets/phones, materially better battery, English UI actually English. Roughly 2–3 days of focused work.

### Week 2 — the touch experience
6. B6 redesign the action bar (5 primary + sheets).
7. B4 `InteractiveViewer` around the Logic Lab.
8. B8 three-card gesture onboarding.
9. B7 type scale + 200 % text test.

**Expected outcome:** the app is usable one-handed with a thumb, and the two flagship "wow" surfaces (canvas, logic lab) survive on a phone.

### Weeks 3–5 — web and accessibility
10. C1/C2 worker or chunked engine; real progress UI; cap the scenario horizon.
11. C5 URL routing + shareable scenarios; C6 real PWA manifest.
12. D1 semantics for the HUD, D4 data-table view of the profile.
13. C8 split provider watches; C9 logging guard.

### Later — architecture
14. F3 split engine-owned vs UI-owned state.
15. F1 delete dead code, F2 split the three god files.
16. F5 provider tests + goldens; G2 validation gate in CI.

---

## 6. What is already good (and should not be lost)

- **Solver separation and constants centralization.** The scientific core is readable and testable; most projects at this stage are one 5,000-line file.
- **Complete bilingual localization.** 1302 keys, en/fi in lockstep, zero missing. The failure is only the last mile, not the system.
- **Adaptive hydrology sub-stepping.** Evidence of real numerical care.
- **Freezed models + functional `SimulationActions`.** Immutable by default is the right call.
- **A deliberate visual language.** The Nordic palette, CPK colours and glass HUD are coherent; the problems are scale and density, not taste.
- **Honest documentation of limits.** The README's "known issues" section is more scientifically mature than most production READMEs.

---

*Method note:* findings come from source reading, `flutter analyze`, the full test suite, ARB diffing, a temporary probe test for payload/tick timing (removed), and a reference scan for semantics, imports and hardcoded strings. No on-device FPS profiling, no browser run, and no accessibility audit with a screen reader were performed — C4, C6 and D5 should be confirmed on real hardware before being scheduled as certainties.
