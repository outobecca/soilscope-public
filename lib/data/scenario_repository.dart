import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../core/debug_log.dart';
import '../domain/models/scenario.dart';

class ScenarioRepository {
  static Future<List<Scenario>> getScenarios() async {
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
