import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/simulation_plot.dart';

void main() {
  group('SimulationPlot', () {
    test('defines a one-square-metre plot centred on the plant', () {
      expect(SimulationPlot.sideM, 1.0);
      expect(SimulationPlot.areaM2, 1.0);
      expect(SimulationPlot.centerNormalizedX, 0.5);
    });

    test('normalized x spans half a metre either side of the plant', () {
      expect(SimulationPlot.normalizedToMetres(0.0), closeTo(-0.5, 1e-12));
      expect(SimulationPlot.normalizedToMetres(0.5), closeTo(0.0, 1e-12));
      expect(SimulationPlot.normalizedToMetres(1.0), closeTo(0.5, 1e-12));

      expect(SimulationPlot.metresToNormalized(-0.5), closeTo(0.0, 1e-12));
      expect(SimulationPlot.metresToNormalized(0.0), closeTo(0.5, 1e-12));
      expect(SimulationPlot.metresToNormalized(0.5), closeTo(1.0, 1e-12));
    });

    test('clamps positions outside the plot', () {
      expect(SimulationPlot.normalizedToMetres(-2), closeTo(-0.5, 1e-12));
      expect(SimulationPlot.normalizedToMetres(2), closeTo(0.5, 1e-12));
      expect(SimulationPlot.metresToNormalized(-2), 0.0);
      expect(SimulationPlot.metresToNormalized(2), 1.0);
    });

    test('converts depth and volume over the full plot', () {
      expect(SimulationPlot.volumeForDepth(0.010), closeTo(0.010, 1e-12));
      expect(SimulationPlot.depthForVolume(0.010), closeTo(0.010, 1e-12));
    });

    test('converts physical distances without applying the centre offset', () {
      expect(SimulationPlot.distanceToNormalized(0.005), closeTo(0.005, 1e-12));
      expect(SimulationPlot.normalizedToDistance(0.005), closeTo(0.005, 1e-12));
    });
  });
}
