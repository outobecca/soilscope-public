import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/providers/game_provider.dart';
import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/presentation/widgets/game/components/magnifier_group_component.dart';
import 'package:soilscope/presentation/widgets/game/components/process_magnifier_component.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

void main() {
  testWidgets(
    'microscope fades in while the inspection card pauses the canvas',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final scenario = Scenario(
        id: 'microscope_test',
        title: 'Microscope Test',
        description: 'Microscope viewport regression test',
        initialProfile: const SoilProfile(
          id: 'microscope-test',
          name: 'Microscope Test',
          layers: [
            SoilLayer(
              id: 'topsoil',
              depth: 0.0,
              thickness: 0.3,
              kSat: 1e-5,
              porosity: 0.45,
              thetaR: 0.05,
              vgAlpha: 2.0,
              vgN: 1.5,
              bulkDensity: 1200.0,
              waterContent: 0.25,
              temperature: 293.15,
              heatCapacity: 2.4e6,
              ph: 6.5,
              ec: 0.2,
              redoxPotential: 250.0,
              nitrateContent: 10.0,
              ammoniumContent: 5.0,
              phosphateContent: 3.0,
              microbialBiomass: 200.0,
              epsContent: 10.0,
              fungalHyphaeDensity: 20.0,
              necromass: 100.0,
              organicCarbon: 12000.0,
              particulateOrganicMatter: 6000.0,
              mineralAssociatedOrganicMatter: 6000.0,
              nitrogenContent: 1000.0,
              name: 'Topsoil',
            ),
          ],
          surfaceAlbedo: 0.2,
          slope: 0.05,
        ),
        weatherData: {'precip': 0.0, 'temp': 293.15, 'rh': 0.5},
      );

      tester.binding.platformDispatcher.defaultRouteNameTestValue =
          '/simulation/microscope_test';
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [scenariosProvider.overrideWith((ref) => [scenario])],
          child: Consumer(
            builder: (context, ref, child) {
              // Keep the auto-disposed game provider alive while the widget
              // under test registers its game instance.
              ref.watch(soilScopeGameProviderProvider);
              return child!;
            },
            child: const SoilScopeApp(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SoilScopeApp)),
        listen: false,
      );
      // The game provider is auto-disposed; keep a listener alive while the
      // test inspects the mounted game instance.
      final gameSubscription = container.listen(
        soilScopeGameProviderProvider,
        (previous, next) {},
        fireImmediately: true,
      );
      addTearDown(gameSubscription.close);

      SoilScopeGame? game;
      ProcessMagnifierComponent? rhizosphere;
      for (var i = 0; i < 20 && rhizosphere == null; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        game = container.read(soilScopeGameProviderProvider);
        if (game == null) continue;
        final groups = game.camera.viewport.children
            .query<MagnifierGroupComponent>()
            .toList();
        if (groups.isNotEmpty) {
          rhizosphere = groups.first.getMagnifier(MagnifierType.rhizosphere);
        }
      }

      expect(game, isNotNull, reason: 'the game should mount');
      expect(rhizosphere, isNotNull, reason: 'the microscope should mount');
      expect(rhizosphere!.opacity, 0.0);

      await tester.tap(find.byIcon(Icons.biotech_outlined).first);
      await tester.pump();
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(game!.isInspectionPaused, isTrue);
      expect(rhizosphere.isVisible, isTrue);
      expect(
        rhizosphere.opacity,
        greaterThan(0.0),
        reason: 'the paused game loop must still drive the microscope fade-in',
      );
    },
  );
}
