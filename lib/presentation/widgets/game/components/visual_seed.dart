import 'dart:math' as math;

/// Deterministic seed helper for cosmetic effects.
///
/// Visual randomness must not use `Random.secure()`: two runs with the same
/// scenario and state should look the same, and a rebuilt effect should keep
/// its appearance instead of receiving a fresh random identity. Derive seeds
/// from stable identities (scenario, entity, effect kind) rather than object
/// identity hashes.
int visualSeed(Iterable<Object?> parts) {
  var hash = 0x811C9DC5;
  for (final part in parts) {
    final value = part?.toString() ?? '';
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    hash ^= 0x1F;
    hash = (hash * 0x01000193) & 0x7FFFFFFF;
  }
  return hash == 0 ? 1 : hash;
}

math.Random visualRandom(Iterable<Object?> parts) =>
    math.Random(visualSeed(parts));
