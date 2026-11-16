import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/simulation_plot.dart';
import 'package:soilscope/presentation/widgets/game/components/scene_coordinate_mapper.dart';

void main() {
  group('SceneCoordinateMapper plot geometry', () {
    const worldWidth = 1200.0;

    test('maps the plot centre to the scene centre', () {
      final expectedCenter =
          worldWidth * SimulationPlot.centerNormalizedX;
      expect(
        SceneCoordinateMapper.plotCenterX(worldWidth),
        closeTo(expectedCenter, 1e-12),
      );
      expect(
        SceneCoordinateMapper.mapRootX(
          SimulationPlot.centerNormalizedX,
          worldWidth,
        ),
        closeTo(expectedCenter, 1e-12),
      );
      expect(
        SceneCoordinateMapper.mapShootPosition(worldWidth, 300).x,
        closeTo(expectedCenter, 1e-12),
      );
    });

    test('maps both plot edges symmetrically around the plant', () {
      final left = SceneCoordinateMapper.mapRootX(0.0, worldWidth);
      final right = SceneCoordinateMapper.mapRootX(1.0, worldWidth);
      final center = SceneCoordinateMapper.plotCenterX(worldWidth);

      expect(center - left, closeTo(right - center, 1e-12));
      expect(
        right - left,
        closeTo(SceneCoordinateMapper.plotWidth(worldWidth), 1e-12),
      );
    });

    test('places roots and shoot on the same animation centre', () {
      final shoot = SceneCoordinateMapper.mapShootPosition(worldWidth, 300);

      expect(
        shoot.x,
        closeTo(
          SceneCoordinateMapper.mapRootX(
            SimulationPlot.centerNormalizedX,
            worldWidth,
          ),
          1e-12,
        ),
      );
      expect(shoot.y, 300);
    });

    test('clamps root positions to the plot', () {
      expect(
        SceneCoordinateMapper.mapRootX(-1, worldWidth),
        closeTo(SceneCoordinateMapper.mapRootX(0, worldWidth), 1e-12),
      );
      expect(
        SceneCoordinateMapper.mapRootX(2, worldWidth),
        closeTo(SceneCoordinateMapper.mapRootX(1, worldWidth), 1e-12),
      );
    });

    test('computes local root offsets from the plot width', () {
      final offset = SceneCoordinateMapper.rootOffsetX(0.8, 0.5, worldWidth);

      expect(
        offset,
        closeTo(SceneCoordinateMapper.plotWidth(worldWidth) * 0.3, 1e-12),
      );
    });
  });
}
