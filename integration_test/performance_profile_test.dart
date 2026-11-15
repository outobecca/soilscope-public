// Profile capture for the Phase 4 (H7) performance matrix.
//
// The Linux desktop is the reference environment: it has real GPU acceleration,
// does not thermally throttle, and every run starts from the same fresh
// scenario, so three runs give a usable median. Run it with:
//
//   flutter drive --profile -d linux \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/performance_profile_test.dart
//
// The phase order is rotated per run (seed printed with the results) so each
// phase appears early, mid and late across three runs; pass
// --dart-define=PHASE4_SEED=<int> to reproduce a run. A rotation is used
// instead of a free shuffle because a shuffle can legitimately put the same
// phases first in every run, which is the bias this is meant to remove.
//
// Add --dart-define=PHASE4_AB=true to run the interleaved A/B for the backdrop
// blur instead of the phase capture. A = blur enabled, B = panel only, in
// short adjacent pairs. B is always measured second, so upward drift biases
// the result against the panel variant; read the sign with that in mind.
//
// The harness loads the real `compacted_clay` scenario, warms up, then records
// frame timings for the four states in PERFORMANCE.md. FrameTiming is only
// populated in profile/release builds, so debug runs report no numbers.
//
// Results are printed as `PHASE4_PHASE`/`PHASE4_RESULT`/`PHASE4_AB` JSON and
// written to the driver's integration response data. Nothing is asserted
// against an FPS budget: the capture informs decisions, it does not gate CI.

import 'dart:convert';

import 'package:flame/components.dart' show Vector2;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/providers/game_provider.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/simulation_session_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/widgets/common/blur_surface.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

const String _scenarioId = 'compacted_clay';
const Duration _warmUp = Duration(seconds: 20);
const Duration _steadyWindow = Duration(seconds: 30);
const Duration _stateWindow = Duration(seconds: 10);
const Duration _abWindow = Duration(seconds: 3);
const Duration _settle = Duration(seconds: 2);
const double _frameBudgetMs = 1000 / 60;

// Attribution phases split per-tick simulation work and decorative animation
// from the baseline scene: run with --dart-define=PHASE4_ATTRIBUTION=true.
const bool _attribution = bool.fromEnvironment('PHASE4_ATTRIBUTION');
// Interleaved backdrop-blur A/B: run with --dart-define=PHASE4_AB=true.
const bool _ab = bool.fromEnvironment('PHASE4_AB');
// Fixed shuffle seed for a reproducible phase order; 0 means pick one.
const int _seedOverride = int.fromEnvironment('PHASE4_SEED');

class _PhaseStats {
  final String name;
  final int frames;
  final double windowSeconds;
  final List<int> buildUs;
  final List<int> rasterUs;
  final List<int> totalUs;

  _PhaseStats({
    required this.name,
    required this.windowSeconds,
    required List<FrameTiming> timings,
  }) : frames = timings.length,
       buildUs = _sortedMicros(timings.map((t) => t.buildDuration)),
       rasterUs = _sortedMicros(timings.map((t) => t.rasterDuration)),
       totalUs = _sortedMicros(timings.map((t) => t.totalSpan));

  static List<int> _sortedMicros(Iterable<Duration> values) {
    final list = values.map((d) => d.inMicroseconds).toList()..sort();
    return list;
  }

  double get fps => windowSeconds <= 0 ? 0 : frames / windowSeconds;

  int _percentile(List<int> values, double p) {
    if (values.isEmpty) return 0;
    final index = ((values.length - 1) * p).round().clamp(0, values.length - 1);
    return values[index];
  }

  int get buildP50 => _percentile(buildUs, 0.50);
  int get buildP95 => _percentile(buildUs, 0.95);
  int get rasterP50 => _percentile(rasterUs, 0.50);
  int get rasterP95 => _percentile(rasterUs, 0.95);
  int get totalP50 => _percentile(totalUs, 0.50);
  int get totalP95 => _percentile(totalUs, 0.95);
  int get totalMax => totalUs.isEmpty ? 0 : totalUs.last;

  int get jankyFrames =>
      totalUs.where((us) => us > _frameBudgetMs * 1000).length;
  int get rasterJankyFrames =>
      rasterUs.where((us) => us > _frameBudgetMs * 1000).length;

  Map<String, Object?> toJson() => {
    'phase': name,
    'frames': frames,
    'windowSeconds': windowSeconds,
    'fps': _ms(fps * 1000),
    'buildP50Ms': _ms(buildP50),
    'buildP95Ms': _ms(buildP95),
    'rasterP50Ms': _ms(rasterP50),
    'rasterP95Ms': _ms(rasterP95),
    'totalP50Ms': _ms(totalP50),
    'totalP95Ms': _ms(totalP95),
    'totalMaxMs': _ms(totalMax),
    'jankyFrames': jankyFrames,
    'rasterJankyFrames': rasterJankyFrames,
    'jankPercent': frames == 0
        ? 0.0
        : double.parse((jankyFrames * 100 / frames).toStringAsFixed(1)),
  };
}

/// One scripted capture window: how to enter the state, how long to measure
/// and how to leave it again before the next phase.
class _PhaseSpec {
  final String name;
  final Duration duration;
  final Duration settle;
  final Future<void> Function() setUp;
  final Future<void> Function() tearDown;
  final void Function()? everySlice;

  const _PhaseSpec({
    required this.name,
    required this.duration,
    required this.setUp,
    required this.tearDown,
    this.settle = _settle,
    this.everySlice,
  });
}

class _SimHandle {
  final ProviderContainer container;
  const _SimHandle(this.container);

  SoilScopeGame? get game => container.read(soilScopeGameProviderProvider);
}

double _ms(num micros) => double.parse((micros / 1000).toStringAsFixed(2));

double _medianOf(Iterable<num> values) {
  final list = values.map((v) => v.toDouble()).toList()..sort();
  if (list.isEmpty) return 0;
  final middle = list.length ~/ 2;
  final median = list.length.isOdd
      ? list[middle]
      : (list[middle - 1] + list[middle]) / 2;
  return double.parse(median.toStringAsFixed(2));
}

double _round(double value) => double.parse(value.toStringAsFixed(1));

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Let the engine drive frames at vsync; the harness only observes them.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'phase 4 device profile capture',
    (tester) async {
      final sim = await _loadSimulation(tester);
      final media = MediaQuery.of(
        tester.element(find.byType(MainSimulationScreen)),
      );

      // Let textures, particles and the isolate reach steady state before the
      // first capture; startup frames are excluded from every window.
      await _idle(tester, _warmUp);

      final seed = _seedOverride != 0
          ? _seedOverride
          : DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
      var panStep = 0;

      final specs = <_PhaseSpec>[
        _PhaseSpec(
          name: 'steady_simulation',
          duration: _steadyWindow,
          setUp: () async {},
          tearDown: () async {},
        ),
        _PhaseSpec(
          name: 'pinned_inspection',
          duration: _stateWindow,
          setUp: () async {
            sim.game
              ?..focusNextInspectable()
              ..activateKeyboardTarget();
          },
          tearDown: () async {
            sim.container.read(uIStateProvider.notifier).setHoverInfo(null);
            sim.container
                .read(simulationSessionProvider.notifier)
                .selectLayer(null);
            sim.game?.clearKeyboardTarget();
          },
        ),
        _PhaseSpec(
          name: 'microscope_open',
          duration: _stateWindow,
          settle: const Duration(seconds: 3),
          setUp: () async {
            sim.container
                .read(simulationSessionProvider.notifier)
                .toggleMicroscope();
          },
          tearDown: () async {
            sim.container
                .read(simulationSessionProvider.notifier)
                .toggleMicroscope();
          },
        ),
        _PhaseSpec(
          name: 'pan_zoom',
          duration: _stateWindow,
          setUp: () async {
            sim.game?.resetCamera();
          },
          tearDown: () async {
            sim.game?.resetCamera();
          },
          everySlice: () {
            final target = sim.game;
            if (target == null) return;
            panStep++;
            final direction = panStep.isEven ? 1.0 : -1.0;
            target.panCameraBy(Vector2(140 * direction, 0));
            target.zoomCameraBy(panStep.isEven ? 1.08 : 1 / 1.08);
          },
        ),
      ];

      if (_attribution) {
        specs.addAll([
          _PhaseSpec(
            name: 'paused_simulation',
            duration: _stateWindow,
            setUp: () async {
              sim.container.read(simulationProvider.notifier).stop();
            },
            tearDown: () async {
              sim.container.read(simulationProvider.notifier).start();
            },
          ),
          _PhaseSpec(
            name: 'reduced_motion',
            duration: _stateWindow,
            setUp: () async {
              sim.game?.setReducedMotion(true);
            },
            tearDown: () async {
              sim.game?.setReducedMotion(false);
            },
          ),
        ]);
      }

      // Rotate so no phase is systematically late in a drifting session. With
      // three runs, each phase lands once early, once mid and once late.
      final rotation = seed % specs.length;
      final ordered = <_PhaseSpec>[
        for (var i = 0; i < specs.length; i++)
          specs[(i + rotation) % specs.length],
      ];

      final order = <String>[];
      final results = <_PhaseStats>[];
      for (final spec in ordered) {
        order.add(spec.name);
        await spec.setUp();
        await _idle(tester, spec.settle);
        results.add(
          await _capture(
            tester,
            spec.name,
            spec.duration,
            everySlice: spec.everySlice,
          ),
        );
        await spec.tearDown();
        await _idle(tester, _settle);
      }

      if (_attribution) {
        // Control stays last: it exists to detect drift across the session.
        order.add('steady_control');
        results.add(await _capture(tester, 'steady_control', _stateWindow));
      }

      final payload = <String, Object?>{
        'scenario': _scenarioId,
        'profileMode': kProfileMode,
        'seed': seed,
        'phaseOrder': order,
        'device': {
          'platform': defaultTargetPlatform.name,
          'logicalWidth': _round(media.size.width),
          'logicalHeight': _round(media.size.height),
          'devicePixelRatio': media.devicePixelRatio,
        },
        'frameBudgetMs': double.parse(_frameBudgetMs.toStringAsFixed(2)),
        'phases': results.map((r) => r.toJson()).toList(),
      };

      binding.reportData = {'phase4': payload};
      debugPrint('PHASE4_RESULT ${jsonEncode(payload)}');

      expect(results, hasLength(_attribution ? 7 : 4));
      if (kProfileMode) {
        final captured = results.fold<int>(0, (sum, r) => sum + r.frames);
        expect(
          captured,
          greaterThan(60),
          reason:
              'profile mode should report FrameTiming for every rendered '
              'frame; $captured frames across the session means the harness did '
              'not observe real frames',
        );
      } else {
        debugPrint(
          'PHASE4_WARNING debug build: FrameTiming is not reported. '
          'Run with --profile for device numbers.',
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 8)),
    skip: _ab,
  );

  testWidgets(
    'phase 4 interleaved backdrop-blur A/B',
    (tester) async {
      final sim = await _loadSimulation(tester);
      final media = MediaQuery.of(
        tester.element(find.byType(MainSimulationScreen)),
      );
      addTearDown(() => BlurSurface.backdropBlurEnabled.value = false);

      sim.container.read(simulationSessionProvider.notifier).toggleMicroscope();
      await _idle(tester, const Duration(seconds: 3));

      // A = backdrop blur (previous behaviour), B = panel only (the change).
      // Short adjacent A/B pairs keep a drifting scene from swamping the
      // signal: the scene grows within a minute and a long block design would
      // measure the drift instead of the surface.
      const pattern = [
        'A',
        'B',
        'A',
        'B',
        'A',
        'B',
        'A',
        'B',
        'A',
        'B',
        'A',
        'B',
      ];
      final blocks = <Map<String, Object?>>[];
      final byCondition = {'A': <_PhaseStats>[], 'B': <_PhaseStats>[]};

      for (final condition in pattern) {
        BlurSurface.backdropBlurEnabled.value = condition == 'A';
        await _idle(tester, const Duration(seconds: 1));
        final stats = await _capture(
          tester,
          'microscope_blur_$condition',
          _abWindow,
        );
        byCondition[condition]!.add(stats);
        blocks.add({
          ...stats.toJson(),
          'condition': condition,
          // Proves the switch changed the tree rather than being a no-op.
          'backdropFilters': find.byType(BackdropFilter).evaluate().length,
        });
      }

      BlurSurface.backdropBlurEnabled.value = false;
      sim.container.read(simulationSessionProvider.notifier).toggleMicroscope();

      final blurRaster = _medianOf(
        byCondition['A']!.map((stats) => stats.rasterP50),
      );
      final panelRaster = _medianOf(
        byCondition['B']!.map((stats) => stats.rasterP50),
      );
      final blurBuild = _medianOf(
        byCondition['A']!.map((stats) => stats.buildP50),
      );
      final panelBuild = _medianOf(
        byCondition['B']!.map((stats) => stats.buildP50),
      );

      // Pair each A block with the B block that follows it.
      final pairedDeltas = <double>[];
      for (var i = 0; i + 1 < pattern.length; i += 2) {
        if (pattern[i] != 'A' || pattern[i + 1] != 'B') continue;
        final a = byCondition['A']![i ~/ 2].rasterP50;
        final b = byCondition['B']![i ~/ 2].rasterP50;
        pairedDeltas.add((a - b) / 1000);
      }

      final payload = <String, Object?>{
        'phase': 'microscope_blur_ab',
        'profileMode': kProfileMode,
        'pattern': pattern,
        'blocksPerCondition': byCondition['A']!.length,
        'blurRasterP50Ms': _ms(blurRaster),
        'panelRasterP50Ms': _ms(panelRaster),
        'rasterDeltaMs': _ms(blurRaster - panelRaster),
        'rasterDeltaPercent': blurRaster == 0
            ? 0
            : double.parse(
                (((blurRaster - panelRaster) * 100) / blurRaster)
                    .toStringAsFixed(1),
              ),
        'blurBuildP50Ms': _ms(blurBuild),
        'panelBuildP50Ms': _ms(panelBuild),
        'pairedRasterDeltasMs': [
          for (final delta in pairedDeltas)
            double.parse(delta.toStringAsFixed(2)),
        ],
        'pairedRasterDeltaMedianMs': _medianOf(pairedDeltas),
        'pairedRasterDeltaMeanMs': double.parse(
          (pairedDeltas.isEmpty
                  ? 0
                  : pairedDeltas.reduce((a, b) => a + b) / pairedDeltas.length)
              .toStringAsFixed(2),
        ),
        'device': {
          'platform': defaultTargetPlatform.name,
          'logicalWidth': _round(media.size.width),
          'logicalHeight': _round(media.size.height),
          'devicePixelRatio': media.devicePixelRatio,
        },
        'blocks': blocks,
      };

      binding.reportData = {'phase4Ab': payload};
      debugPrint('PHASE4_AB ${jsonEncode(payload)}');

      expect(byCondition['A'], hasLength(6));
      expect(byCondition['B'], hasLength(6));
      expect(pairedDeltas, hasLength(6));
      final blurLayers = blocks
          .where((block) => block['condition'] == 'A')
          .map((block) => block['backdropFilters']! as int);
      final panelLayers = blocks
          .where((block) => block['condition'] == 'B')
          .map((block) => block['backdropFilters']! as int);
      expect(
        blurLayers.every((count) => count > 0),
        isTrue,
        reason: 'the blur condition must mount a BackdropFilter',
      );
      expect(
        panelLayers.every((count) => count == 0),
        isTrue,
        reason: 'the panel condition must not mount a BackdropFilter',
      );
      if (kProfileMode) {
        expect(blocks.every((block) => (block['frames']! as int) > 0), isTrue);
      }
    },
    timeout: const Timeout(Duration(minutes: 6)),
    skip: !_ab,
  );
}

Future<_SimHandle> _loadSimulation(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'gesture_intro_seen_v1': true,
    'soilscope_onboarding_completed_v1': true,
  });
  tester.binding.platformDispatcher.defaultRouteNameTestValue =
      '/simulation/$_scenarioId';
  addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);

  await tester.pumpWidget(const ProviderScope(child: SoilScopeApp()));
  await tester.pump();

  final container = ProviderScope.containerOf(
    tester.element(find.byType(MainSimulationScreen)),
    listen: false,
  );
  final sim = _SimHandle(container);

  await _waitFor(
    tester,
    () =>
        container.read(simulationProvider).isRunning &&
        (sim.game?.children.isNotEmpty ?? false),
    label: 'the simulation to start',
  );
  return sim;
}

Future<void> _waitFor(
  WidgetTester tester,
  bool Function() condition, {
  required String label,
  Duration timeout = const Duration(seconds: 90),
}) async {
  final clock = Stopwatch()..start();
  while (clock.elapsed < timeout) {
    if (condition()) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }
  fail('Timed out waiting for $label after ${timeout.inSeconds}s');
}

/// Waits in real time so the engine keeps presenting vsync-driven frames.
Future<void> _idle(WidgetTester tester, Duration duration) async {
  await _capture(tester, 'warmup', duration, report: false);
}

Future<_PhaseStats> _capture(
  WidgetTester tester,
  String name,
  Duration duration, {
  void Function()? everySlice,
  bool report = true,
}) async {
  final timings = <FrameTiming>[];
  void collect(List<FrameTiming> batch) => timings.addAll(batch);

  SchedulerBinding.instance.addTimingsCallback(collect);
  final clock = Stopwatch()..start();
  try {
    while (clock.elapsed < duration) {
      everySlice?.call();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
    }
  } finally {
    SchedulerBinding.instance.removeTimingsCallback(collect);
  }

  final rendered = timings
      .where(
        (t) =>
            t.buildDuration > Duration.zero || t.rasterDuration > Duration.zero,
      )
      .toList();
  final stats = _PhaseStats(
    name: name,
    windowSeconds: clock.elapsedMicroseconds / 1000000,
    timings: rendered,
  );
  if (report) {
    debugPrint('PHASE4_PHASE ${jsonEncode(stats.toJson())}');
  }
  return stats;
}
