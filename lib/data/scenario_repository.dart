import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../core/debug_log.dart';
import '../domain/models/scenario.dart';

class ScenarioRepository {
  static Future<List<Scenario>>? _cached;

  /// Scenarios are immutable bundled assets. Every screen visit — and every
  /// re-subscription of `scenariosProvider` — used to read and parse all four
  /// files again. Cache the future the same way [ReferenceDatasetRepository]
  /// caches its dataset.
  static Future<List<Scenario>> getScenarios() async {
    final cached = _cached;
    if (cached != null) return cached;

    final future = _loadScenarios();
    _cached = future;
    try {
      return await future;
    } catch (_) {
      // Do not keep a failed load: a retry must read the assets again.
      if (identical(_cached, future)) _cached = null;
      rethrow;
    }
  }

  /// Test hook: forget the cached list so a different bundle can be used.
  static void resetCache() => _cached = null;

  static Future<List<Scenario>> _loadScenarios() async {
    final List<String> assetPaths = [
      'assets/scenarios/compacted_clay.json',
      'assets/scenarios/nitrate_leaching.json',
      'assets/scenarios/nitrogen_lock.json',
      'assets/scenarios/waterlogging.json',
    ];

    final List<Future<Scenario?>> scenarioFutures = assetPaths.map((
      path,
    ) async {
      try {
        final String jsonStr = await rootBundle.loadString(path);
        final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
        return Scenario.fromJson(jsonMap);
      } on FlutterError catch (e, stack) {
        debugLog('ScenarioRepository: missing or unreadable asset $path. $e');
        debugPrintStack(stackTrace: stack);
      } on FormatException catch (e, stack) {
        debugLog('ScenarioRepository: invalid JSON in $path. $e');
        debugPrintStack(stackTrace: stack);
      } catch (e, stack) {
        debugLog('ScenarioRepository: unexpected error for $path. $e');
        debugPrintStack(stackTrace: stack);
      }
      return null;
    }).toList();

    final List<Scenario?> results = await Future.wait(scenarioFutures);
    final List<Scenario> scenarios = results.whereType<Scenario>().toList();

    if (scenarios.isEmpty) {
      throw StateError(
        'ScenarioRepository: no scenarios could be loaded from assets.',
      );
    }

    return scenarios;
  }
}
