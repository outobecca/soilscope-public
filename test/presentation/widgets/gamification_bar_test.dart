import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/tutorial_provider.dart';
import 'package:soilscope/presentation/widgets/gamification_bar.dart';

const _testProfile = SoilProfile(
  id: 'gamification-test',
  name: 'Gamification test',
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
);

const _testState = BiophysicalState(
  profile: _testProfile,
  plants: [],
  timeElapsed: 0,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  for (final size in const [Size(390, 844), Size(1200, 800)]) {
    testWidgets(
      'tutorial icon starts the tutorial at ${size.width}x${size.height}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [simulationProvider.overrideWithValue(_testState)],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              home: const Scaffold(body: GamificationBar()),
            ),
          ),
        );
        await tester.pump();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(GamificationBar)),
        );
        expect(container.read(tutorialProvider).isVisible, isFalse);

        final tutorialIcon = find.byIcon(Icons.school_rounded);
        expect(
          tutorialIcon,
          findsOneWidget,
          reason: 'the tutorial action belongs in the gamification bar',
        );

        await tester.tap(tutorialIcon);
        await tester.pump();

        expect(container.read(tutorialProvider).isVisible, isTrue);
      },
    );
  }
}
