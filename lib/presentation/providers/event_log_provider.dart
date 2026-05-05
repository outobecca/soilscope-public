import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../l10n/app_localizations.dart';

part 'event_log_provider.g.dart';

class EventLogEntry {
  final String key;
  final List<String> params;
  final double timestamp; // Simulation time
  final DateTime realTime;

  EventLogEntry({
    required this.key,
    this.params = const [],
    required this.timestamp,
    required this.realTime,
  });

  String getLocalizedMessage(AppLocalizations l10n) {
    switch (key) {
      case 'insight_droughtStress':
        return l10n.insight_droughtStress;
      case 'insight_vigorousGrowth':
        return l10n.insight_vigorousGrowth;
      case 'insight_chainReaction':
        return l10n.insight_chainReaction(params.isNotEmpty ? params[0] : '');
      case 'insight_phosphateLockup':
        return l10n.insight_phosphateLockup(
          params.isNotEmpty ? params[0] : '',
          params.length > 1 ? params[1] : '',
        );
      case 'insight_leachingAlert':
        return l10n.insight_leachingAlert;
      case 'insight_nitrogenLock':
        return l10n.insight_nitrogenLock;
      case 'insight_thermalInertia':
        return l10n.insight_thermalInertia;
      case 'insight_lowAlbedo':
        return l10n.insight_lowAlbedo;
      case 'insight_radiativeCooling':
        return l10n.insight_radiativeCooling;
      case 'insight_hungryMicrobes':
        return l10n.insight_hungryMicrobes;
      case 'insight_bioGlueActive':
        return l10n.insight_bioGlueActive;
      case 'insight_activeCycling':
        return l10n.insight_activeCycling;
      case 'insight_physicalBarrier':
        return l10n.insight_physicalBarrier;
      case 'insight_runoffRisk':
        return l10n.insight_runoffRisk(
          params.isNotEmpty ? params[0] : '',
          params.length > 1 ? params[1] : '',
        );
      case 'insight_surfaceSealing':
        return l10n.insight_surfaceSealing;
      case 'insight_bioArmor':
        return l10n.insight_bioArmor;
      case 'insight_structureCrisis':
        return l10n.insight_structureCrisis;
      case 'insight_resilientStructure':
        return l10n.insight_resilientStructure;
      case 'insight_biologicalDesert':
        return l10n.insight_biologicalDesert;
      case 'insight_metabolicStress':
        return l10n.insight_metabolicStress;
      case 'insight_tillageTradeoff':
        return l10n.insight_tillageTradeoff;
      default:
        return key;
    }
  }
}

@riverpod
class EventLog extends _$EventLog {
  @override
  List<EventLogEntry> build() => [];

  void addEvent(String rawKey, double simulationTime) {
    final parts = rawKey.split('|');
    final key = parts[0];
    final params = parts.sublist(1);

    if (state.isNotEmpty &&
        state.first.key == key &&
        state.first.timestamp == simulationTime) {
      return;
    }

    final recentMatches = state.where((e) => e.key == key);
    if (recentMatches.isNotEmpty) {
      final lastTime = recentMatches.first.timestamp;
      if (simulationTime - lastTime < 3600) {
        return;
      }
    }

    state = [
      EventLogEntry(
        key: key,
        params: params,
        timestamp: simulationTime,
        realTime: DateTime.now(),
      ),
      ...state,
    ];
  }

  void clear() {
    state = [];
  }
}
