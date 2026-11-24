import 'dart:convert';

import '../../core/model_config.dart';
import 'simulation_plot.dart';

/// The simulation parameter set a run was produced with.
///
/// Only model-affecting constants are listed. Visual constants (particle
/// speeds, node spacing, zoom thresholds) are deliberately excluded so a
/// rendering change does not invalidate a scientific reference.
///
/// [fingerprint] is a stable 32-bit hash of the id, version and every listed
/// value. It is recorded next to saved runs, reference datasets and profile
/// captures, so a result can be traced to the exact parameterisation that
/// produced it. Changing any listed constant changes the fingerprint; that is
/// intentional and fails the validation gate until the reference is
/// regenerated with provenance.
class ModelParameterSet {
  static const String currentId = 'soilscope-core';
  static const int currentVersion = 4;

  /// Every configured model value plus the plot geometry. Order is
  /// irrelevant; [fingerprint] sorts the keys first. Reading
  /// [ModelConfig.values] here is what makes a runtime configuration override
  /// part of the model identity rather than only documentation.
  static Map<String, double> _currentParameters() => {
    ...ModelConfig.values,
    // One-square-metre plot geometry. Root-domain bounds, distance
    // conversions and irrigation volumes all resolve through these values, so
    // resizing the plot is a model change, not a rendering change.
    'plotAreaM2': SimulationPlot.areaM2,
    'plotCenterNormalizedX': SimulationPlot.centerNormalizedX,
    'plotMaxNormalizedX': SimulationPlot.maxNormalizedX,
    'plotMinNormalizedX': SimulationPlot.minNormalizedX,
    'plotSideM': SimulationPlot.sideM,
  };

  final String id;
  final int version;
  final String fingerprint;
  final Map<String, double> parameters;

  ModelParameterSet._({
    required this.id,
    required this.version,
    required this.fingerprint,
    required this.parameters,
  });

  factory ModelParameterSet({
    required String id,
    required int version,
    required Map<String, double> parameters,
  }) {
    if (parameters.isEmpty) {
      throw ArgumentError.value(parameters, 'parameters', 'must not be empty');
    }
    for (final entry in parameters.entries) {
      if (!entry.value.isFinite) {
        throw ArgumentError('Parameter ${entry.key} is not finite');
      }
    }
    final sorted = Map<String, double>.fromEntries(
      parameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return ModelParameterSet._(
      id: id,
      version: version,
      fingerprint: _fingerprint(id, version, sorted),
      parameters: Map.unmodifiable(sorted),
    );
  }

  static ModelParameterSet get current => ModelParameterSet(
    id: currentId,
    version: currentVersion,
    parameters: _currentParameters(),
  );

  /// Compact record for saved sessions, references and captures.
  Map<String, Object?> toJson() => {
    'id': id,
    'version': version,
    'fingerprint': fingerprint,
  };

  /// Full record, for reports and reproducibility checks.
  Map<String, Object?> toCanonicalJson() => {
    ...toJson(),
    'parameters': Map<String, double>.from(parameters),
  };

  String get label => '$id v$version ($fingerprint)';

  /// Parses a compact record. Returns null for a missing or malformed block so
  /// old saves and fixtures stay readable.
  static ModelParameterSet? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final version = raw['version'];
    final fingerprint = raw['fingerprint'];
    if (id is! String || id.trim().isEmpty) return null;
    if (version is! int || version <= 0) return null;
    if (fingerprint is! String || fingerprint.trim().isEmpty) return null;
    return ModelParameterSet._(
      id: id,
      version: version,
      fingerprint: fingerprint,
      parameters: const {},
    );
  }

  bool sameAsCurrent() =>
      id == current.id &&
      version == current.version &&
      fingerprint == current.fingerprint;

  @override
  String toString() => label;

  /// FNV-1a 32-bit, split into 16-bit halves so the arithmetic stays exact on
  /// the web (where ints are doubles above 2^53).
  static String _fingerprint(
    String id,
    int version,
    Map<String, double> parameters,
  ) {
    final canonical = StringBuffer('$id@$version;');
    parameters.forEach((key, value) {
      canonical
        ..write(key)
        ..write('=')
        ..write(value)
        ..write(';');
    });
    var hash = 0x811c9dc5;
    for (final codeUnit in canonical.toString().codeUnits) {
      hash ^= codeUnit;
      final low = (hash & 0xffff) * 0x01000193;
      final high = ((hash >> 16) & 0xffff) * 0x01000193;
      hash = (low + ((high & 0xffff) << 16)) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

/// Convenience for reports: the full parameter set as pretty JSON.
String canonicalModelJson() => const JsonEncoder.withIndent(
  '  ',
).convert(ModelParameterSet.current.toCanonicalJson());
