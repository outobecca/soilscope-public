# Performance and device profiling

## Guardrail

Raster or frame-time optimization is not accepted without a before/after
profile from a real target device. Local desktop numbers are directional and
must not be presented as a release-device baseline.

## H7 device matrix

Fill one row per capture. Use the same scenario, viewport, and interaction
script for before/after comparisons.

| Tier | Device model | OS / browser | Build mode | Capture date | Status |
|---|---|---|---|---|---|
| Low-end Android | 4K Hybrid STB (Amlogic HY46B, Mali-G31) | Android 14 / API 34, 1920×1080 @ dpr 2.0 | `flutter drive --profile` | 2026-11-15 | Captured, below budget |
| Mid-range Android | Record model | Record API level | `flutter run --profile` | — | Pending |
| Desktop (Linux) | AMD Radeon 760M, Ryzen, Flutter 3.47.9 | Pop!_OS 24.04, kernel 7.2.15 | `flutter drive --profile` | 2026-11-15 | Captured, median of 3 rotated runs; raster-bound |
| Desktop Chrome | Record GPU/CPU | Record Chrome version | Flutter web profile | — | Pending |
| iPhone / iPad | Record model | Record iOS version | `flutter run --profile` | — | Pending if hardware is available |

### On-device profile harness

`integration_test/performance_profile_test.dart` loads the real
`compacted_clay` scenario, warms up for 20 s, then records `FrameTiming`
build/raster durations for each protocol phase. It prints one
`PHASE4_PHASE {json}` line per phase and a final `PHASE4_RESULT {json}`.

Every payload carries a `model` block (`id`, `version`, `fingerprint`) from
`ModelParameterSet`. Compare before/after numbers only within the same
fingerprint: a parameter change can move frame costs and invalidates the
comparison. Print the current identity with `dart run tool/model_version.dart`.

```sh
flutter drive --profile -d <device-id> \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/performance_profile_test.dart

# Add diagnostic phases that separate per-tick work and decorative motion:
flutter drive --profile --dart-define=PHASE4_ATTRIBUTION=true -d <device-id> \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/performance_profile_test.dart
```

The harness asserts only that profile mode reported frames. It does not gate
CI on an FPS number, and debug runs print a warning because `FrameTiming` is
not populated in debug builds.

### Capture: low-end Android, 2026-11-15

Single run, not yet the three-run median the protocol asks for. Device:
`4K Hybrid STB`, Amlogic HY46B / Mali-G31, Android 14 (API 34), 1920×1080 at
320 dpi (960×540 logical, dpr 2.0), OpenGL ES 3.2, Flutter 3.47.9 profile
build, scenario `compacted_clay`.

| Phase | Frames | FPS | Build p50 / p95 (ms) | Raster p50 / p95 (ms) | Total p50 / p95 (ms) | Janky frames |
|---|---|---|---|---|---|---|
| Steady simulation | 175 | 5.83 | 100.0 / 133.2 | 168.9 / 213.5 | 334.2 / 415.8 | 175 / 175 |
| Pinned inspection | 50 | 4.95 | 107.4 / 136.5 | 197.0 / 209.5 | 388.3 / 405.7 | 50 / 50 |
| Microscope open | 40 | 3.98 | 129.8 / 149.1 | 253.1 / 285.6 | 500.5 / 549.6 | 40 / 40 |
| Pan + zoom | 32 | 3.17 | 158.8 / 189.4 | 307.1 / 351.9 | 608.2 / 687.1 | 32 / 32 |

What the capture establishes:

- The device misses the 33.3 ms budget by roughly 10× in every phase. It is
  a TV-class box with a Mali-G31, so it is a deliberately harsh lower bound,
  not a stand-in for a current phone. It still qualifies as the low-end
  Android row and should be paired with a mid-range phone capture.
- Raster dominates build in every phase (169 ms vs 100 ms steady), and the
  ratio grows with overlays and camera motion. The scene is GPU-bound.
- Opening the inspection card adds ~28 ms raster and ~7 ms build; opening the
  microscope adds ~84 ms raster and ~30 ms build; continuous pan/zoom adds
  ~138 ms raster and ~59 ms build. Overlay blur and camera-driven redraw are
  the measured add-on costs, not assumptions.
- The previous "16,000 px background" concern is stale: `backgroundWidth` is
  already clamped to the visible viewport plus 800 px, and the soil texture is
  already limited to the visible slice. Neither is the whole-scene problem.

### Attribution capture and the session-drift caveat

Second run on the same device with the diagnostic phases enabled
(`--dart-define=PHASE4_ATTRIBUTION=true`). Same scenario, same build.

| Phase | Frames | FPS | Build p50 (ms) | Raster p50 (ms) | Total p50 (ms) |
|---|---|---|---|---|---|
| Steady simulation (opening) | 161 | 5.37 | 106.3 | 182.0 | 358.9 |
| Pinned inspection | 44 | 4.36 | 125.7 | 228.8 | 449.7 |
| Microscope open | 34 | 3.38 | 149.7 | 283.3 | 555.0 |
| Pan + zoom | 30 | 2.92 | 166.5 | 326.1 | 661.7 |
| Paused simulation | 34 | 3.36 | 84.4 | 299.3 | 591.1 |
| Reduced motion | 28 | 2.73 | 181.4 | 346.0 | 703.0 |
| Steady control (end) | 22 | 2.17 | 212.8 | 455.2 | 908.7 |

**The control invalidates the sequential comparison.** The identical steady
scene was 2.5× slower at the end of the session than at the start (raster
182 → 455 ms). The cause is not isolated: the box is passively cooled and
plausibly thermal-throttles, but the scene also evolves while it runs (plants
grow, root systems and particle budgets fill over simulated time). The desktop
control below shows a similar 2.2× drift with no thermal reason, so session and
scene drift are at least part of it. Either way, the later phases in a single
run are biased slow, including the paused and reduced-motion windows and the
phase deltas in the first table.

What survives the confound:

- The device is below the 33.3 ms budget by roughly an order of magnitude even
  in the best (opening) window. This is a lower bound on its performance, not
  an average.
- Pausing the simulation lowered build from 106 ms to 84 ms even though that
  window ran after the microscope and pan/zoom phases, when the session had
  already drifted slow. Per-tick state merging and provider rebuilds are
  therefore a real but secondary part of build; most of the build is the
  scene recording itself.
- Raster exceeded build in every window, so the scene is GPU-bound. That
  conclusion does not depend on phase order.

**Protocol correction:** a before/after must interleave the two conditions
(A-B-A-B blocks of a few seconds) and compare paired blocks, or cool to the
same baseline and load a fixed pre-advanced simulation state so both runs see
the same scene. Sequential phases cannot be compared as a before/after.

### Capture: Linux desktop reference (rotated order, 3 runs), 2026-11-15

The Linux desktop is the reference environment: real GPU (AMD Radeon 760M via
Mesa radeonsi, OpenGL 4.6), Pop!_OS 24.04, kernel 7.2.15, 1280×720 at dpr 1.0,
Flutter 3.47.9 profile build, same scenario and harness as the device rows.

Three fresh runs, seeds 101–103. The phase order is a rotation of the protocol
list (`seed % 4`) instead of a free shuffle: a shuffle can legitimately put the
same phases first in every run, which is the bias the rotation removes. With
three runs each phase lands once early, once mid-session and once late.

| Run | Phase order |
|---|---|
| 101 | pinned inspection, microscope, pan + zoom, steady |
| 102 | microscope, pan + zoom, steady, pinned inspection |
| 103 | pan + zoom, steady, pinned inspection, microscope |

Medians of the three per-run p50/p95 values:

| Phase | FPS | Build p50 / p95 (ms) | Raster p50 / p95 (ms) | Total p50 (ms) | Raster p50 across runs (ms) |
|---|---|---|---|---|---|
| Steady simulation | 9.94 | 17.6 / 40.7 | 98.7 / 123.4 | 190.3 | 69.9–99.1 |
| Pinned inspection | 13.68 | 15.0 / 43.0 | 72.1 / 77.9 | 137.9 | 50.8–95.7 |
| Microscope open | 13.71 | 13.8 / 37.6 | 73.3 / 87.5 | 138.9 | 49.8–140.7 |
| Pan + zoom | 11.11 | 13.4 / 38.3 | 78.7 / 103.0 | 155.0 | 61.8–86.3 |

What the rotated capture establishes:

- The previous fixed-order numbers were placement artifacts. Steady was always
  measured first and read 61.4 ms raster; with rotation it reads 98.7 ms
  because some runs sample it late. The microscope was always second and read
  108.1 ms; with rotation it reads 73.3 ms. The old "overlay costs" were the
  session drift, not the overlays.
- Spread is still large (steady 69.9–99.1 ms, microscope 49.8–140.7 ms).
  Rotation removes the systematic bias, but three 10–30 s windows cannot
  average out a 2× drift within a session. Treat these medians as direction,
  not as a baseline for a before/after; use the interleaved A/B for that.
- Build p50 stays at 13.4–17.6 ms, at or near the 16.7 ms budget; raster is
  72–99 ms. The bottleneck remains GPU draw work.
- These runs used the panel-only `BlurSurface` variant described below. The
  A/B found the blur unmeasurable, so the restored default does not change
  these numbers beyond noise.

### First optimization: HUD backdrop blur (rejected by measurement)

Candidate: drop the `BackdropFilter` from `BlurSurface` (the panel-only look
phones already use below 600 px), because the microscope phase had carried the
largest apparent delta.

`PHASE4_AB` opens the microscope and alternates A (blur) and B (panel) in 3 s
blocks, six pairs, asserting that A blocks mount a `BackdropFilter` and B
blocks mount none. That assertion passed, so the switch is real. Deltas are
A − B, so a positive value would mean the blur costs time. The pairing always
measures B second, which biases the result *against* B under upward drift —
the bias direction is stated so a negative value is not read as a blur win.

| Target | Blur p50 (ms) | Panel p50 (ms) | Pooled delta | Paired delta median | Paired delta mean |
|---|---|---|---|---|---|
| Linux desktop, running | 59.8 | 59.9 | −0.1 | −2.37 | −2.33 |
| Linux desktop, paused | 34.3 | 33.7 | +0.5 | +0.43 | +0.28 |
| Low-end Android, running | 185.7 | 192.4 | −6.7 | −7.47 | −12.47 |

No target shows a win for removing the blur; the negative values sit inside
the drift bias against the panel variant. The visual default is therefore
restored to blurred, and the switch remains only as measurement
instrumentation. The optimization log records the rejection rather than an
unmeasured change.

The useful side measurement: with the simulation paused, the open-microscope
state renders at ~34 ms raster on desktop versus ~60 ms running. The cost is
the animated scene, not the HUD surface, so the next candidate should target
per-frame animated draw work (particles, flow lines, plant glow) rather than
panel compositing.

### Provisional budget

- **Lowest supported Android:** steady-state frame time ≤ 33.3 ms (30 FPS),
  measured after a 30-second warm-up.
- **Desktop and mid-range devices:** target ≤ 16.7 ms (60 FPS) where the
  device sustains it.
- Report both the median and p95 build/raster times, plus the number of janky
  frames in the capture window. Startup frames are excluded.

These are provisional targets until the lowest supported device is recorded
in the matrix.

## Profile capture protocol

1. List available targets with `flutter devices`.
2. Launch the scenario in profile mode:
   `flutter run --profile -d <device-id>`.
3. Let the simulation reach steady state for at least 30 seconds.
4. Record a 30-second DevTools Performance capture while:
   - the normal simulation is running;
   - a layer inspection card is pinned;
   - the microscope is open;
   - the canvas is panned and zoomed.
5. Record the UI/build and raster medians and p95 values separately. Repeat
   the capture three times and record the median of the three runs. On a
   every device, run a steady control phase at the end of the session (see the
   session-drift note above); if it differs from the opening baseline, the
   captures are not comparable and must be interleaved instead. Growth of the
   simulated scene during a run is itself a confound, not just heat. Prefer the
   Linux desktop for the three-run median: fresh runs there start from the same
   scene and the frame times are repeatable within ~30 %.
6. Use the Flutter Inspector repaint/layer overlays and, where supported, the
   platform GPU profiler to check these suspected costs:
   - `BackdropFilter` and other blur/`MaskFilter` layers;
   - soil texture/noise fill;
   - particle and molecule counts;
   - the 16,000 px visual background;
   - any `saveLayer` calls or offscreen compositing.
7. For web, use `flutter run -d chrome --profile` if the installed Flutter
   version supports it; otherwise build a profile web artifact and record the
   browser version and Chrome tracing setup.
8. Add the measurements to the matrix above before optimizing. Link the
   before/after commits or benchmark output in the optimization log.

## Non-GPU benchmarks

Run:

```sh
flutter test --no-pub test/performance/phase4_benchmark_test.dart
# Include the environment-sensitive RSS sample:
flutter test --no-pub --dart-define=PHASE4_MEMORY=true \
  test/performance/phase4_benchmark_test.dart
```

Local sample captured on 2026-11-15 with Flutter 3.47.9 / Dart 3.13.7 on
Linux x86_64. This is a host measurement, not a device baseline:

| Metric | Local sample |
|---|---|
| Engine tick, two layers, no plant | 0.66–1.08 ms/tick median (5 × 40-tick samples across runs) |
| One-day timeline pre-calculation | 9–11 ms, 4 snapshots |
| History lookup, 2,000 snapshots | 51–59 ms for 100,000 queries |
| RSS after 20 scenario loads | −1.1 to +2.7 MB across four runs |

These are host runs, not a controlled benchmark. The RSS range includes a
negative delta after garbage collection and is not evidence of a leak. Re-run
the memory probe after repeated scenario loads and with the app backgrounded
before drawing any retention conclusion.

## Optimization log

| Date | Change | Before | After | Device | Result |
|---|---|---|---|---|---|
| 2026-11-15 | `BlurSurface` backdrop blur removed (panel-only) | Microscope raster 59.8 ms desktop, 185.7 ms box | 59.9 ms desktop, 192.4 ms box | Linux desktop, low-end Android | **Rejected:** paired deltas inside drift bias, no measured win; default restored to blurred |

## Status

Two matrix rows are captured. The Linux desktop reference now has the
three-run median with rotated phase order: steady 9.9 FPS at 1280×720, build
17.6 ms p50 against raster 98.7 ms p50, and 72–99 ms raster across the four
phases. The low-end Android box is a single-run lower bound at ~5.4–5.8 FPS.
Both are raster-bound, so the bottleneck is GPU draw work, not Dart or the
solver.

Rotation also corrected the phase picture: the earlier fixed-order capture
measured steady first every time and microscope second every time, which made
steady look 1.6× better and the microscope 1.5× worse than the rotated
medians. Three windows per run still leave a large spread (49.8–140.7 ms on
the microscope), so the phase medians are directional only; a change must be
verified with the interleaved A/B.

The first candidate, removing the HUD backdrop blur, failed that test: paired
deltas were −2.4 ms on desktop and −7.5 ms on the box, both in the drift-bias
direction against the panel variant, so there was no measured win and the
blurred default was restored. Pausing the simulation cuts the microscope state
from ~60 ms to ~34 ms raster on desktop, so the cost is per-frame animated
draw work, not panel compositing. That is the next candidate class.

The matrix still needs a mid-range phone, a desktop browser and (if available)
an iOS device, and the Android row still needs repeated runs.

H7 stays open until at least the mid-range Android row exists and a measured
optimization moves the low-end capture toward the budget without changing
scientific correctness or accessibility.
