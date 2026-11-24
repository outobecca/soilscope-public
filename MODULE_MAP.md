# SoilScope Module Map & Integration Guide

This guide documents the reusable modules, data structures, JSON schemas, package dependencies, and integration patterns in **SoilScope** (`pubspec.yaml`: `name: soilscope`, `version: 0.1.0+1`, Dart SDK `^3.11.0`). Every class, field, file path, and JSON key below is verified against the actual codebase.

---

## 1. Overview & Architecture

SoilScope is organized into four primary layers under `lib/` plus bundled JSON assets under `assets/`:

| Layer | Directory | Responsibility |
| :--- | :--- | :--- |
| **Core** | `lib/core/` | Physical/visual constants, van Genuchten & thermodynamic helpers, soil texture classification, CPK colors, periodic table, theme, logging |
| **Domain Models** | `lib/domain/models/` | Immutable Freezed/JSON-serializable state models (`BiophysicalState`, `SoilProfile`, `SoilLayer`, `Plant`, `Scenario`, `SustainabilityScore`), plot geometry, parameter fingerprinting, validation dataset models |
| **Domain Solvers** | `lib/domain/solvers/` | Deterministic biophysical engine (`SimulationEngine`), domain-specific solvers (hydrology, energy, gas, chemistry, nutrients, enzymes, aggregation, plant, mycorrhiza, scoring), particle physics, validation metrics, and isolate managers |
| **Domain Services & Actions** | `lib/domain/actions/`, `lib/domain/services/`, `lib/domain/logic_lab/` | Pure state transitions (`SimulationActions`), lifecycle/persistence/timeline/intervention services, and the node-based `LogicEvaluator` |
| **Data** | `lib/data/` | Asset loaders (`ScenarioRepository`, `ReferenceDatasetRepository`) |
| **Presentation** | `lib/presentation/` | Riverpod providers (`lib/presentation/providers/`), Flame 2D simulation (`lib/presentation/widgets/game/soil_scope_game.dart`), HUD, controls, and screens |
| **Assets** | `assets/` | Bundled scenario JSONs (`assets/scenarios/`), validation reference JSON (`assets/validation/reference.json`), and SVG/PNG images (`assets/images/`) |

---

## 2. Package Dependencies

From `pubspec.yaml`:

### Runtime Dependencies

| Package | Constraint | Used By / Purpose |
| :--- | :--- | :--- |
| `flutter` | `sdk: flutter` | UI framework, `rootBundle`, `kDebugMode` / `kIsWeb` |
| `flutter_localizations` | `sdk: flutter` | Localization delegates (`lib/l10n/`) |
| `collection` | `^1.18.0` | Collection utilities |
| `equations` | `^6.0.0` | Numerical equation solving in solvers |
| `flame` | `^1.18.0` | 2D game/simulation canvas (`SoilScopeGame` & components) |
| `flame_riverpod` | `^5.5.2` | Bridges Flame components with Riverpod providers |
| `flame_svg` | `^2.0.0` | SVG rendering inside Flame |
| `flutter_svg` | `^2.2.4` | SVG rendering in Flutter widgets |
| `oxygen` | `^0.3.1` | Lightweight ECS utilities |
| `material_ui` | `^1.11.0` | UI components & `Color` / `Offset` types (also imported by `cpk_standards.dart`, `periodic_table.dart`, `logic_lab/models.dart`) |
| `cupertino_ui` | `^1.1.6` | Cupertino UI components |
| `flutter_riverpod` | `^3.2.1` | Reactive state management in Flutter |
| `riverpod` | `^3.2.1` | Core Riverpod |
| `riverpod_annotation` | `^4.0.2` | `@Riverpod` code-generation annotations |
| `freezed_annotation` | `^3.1.0` | `@freezed` / `@Freezed` immutable model annotations |
| `json_annotation` | `^4.11.0` | `@JsonKey` / JSON serialization annotations |
| `intl` | `^0.20.2` | Internationalization & formatting |
| `shared_preferences` | `^2.5.2` | On-device session persistence (`SimulationPersistence`) |

### Dev Dependencies

- `flutter_test`, `integration_test` (`sdk: flutter`)
- `flutter_lints: ^6.0.0`
- `build_runner: ^2.11.1`, `freezed: ^4.0.2`, `json_serializable: ^6.13.0`, `riverpod_generator: ^4.0.3`
- `flutter_launcher_icons: ^0.14.4`

---

## 3. Connecting SoilScope to Other Applications

`pubspec.yaml` sets `publish_to: 'none'`. External Dart/Flutter applications can integrate SoilScope via a local `path` or `git` dependency:

```yaml
dependencies:
  soilscope:
    git:
      url: https://github.com/outobecca/soilscope-public.git
      # or path: ../soilscope-public
```

If you modify any `@freezed`, `@JsonSerializable`, or `@riverpod` annotated files, regenerate code with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Integration Patterns

1. **Headless Biophysical Solver (No UI / No Isolates)**
   Use `BiophysicalState`, `SoilProfile`, `SoilLayer`, `Plant`, `defaultSoilProfile()`, `seedPlant()`, `SimulationEngine.tick()`, and `SimulationActions` directly:
   ```dart
   import 'package:soilscope/domain/models/biophysical_state.dart';
   import 'package:soilscope/domain/models/default_simulation_profile.dart';
   import 'package:soilscope/domain/solvers/simulation_engine.dart';
   import 'package:soilscope/domain/actions/simulation_actions.dart';

   var state = BiophysicalState(
     profile: defaultSoilProfile(),
     plants: [seedPlant()],
     timeElapsed: 0.0,
     isInitializing: false,
   );

   state = SimulationActions.applyIrrigation(state, amountMm: 10.0);
   state = SimulationEngine.tick(state, 3600.0, precipitation: 0.0);
   ```
   > **Note:** `SimulationEngine` imports `package:flutter/foundation.dart` for `kDebugMode`. Running in a Flutter app or `flutter test` works out of the box; running in a standalone `dart` VM script without Flutter requires stubbing or removing `kDebugMode` guards.

2. **Background Isolate Runtime (Non-blocking UI)**
   Use `SimulationIsolateManager` (`lib/domain/solvers/simulation_isolate.dart`) for the biophysical loop (200 ms periodic tick on native; fallback behavior on `kIsWeb`), or `SimulationRuntime` (`lib/domain/services/simulation_runtime.dart`) to coordinate both `SimulationIsolateManager` and `ParticlePhysicsIsolateManager`.

3. **Full Flutter + Riverpod + Flame Integration**
   Wrap your app in `ProviderScope`, watch/read `simulationProvider` (`lib/presentation/providers/simulation_provider.dart`), and embed `SoilScopeGame` (`lib/presentation/widgets/game/soil_scope_game.dart`). Load scenarios via `ScenarioRepository.getScenarios()` and validation datasets via `ReferenceDatasetRepository.loadDefault()`.

4. **Validation & Reproducibility Integration**
   Use `ValidationFramework` (`lib/domain/solvers/validation_framework.dart`) to compute `RMSE`, `MAE`, `NSE`, `R²`, `Bias`, and `Index of Agreement` against `ReferenceDataset` (`assets/validation/reference.json`), and `ModelParameterSet.current` (`lib/domain/models/model_parameter_set.dart`) to track the 32-bit FNV-1a parameter fingerprint (`id`, `version`, `fingerprint`).

---

## 4. Reusable Modules Reference

### 4.1 Core Utilities (`lib/core/`)

| File | Primary Symbols | Purpose |
| :--- | :--- | :--- |
| `lib/core/simulation_constants.dart` | `SimulationConstants` | Central physical, biological, and visual constants (`baseTickDelta`, `maxSubStep`, `maxSubStepsPerTick`, `gasConstant`, `atmCO2Default`, `stefanBoltzmann`, `immobilizationCnThreshold`, `microbialCnTarget`, etc.). |
| `lib/core/biophysics_utils.dart` | `BiophysicsUtils`, `VGParams`, `SoilTexture`, `FinnishSoilTexture` | `q10Factor`, `moistureActivityFactor`, van Genuchten (`calculateSe`, `thetaToPsi`, `calculateTheta`, `calculateK`, `getVGParams`), USDA & Finnish soil texture classifiers (`getSoilTextureClass`, `getFinnishSoilTextureClass`), vapor pressure / VPD / humidity ratio (`getSaturationVaporPressure`, `getVPD`, `getHumidityRatio`). |
| `lib/core/cpk_standards.dart` | `CPKStandards` | CPK element colors (`getColor(symbol)`), semantic rhizosphere/carbon colors, and relative atomic radii (`getRelativeScale(symbol)`). |
| `lib/core/periodic_table.dart` | `PeriodicTable`, `ElementInfo`, `ElementCategory`, `ElementAgronomicRole` | Bilingual (EN/FI) periodic table metadata with atomic mass, typical charge, and agronomic/soil role. |
| `lib/core/app_theme.dart` | `AppTheme` | Shared Flutter theme definitions. |
| `lib/core/debug_log.dart` | `debugLog` | Conditional debug logging helper. |

### 4.2 Domain Solvers (`lib/domain/solvers/`)

`SimulationEngine.tick(BiophysicalState state, double dt, {double precipitation = 0.0})` (`lib/domain/solvers/simulation_engine.dart`) sub-steps `dt` using `SimulationConstants.maxSubStep` (600 s) and `SimulationConstants.maxSubStepsPerTick` (50), executing solvers in this exact sequence per sub-step:

| Order | File | Class & Entry Method | Role |
| :--- | :--- | :--- | :--- |
| 1 | `lib/domain/solvers/hydrology_solver.dart` | `HydrologySolver.solve(profile, dt, {precipitation, plants})` | 1D Richards / van Genuchten-Mualem water flow, hysteresis, bypass flow, evaporation; returns `HydrologyResult`. |
| 2 | `lib/domain/solvers/energy_solver.dart` | `EnergySolver.solve(profile, dt, timeElapsed, {airTemperature, latentHeat, plants, solarRadiation})` | Soil surface energy balance & heat transfer. |
| 3 | `lib/domain/solvers/gas_solver.dart` | `GasSolver.solve(profile, dt, {plants, atmCO2})` | O₂ / CO₂ / CH₄ / N₂O diffusion & root respiration. |
| 4 | `lib/domain/solvers/chemistry_solver.dart` | `ChemistrySolver.solve(profile, dt)` | Redox potential (Eh), pH, and TEA ladder dynamics. |
| 5 | `lib/domain/solvers/nutrient_solver.dart` | `NutrientSolver.solve(profile, dt, {waterFluxes})` | Solute diffusion/advection and N-cycle (`NitrogenCycleModel.tick(dt, layer)` in `lib/domain/solvers/nitrogen_cycle_model.dart`). |
| 5.5 | `lib/domain/solvers/microbial_enzymes_solver.dart` | `MicrobialEnzymesSolver.solve(profile, dt)` | Michaelis-Menten enzyme kinetics (urease, phosphatase, cellulase, protease) and mineralization. |
| 6 | `lib/domain/solvers/aggregation_solver.dart` | `AggregationSolver.solve(profile, dt, {plants, hasCoverCrop, precipitation})` | EPS, fungal hyphae, POM/MAOM carbon pump, aggregate stability. |
| 7 | `lib/domain/solvers/plant_solver.dart` | `PlantSolver.solve(plant, profile, dt, {airTemperature, atmCO2, relativeHumidity, solarRadiation})` & `PlantSolver.accumulateSinks(...)` | Coordinates `lib/domain/solvers/plant/` sub-solvers: `PlantHydraulicsSolver`, `PlantBiomassSolver`, `PlantNutrientUptakeSolver`, `RootArchitectureSolver`. |
| 7.5 | `lib/domain/solvers/mycorrhiza_solver.dart` | `MycorrhizaSolver.solve(profile, plant, previousState, dt, {dailyPhotosynthate})` | C-P-N symbiotic exchange and hyphal network expansion; returns `({SoilProfile profile, Plant plant, MycorrhizaState mycorrhizaState})`. |
| 8 | `lib/domain/solvers/nutrient_buffer.dart` | `NutrientBuffer` | Zero-allocation `Float64List` sink accumulator applied across all plants and layers. |
| Post | `lib/domain/solvers/scoring_solver.dart` | `ScoringSolver.solve(state, dt)` | Computes `SustainabilityScore` (`yieldScore`, `carbonScore`, `biodiversityScore`, `environmentalImpact`, `totalSoilHealth`, `metObjectiveIds`). |

Additional solver/validation modules:
- `lib/domain/solvers/particle_physics_solver.dart`: `ParticlePhysicsSolver`, `Particle`, `ParticleSnapshot`, `ParticleType`.
- `lib/domain/solvers/particle_physics_isolate.dart`: `ParticlePhysicsIsolateManager` and command classes (`StartParticles`, `StopParticles`, `UpdateEnvironment`, `AddParticles`, `SetParticles`, `RemoveParticles`).
- `lib/domain/solvers/simulation_isolate.dart`: `SimulationIsolateManager` and command classes (`StartCommand`, `StopCommand`, `UpdateStateCommand`).
- `lib/domain/solvers/validation_framework.dart`: `ValidationFramework`, `ValidationResult`, `ValidationComparison`.

### 4.3 Domain Actions, Services & Logic Lab

| Module | File | Key Classes / Functions | Purpose |
| :--- | :--- | :--- | :--- |
| Pure State Actions | `lib/domain/actions/simulation_actions.dart` | `SimulationActions` (`applyTillage`, `applyIrrigation`, `applyOrganicMatter`, `applyDrainage`, `applyNutrients`, `updateWeather`, `triggerHeatWave`, `triggerFlashFlood`, `toggleCoverCrop`) | Pure `BiophysicalState -> BiophysicalState` transformations. |
| Interventions | `lib/domain/services/simulation_interventions.dart` | `SimulationInterventions` | Callback-driven intervention facade decoupled from Riverpod/isolates. |
| Persistence | `lib/domain/services/simulation_persistence.dart` | `SimulationPersistence`, `SavedSession` | `SharedPreferences` save/load with versioned JSON envelope and `ModelParameterSet` check. |
| Runtime | `lib/domain/services/simulation_runtime.dart` | `SimulationRuntime` | Coordinates `SimulationIsolateManager` and `ParticlePhysicsIsolateManager` with initialization watchdog. |
| Tick Processor | `lib/domain/services/simulation_tick_processor.dart` | `SimulationTickProcessor`, `SimulationTickResult` | Reconciles engine ticks with UI-owned fields, cultivation events, and timeline snapshots. |
| Timeline | `lib/domain/services/simulation_timeline.dart` | `SimulationTimeline` | Stores history-stripped `BiophysicalState` snapshots for scrubbing. |
| Precalculation | `lib/domain/services/timeline_precalculation.dart` | `preCalculateTimelineTask` | Top-level `compute`-compatible function for multi-day timeline pre-calculation. |
| Resource Exchange | `lib/domain/services/simulation_resource_exchange.dart` | `SimulationResourceExchange` | Applies particle/Flame-driven nutrient absorption and exudation. |
| Reference Run | `lib/domain/services/validation_reference_run.dart` | `ValidationReferenceRun` | Deterministic 168-hour plant-free run used by `test/validation/`. |
| Logic Lab | `lib/domain/logic_lab/models.dart`, `lib/domain/logic_lab/evaluator.dart` | `LogicNode`, `NodeConnection`, `NodePort`, `LogicGraph`, `NodeType`, `PortType`, `LogicEvaluator` | Visual node-graph evaluator supporting `+`, `-`, `*`, `/`, `Q10`, `MM`, `VG`, `Farquhar`, `Redox`, `Chemotaxis`, `CostBenefit`. |

### 4.4 Data Repositories (`lib/data/`)

- `ScenarioRepository.getScenarios()` (`lib/data/scenario_repository.dart`): Loads and parses the four bundled scenarios (`assets/scenarios/compacted_clay.json`, `nitrate_leaching.json`, `nitrogen_lock.json`, `waterlogging.json`) via `rootBundle`.
- `ReferenceDatasetRepository.loadDefault({AssetBundle? bundle})` (`lib/data/reference_dataset_repository.dart`): Loads and caches `assets/validation/reference.json` as a `ReferenceDataset`.

---

## 5. Data Content Structure & JSON Schemas

All `@freezed` / `@Freezed(fromJson: true, toJson: true)` models serialize using their exact Dart field names (camelCase) unless noted otherwise.

### 5.1 `BiophysicalState` (`lib/domain/models/biophysical_state.dart`)

| JSON Key / Field | Type | Default / Required | Notes |
| :--- | :--- | :--- | :--- |
| `profile` | `SoilProfile` | required | Active soil column |
| `plants` | `List<Plant>` | required | All plants in the plot |
| `timeElapsed` | `double` | required | Simulated seconds |
| `currentScenario` | `Scenario?` | `null` | Active scenario, if any |
| `precipitation` | `double` | `0.0` | Precipitation rate |
| `soilEvaporation` | `double` | `0.0` | Actual evaporation [m/s] |
| `airTemperature` | `double` | `293.15` | Air temperature [K] |
| `relativeHumidity` | `double` | `0.5` | Relative humidity [0..1] |
| `atmCO2` | `double` | `0.017` | Atmospheric CO₂ [mol/m³] |
| `autoWeather` | `bool` | `false` | Automatic weather flag |
| `timeScale` | `double` | `1.0` | Simulation speed multiplier |
| `hasCoverCrop` | `bool` | `false` | Cover crop active flag |
| `isRunning` | `bool` | `false` | Engine running flag |
| `isInitializing` | `bool` | `true` | Initialization flag |
| `history` | `List<BiophysicalState>` | `[]` | **Excluded from JSON** (`@JsonKey(includeFromJson: false, includeToJson: false)`) |
| `score` | `SustainabilityScore` | `SustainabilityScore()` | Computed sustainability metrics |
| `solarRadiationOverride` | `double?` | `null` | Optional solar radiation override [W/m²] |
| `mycorrhizaState` | `MycorrhizaState?` | `null` | Symbiosis state |

Computed getters (not serialized): `plant` (first plant or stub), `solarRadiation`, `par`.

### 5.2 `SoilProfile` (`lib/domain/models/soil_profile.dart`)

| JSON Key / Field | Type | Required / Default |
| :--- | :--- | :--- |
| `id` | `String` | required |
| `name` | `String` | required |
| `layers` | `List<SoilLayer>` | required |
| `surfaceAlbedo` | `double` | required |
| `slope` | `double` | required (%) |

### 5.3 `SoilLayer`, `RhizosphereHotspot`, `HotspotType` (`lib/domain/models/soil_layer.dart`)

**Required fields:**
`id` (`String`), `depth` (`double`, m), `thickness` (`double`, m), `kSat` (`double`, m/s), `porosity` (`double`, 0..1), `thetaR` (`double`), `vgAlpha` (`double`, 1/m), `vgN` (`double`), `bulkDensity` (`double`, kg/m³), `waterContent` (`double`, m³/m³), `temperature` (`double`, K), `heatCapacity` (`double`, J/(m³·K)), `ph` (`double`), `ec` (`double`, dS/m), `redoxPotential` (`double`, mV), `nitrateContent` (`double`, mg/kg), `ammoniumContent` (`double`, mg/kg), `phosphateContent` (`double`, mg/kg), `microbialBiomass` (`double`, kg/m³), `epsContent` (`double`), `fungalHyphaeDensity` (`double`), `necromass` (`double`), `organicCarbon` (`double`, kg/m³), `particulateOrganicMatter` (`double`, kg/m³), `mineralAssociatedOrganicMatter` (`double`, kg/m³), `nitrogenContent` (`double`).

**Optional fields with defaults:**
- Physical/Hydraulic/Thermal: `vgL` (`0.5`), `previousWaterContent` (`0.0`), `verticalFlux` (`0.0`), `clayFraction` (`0.2`), `sandFraction` (`0.4`), `siltFraction` (`0.4`), `effectiveMacroPorosity` (`0.0`), `aggregateStability` (`0.5`), `thermalConductivity` (`1.0`).
- Chemical/Gas: `sorbedPhosphate` (`0.0`), `potassiumContent` (`5.0`), `exchangeablePotassium` (`50.0`), `solutionCalcium` (`100.0`), `exchangeableCalcium` (`1000.0`), `solutionMagnesium` (`20.0`), `exchangeableMagnesium` (`200.0`), `exchangeableAluminium` (`5.0`), `cec` (`10.0`), `oxygenContent` (`8.5`), `co2Content` (`0.02`), `methaneContent` (`0.0`), `nitrousOxideContent` (`0.0`), `traceElements` (`Map<String, double>`, `{}`).
- Carbon/Nitrogen/Tillage/Diagnostics: `isCultivated` (`false`), `cultivationDisturbance` (`0.0`), `labileCarbon` (`0.0`), `stableCarbon` (`0.0`), `organicNitrogen` (`100.0`), `microbialNitrogen` (`10.0`), `maomNitrogen` (`50.0`), `nitrificationRate` (`0.0`), `denitrificationRate` (`0.0`).
- Display & Hotspots: `name` (`''`), `description` (`''`), `colorValue` (`0xFF795548`), `hotspots` (`List<RhizosphereHotspot>`, `[]`).

**Computed getters (not serialized):** `aluminumLevel`, `cnRatio`, `calculatedEC`, `organicMatterContent`, `microbialActivity`, `rootPenetrationResistance`, `rootGrowthFactor`.

**`RhizosphereHotspot`:** `id` (`String`), `x` (`double`), `z` (`double`), `intensity` (`double`), `radius` (`double`, default `0.05`), `age` (`double`, default `0.0`), `type` (`HotspotType`: `rhizosphere` | `decomposition` | `fungalHub`, default `HotspotType.rhizosphere`).

### 5.4 `Plant` & `RootNode` (`lib/domain/models/plant.dart`)

- **`Plant`**: `id` (`String`), `species` (`String`), `age` (`double`, days), `height` (`double`, m), `lai` (`double`), `turgorPressure` (`double`, MPa), `baseX` (`double`, default `0.5`), `rootSystem` (`List<RootNode>`), `nitrogenUptake` (`double`), `waterUptake` (`double`), `phosphorusUptake` (`0.0`), `calciumUptake` (`0.0`), `magnesiumUptake` (`0.0`), `totalBiomass` (`100.0`, mg), `rootBiomass` (`50.0`, mg), `psiLeaf` (`-0.3`, MPa), `stomatalConductance` (`0.3`, mol H₂O m⁻² s⁻¹), `waterStressIndex` (`0.0`), `relativeWaterContent` (`0.9`), `actualTranspiration` (`0.0`), `absorbedPAR` (`0.0`, W/m²), `lightTransmission` (`1.0`).
- **`RootNode`**: `x` (`double`), `z` (`double`), `radius` (`double`), `isTip` (`bool`), `parentIndex` (`int?`), `branchLevel` (`int`, default `0`), `branchSegmentCount` (`int`, default `0`).

### 5.5 `MycorrhizaState` & `SustainabilityScore`

- **`MycorrhizaState`** (`lib/domain/solvers/mycorrhiza_solver.dart`): `rootColonization` (`0.0`), `totalHyphalLength` (`0.0`), `layerHyphalDensities` (`List<double>`, `const []`), `carbonTransferredToday` (`0.0`), `pTransferredToday` (`0.0`), `nTransferredToday` (`0.0`), `fungalBiomass` (`0.0`). Computed getter: `benefitRatio`.
- **`SustainabilityScore`** (`lib/domain/models/sustainability_score.dart`): `yieldScore` (`0.0`), `carbonScore` (`0.0`), `biodiversityScore` (`0.0`), `environmentalImpact` (`0.0`), `totalSoilHealth` (`0.0`), `metObjectiveIds` (`List<String>`, `[]`).

### 5.6 `Scenario` JSON Schema (`lib/domain/models/scenario.dart` & `assets/scenarios/*.json`)

- **`Scenario`**: `id` (`String`), `title` (`String`), `description` (`String`), `initialProfile` (`SoilProfile`), `weatherData` (`Map<String, dynamic>` — bundled scenario JSONs use keys `"precip"`, `"temp"`, `"rh"`), `objectives` (`List<MissionObjective>`, `[]`), `features` (`List<String>`, `[]`), `tutorialSteps` (`List<ScenarioTutorialStep>`, `[]`), `cultivationPlan` (`List<CultivationEvent>`, `[]`).
- **`MissionObjective`**: `id` (`String`), `title` (`String`), `targetValue` (`double`), `type` (`String`: `'yield'`, `'carbon'`, `'structure'`, `'pollution'`), `isMet` (`bool`, default `false`).
- **`ScenarioTutorialStep`**: `triggerTime` (`double`), `targetId` (`String`), `title` (`String`), `description` (`String`).
- **`CultivationEvent`**: `executionTime` (`double`), `type` (`String`: `'fertilize'`, `'till'`, `'water'`), `amount` (`double`, default `0.0`), `layerId` (`String?`), `extraData` (`String?`).

### 5.7 Persistence Envelope & `ModelParameterSet`

- **`SimulationPersistence`** (`lib/domain/services/simulation_persistence.dart`) stores JSON under `SharedPreferences` key `'simulation_session'` (migrating legacy key `'last_biophysical_state'`):
  ```json
  {
    "version": 1,
    "model": {
      "id": "soilscope-core",
      "version": 4,
      "fingerprint": "3cab39ed"
    },
    "state": { "...BiophysicalState JSON..." }
  }
  ```
- **`ModelParameterSet`** (`lib/domain/models/model_parameter_set.dart`): `currentId = 'soilscope-core'`, `currentVersion = 4`. Its parameters are `ModelConfig.values` plus the `SimulationPlot` geometry, so a runtime override changes the identity. `toJson()` emits `id`, `version`, `fingerprint`; `toCanonicalJson()` adds `parameters` (`Map<String, double>`).
- **`ModelConfig`** (`lib/core/model_config.dart`): one defaults map for all model-affecting solver values and the `interaction.*` component pool doses, with `of(key)`, `values`, `applyOverrides()` and `reset()`. Rendering-only motion and layout stay in `SimulationConstants` and `MicrobeMotility`. `ModelConfigRepository` (`lib/data/model_config_repository.dart`) loads `assets/config/model_parameters.json` before `runApp`; the checked-in `parameters` map is empty, so defaults reproduce prior behavior.

### 5.8 `ReferenceDataset` JSON Schema (`lib/domain/models/reference_dataset.dart` & `assets/validation/reference.json`)

- Root keys: `id` (`String`), `kind` (`'illustrative'` | `'measured'`), `source` (`String`), `provenanceNotes` (`String`), `sampling` (`String`), `generatedBy` (`String`), `model` (`ModelReference?` — required when `kind == 'measured'`; keys `id`, `version`, `fingerprint`), and **exactly one** of `relativeTimes` (`List<double>` in `(0, 1]`) or `timesSeconds` (`List<double>` >= 0), plus `series` (`List<ReferenceSeries>`).
- **`ReferenceSeries`**: `variable` (`String`), `layerIndex` (`int`), `layerId` (`String?`), `unit` (`String`), `values` (`List<double>`), `threshold` (`{ "nse": double, "rmse": double }`).

### 5.9 Non-JSON Helper Models

- `SimulationPlot` (`lib/domain/models/simulation_plot.dart`): `sideM = 1.0`, `areaM2 = 1.0`, `centerNormalizedX = 0.5`, `minNormalizedX = 0.0`, `maxNormalizedX = 1.0`, plus coordinate/volume conversion helpers.
- `HydrologyResult` (`lib/domain/models/hydrology_result.dart`): `profile`, `averageFluxes`, `latentHeat`, `actualEvaporation`.
- `ScenarioProcessProfile` (`lib/domain/models/scenario_process_profile.dart`): normalized `0..1` process emphasis (`nitrification`, `denitrification`, `leaching`, `immobilization`, `compaction`, `clayDensity`) derived via `fromState` / `fromScenario`.
- `defaultSoilProfile()` & `seedPlant()` (`lib/domain/models/default_simulation_profile.dart`): 3-layer (`A1`, `B1`, `C1`) starting soil column and `"Wheat"` seedling.
