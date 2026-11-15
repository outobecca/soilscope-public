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
| Low-end Android | Record model | Record API level | `flutter run --profile` | — | Pending |
| Mid-range Android | Record model | Record API level | `flutter run --profile` | — | Pending |
| Desktop Chrome | Record GPU/CPU | Record Chrome version | Flutter web profile | — | Pending |
| iPhone / iPad | Record model | Record iOS version | `flutter run --profile` | — | Pending if hardware is available |

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
   the capture three times and record the median of the three runs.
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
| — | No raster optimization attempted yet | — | — | — | Awaiting device captures |

## Status

Phase 4 harness and profiling protocol are in place. H7 remains open until
the device matrix is populated with real profile-mode captures; no FPS or
raster claim should be made from the local benchmark numbers.
