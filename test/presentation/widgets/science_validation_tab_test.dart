import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/data/reference_dataset_repository.dart';
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
}
