/// A reference profile used by the reference-check surface and the accuracy
/// gate.
///
/// The dataset carries its own provenance. `kind` distinguishes a synthetic
/// pattern from measured observations, so the UI cannot present one as the
/// other by accident. Each [ReferenceSeries] keeps its own layer, unit and
/// gate threshold, so depth-resolved measured profiles need no code changes.
class ReferenceDataset {
  ReferenceDataset({
    required this.id,
    required this.kind,
    required this.source,
    required this.provenanceNotes,
    required this.sampling,
    required this.generatedBy,
    required this.series,
    this.relativeTimes,
    this.timesSeconds,
  }) {
    if (kind != 'illustrative' && kind != 'measured') {
      throw FormatException('Unknown reference kind: $kind');
    }
    if (source.trim().isEmpty ||
        provenanceNotes.trim().isEmpty ||
        sampling.trim().isEmpty ||
        generatedBy.trim().isEmpty) {
      throw const FormatException(
        'Reference datasets must carry source, provenance, sampling and '
        'generation notes',
      );
    }
    if ((relativeTimes == null) == (timesSeconds == null)) {
      throw const FormatException(
        'Reference dataset needs exactly one of relativeTimes or timesSeconds',
      );
    }
    final times = timesSeconds ?? relativeTimes!;
    if (times.isEmpty) {
      throw const FormatException('Reference dataset needs sample times');
    }
    if (times.any((time) => time <= 0)) {
      throw const FormatException('Sample times must be positive');
    }
    for (var i = 1; i < times.length; i++) {
      if (times[i] <= times[i - 1]) {
        throw const FormatException('Sample times must increase');
      }
    }
    if (relativeTimes != null && relativeTimes!.any((f) => f > 1)) {
      throw const FormatException('Relative sample times must be ≤ 1');
    }
    if (series.isEmpty) {
      throw const FormatException('Reference dataset needs at least one series');
    }
    final keys = <String>{};
    for (final profile in series) {
      if (!keys.add(profile.key)) {
        throw FormatException('Duplicate reference series: ${profile.key}');
      }
      if (profile.values.length != times.length) {
        throw FormatException(
          '${profile.key} has ${profile.values.length} points for '
          '${times.length} sample times',
        );
      }
    }
  }

  final String id;
  final String kind;
  final String source;
  final String provenanceNotes;
  final String sampling;
  final String generatedBy;
  final List<double>? relativeTimes;
  final List<double>? timesSeconds;
  final List<ReferenceSeries> series;

  bool get isIllustrative => kind == 'illustrative';

  int get sampleCount => timesSeconds?.length ?? relativeTimes!.length;

  /// Resolves sample times against a run of [elapsedSeconds].
  /// Absolute times are used as-is; relative fractions are scaled.
  List<double> timesFor(double elapsedSeconds) {
    final absolute = timesSeconds;
    if (absolute != null) return absolute;
    return relativeTimes!
        .map((fraction) => fraction * elapsedSeconds)
        .toList(growable: false);
  }

  factory ReferenceDataset.fromJson(Map<String, dynamic> json) {
    String readString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Reference dataset is missing "$key"');
      }
      return value;
    }

    List<double>? readTimes(String key) {
      final raw = json[key];
      if (raw == null) return null;
      if (raw is! List) throw FormatException('"$key" must be a list');
      return raw
          .map((value) => (value as num).toDouble())
          .toList(growable: false);
    }

    final relativeTimes = readTimes('relativeTimes');
    final timesSeconds = readTimes('timesSeconds');

    final rawSeries = json['series'];
    if (rawSeries is! List || rawSeries.isEmpty) {
      throw const FormatException('Reference dataset is missing "series"');
    }
    final series = rawSeries.map((raw) {
      if (raw is! Map) {
        throw const FormatException('Reference series must be objects');
      }
      final values = (raw['values'] as List? ?? const [])
          .map((point) => (point as num).toDouble())
          .toList(growable: false);
      final threshold = raw['threshold'];
      if (threshold is! Map) {
        throw const FormatException('Reference series needs a threshold');
      }
      final nse = (threshold['nse'] as num?)?.toDouble();
      final rmse = (threshold['rmse'] as num?)?.toDouble();
      if (nse == null || rmse == null) {
        throw const FormatException(
          'Reference threshold needs nse and rmse',
        );
      }
      return ReferenceSeries(
        variable: raw['variable'] as String? ?? '',
        layerIndex: (raw['layerIndex'] as num?)?.toInt() ?? 0,
        layerId: raw['layerId'] as String?,
        unit: raw['unit'] as String? ?? '',
        values: values,
        threshold: ReferenceThreshold(nse: nse, rmse: rmse),
      );
    }).toList(growable: false);

    return ReferenceDataset(
      id: readString('id'),
      kind: readString('kind'),
      source: readString('source'),
      provenanceNotes: readString('provenanceNotes'),
      sampling: readString('sampling'),
      generatedBy: readString('generatedBy'),
      relativeTimes: relativeTimes,
      timesSeconds: timesSeconds,
      series: series,
    );
  }
}

class ReferenceSeries {
  ReferenceSeries({
    required this.variable,
    required this.layerIndex,
    required this.unit,
    required this.values,
    required this.threshold,
    this.layerId,
  }) {
    if (variable.isEmpty) {
      throw const FormatException('Reference series is missing "variable"');
    }
    if (layerIndex < 0) {
      throw const FormatException('Reference series layer cannot be negative');
    }
    if (unit.trim().isEmpty) {
      throw const FormatException('Reference series is missing a unit');
    }
    if (values.isEmpty) {
      throw const FormatException('Reference series has no values');
    }
  }

  final String variable;
  final int layerIndex;
  final String? layerId;
  final String unit;
  final List<double> values;
  final ReferenceThreshold threshold;

  String get key => '$variable@$layerIndex';

  String get layerLabel => layerId ?? 'layer ${layerIndex + 1}';
}

class ReferenceThreshold {
  const ReferenceThreshold({required this.nse, required this.rmse});

  final double nse;
  final double rmse;
}
