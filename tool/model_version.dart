// Prints the model parameter set identity used by saved sessions, the
// validation reference and profile captures.
//
//   dart run tool/model_version.dart
//
// Run it after changing a simulation constant; the fingerprint changes and the
// validation gate fails until the reference is regenerated deliberately.
import 'package:soilscope/domain/models/model_parameter_set.dart';

void main() {
  // ignore: avoid_print
  print('model: ${ModelParameterSet.current.label}');
  // ignore: avoid_print
  print(canonicalModelJson());
}
