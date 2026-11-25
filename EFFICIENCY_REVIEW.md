# SoilScope — Performance & Efficiency Review

**Date:** 25 November 2026
**Scope:** whole repository — simulation state layer, persistence, Riverpod providers, Flame render loop, component caches.
**Lens, in the order requested:** (1) redundant execution, (2) cache-key consolidation, (3) state-management streamlining.
**Method:** source reading plus a temporary in-process probe (removed after the run) on the Linux reference host, and — for the memory section — a temporary CDP heap profiler (removed after the run) driving headless Chrome.

**Implementation status (25 Nov 2026):** A1, B1/B2, A10, A5, C4, A2, A4, A7, A8,
B3 and A9 are implemented; A6 was measured and closed as a non-finding, and A9's
proposed selection rewrite was measured and reverted — see §1.1. The remaining
findings are recommendations. The repository's `PERFORMANCE.md` guardrail (*no raster optimization is
accepted without a before/after profile on a real target*) still applies before these
are presented as device wins.

---

## 0. Baseline

| Check | Result |
|---|---|
| `flutter analyze --no-pub` | **No issues found** (3.7 s) |
| Toolchain on this host | Flutter 3.50.1 / Dart, Linux x86_64, debug test host |
| Test probe | temporary `test/performance/tmp_visual_cache_probe_test.dart`, ran green, deleted |
| Device profiles | **not run** (no device attached; `PERFORMANCE.md` numbers cited only as context) |
| UI / browser | **profile build driven in Chromium** (integrated browser, 25 Nov) — §1.2 |

`PERFORMANCE.md` reports all four measured canvas phases under the 16.7 ms raster
budget on the desktop reference after the 2026-11-16 passes. Nothing here disputes
that; the findings below are about work that still happens **every tick or every
frame** and did not appear in phase-level raster totals because it lands on the UI
thread or inside `update()` rather than in a draw call.

---

## 1. Executive summary

| # | Finding | Severity | Measured / structural cost |
|---|---|---|---|
| A1 | The soil-layer noise image is re-rasterized **every engine tick** (not cached in practice) | **P0** | gate fires 30/30 ticks; **6.54 ms per layer**; ~19.6 ms per tick for 3 layers, ~2 MB image churn per layer per tick |
| A2 | `_syncSubComponents` runs 2–3× per layer per tick, each with 2–3 full Flame tree scans | P1 (done) | three `query<T>()` scans + a map per call; measured **22.2 µs/call → 8.6 µs** after (6.2–8.6 across runs); a naive scan without the layer caches costs **15.3 µs** |
| B1 | Layer-noise cache key is **incomplete** (`siltFraction` missing) and the paint key omits `porosity` | **P0 (correctness)** | stale texture/paint after a texture or porosity edit |
| A6/C1 | Deep-equality `select` in Flame components; the whole-state HUD watches (C1) remain | Closed | measured 25 Nov: **<0.01 µs** early-exit, **4 µs** forced 350-root walk — not hot |
| A5 | A slider drag sends one full state across the isolate port **per pointer event** | P1 | ~60 state copies + port messages per second of drag |
| C4 | `SimulationSessionState` has no `==`; every re-select re-notifies and rebuilds ~30 sliders | P1 | O(30) widget rebuilds per tap |
| A7 | `ScenarioRepository` has no cache while its sibling repository does | P2 | 4 asset reads + JSON parses per screen visit |
| A8 | `ModelParameterSet.current` rebuilds and hashes the whole parameter set on every access | P2 | **161 µs per access** |
| C8 | `retryInitialization()` can double-subscribe the engine tick stream | P2 | two `process()` calls and duplicate snapshots per tick |
| A4 | Per-frame `Paint`/`Shader`/`Path`/`Random` allocations in three always-visible components | P2 (done) | ~360 gradient shader builds/s at 60 fps; removed — measured **1395 → 1358 MB allocated per 20 s** (−2.7%) |
| A3 | A run-constant process profile is derived 4× per state update | P3 | 3 µs × 4 (CPU small, structurally wrong) |
| C5 | Five hand-rolled "pending value + microtask" coalescers | P3 | duplication; the source of two subtle hover bugs already fixed by hand |

The single largest win is A1: it is measured, it is per-tick, and it is the exact
opposite of what `PERFORMANCE.md` claims the render pass achieved ("rasterizes …
into cached `ui.Image`s" — cached only in name).

### 1.1 Implementation status

| Change | File | Before | After |
|---|---|---|---|
| Layer-noise cache identity | `SoilLayerNoiseKey` in `logic/soil_layer_noise_engine.dart` | 4 raw fields, exact compare, fires **30/30** ticks | 5 quantized fields (sand/silt/clay 0.005, stability 0.05, carbon saturated) — **0/30** steady, **10/30** during the one-time stability ramp |
| Raster scheduling | `components/soil_layer_component.dart` | `toImageSync` in the state listener, every tick | first raster sync in `onLoad`; later rasters via `Picture.toImage`, one in flight, previous image drawn meanwhile |
| Paint cache input | `components/soil_layer_component.dart` | 6 scalars, no `porosity` | 7 scalars including `porosity` |
| Engine subscription | `services/simulation_runtime.dart` | previous listener leaked on retry | `await _subscription?.cancel()` before re-listening |

Same temporary probe (30 ticks at the in-app 2 s delta, default profile, Linux test host):

| Window | Old gate | New key | Notes |
|---|---|---|---|
| Startup (first 30 ticks) | 30/30 | 10/30 | stability ramps 0.5 → 1.0 once |
| Steady (after 300 warm-up ticks) | 30/30 | **0/30** | carbon patches saturate; stability clamped |

Per miss, the CPU-side recording is unchanged (2.2–4.6 ms median on this host); it now
happens off the update path and only on a real visual change. The paint gate still fires
30/30 during a run because water content drifts every displayed frame, so adding
`porosity` costs no extra repaints.

Second batch (state pushes and session notifications):

| Change | File | Before | After |
|---|---|---|---|
| Engine state pushes | `EngineSyncGate` in `services/simulation_runtime.dart` | one `updateState` per sync — **60 pushes per 60 drag events** | first push immediate, the rest coalesced, latest flushed on the engine frame — **2 pushes per 60 events** |
| Session re-selection | `providers/simulation_session_provider.dart` | selecting the same layer twice notified twice; duplicate element selects added two more | duplicate re-selections add **0** notifications (value equality + early return) |
| A6 equality | measurement only | claimed deep walk of 350 roots per tick | early-exit **<0.01 µs**, forced full walk **4 µs** — not hot, closed |
| A2 sub-component sync | `components/soil_layer_component.dart` | 3 recursive `query<T>()` scans, a rebuilt hotspot map and a full node re-anchor every call — **22.2 µs/call** | direct-child ion scan, layer-owned tech/rhizosphere lists, geometry-gated re-anchor, and no session/state reads below detail zoom — **8.6 µs/call** common path (6.2–8.6 across runs; 15.3 without the layer caches), 20–38 µs at detail zoom (provider read dominates; noisy) |
| A4 per-frame paints | `components/soil_layer_component.dart`, `scientific_overlays_component.dart`, `horizon_color_bands_component.dart` | 2 shadow shaders + 3 `Paint`s + a `Random` + up to 10 `Path`s per layer per frame; the grass strip rebuilt (30 `Path`s, 3 `Paint`s, `Random`); a 12-colour list + shader per horizon frame | shadow/crack/selection paints cached on geometry; grass recorded as a `ui.Picture` per soil geometry; band colours/stops static and the shader cached per column rect — **69.8 → 67.9 MB/s allocated** |
| A8 parameter-set identity | `domain/models/model_parameter_set.dart` | `current` rebuilt (sort ~190 values, canonical string, FNV hash) on every access — **174 µs** | memoized on `ModelConfig.values` identity — **0.046 µs** per access |
| A7 scenario loads | `data/scenario_repository.dart` | 4 asset reads + JSON parses per screen visit — **12.8 ms** cold | one shared future — **5.3 µs** warm |
| B3 overlay text | `components/scientific_overlays_component.dart` | a fresh `TextPainter` per zoom step per label; the animated boundary issued one `drawLine` per dash | one layout per label, drawn through a `1 / zoom` canvas transform; dashes batched into one `drawPath` per boundary — **1435 → 1405 MB per 20 s (−2.1%)** |
| A9 edge identity | `components/soil_symbiosis_network_component.dart` | `stableId` string rebuilt per access (**0.066 µs**, three times per edge per frame) | final field + cached phase seed (**0.014 µs**); the nearest-target selection rewrite was measured and rejected (56 vs 51 µs per rebuild) |

Probe: 60 gate requests, a provider listener counting notifications for duplicate
selections, and 500 timed comparisons on a 350-node plant. The A2 probe built the
real Flame tree through `MainSimulationScreen` (1 layer, 4 technical nodes, 1
rhizosphere hotspot) and timed `triggerSubComponentSync` over 2000 calls after a
50-call warm-up, including a cached-vs-naive A/B (8.6 vs 15.3 µs); the debug-VM
numbers are only meaningful as before/after ratios.

### 1.2 Web build profile (integrated browser)

Run on 25 Nov 2026 against `flutter build web --profile`, served from `build/web` on
`127.0.0.1:8099` and driven in the integrated Chromium. Host: Linux desktop, **144 Hz**
display, viewport 460×1100 at DPR 1, CanvasKit fetched from gstatic.

Build: `main.dart.js` **14.1 MB unminified**; first Flutter frame **0.97 s** cold /
**1.45 s** warm. Profile mode is the right target for frame pacing but not for load
size or memory: it keeps instrumentation, does not minify, and the local server sends
no compression.

| State | Frames / span | rAF fps | p50 | p95 | max | >33 ms | >50 ms | long tasks |
|---|---|---|---|---|---|---|---|---|
| Scenario menu, idle | 720 / 5.00 s | 143.9 | 6.9 ms | 7.0 ms | 7.1 ms | 0 | 0 | 0 |
| Simulation, steady | 603 / 8.00 s | 75.4 | 13.9 ms | 20.8 ms | 34.8 ms | 1 | 0 | 0 |
| Microscope open | 482 / 8.02 s | 60.1 | 13.9 ms | 20.9 ms | 34.8 ms | 2 | 0 | 0 |
| Pan/zoom, 500 key events | 832 / 15.16 s | 54.9 | 14.0 ms | 27.8 ms | 48.7 ms | 29 | 0 | 0 |

Method: a `requestAnimationFrame` interval recorder plus `PerformanceObserver` for
`long-animation-frame` and `longtask`. The canvas was focused with synthetic pointer
events and driven through the app's own `KeyDownEvent` handler (verified by the
`Focused target: Wheat` live region the handler updates). The pan/zoom burst alternated
`←`/`→`/`↑`, `=` and `-` every 16 ms; every event changed the camera and forced a
repaint.

Reading: the display is 144 Hz and the idle menu holds vsync. Simulation frame work
does not fit the 6.9 ms budget, so the compositor settles on every second vsync — the
13.9 ms p50 is exactly 2 × 6.9 ms, i.e. ~72 fps rather than 144. Continuous camera
input is the costliest state and still stays under two 60 fps frames at p95 (27.8 ms).
No window produced a long animation frame or a long task, and nothing exceeded 50 ms.

Load (warm cache): TTFB 16 ms, FCP 98 ms, DCL 87 ms, load event 160 ms. These are not
production numbers: the profile bundle is 14.1 MB versus the release build and the
local server does not gzip. For production load numbers use the release/wasm figures
already recorded in `AUDIT.md` C7 (cold LCP 238 ms, warm first frame 137 ms, 3.6 MB
wasm).

Memory observation (confirmed in release; attributed below to collectable per-frame
paint churn): the menu page held 75 MB JS heap; the simulation page climbed
121 MB → 184 MB (+63 MB in 12 s) → 375 MB (+191 MB in 20 s) during a steady run, and
a 12-minute session with scripted input peaked at ~738 MB. Profile marks stayed low
(~32/s), and the noise-raster path keeps exactly one image in flight and disposes the
previous one (`soil_layer_component._refreshNoiseLoop`), so this is not a retained
raster cache.

#### Release check

The churn is **not a profile-mode artifact**. Rebuilt with
`flutter build web --release --pwa-strategy=none` (4.69 MB `main.dart.js`) and served
from a fresh origin so no profile asset could be reused:

| Metric | Release | Profile |
|---|---|---|
| first Flutter frame | **931 ms** | 970 ms cold / 1447 ms warm |
| TTFB / DCL / load event | 8 / 29 / 668 ms | 16 / 87 / 160 ms |
| first contentful paint | 191 ms | 98 ms |
| `main.dart.js` | 4.69 MB | 14.1 MB |

The bundle is 3× smaller but the first frame is unchanged: CanvasKit init and app
startup dominate, and the script itself arrived in 57 ms. Neither run is compressed
(the local server sends no gzip), so these are not production load numbers.

Heap over a single release session (semantics enabled for scripted navigation):

| State | Heap |
|---|---|
| scenario menu, 12 s | 62 MB, flat |
| simulation, 4.5 s | 109 MB |
| 25 s | 172 MB |
| 50 s | 270 MB |
| 110 s | 373 MB |
| ~190 s | 469 MB |
| paused, +30 s | 563 → 569 MB (~0.2 MB/s) |

That is ~3–4 MB/s while running, decelerating to ~1–2 MB/s, and almost zero once the
run is paused.

**Attribution (25 Nov, CDP).** Headless Chrome (`--headless=new`, CDP on 9223) drove
the same release bundle at 460×1100 with the simulation running (the HUD semantics
reads "Pause") and forced GC through `HeapProfiler.collectGarbage`:

| Measure | Value |
|---|---|
| JS heap while running | 57 MB |
| after forced GC | **36 MB** |
| 20 s later | 64 MB running → **38 MB retained** (+2 MB) |
| allocation over those 20 s (sampling, collected objects included) | **1.3 GB (~65 MB/s)** |
| top allocation sites | `canvaskit.js:108` 343 MB, `create` 192 MB, `fromWireType @ canvaskit.js:133` 107 MB, minified Dart paint paths, `Canvas.drawLine` 24 MB |

The 77.6 MB heap snapshot is dominated by CanvasKit buffers (`JSArrayBufferData`
32.3 MB, `ExternalStringData` 13.6 MB, `WasmNativeModule` 8.9 MB) — engine assets,
not app data. So the browser's 121 → 738 MB was V8 deferring collection of per-frame
paint-bridge garbage, not a leak: a forced GC returns the heap to ~36–38 MB and 20 s
of ticking retains only +2 MB. The churn is per **rendered frame**, not per engine
tick — pausing stops it because a static scene stops producing frames — and the
largest contributors are the CanvasKit glue around each paint operation
(`canvaskit.js:108`, `fromWireType`, `create`, `Canvas.drawLine`) plus a few minified
Dart paint paths. A4 (per-frame `Paint`/`Shader`/`Path` construction in three
always-visible components) did reduce the rate when implemented — 69.8 → 67.9 MB/s —
but the bulk is the per-draw CanvasKit bridge, so the simulation state itself retains
nothing; the remaining lever is the number of paint operations, not their setup. Caveat: headless SwiftShader ran at ~23 fps versus ~72 fps in
the integrated browser, so the absolute churn rate is ~3× lower there; the forced-GC
result is the decisive part.

---

## 2. Redundant execution

### A1 — The layer noise raster is rebuilt on every tick · **P0**

`lib/presentation/widgets/game/components/soil_layer_component.dart:204-216`

```dart
final needsNoiseUpdate =
    noiseSource == null ||
    noiseSource.sandFraction != next.sandFraction ||
    noiseSource.clayFraction != next.clayFraction ||
    noiseSource.aggregateStability != next.aggregateStability ||
    noiseSource.organicCarbon != next.organicCarbon;
…
if (needsNoiseUpdate) { _noiseSourceLayer = next; _preRenderNoise(); }
```

`_preRenderNoise()` (`:298-301`) calls `SoilLayerNoiseEngine.generateNoiseImage`,
which records **up to ~1,500 draw operations** and rasterizes a **1000×500** image
(`soil_layer_noise_engine.dart:12-15`), disposing the previous one.

Measured on the default profile at the in-app tick delta (2 simulated seconds):

| Probe | Result |
|---|---|
| Noise gate fires | **30 / 30 ticks** |
| `organicCarbon` differs from previous tick | 30 / 30 |
| `aggregateStability` differs | 23 / 30 |
| `generateNoisePicture` (record only) | median **2.27 ms** (min 1.53) |
| `generateNoiseImage` (record + raster) | median **6.54 ms** (min 5.95) |

Why the gate can never settle:

- `aggregateStability` is rewritten every aggregation step
  (`lib/domain/solvers/aggregation_solver.dart:200`), and
- `organicCarbon` is rewritten every nitrogen-cycle step
  (`lib/domain/solvers/nitrogen_cycle_model.dart:146`).

Both are continuous floats, and the comparison is exact, so any non-zero drift
invalidates the cache.

Consequences at 3 layers × 5 Hz:

- ≈ **19.6 ms of raster work per engine tick** (test-host software raster), i.e. a
  dropped frame whenever a tick lands inside one, and ≈ 10 % of wall-clock time.
- A **1000×500 image (≈2 MB)** allocated and disposed per layer per tick — ≈30 MB/s
  of allocation churn and texture pressure, independent of how the raster is scheduled.

There is a second, subtler problem: **the drift that triggers the rebuild is invisible**.
`carbonPart = (organicCarbon * 25).clamp(0, 1)` saturates at `organicCarbon ≥ 0.04`;
the default layers are 25.5 / 10.1 / 5.02 kg/m³, so the carbon term is already pinned
at 1.0 in every realistic soil. The key therefore tracks a field that cannot change
the picture.

**Fix (in preference order):**

1. Quantize the key and drop saturated inputs — the pattern already used by
   `SoilTexturePatternComponent` (see B3). For the noise raster that means:
   sand/silt/clay to 2 decimals, `aggregateStability` to 0.05, and
   `organicCarbon` only below the 0.04 saturation point (or bucket it to 0.01).
2. Never rasterize inside `update()`. Keep drawing the previous `ui.Image`, request
   a refresh, and swap it in when ready (the texture component already does this with
   `_pendingTextureKey`, `_textureGeneration`, `_lastTextureRequestAt`).
3. Reuse a single image buffer per layer instead of dispose/allocate.

**Expected effect:** one rebuild per visible change instead of 5 per second — a
> 95 % reduction in this work at steady state. Must be verified with the interleaved
A/B protocol and a low-end Android capture before being claimed as a device win.

---

### A2 — Three tree scans per layer per sync, and the sync runs repeatedly · P1 (done)

`soil_layer_component.dart` (`_syncSubComponents`), called from `_handleLayerUpdate`
(every tick), `updateLayerRect` (on geometry change) and `triggerSubComponentSync`
(from `SoilScopeGame._updateMassFlow` every 2 s).

Each call does:

- `children.query<IonComponent>()` — allocates a list,
- `game.technicalHotspotLayer.children.query<ExpandableHotspotNode>().where(layerId)` —
  scans the **global** overlay and allocates a list,
- `children.query<RhizosphereHotspotComponent>()` plus a `Map<String, …>` of every
  hotspot,
- an O(hotspots²)-ish `removeWhere`/`contains` pass at the end.

With three layers that is ~9 full scans per second, all of which usually find the same
set as last time. Two of the three invocations are duplicates of work the same tick
already did.

**Fix:** retain the layer's own hotspot node list on add/remove (the game already keeps
`_layerComponents` keyed by layer id); index technical hotspot nodes by `layerId` in the
overlay; early-out when the hotspot id set and the selected element are unchanged.
The mass-flow timer can then call a cheap "reposition only" path.

**Implemented (25 Nov):** `SoilLayerComponent` now owns its technical nodes
(`_techNodes`) and rhizosphere components (`_rhizosphere`), adopting existing
components on the spawn path instead of re-querying them every sync. Ions are
scanned as direct children (they are always added directly), re-anchoring only
runs when the layer position or size changed, `updateIntensity` returns early when
the value is unchanged, and the session/displayed-state reads are skipped below
the 5.5 detail-zoom threshold where ions cannot exist.

The ownership caches were re-checked before keeping them: a clean A/B on the same
tree measures **8.6 µs/call with them** and **15.3 µs/call** with a naive
direct-child scan on every sync, so they remove ~44% of the remaining cost and stay.
Their lifecycle is guarded by
`test/presentation/widgets/soil_layer_subcomponent_lifecycle_test.dart` (repeated
syncs do not duplicate nodes; hotspot add/remove through the real
`_handleLayerUpdate` listener; geometry re-anchor; ions cleared below detail zoom),
which drives the component through `@visibleForTesting debugHandleLayerUpdate` so
the engine's own hotspot updates cannot race the assertions.

Measured on the real tree described in §1.1:

| Path | Before | After |
|---|---|---|
| `triggerSubComponentSync`, default zoom (common) | **22.2 µs/call** | **8.6 µs/call** (6.2–8.6 across runs) |
| `triggerSubComponentSync`, default zoom, no layer caches | 22.2 µs/call | 15.3 µs/call (A/B on the same tree) |
| `triggerSubComponentSync`, detail zoom (session read each call) | 22.2 µs/call | 20–38 µs/call (noisy; provider read dominates) |
| the three tree queries | 0.3 + 1.0 + 1.4 µs | replaced by a direct-child scan (~0.1 µs) |
| session provider read | 7–8 µs inside every call | 0 below detail zoom |

At the in-app 5 Hz tick with 2–3 syncs per layer this was ~0.3 ms/s of UI thread and
is now ~0.1 ms/s, so A2 is structural hygiene rather than a frame-time win. The
remaining detail-zoom cost is dominated by the `simulationSessionProvider` read.

---

### A3 — Run-constant profile derived four times per state update · P3

`lib/presentation/widgets/game/soil_scope_game.dart:576, 587, 599, 677`

`ScenarioProcessProfile.fromState` is documented as derived from the scenario's
**initial** profile precisely so it stays stable during a run
(`scenario_process_profile.dart:8-11`). `updateSession`, `updateIsRunning`,
`updateBiophysicalState` and `_updateScene` each recompute it from the same snapshot.

Measured at **3.0 µs** per call, so the CPU cost is negligible — but it is four
identical derivations of a value that changes only when the scenario changes.

**Fix:** compute it once per scenario load (or memoize on `currentScenario.id`) and
expose it as a provider. This also removes the `state` dependency from the canvas's
process overlays.

---

### A4 — Per-frame allocations in always-visible components · P2 (done)

Not the measured raster bottleneck (`calculateLayerPaint` is **4.0 µs** and already
throttled), but it is unconditional garbage and shader compilation per frame:

| Site | Per frame, per layer | Why it is avoidable |
|---|---|---|
| `soil_layer_component.dart:358-366` | one `LinearGradient(...).createShader(topShadowRect)` | 25 px, fixed colors — depends only on `wideRect.width` |
| `soil_layer_component.dart:374-382` | one more for the bottom shadow | same |
| `soil_layer_component.dart:342-353` | a `Paint` for the bio pulse, a `Paint` for the noise draw | both are constant apart from alpha/filter |
| `soil_layer_component.dart:404-421` | `_drawCracks` builds `math.Random(layerId.hashCode + 2)`, one `Path` per crack, at zoom > 2 | deterministic; cache the paths on first use |
| `scientific_overlays_component.dart:243-280` | `math.Random(42)` **and 30 `Path`s** for the grass strip | the strip is static; rasterize once |
| `horizon_color_bands_component.dart:62-88` | 12-color list + stops + `createShader` | depends only on the column rect |

≈360 gradient shader builds and ≈500 `Paint` allocations per second at 60 fps for the
three layer shadows alone.

**Fix:** hoist the shadow paints into `_updatePaint()` (the same invalidation path that
already exists), cache the grass strip as a picture/image, and cache the horizon
gradient on its rect.

**Implemented (25 Nov):** `SoilLayerComponent` keeps its noise, bio, selection and crack
paints as fields, builds the two 25 px shadow shaders only when the layer height changes
(the top one is constant), and caches the deterministic crack paths per layer size while
the live porosity selects how many of the ten are drawn. `ScientificOverlays` records the
static grass strip as a `ui.Picture` keyed by the soil geometry and reuses the boundary,
marker and water paints; `HorizonColorBands` computes its colour/stop lists once and
rebuilds the band shader only when the column rect changes (pan, zoom, viewport,
scenario), not every frame.

Measured with the same CDP sampling method as the heap attribution (release bundle at
460×1100, simulation running, forced GC before and after, 20 s window, collected objects
included), three runs per build:

| Build | Allocated per 20 s | Rate | Retained after GC |
|---|---|---|---|
| before A4 | 1386 / 1405 / 1395 MB | **69.8 MB/s** | +2–3 MB |
| with A4 | 1350 / 1362 / 1362 MB | **67.9 MB/s** | +2 MB |

That is **−37 MB per 20 s (−1.9 MB/s, −2.7%)**, consistent across runs and outside the
run-to-run spread (±0.5%). The remaining ~68 MB/s is CanvasKit's per-draw bridge
(`canvaskit.js:108` 362 MB, `create` 193 MB, `fromWireType` 109 MB per 20 s), allocated
per canvas call regardless of whether the Dart-side `Paint` is reused: to move the rate
materially the number of paint operations must drop, not just their setup. A4 is still
worth keeping — it removes unconditional per-frame garbage and shader builds for no
cost — but it is not a memory lever on its own.

---

### A5 — A slider drag crosses the isolate boundary once per pointer event · P1

`SimulationInterventions.updateLayer` now applies synchronously (good — the old
microtask lag is gone). That means a drag produces, per pointer event:

1. a new `BiophysicalState` + new `SoilLayer` + new layer list,
2. a full Riverpod notification,
3. `SimulationRuntime.sync` → `UpdateStateCommand` → `SendPort.send` of the **entire
   state** (`simulation_runtime.dart:79-86`).

At 60 events/s that is ~60 full-state copies and port messages per second, while the
engine only consumes one per 200 ms tick.

**Fix:** coalesce engine updates — keep the latest `UpdateStateCommand` and flush at
most one per engine tick (or per frame), mirroring the `_pendingState` pattern the tick
handler already uses. The UI must still update per event.

---

### A6 — Deep-equality `select` over freezed models, per tick · P1

```dart
// animated_plant_component.dart:218
displayedSimulationStateProvider.select(
  (s) => s.plants.cast<Plant?>().firstWhere((p) => p?.id == plantId, …),
)
```

`select` compares the selected value with `==`. `Plant` is freezed, so equality walks
the whole immutable object, including `rootSystem` (bounded at
`ModelConfig: maxRootsPerPlant = 350`). `SoilLayerComponent` does the same with
`SoilLayer` (`soil_layer_component.dart:67-75`), which includes a `hotspots` list.

Because the engine produces a **new** `Plant`/`SoilLayer` instance every tick, the
comparison almost always fails; the deep walk is pure overhead before the listener runs
anyway. Note that `VisualStateInterpolator` produces a fresh state every displayed frame
during transitions, increasing the pressure.

**Fix:** select a cheap projection — `(rootSystem.length, plant.id)` for growth
triggers, `timeElapsed` or a monotonically increasing `stateRevision` for "anything
changed" — and read the full object inside the listener. Alternatively expose
`soilLayerProvider(id)` / `plantProvider(id)` families whose identity is the object
itself, so `identical` suffices and deep equality is skipped.

**Measured (25 Nov 2026):** the premise does not hold in practice. Freezed compares
fields in declaration order, and consecutive engine snapshots differ in `age` /
`waterContent` before reaching `rootSystem` / `hotspots`, so the comparison returns in
**<0.01 µs**. A forced full walk of 350 root nodes costs **4 µs**; at 5 Hz for one plant
and three layers that is ≤0.1 ms/s even if every comparison went deep. This is **not a
hot path** and the refactor is closed; the real cost in this area is C1's whole-state
widget watches, tracked separately.

---

### A7 — One repository caches, the sibling does not · P2

| Repository | Cache |
|---|---|
| `ReferenceDatasetRepository` | `static Future<ReferenceDataset>? _cached` + `resetCache()` |
| `ScenarioRepository` | **none** — 4 × `rootBundle.loadString` + `jsonDecode` + `Scenario.fromJson` per call |

`scenariosProvider` is a plain `@riverpod` (auto-dispose), so every re-subscription
re-parses all four scenarios; `main.dart:210` may also race a second parse on a deep
link.

**Fix:** mirror the existing `_cached` future pattern (`ScenarioRepository._cached`),
or make `scenariosProvider` `keepAlive`. Prefer the repository cache so non-Riverpod
callers and tests get the same behaviour.

**Implemented (25 Nov):** `ScenarioRepository` caches its load future like
`ReferenceDatasetRepository`, and drops the cache if the load throws so a retry reads
the assets again. Measured: a cold load (four asset reads + parses) is **12.8 ms**;
subsequent calls return the shared list in **5.3 µs**. `scenario_repository_test`
asserts that repeated calls share one list and that `resetCache()` reloads.

---

### A8 — Model identity rebuilt from scratch on every access · P2

`ModelParameterSet.current` (`model_parameter_set.dart:56-60`) constructs a new set
every time: copies `ModelConfig.values`, adds five plot values, sorts ~190 entries,
builds a canonical string, FNV-hashes it, and wraps an unmodifiable map.

Measured: **161 µs per access**.

Call sites are not hot (`SimulationPersistence._encode` every 10 s, `sameAsCurrent`,
`canonicalModelJson`, tooling, tests), so this is not currently visible in a profile —
but it is the textbook "cache key recomputed on every use" case, and the cost scales
with the parameter set, which the project intends to grow.

**Fix:** memoize on the active configuration identity, which is already explicit:

```dart
static ModelParameterSet? _memo;
static Map<String, double>? _memoFor;

static ModelParameterSet get current {
  final active = ModelConfig.values;
  if (_memo != null && identical(_memoFor, active)) return _memo!;
  _memoFor = active;
  return _memo = ModelParameterSet(id: currentId, version: currentVersion,
      parameters: _currentParameters());
}
```

Because `ModelConfig.applyOverrides`/`reset` replace `_active` with a new map instance,
`identical` invalidates correctly and the fingerprint stays honest.

**Implemented (25 Nov):** `current` memoizes on `ModelConfig.values` identity. Measured
on this host: **174 µs per rebuild → 0.046 µs per memoized access**. The pinned
fingerprint and every override/reset provenance test still pass; a regression test
asserts identity reuse, invalidation after an override, and the restored fingerprint
after `reset()`.

---

### A9 — Symbiosis graph rebuild is O(n² log n) with per-access string keys · P3

`soil_symbiosis_network_component.dart`

- `_rebuildSymbioticGraph` runs every 0.8 s of visual time (`:98-101`).
- It sorts `remainingTargets` **inside** the frontier loop (`:281`) — repeated
  `O(m log m)` for each node, on every rebuild.
- `removeWhere((n) => nextFrontier.contains(n))` (`:297`) is O(n·k) on a list.
- `NetworkEdge.stableId` (`:766`) is a getter that builds `"${a.id}_${b.id}"`; it is
  called three times per edge per frame (`:352`, `:368`, plus the `==`/`hashCode`
  implementations).

**Fix:** sort once per rebuild into a reusable buffer, use a `Set<NetNode>` for
membership, and store `stableId` as a `final` field on the edge (constructed once).
The birth-time map is otherwise correct and well-bounded (`removeWhere` on active keys).

**Implemented (25 Nov):** `NetworkEdge.stableId` is built once in the constructor and
the per-frame phase seed is cached with it. Measured: **0.066 µs → 0.014 µs per
access** (4.7×), for three accesses per edge per frame. The `nextFrontier` membership
check now uses a `Set`, which preserves behaviour and removes a list scan per frontier
node. The proposed nearest-target selection was measured on the real frontier size
(40 frontier nodes × 60 remaining targets) and came out **slower** than the in-place
sort (56 vs 51 µs per rebuild), so it was reverted — the sort also benefits from the
near-sorted order it leaves behind. The rebuild only runs every 2.6 s of visual time.

---

### A10 — Duplicate tick subscription reachable through retry · P2 (also correctness)

`SimulationRuntime.initialize` (`simulation_runtime.dart:59-64`) assigns a new
`_subscription` without cancelling the previous one. `SimulationIsolateManager.init`
returns early when `_initialized` is already true, so a second `initialize()` call —
reachable via `Simulation.retryInitialization()` after the 10 s watchdog fired even
though the spawn eventually succeeded — attaches a **second** listener to the same
broadcast stream. Result: `_handleEngineTick` runs twice per tick, doubling the merge,
the snapshot decision and `_tickCount`.

**Fix:** `await _subscription?.cancel();` before subscribing, and make `initialize`
idempotent with an explicit state (`idle / starting / ready / failed`).

---

## 3. Cache keys

### B1 — Inventory: five ad-hoc key schemes for one canvas

| Cache | Location | Key | Verdict |
|---|---|---|---|
| Layer paint | `soil_layer_component.dart:243-257` | 6 raw doubles + `Size`, `==` | **Incomplete** (see B2); correct throttle |
| Layer noise raster | `soil_layer_component.dart:204` | 4 raw doubles | **Fires every tick**; **incomplete** (see B1a) |
| Soil texture raster | `soil_texture_pattern_component.dart:79-110` | pan snapped to 256 px, width/surface/height to 0.1, zoom bucketed to 0.25, per-layer fractions to 0.01, compaction to 0.1, biomass to 20 | **Reference implementation** |
| Background noise | `background_noise_component.dart:22-27` | `Vector2 size` | Correct |
| Text painters | `scientific_overlays_component.dart:206-231` | `'text\|ARGB\|fontSize.toStringAsFixed(2)\|bold'` | **Thrashes** (see B3) |
| Edge birth times | `soil_symbiosis_network_component.dart:78` | string built per access | Recompute, not a miss |

### B1a — The noise key omits `siltFraction` · **P0 correctness**

`generateNoisePicture` reads `sandFraction`, **`siltFraction`**, `clayFraction`,
`organicCarbon`, `aggregateStability` (`soil_layer_noise_engine.dart:20-30`), and the
selection of grain palette/density depends on the texture class, which depends on silt.
The invalidation check compares four of those five fields. Editing silt through the
texture sliders (`control_panel_section.dart`, `handleTextureChange`) therefore leaves
the grain layer stale until sand/clay/stability/carbon drift — which, per A1, happens
one tick later, masking the bug at runtime and making it fire only while paused.

### B2 — The paint key omits `porosity`

`SoilLayerStyleEngine.calculateLayerPaint` derives
`saturation = waterContent / porosity` (`soil_layer_style_engine.dart:17`), but the
settle check (`soil_layer_component.dart:243-251`) compares `waterContent`,
`redoxPotential`, `temperature`, `ph`, `depth`, `thickness` — not `porosity`.
`updateLayerParameter('porosity')` exists, so a programmatic or future UI change to
porosity repaints only when another keyed scalar moves.

### B3 — The text-painter key is zoomed too finely and evicted FIFO · P2

```dart
final key = '$text|${color.toARGB32()}|${fontSize.toStringAsFixed(2)}|$bold';
```

`fontSize` is `11 / zoom` / `12 / zoom` / `11 / zoom` (`:120, 152, 196, 316`), so every
zoom step produces a new key. During a pinch or scroll, each frame lays out new
`TextPainter`s and disposes old ones; the 64-entry bound is filled with zoom variants
that are never reused. Eviction uses `_textPainters.keys.first` — insertion order, not
LRU.

**Fix (two options):**

1. Quantize zoom for text: `final textScale = (zoom * 4).round() / 4;` and use
   `fontSize(textScale)`, so a zoom gesture produces ~4 keys instead of ~60.
2. Better: lay out one painter per label at a fixed size and scale the canvas
   (`canvas.save(); canvas.scale(1 / zoom); …`) — no key at all.

**Implemented (25 Nov, option 2):** labels are laid out once at their logical size and
painted through a canvas scaled by `1 / zoom`, so pinch/scroll reuses one painter per
label for the whole session. Cache hits now refresh insertion order, making eviction
LRU. The animated horizon boundary also records its dashes into one reused `Path` and
issues **one `drawPath` instead of one `drawLine` per dash** (~58 lines per frame at
the default 460 px viewport collapse into two paths). Rendering is geometrically
unchanged at every zoom (the old code compensated `fontSize` by `1 / zoom`); the
golden capture at the default zoom still matches.

Measured with the A4 CDP method (release bundle, 460×1100 headless Chrome, forced GC,
20 s sampling window, collected objects included), three runs per build, same scene:

| Build | Allocated per 20 s | Rate | `canvaskit.js:108` site |
|---|---|---|---|
| before B3 | 1458 / 1420 / 1428 MB | 71.8 MB/s | 375 / 364 / 369 MB |
| with B3 | 1408 / 1397 / 1409 MB | 70.2 MB/s | 340 / 340 / 347 MB |

That is **−30.6 MB per 20 s (−1.5 MB/s, −2.1%)**; every with-B3 run is below every
before run, and the CanvasKit glue site itself drops ~27 MB (−7%). Kept. As with A4
this is an allocation result, not a frame-time claim — the absolute rate is ~3× lower
in the headless software raster than in the integrated browser.

### B4 — Consolidation proposal

Introduce one small helper and one rule, then migrate the five sites:

```dart
// lib/presentation/widgets/game/logic/visual_cache_key.dart
/// Buckets [value] to the smallest change the renderer can show.
int bucket(double value, double step) => (value / step).round();

/// Stable, allocation-free cache identity for a Flame component.
/// Built from quantized inputs only; never from string interpolation in a frame loop.
final class VisualKey {
  const VisualKey(this.a, this.b, this.c, this.d);
  final int a, b, c, d;
  @override bool operator ==(Object o) => o is VisualKey &&
      o.a == a && o.b == b && o.c == c && o.d == d;
  @override int get hashCode => Object.hash(a, b, c, d);
}
```

**Rule:** *a cache key must contain every input the painter reads, quantized to the
smallest visible difference; a miss must never rasterize synchronously inside
`update()`/`render()`.* B1a and B2 are violations of the first clause; A1 is a
violation of the second.

`SoilTexturePatternComponent` already demonstrates the whole pattern and can be lifted
into a small `RasterCache<T>` (key, image, pending key, generation, last request time)
used by layer noise, texture and background noise alike.

---

## 4. State management

### C1 — One god-state, many whole-state watchers · P1

`BiophysicalState` carries engine output (`profile`, `plants`, `score`, `timeElapsed`),
UI controls (`isRunning`, `timeScale`, `precip`, `autoWeather`, …), the scenario and a
`history` list. `Simulation.uiFields` / `engineFields` already classify the merge, and
a companion test guards it — that part is solid.

The remaining problem is **fan-out**. Widgets that watch the whole provider rebuild at
5 Hz even when their slice did not change:

| Site | Watch |
|---|---|
| `widgets/controls/atmosphere_informatics_view.dart:24` | entire `displayedSimulationStateProvider` |
| `widgets/tutorial/mission_briefing_dialog.dart:17` | entire state |
| `screens/science_reference_screen.dart:22` | entire state |
| `screens/logic_lab_screen.dart:671` | entire state |
| `widgets/hud_dashboard.dart:111` (`_HUDSelectedLayerDetails`) | entire state when a layer is selected |
| `widgets/game/components/scientific_overlays_component.dart` | reads `game.displayedState` per frame (cheap, but the whole object) |

`ControlPanelSection` was already fixed to select only `profile.layers` and is the
model to follow.

**Fix:** add domain selectors so call sites cannot accidentally watch everything:

```dart
final soilLayerProvider = Provider.family<SoilLayer?, String>((ref, id) => …);
final plantProvider     = Provider.family<Plant?, String>((ref, id) => …);
final scoreProvider     = Provider<SustainabilityScore>((ref) => …);
final simulationClockProvider = Provider<double>((ref) => …);
```

For Flame components, prefer these families over `firstWhere` + deep equality (A6).

### C2 — The timeline's mutability invariant is a boolean handshake · P2

`SimulationTimeline` exposes `entries` mutably for the tick processor to append to
(`simulation_tick_processor.dart:84`), and the view is only refreshed when the provider
observes `result.snapshotAdded` (`simulation_provider.dart:220-222`). Nothing in the
timeline enforces "mutate ⇒ refresh".

**Fix:** make `append(entry)` the only mutation API on the timeline, have it maintain
`_view` itself, and let the processor call it. Removes the boolean from the result and
the risk of a stale scrubber.

### C3 — Two to three full state copies per tick · P3

Per engine tick, `SimulationTickProcessor.process` produces:

1. `engineState.copyWith(isInitializing: false)`,
2. `mergeSimulationState(processedState, uiState)` → another `copyWith` with ~10 fields,
3. `entry.copyWith(history: const [])` when a snapshot is due,
4. provider: `_pendingState!.copyWith(history: _timeline.view)`.

Nested lists are shared, so each copy is shallow — but 4 allocations of a 20-field
object per tick is avoidable. Steps 1+2 can be one construction; step 3 disappears with
C2 (`append` can strip once).

### C4 — `SimulationSessionState` has no value equality · P1

`simulation_session_provider.dart` defines `copyWith` but no `==`/`hashCode`, and every
setter schedules a microtask that assigns a new instance. Consequences:

- `selectLayer(id)` with the **same** id still notifies;
- `ControlPanelSection` watches the whole session, so all ~30 `SliderControl`s rebuild;
- `FlameSimulationView`'s record-select `(selectedLayerId, selectedInspectorType)` does
  compare by value, so the canvas is protected — by accident of using a record.

**Fix:** add `==`/`hashCode` (or early-return in each setter), and select narrow fields
(`.select((s) => s.selectedLayerId)`) in the panel.

### C5 — Five hand-rolled coalescers · P3

| Owner | Mechanism | Pending fields |
|---|---|---|
| `Simulation` | `_pendingState` + microtask | state |
| `UIState` | `_pendingHoverInfo` + `_isUpdateScheduled` | hover |
| `SimulationSession` | `_pendingViewTime` + `_isTimeUpdateScheduled` | view time |
| `SoilScopeGame` | `_syncActionBuffer` + drain in `update()` | closures |
| `RiverpodLifecycleMixin` | `_bufferedSyncActions` per component | closures |

Each has the same shape and its own edge cases (e.g. `clearUnpinnedHover` must inspect
`_pendingHoverInfo` as well as `state`). **Fix:** extract

```dart
final class CoalescedWrite<T> {
  CoalescedWrite(this._apply);
  final void Function(T) _apply;
  T? _pending;
  bool _scheduled = false;
  void set(T value) { _pending = value; if (_scheduled) return;
    _scheduled = true; Future.microtask(_flush); }
  void _flush() { _scheduled = false; final v = _pending; if (v != null) _apply(v); }
}
```

…and use it for the three provider cases. The component-side buffers can share a single
`FrameActionBuffer` mixin (the two implementations are already identical apart from
`RiverpodLifecycleMixin` also owning subscriptions).

### C6 — `EventLog` is unbounded and scans on every add · P3

`event_log_provider.dart:91-96` does `state.where((e) => e.key == key)` then
`recentMatches.first`, and prepends to an unbounded list. In a long run, every event add
walks the whole log and copies it.

**Fix:** cap at ~200 entries, and keep `Map<String, double> _lastTimestampByKey` for the
1-hour de-duplication check (O(1) instead of O(n)).

### C7 — Merge-field classification (keep)

`uiFields` / `engineFields` plus the companion test is the right structure; it turns a
silent-drift bug class into a test failure. No change recommended.

### C8 — Double subscription on retry · P2

See A10. This is both wasted work and a duplicated-snapshot correctness risk.

---

## 5. What is already efficient (do not redo)

These were checked because a review that "finds" already-solved problems is noise:

- **History is no longer copied per tick.** `SimulationTimeline.view` is rebuilt only
  when a snapshot is appended; `strip()` keeps snapshots history-free. The audit's
  `List.unmodifiable` per tick is gone.
- **Scrub lookup is already binary search** (`nearestHistorySnapshotIndex` /
  `_lowerBound`).
- **Layer paint is throttled to 30 Hz and early-outs when the visual scalars settle**
  (`soil_layer_component.dart:238-251`) — measured 4 µs per rebuild; leave it alone.
- **`SoilTexturePatternComponent` is the reference cache**: 256 px pan snap, 0.25 zoom
  bucket, 0.01 fraction quantization, deferred regeneration with a generation guard and
  a 0.5 s request throttle.
- **`BackgroundNoiseComponent` rasterizes once per size** and replays one
  `drawRawPoints`-derived image.
- **The tutorial ticker now starts/stops with visibility** (`tutorial_overlay_widget.dart:36-46`).
- **`ControlPanelSection` selects only the layer list** (audit C8 resolved).
- **`debugLog` is `kDebugMode`-gated**, so release builds compile the string work out.
- **`SimulationInterventions.updateLayer` applies synchronously** (audit's microtask
  thumb-lag resolved).
- **`GameProviderReader` keeps Flame out of `WidgetRef`** — no subscription leaks from
  canvas components.
- **`ModelConfig` replaces the active map by identity** on override/reset, which makes
  A8's memoization safe.

---

## 6. Prioritised action list

| Priority | Action | Effort | Where | Expected effect |
|---|---|---|---|---|
| **P0** | Quantize + defer the layer noise raster; drop saturated `organicCarbon` from the key **(done)** | S | `soil_layer_component.dart:204-301`, `soil_layer_noise_engine.dart` | removes ~6.5 ms/layer per tick and ~30 MB/s allocation |
| **P0** | Add `siltFraction` to the noise key; `porosity` to the paint key **(done)** | XS | same | fixes stale texture/paint |
| P1 | Cache layer hotspot nodes by id; stop re-scanning the global overlay twice per tick | M | `soil_layer_component.dart:424-540` | removes ~9 tree scans/s |
| — | ~~Add `soilLayerProvider` / `plantProvider` families~~ **(closed: measured 4 µs worst case, not hot)** | — | `animated_plant_component.dart:218`, `soil_layer_component.dart:67` | equality short-circuits before the deep fields |
| P1 | Coalesce `UpdateStateCommand` to one per tick **(done)** | S | `simulation_runtime.dart` | 60 pushes → 2 per 60 drag events |
| P1 | Value equality on `SimulationSessionState`; narrow selects in the panel **(equality done; panel selects remain)** | S | `simulation_session_provider.dart`, `control_panel_section.dart` | duplicate re-selection adds 0 notifications |
| P2 | Cancel the old subscription in `SimulationRuntime.initialize` **(done)** | XS | `simulation_runtime.dart:59` | prevents duplicate tick processing |
| P2 | Memoize `ModelParameterSet.current` on `ModelConfig.values` identity **(done)** | XS | `model_parameter_set.dart:56` | 174 µs → 0.046 µs per access |
| P2 | Cache `ScenarioRepository.getScenarios()` like the reference repository **(done)** | XS | `scenario_repository.dart` | 12.8 ms → 5.3 µs per screen visit |
| P2 | Hoist per-frame shadow/horizon/grass paints and shaders | S | `soil_layer_component.dart:342-421`, `horizon_color_bands_component.dart:62-88`, `scientific_overlays_component.dart:243-280` | ~360 shader builds/s → 0 |
| P2 | Scale the canvas instead of re-laying-out text per zoom **(done, measured)** | S | `scientific_overlays_component.dart:206-231` | stops cache thrash during zoom; one `drawPath` per dashed boundary; **−2.1% allocation** |
| P2 | `SimulationTimeline.append()` owns the view; drop `snapshotAdded` handshake | S | `simulation_timeline.dart`, `simulation_tick_processor.dart` | removes a stale-view failure mode |
| P3 | Memoize `ScenarioProcessProfile` per scenario | XS | `soil_scope_game.dart:576-677` | 4 derivations → 1 |
| P3 | Cache `NetworkEdge.stableId` **(done)**; target-selection rewrite rejected by measurement | S | `soil_symbiosis_network_component.dart:281-330, 766` | 0.066 → 0.014 µs per id access |
| P3 | Extract `CoalescedWrite<T>`; cap the event log; delete `_webTimer` | M | providers, `event_log_provider.dart`, `simulation_isolate.dart` | duplication and unbounded growth |

---

## 7. Verification plan (per the repo's own guardrail)

1. **Before/after for A1 and A4** must use the interleaved A/B protocol in
   `PERFORMANCE.md` (`PHASE4_AB` or an equivalent), not sequential phases — the
   documented 2.2–2.5× session drift makes sequential deltas meaningless.
2. Re-run `integration_test/performance_profile_test.dart` on the Linux reference
   **and** the low-end Android box. The last Android capture predates both 2026-11-16
   passes, so it cannot validate a new change.
3. Keep the model fingerprint fixed (`dart run tool/model_version.dart`) — none of
   these changes touch `ModelConfig`, so `113669a6` must stay.
4. For A1, also assert the invariant directly: a temporary probe (as used here) that
   counts `_preRenderNoise` calls over 30 ticks should go from **30/30 to ≤1**.
5. For A6/C1, the check is structural: `flutter analyze` plus the existing provider,
   golden and canvas-interaction tests. No new UI behaviour is introduced.

The probe used for this review is reproducible in ~40 lines: construct
`BiophysicalState(profile: defaultSoilProfile(), plants: [seedPlant()])`, tick
`SimulationEngine.tick(state, 2.0)`, count changes in the four gated fields, then time
`generateNoisePicture` / `generateNoiseImage` with a `Stopwatch` (medians over 12 runs).

---

## 8. Limitations

- **No device or browser profiling was performed for this review.** The micro-benchmarks
  run on the Linux host in a debug test process; absolute raster milliseconds on a
  phone will differ, and `toImageSync` may rasterize lazily on a real engine (the
  picture-recording cost and the image allocation are unconditional either way).
- Severity reflects structural certainty (per-tick invocation, measured call counts)
  plus host measurements, not a release-device frame budget.
- The review did not attempt to re-litigate the 2026-11-16 render passes; their
  measured results stand.
- Accessibility, localization and scientific-model questions raised in `AUDIT.md` are
  out of scope here and were not re-checked.
