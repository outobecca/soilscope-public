import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/simulation_provider.dart';
import '../providers/simulation_session_provider.dart';
import '../widgets/science/science_elements_tab.dart';
import '../widgets/science/science_soil_tab.dart';
import '../widgets/science/science_atmosphere_tab.dart';
import '../widgets/science/science_profiles_tab.dart';
import '../widgets/science/science_validation_tab.dart';

/// Comprehensive science reference screen.
/// Refactored to use modular tab widgets for better maintainability.
class ScienceReferenceScreen extends ConsumerWidget {
  const ScienceReferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulationProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Safely find the current layer for context
    final layers = state.profile.layers;
    if (layers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.scienceReference)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final session = ref.watch(simulationSessionProvider);
    final selectedId = session.selectedLayerId;
    final layer = layers.firstWhere(
      (l) => l.id == (selectedId ?? layers.first.id),
      orElse: () => layers.first,
    );

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.scienceReference.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: [
              Tab(icon: const Icon(Icons.apps), text: l10n.elements),
              Tab(
                icon: const Icon(Icons.grid_goldenratio),
                text: l10n.soilStructure,
              ),
              Tab(icon: const Icon(Icons.thermostat), text: l10n.atmosphere),
              Tab(icon: const Icon(Icons.bar_chart), text: l10n.depthProfiles),
              Tab(icon: const Icon(Icons.verified), text: 'Validointi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const ScienceElementsTab(),
            ScienceSoilTab(layer: layer),
            ScienceAtmosphereTab(state: state),
            ScienceProfilesTab(state: state),
            ScienceValidationTab(state: state),
          ],
        ),
      ),
    );
  }
}
