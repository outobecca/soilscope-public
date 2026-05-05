import 'dart:typed_data';

/// Pre-allocated buffer for tracking aggregate nutrient sinks across layers
/// to prevent per-substep Map object allocations and GC churn.
class NutrientBuffer {
  final Float64List nitrate;
  final Float64List ammonium;
  final Float64List potassium;
  final Float64List phosphate;
  final Float64List calcium;
  final Float64List magnesium;
  final Float64List carbonSource;

  NutrientBuffer(int length)
      : nitrate = Float64List(length),
        ammonium = Float64List(length),
        potassium = Float64List(length),
        phosphate = Float64List(length),
        calcium = Float64List(length),
        magnesium = Float64List(length),
        carbonSource = Float64List(length);

  void clear() {
    for (int i = 0; i < nitrate.length; i++) {
      nitrate[i] = 0.0;
      ammonium[i] = 0.0;
      potassium[i] = 0.0;
      phosphate[i] = 0.0;
      calcium[i] = 0.0;
      magnesium[i] = 0.0;
      carbonSource[i] = 0.0;
    }
  }
}
