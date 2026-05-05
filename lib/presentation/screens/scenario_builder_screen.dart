import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/soil_profile.dart';
import '../../domain/models/soil_layer.dart';
// import '../../domain/models/biophysical_state.dart';
import '../providers/simulation_provider.dart';

class ScenarioBuilderScreen extends ConsumerStatefulWidget {
  const ScenarioBuilderScreen({super.key});

  @override
  ConsumerState<ScenarioBuilderScreen> createState() => _ScenarioBuilderScreenState();
}

class _ScenarioBuilderScreenState extends ConsumerState<ScenarioBuilderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // State for Scenario Settings
  String _title = '';
  String _desc = '';
  double _durationDays = 30.0;
  
  // Soil profile overrides
  String _soilType = 'loam'; // loam, sand, clay
  double _initialWater = 0.25;
  double _initialNitrate = 15.0;
  
  // Cultivation plan builder
  final List<CultivationEvent> _cultivationPlan = [];
  double _eventTime = 5.0;
  String _eventType = 'fertilize';
  double _eventAmount = 10.0;
  
  // Tutorial highlights builder
  final List<ScenarioTutorialStep> _tutorialSteps = [];
  double _tutTime = 1.0;
  String _tutTarget = 'leaf'; // leaf, root, rhizosphere, soilStructure
  String _tutTitle = '';
  String _tutDesc = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_title.isEmpty) _title = l10n.scenarioTitle;
    if (_desc.isEmpty) _desc = l10n.resumeLastSessionDesc;
    if (_tutTitle.isEmpty) _tutTitle = l10n.tutTargetLeaf;
    if (_tutDesc.isEmpty) _tutDesc = l10n.transpirationDesc;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addCultivationEvent() {
    setState(() {
      _cultivationPlan.add(
        CultivationEvent(
          executionTime: _eventTime * 86400, // convert days to seconds (simulated)
          type: _eventType,
          amount: _eventAmount,
          layerId: 'A1',
        ),
      );
    });
  }

  void _addTutorialStep() {
    setState(() {
      _tutorialSteps.add(
        ScenarioTutorialStep(
          triggerTime: _tutTime * 86400,
          targetId: _tutTarget,
          title: _tutTitle,
          description: _tutDesc,
        ),
      );
    });
  }

  Scenario _buildScenario() {
    // Generate default profile based on soil type
    final baseLayer = SoilLayer(
      id: "A1",
      depth: 0.0,
      thickness: 0.3,
      kSat: _soilType == 'sand' ? 1e-4 : (_soilType == 'clay' ? 1e-7 : 1e-6),
      porosity: _soilType == 'sand' ? 0.35 : (_soilType == 'clay' ? 0.50 : 0.45),
      thetaR: 0.05,
      vgAlpha: _soilType == 'sand' ? 3.0 : 1.5,
      vgN: 1.5,
      vgL: 0.5,
      bulkDensity: 1400.0,
      waterContent: _initialWater,
      temperature: 293.15,
      heatCapacity: 800.0,
      ph: 6.5,
      ec: 0.2,
      redoxPotential: 500.0,
      nitrateContent: _initialNitrate,
      ammoniumContent: 5.0,
      phosphateContent: 5.0,
      potassiumContent: 150.0,
      exchangeableAluminium: 0.0,
      organicCarbon: 0.5,
      stableCarbon: 25.0,
      nitrogenContent: 0.2,
      microbialBiomass: 100.0,
      epsContent: 0.0,
      fungalHyphaeDensity: 0.0,
      necromass: 0.0,
      mineralAssociatedOrganicMatter: 25.0,
      particulateOrganicMatter: 0.5,
    );

    final defaultProfile = SoilProfile(
      id: "custom",
      name: "Custom Profile",
      layers: [baseLayer],
      surfaceAlbedo: 0.2,
      slope: 0.0,
    );

    return Scenario(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: _title,
      description: _desc,
      initialProfile: defaultProfile,
      weatherData: {},
      cultivationPlan: _cultivationPlan,
      tutorialSteps: _tutorialSteps,
      features: ['Custom Build', _soilType.toUpperCase()],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.buildScenarioTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.tune), text: l10n.parametersTab),
            Tab(icon: const Icon(Icons.agriculture), text: l10n.actionsTab),
            Tab(icon: const Icon(Icons.school), text: l10n.tutorialTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildParamTab(theme, l10n),
          _buildCultivationTab(theme, l10n),
          _buildTutorialTab(theme, l10n),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final sc = _buildScenario();
                  ref.read(simulationProvider.notifier).loadScenario(sc);
                  // Trigger Pre-calculation
                  ref.read(simulationProvider.notifier).preCalculateTimeline(_durationDays.toInt());
                  Navigator.of(context).pushNamed('/simulation');
                },
                icon: const Icon(Icons.calculate),
                label: Text(l10n.calculateDays(_durationDays.toInt())),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  final sc = _buildScenario();
                  ref.read(simulationProvider.notifier).loadScenario(sc);
                  ref.read(simulationProvider.notifier).start();
                  Navigator.of(context).pushNamed('/simulation');
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.startLive),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamTab(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: l10n.scenarioNameLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => _title = v,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: l10n.descriptionLabel,
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => _desc = v,
        ),
        const SizedBox(height: 24),
        Text(l10n.simulationLengthDays(_durationDays.toInt()), style: theme.textTheme.titleMedium),
        Slider(
          value: _durationDays,
          min: 1,
          max: 180,
          onChanged: (v) => setState(() => _durationDays = v),
        ),
        const SizedBox(height: 24),
        Text(l10n.soilType, style: theme.textTheme.titleMedium),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'sand', label: Text(l10n.sand)),
            ButtonSegment(value: 'loam', label: Text(l10n.loam)),
            ButtonSegment(value: 'clay', label: Text(l10n.clay)),
          ],
          selected: {_soilType},
          onSelectionChanged: (v) => setState(() => _soilType = v.first),
        ),
        const SizedBox(height: 24),
        Text(l10n.initialMoisture((_initialWater * 100).toStringAsFixed(1)), style: theme.textTheme.titleMedium),
        Slider(
          value: _initialWater,
          min: 0.05,
          max: 0.45,
          onChanged: (v) => setState(() => _initialWater = v),
        ),
        const SizedBox(height: 24),
        Text(l10n.initialNitrate(_initialNitrate.toStringAsFixed(1)), style: theme.textTheme.titleMedium),
        Slider(
          value: _initialNitrate,
          min: 0.0,
          max: 50.0,
          onChanged: (v) => setState(() => _initialNitrate = v),
        ),
      ],
    );
  }

  Widget _buildCultivationTab(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.addEvent, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Text(l10n.dayTimeLabel(_eventTime.toStringAsFixed(1)), style: theme.textTheme.titleMedium),
        Slider(
          value: _eventTime,
          min: 0.0,
          max: _durationDays,
          onChanged: (v) => setState(() => _eventTime = v),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _eventType,
          items: [
            DropdownMenuItem(value: 'fertilize', child: Text(l10n.actionFertilize)),
            DropdownMenuItem(value: 'till', child: Text(l10n.actionTill)),
            DropdownMenuItem(value: 'water', child: Text(l10n.actionWater)),
          ],
          onChanged: (v) => setState(() => _eventType = v!),
          decoration: InputDecoration(labelText: l10n.eventTypeLabel),
        ),
        const SizedBox(height: 16),
        if (_eventType != 'till') ...[
          Text(l10n.amountLabel(_eventAmount.toStringAsFixed(1)), style: theme.textTheme.titleMedium),
          Slider(
            value: _eventAmount,
            min: 0.0,
            max: 100.0,
            onChanged: (v) => setState(() => _eventAmount = v),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addCultivationEvent,
          icon: const Icon(Icons.add),
          label: Text(l10n.addAction),
        ),
        const Divider(height: 40),
        Text(l10n.cultivationPlan, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        ..._cultivationPlan.map((e) => ListTile(
              leading: Icon(e.type == 'fertilize' ? Icons.bolt : (e.type == 'till' ? Icons.agriculture : Icons.water_drop)),
              title: Text('${e.type.toUpperCase()} (Päivä ${(e.executionTime / 86400).toStringAsFixed(1)})'),
              subtitle: Text(e.type == 'till' ? l10n.fullField : l10n.amountLabel(e.amount.toStringAsFixed(1))),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => _cultivationPlan.remove(e)),
              ),
            )),
      ],
    );
  }

  Widget _buildTutorialTab(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.tutBuilderTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Text(l10n.dayTimeLabel(_tutTime.toStringAsFixed(1)), style: theme.textTheme.titleMedium),
        Slider(
          value: _tutTime,
          min: 0.0,
          max: _durationDays,
          onChanged: (v) => setState(() => _tutTime = v),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _tutTarget,
          items: [
            DropdownMenuItem(value: 'leaf', child: Text(l10n.tutTargetLeaf)),
            DropdownMenuItem(value: 'root', child: Text(l10n.tutTargetRoot)),
            DropdownMenuItem(value: 'rhizosphere', child: Text(l10n.tutTargetRhizosphere)),
            DropdownMenuItem(value: 'soilStructure', child: Text(l10n.tutTargetSoil)),
          ],
          onChanged: (v) => setState(() => _tutTarget = v!),
          decoration: InputDecoration(labelText: l10n.tutTargetLabel),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(text: _tutTitle),
          decoration: InputDecoration(labelText: l10n.tutTitleLabel),
          onChanged: (v) => _tutTitle = v,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(text: _tutDesc),
          decoration: InputDecoration(labelText: l10n.tutDescLabel),
          onChanged: (v) => _tutDesc = v,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addTutorialStep,
          icon: const Icon(Icons.add_task),
          label: Text(l10n.addTutorialStepAction),
        ),
        const Divider(height: 40),
        Text(l10n.tutorialBuilt, style: theme.textTheme.titleLarge),
        ..._tutorialSteps.map((s) => ListTile(
              leading: const Icon(Icons.school),
              title: Text('${s.title} (Päivä ${(s.triggerTime / 86400).toStringAsFixed(1)})'),
              subtitle: Text(s.description),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => _tutorialSteps.remove(s)),
              ),
            )),
      ],
    );
  }
}
