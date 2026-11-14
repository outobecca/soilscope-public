import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/widgets/game/components/canvas_hit_testing.dart';

void main() {
  group('CanvasHitTesting.worldRadius', () {
    test('keeps a stable screen radius at normal zoom', () {
      expect(
        CanvasHitTesting.worldRadius(zoom: 1.0, screenRadius: 24),
        closeTo(24, 1e-9),
      );
      expect(
        CanvasHitTesting.worldRadius(zoom: 2.0, screenRadius: 24),
        closeTo(12, 1e-9),
      );
    });

    test('grows the world radius when zoomed out', () {
      expect(
        CanvasHitTesting.worldRadius(zoom: 0.5, screenRadius: 24),
        closeTo(40, 1e-9),
      );
    });

    test('covers the drawn entity when zoomed in', () {
      expect(
        CanvasHitTesting.worldRadius(
          zoom: 10.0,
          screenRadius: 24,
          visualWorldRadius: 7,
        ),
        closeTo(7, 1e-9),
      );
    });

    test('falls back safely for an invalid zoom', () {
      expect(
        CanvasHitTesting.worldRadius(zoom: 0, screenRadius: 24),
        closeTo(24, 1e-9),
      );
    });
  });

  group('CanvasHitTesting.nearestIndex', () {
    test('picks the closest candidate inside the radius', () {
      final index = CanvasHitTesting.nearestIndex(
        xs: const [0, 10, 50],
        ys: const [0, 0, 0],
        x: 9,
        y: 2,
        radius: 10,
      );

      expect(index, 1);
    });

    test('returns null when all candidates are outside the radius', () {
      final index = CanvasHitTesting.nearestIndex(
        xs: const [0, 100],
        ys: const [0, 100],
        x: 50,
        y: 50,
        radius: 10,
      );

      expect(index, isNull);
    });

    test('respects stride and offset for packed particle data', () {
      final index = CanvasHitTesting.nearestIndex(
        xs: const [1, 0, 2, 30, 3, 40],
        ys: const [1, 0, 2, 30, 3, 40],
        x: 31,
        y: 31,
        radius: 5,
        stride: 2,
        offset: 1,
      );

      expect(index, 3);
    });

    test('finds the closest record in the packed particle layout', () {
      final data = Float32List.fromList([
        1, 0, 0, 0, 0, 0, 1, 0, 0, 0, // particle at (0, 0)
        2, 30, 30, 0, 0, 0, 1, 0, 0, 0, // particle at (30, 30)
      ]);

      expect(
        CanvasHitTesting.nearestPackedIndex(
          data: data,
          x: 31,
          y: 31,
          radius: 5,
        ),
        10,
      );
    });
  });
}
