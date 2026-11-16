import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/biophysical_state.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/simulation_session_provider.dart';
import '../../providers/ui_state_provider.dart';

/// The process a hotspot represents. Each process selects the model graph
/// shown by the Logic Lab and the simulation value that can be edited there.
enum LogicLabProcess {
  nitrification('nitrification'),
  waterRetention('vangenuchten'),
  photosynthesis('farquhar'),
  redox('redox'),
  diffusion('chemotaxis');

  const LogicLabProcess(this.exampleKey);

  /// Key used by the existing example initializers in the Lab.
  final String exampleKey;

  static LogicLabProcess? fromKey(String? key) {
    if (key == null) return null;
    final normalized = key.toLowerCase();
    for (final process in values) {
      if (process.name.toLowerCase() == normalized ||
          process.exampleKey == normalized) {
        return process;
      }
    }
    switch (normalized) {
      case 'water':
      case 'moisture':
        return LogicLabProcess.waterRetention;
      case 'photo':
      case 'photosynthesis':
        return LogicLabProcess.photosynthesis;
      case 'chemotaxis':
      case 'diffusion':
        return LogicLabProcess.diffusion;
      default:
        return null;
    }
  }
}

/// A simulation value exposed by the Lab for the selected hotspot.
enum LogicLabSimulationLink {
  ammonium,
  waterContent,
  solarRadiation,
  redoxPotential,
  organicNitrogen,
}

/// Everything the Lab needs to show the hotspot's process, layer and data.
class LogicLabLaunchContext {
  final LogicLabProcess process;
  final String title;
  final String description;
  final Map<String, String> stats;
  final String? formula;
  final String? sourceId;
  final String? layerId;
  final bool isAtmosphere;
  final Color? accentColor;

  const LogicLabLaunchContext({
    required this.process,
    required this.title,
    required this.description,
    this.stats = const {},
    this.formula,
    this.sourceId,
    this.layerId,
    this.isAtmosphere = false,
    this.accentColor,
  });

  LogicLabSimulationLink get link {
    switch (process) {
      case LogicLabProcess.nitrification:
        return LogicLabSimulationLink.ammonium;
      case LogicLabProcess.waterRetention:
        return LogicLabSimulationLink.waterContent;
      case LogicLabProcess.photosynthesis:
        return LogicLabSimulationLink.solarRadiation;
      case LogicLabProcess.redox:
        return LogicLabSimulationLink.redoxPotential;
      case LogicLabProcess.diffusion:
        return LogicLabSimulationLink.organicNitrogen;
    }
  }

  /// Resolves a hover/inspection card into a Lab context.
  ///
  /// Source ids are preferred because they are stable identifiers; titles are
  /// used only as a fallback for older callers that do not provide one.
  factory LogicLabLaunchContext.fromHoverInfo({
    required HoverInfo info,
    required BiophysicalState state,
    String? selectedLayerId,
  }) {
    final process = _resolveProcess(info);
    final layerId = _resolveLayerId(
      info: info,
      state: state,
      selectedLayerId: selectedLayerId,
    );
    final source = (info.sourceId ?? '').toLowerCase();

    return LogicLabLaunchContext(
      process: process,
      title: info.title,
      description: info.description,
      stats: Map<String, String>.unmodifiable(info.stats ?? const {}),
      formula: info.formula,
      sourceId: info.sourceId,
      layerId: layerId,
      isAtmosphere:
          selectedLayerId == 'atmosphere' ||
          source.contains('selection-atmosphere'),
      accentColor: info.accentColor,
    );
  }

  static LogicLabProcess _resolveProcess(HoverInfo info) {
    final hinted = LogicLabProcess.fromKey(info.logicLabModel);
    if (hinted != null) return hinted;

    final source = (info.sourceId ?? '').toLowerCase();
    final title = info.title.toLowerCase();

    if (source.startsWith('inspection-')) {
      switch (source.substring('inspection-'.length)) {
        case 'leaf':
        case 'apicalmeristem':
          return LogicLabProcess.photosynthesis;
        case 'stem':
        case 'soilstructure':
          return LogicLabProcess.waterRetention;
        case 'root':
        case 'rhizosphere':
          return LogicLabProcess.diffusion;
        case 'microbe':
          return LogicLabProcess.nitrification;
      }
    }

    if (source.startsWith('selection-')) {
      if (source.contains('atmosphere')) return LogicLabProcess.photosynthesis;
      if (source.contains('soillayer')) return LogicLabProcess.waterRetention;
      if (source.contains('enzymes')) return LogicLabProcess.nitrification;
    }

    if (source.startsWith('hotspot-')) {
      final upperTitle = info.title.toUpperCase();
      if (RegExp(r'-\s*(PH|O2)\s*$').hasMatch(upperTitle)) {
        return LogicLabProcess.redox;
      }
      if (RegExp(r'-\s*(W)\s*$').hasMatch(upperTitle)) {
        return LogicLabProcess.waterRetention;
      }
      if (RegExp(r'-\s*(P|K)\s*$').hasMatch(upperTitle)) {
        return LogicLabProcess.diffusion;
      }
      return LogicLabProcess.nitrification;
    }

    if (source.contains('plant-root')) return LogicLabProcess.diffusion;
    if (source.contains('photosynthesis') ||
        source.contains('sun-') ||
        source.contains('gas-flux') ||
        source.contains('plant-')) {
      return LogicLabProcess.photosynthesis;
    }
    if (source.contains('redox') || source.contains('ph-gradient')) {
      return LogicLabProcess.redox;
    }
    if (source.contains('diffusion') ||
        source.contains('rhizosphere') ||
        source.contains('mycorrh') ||
        source.contains('symbiosis')) {
      return LogicLabProcess.diffusion;
    }
    if (source.contains('wetting') ||
        source.contains('capillary') ||
        source.contains('water-flow') ||
        source.contains('soil-layer')) {
      return LogicLabProcess.waterRetention;
    }
    if (source.contains('nitrous') ||
        source.contains('bubble') ||
        source.contains('process-') ||
        source.contains('nitro')) {
      return LogicLabProcess.nitrification;
    }

    if (title.contains('photo') || title.contains('leaf')) {
      return LogicLabProcess.photosynthesis;
    }
    if (title.contains('redox') || title.contains('hapetus')) {
      return LogicLabProcess.redox;
    }
    if (title.contains('water') ||
        title.contains('moisture') ||
        title.contains('wetting') ||
        title.contains('capillary')) {
      return LogicLabProcess.waterRetention;
    }
    if (title.contains('diffusion') ||
        title.contains('rhizo') ||
        title.contains('mycorrh')) {
      return LogicLabProcess.diffusion;
    }
    return LogicLabProcess.nitrification;
  }

  static String? _resolveLayerId({
    required HoverInfo info,
    required BiophysicalState state,
    String? selectedLayerId,
  }) {
    bool exists(String id) =>
        state.profile.layers.any((layer) => layer.id == id);

    if (info.layerId != null && exists(info.layerId!)) {
      return info.layerId;
    }
    if (selectedLayerId != null &&
        selectedLayerId != 'atmosphere' &&
        exists(selectedLayerId)) {
      return selectedLayerId;
    }

    final source = info.sourceId ?? '';
    const prefix = 'soil-layer-';
    if (source.startsWith(prefix)) {
      final candidate = source.substring(prefix.length);
      if (exists(candidate)) return candidate;
    }
    return null;
  }
}

/// Opens the Lab with the selected hotspot as its context.
///
/// The card itself stays pinned in the provider, so returning from the Lab
/// restores the same inspection and its canvas highlight.
void openLogicLabForInfo(BuildContext context, WidgetRef ref, HoverInfo info) {
  final state = ref.read(displayedSimulationStateProvider);
  final selectedLayerId = ref.read(simulationSessionProvider).selectedLayerId;
  final launchContext = LogicLabLaunchContext.fromHoverInfo(
    info: info,
    state: state,
    selectedLayerId: selectedLayerId,
  );

  Navigator.of(context).pushNamed('/logic_lab', arguments: launchContext);
}
