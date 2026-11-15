import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/data/reference_dataset_repository.dart';
import 'package:soilscope/domain/models/reference_dataset.dart';
import 'package:soilscope/domain/services/validation_reference_run.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/presentation/widgets/science/science_validation_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('illustrative reference is labeled and makes no field claim', (
    tester,
  ) async {
    ReferenceDatasetRepository.resetCache();
    final history = ValidationReferenceRun.run(hours: 8);
    final state = history.last.copyWith(history: history);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ScienceValidationTab(state: state)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Illustrative Pattern Check'), findsOneWidget);
    expect(find.text('ILLUSTRATIVE PATTERN'), findsOneWidget);
    expect(
      find.textContaining('NSE and RMSE measure pattern agreement'),
      findsOneWidget,
    );
    expect(find.textContaining('FLUXNET'), findsNothing);
    expect(find.textContaining('LUCAS'), findsNothing);
  });

  testWidgets('measured reference is labeled with its provenance', (
    tester,
  ) async {
    final history = ValidationReferenceRun.run(hours: 8);
    final state = history.last.copyWith(history: history);
    final reference = ReferenceDataset(
      id: 'measured_ui_fixture',
      kind: 'measured',
      source: 'Example et al. (2026), test site.',
      provenanceNotes:
          'Test fixture for the measured UI path; not a field claim.',
      sampling: 'Topsoil at 0 and 8 hours.',
      generatedBy: 'Measured reference UI test fixture.',
      timesSeconds: [0, history.last.timeElapsed],
      model: const ModelReference(
        id: 'test-model',
        version: 1,
        fingerprint: 'test-fingerprint',
      ),
      series: [
        ReferenceSeries(
          variable: 'waterContent',
          layerIndex: 0,
          layerId: 'A',
          unit: 'm3/m3',
          values: [
            history.first.profile.layers.first.waterContent,
            history.last.profile.layers.first.waterContent,
          ],
          threshold: const ReferenceThreshold(nse: 0.0, rmse: 1.0),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ScienceValidationTab(state: state, reference: reference),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MEASURED REFERENCE'), findsOneWidget);
    expect(
      find.textContaining('This reference contains measured data'),
      findsOneWidget,
    );
    expect(find.text('ILLUSTRATIVE PATTERN'), findsNothing);
    expect(find.textContaining('synthetic pattern'), findsNothing);
  });
}
