// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SoilScope';

  @override
  String get soilStructure => 'Soil Structure';

  @override
  String get bioActivity => 'Bio-Activity';

  @override
  String get leachingRisk => 'Leaching Risk';

  @override
  String plantTurgor(String percentage) {
    return 'Plant Turgor: $percentage%';
  }

  @override
  String timeElapsed(String hours) {
    return 'Time: ${hours}h';
  }

  @override
  String get tillage => 'Tillage';

  @override
  String get irrigate => 'Irrigate';

  @override
  String get fertilize => 'Fertilize';

  @override
  String analysisTitle(String id) {
    return 'Layer $id Analysis';
  }

  @override
  String get depth => 'Depth';

  @override
  String get waterContent => 'Water Content';

  @override
  String get temperature => 'Temperature';

  @override
  String get ph => 'pH';

  @override
  String get ec => 'EC (Salinity)';

  @override
  String get redoxPotential => 'Redox (Eh)';

  @override
  String get nitrate => 'Nitrate';

  @override
  String get phosphate => 'Phosphate';

  @override
  String get microbialBiomass => 'Microbial Biomass';

  @override
  String get oxygen => 'Oxygen (O2)';

  @override
  String get co2 => 'Carbon Dioxide (CO2)';

  @override
  String get soilRespiration => 'Soil Respiration';

  @override
  String get soilEvaporation => 'Soil Evaporation';

  @override
  String get redoxPotentialTitle => 'Redox Potential (Eh)';

  @override
  String get phLabel => 'Acidity / pH';

  @override
  String get phDescription => 'A measure of the acidity or alkalinity of the soil solution.';

  @override
  String get biophysicsInsights => 'Biophysics Insights:';

  @override
  String get anaerobicWarning => 'Anaerobic conditions detected. Risk of denitrification.';

  @override
  String get aerobicStatus => 'Aerobic conditions. Healthy microbial activity.';

  @override
  String get tillageSuccess => 'Tillage applied! Soil structure loosened.';

  @override
  String get tillageFailure => 'CRITICAL: Tilling wet soil caused structural collapse!';

  @override
  String get irrigatingField => 'Irrigating field...';

  @override
  String get fertilizerSuccess => 'Nitrogen & Phosphorus applied to surface.';

  @override
  String get selectScenario => 'Select Scenario';

  @override
  String get startSimulation => 'Start Simulation';

  @override
  String get compactedClayTitle => 'Compacted Clay Challenge';

  @override
  String get compactedClayDesc => 'Improve soil structure through tillage and biology.';

  @override
  String get nitrateLeachingTitle => 'Nitrogen Leaching Crisis';

  @override
  String get nitrateLeachingDesc => 'Manage nutrients during excessive rainfall.';

  @override
  String get nitrogenLockTitle => 'Nitrogen Lock Challenge';

  @override
  String get nitrogenLockDesc => 'You added too much straw (high C/N). Save the crop!';

  @override
  String get simulationSettings => 'Simulation Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get finnish => 'Finnish';

  @override
  String get nanovisionHint => 'Tap soil layers to activate Nanovision analysis';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get logicLab => 'Logic Lab';

  @override
  String get science => 'Science';

  @override
  String get showFormulas => 'Show Formulas';

  @override
  String get saveScenario => 'Save Scenario';

  @override
  String get copyToClipboard => 'JSON copied to clipboard!';

  @override
  String get scenarioTitle => 'My Custom Scenario';

  @override
  String get importScenario => 'Import from Clipboard';

  @override
  String get importFromClipboardDesc => 'Load a scenario JSON from your clipboard.';

  @override
  String get clipboardEmpty => 'Clipboard is empty. Copy scenario JSON first.';

  @override
  String get importSuccess => 'Scenario imported successfully!';

  @override
  String get importError => 'Invalid JSON format.';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get scenarioLibrary => 'Scenario library';

  @override
  String get noScenariosAvailable => 'No scenarios available right now.';

  @override
  String get resumeLastSession => 'Resume Last Session';

  @override
  String get resumeLastSessionDesc => 'Continue where you left off with your previous soil and plant state.';

  @override
  String get noSavedSession => 'No saved session found yet.';

  @override
  String get resumeFailed => 'Could not restore the saved session.';

  @override
  String get openScenario => 'Open';

  @override
  String get teacherMode => 'Teacher Mode';

  @override
  String get heatWave => 'Heat Wave';

  @override
  String get flashFlood => 'Flash Flood';

  @override
  String get frost => 'Frost';

  @override
  String get pestOutbreak => 'Pest Outbreak';

  @override
  String get soilCompaction => 'Heavy Machinery Compaction';

  @override
  String get surfaceErosion => 'Intense Erosion';

  @override
  String get aiAdvisor => 'AI Advisor';

  @override
  String get topRecommendation => 'Strategic Advice';

  @override
  String confidence(String value) {
    return 'Confidence: $value%';
  }

  @override
  String get rationale => 'Rationale';

  @override
  String get coverCrop => 'Cover Crop';

  @override
  String get coverCropAlreadyActive => 'Cover crop is already active.';

  @override
  String get coverCropApplied => 'Cover crop planted. Surface protection improved.';

  @override
  String get irrigationStopped => 'Irrigation stopped.';

  @override
  String get autoWeather => 'Auto Weather';

  @override
  String get dynamicWeatherOn => 'Dynamic weather enabled.';

  @override
  String get dynamicWeatherOff => 'Dynamic weather disabled.';

  @override
  String get drain => 'Drain';

  @override
  String get drainageOpened => 'Drainage channels opened. Surface is drying.';

  @override
  String get analytics => 'Analytics';

  @override
  String get researchDashboard => 'Research Dashboard';

  @override
  String get menu => 'Menu';

  @override
  String get controls => 'Controls';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get microscope => 'Microscope';

  @override
  String get controlPanel => 'Control Panel';

  @override
  String get returnToMenuTitle => 'Return to menu?';

  @override
  String get returnToMenuMessage => 'Simulation will be paused and your current state saved.';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get returnToMenuAction => 'Return';

  @override
  String speed(String value) {
    return 'Speed: ${value}x';
  }

  @override
  String get atmosphere => 'Atmosphere';

  @override
  String get systemHealth => 'System Health';

  @override
  String get productivity => 'Productivity';

  @override
  String get carbonSink => 'Carbon Sink';

  @override
  String get biodiversity => 'Bio-Diversity';

  @override
  String get impact => 'Impact';

  @override
  String get reward => 'Reward';

  @override
  String get index => 'Index';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get hideSidebar => 'Hide Sidebar';

  @override
  String get showSidebar => 'Show Sidebar';

  @override
  String get scienceReference => 'Science Reference';

  @override
  String get fullScienceReference => 'Full Science Reference';

  @override
  String get selectLayerToView => 'Select a soil layer to view analysis';

  @override
  String get sand => 'Sand';

  @override
  String get silt => 'Silt';

  @override
  String get clay => 'Clay';

  @override
  String get water => 'Water';

  @override
  String get root => 'Root';

  @override
  String get leaf => 'Leaf';

  @override
  String get vaporPressureDeficit => 'Vapor Pressure Deficit';

  @override
  String get relativeHumidity => 'Relative Humidity';

  @override
  String get selectElementRole => 'Select an element to see its role in the ecosystem';

  @override
  String concentration(String id) {
    return 'Concentration ($id)';
  }

  @override
  String get semanticZoomLevels => 'Semantic Zoom Levels';

  @override
  String get macroZoomTitle => '1.0x - 2.0x (Macro)';

  @override
  String get macroZoomDesc => 'General landscape view. Highlights soil moisture levels and layer boundaries.';

  @override
  String get mesoZoomTitle => '2.0x - 4.0x (Meso)';

  @override
  String get mesoZoomDesc => 'Reveals structural details like cracks, fungal networks, and water infiltration/rise.';

  @override
  String get microZoomTitle => '4.0x - 5.5x (Micro)';

  @override
  String get microZoomDesc => 'Visible microbes, root hairs, and gas bubbles (CO₂/N₂O). Shows thermal heat flow.';

  @override
  String get nanoZoomTitle => '5.5x+ (Nano)';

  @override
  String get nanoZoomDesc => 'Deep-dive into ions (N, P, K), matrix pore gaps, and real-time metabolic math.';

  @override
  String get soilStructureTexture => 'Soil Structure & Texture';

  @override
  String get aggregates => 'Aggregates';

  @override
  String get aggregatesDesc => 'Clusters of soil particles (peds). Only visible in high-stability soil.';

  @override
  String get sandGrains => 'Sand Grains';

  @override
  String get sandGrainsDesc => 'Sharp, crystalline particles. Large gaps allow fast water movement.';

  @override
  String get waterFlux => 'Water Flux';

  @override
  String get waterFluxDesc => 'Upward arrows indicate capillary rise; downward indicate infiltration.';

  @override
  String get plantInteractions => 'Plant Interactions';

  @override
  String get rhizosphere => 'Rhizosphere';

  @override
  String get rhizosphereDesc => 'Biological hotspot around roots where exudates drive hyper-active microbial life.';

  @override
  String get rootExudates => 'Root Exudates';

  @override
  String get rootExudatesDesc => 'Carbon leaking from roots to feed microbes. Visualized as a green glow.';

  @override
  String get transpiration => 'Transpiration';

  @override
  String get transpirationDesc => 'Rising blue particles in the stem showing active water transport from soil to sky.';

  @override
  String get hiddenGasCycles => 'Hidden Gas Cycles';

  @override
  String get boundaryFlux => 'Boundary Flux';

  @override
  String get boundaryFluxDesc => 'Water vapor and CO2 rising from the surface; Oxygen falling into the soil.';

  @override
  String get co2Bubbles => 'CO₂ Bubbles';

  @override
  String get co2BubblesDesc => 'Byproduct of healthy respiration. Rises faster when microbes are warm.';

  @override
  String get hiddenChemicalDynamics => 'Hidden Chemical Dynamics';

  @override
  String get cecSnapping => 'CEC Snapping';

  @override
  String get cecSnappingDesc => 'Ions (N, P, K) being captured or released by clay particle exchange sites.';

  @override
  String get cationExchange => 'Cation Exchange';

  @override
  String get cationExchangeDesc => 'Competitive adsorption of K+, Ca²+, and Mg²+ on clay surfaces. High CEC allows for better nutrient retention.';

  @override
  String get elementToxicity => 'Element Toxicity';

  @override
  String get elementToxicityDesc => 'High Aluminium (Al) at low pH (<5.5) or high Sodium (Na) inhibits root elongation and reduces growth.';

  @override
  String get phEmergence => 'pH Emergence';

  @override
  String get phEmergenceDesc => 'Dynamically calculated based on base saturation (Ca/Mg/K balance) and CO₂ acidification from respiration.';

  @override
  String get atmosphereDesc => 'Live weather forcing that drives evapotranspiration and infiltration.';

  @override
  String get plantCanopy => 'Plant Canopy';

  @override
  String get plantCanopyDesc => 'Crop vitality and root-foraging response under current soil conditions.';

  @override
  String get layerAnalysisDesc => 'Contextual layer diagnostics at pointer location (no manual panel opening needed).';

  @override
  String get vpd => 'VPD';

  @override
  String get rain => 'Rain';

  @override
  String get turgor => 'Turgor';

  @override
  String get height => 'Height';

  @override
  String get lai => 'LAI';

  @override
  String get rootNodes => 'Root Nodes';

  @override
  String get saturation => 'Saturation';

  @override
  String get porosity => 'Porosity';

  @override
  String get cracks => 'Cracks';

  @override
  String get microbes => 'Microbes';

  @override
  String get gasBubbles => 'Gas Bubbles';

  @override
  String get ions => 'Ions';

  @override
  String get cecSites => 'CEC Sites';

  @override
  String get visualKey => 'VISUAL KEY';

  @override
  String get systemAdvisor => 'System Advisor';

  @override
  String confidenceLabel(String value) {
    return '$value% Confidence';
  }

  @override
  String get fieldDiagnostics => 'Field Diagnostics';

  @override
  String get redoxEh => 'Redox (Eh)';

  @override
  String get oxygenLabel => 'Oxygen';

  @override
  String get phLevel => 'pH Level';

  @override
  String get atmosphereLabel => 'Atmosphere:';

  @override
  String get co2Label => 'CO2';

  @override
  String get vpdLabel => 'VPD:';

  @override
  String get physical => 'Physical';

  @override
  String get chemical => 'Chemical';

  @override
  String get biological => 'Biological';

  @override
  String get ammonium => 'Ammonium (NH₄)';

  @override
  String get organicN => 'Organic N (POM)';

  @override
  String get organicCarbon => 'Organic Carbon';

  @override
  String get denitrification => 'Denitrification';

  @override
  String get mechanical => 'Mechanical';

  @override
  String get fungalHyphae => 'Fungal Hyphae';

  @override
  String get bioGlue => 'Bio-Glue (EPS)';

  @override
  String get structureHP => 'Structure HP';

  @override
  String get fragile => 'Fragile';

  @override
  String get resilient => 'Resilient';

  @override
  String stabilityLabel(String value) {
    return '$value% Stability';
  }

  @override
  String get physicsOverride => 'Physics Override';

  @override
  String get constituents => 'Constituents';

  @override
  String get microbialEngines => 'Microbial Engines';

  @override
  String get liveCalculations => 'Live Calculations';

  @override
  String get tempFactor => 'Temp Factor (Q10)';

  @override
  String get metabolicMultiplier => 'Metabolic multiplier';

  @override
  String get waterLimitation => 'Water Limitation';

  @override
  String get hydraulicConnectivity => 'Hydraulic connectivity';

  @override
  String get o2Availability => 'O2 Availability';

  @override
  String get aerobicRespirationPotential => 'Aerobic respiration potential';

  @override
  String get bioChemicalRates => 'Bio-Chemical Rates';

  @override
  String get co2ProductionRate => 'CO₂ production rate';

  @override
  String get nNitrification => 'N-Nitrification';

  @override
  String get transformationDesc => 'NH₄⁺ ➔ NO₃⁻ transformation';

  @override
  String get denitrificationDesc => 'N₂O loss (Anaerobic)';

  @override
  String get active => 'Active';

  @override
  String get inhibited => 'Inhibited';

  @override
  String get zoomNote => 'NOTE: Zoom in further to see individual bacterial colonies and fungal hyphae responding to these factors.';

  @override
  String get metabolicFlux => 'Metabolic Flux';

  @override
  String get causalPathways => 'Causal Pathways';

  @override
  String get oxygenRedoxEh => 'Oxygen ➔ Redox (Eh)';

  @override
  String get hypoxiaDesc => 'Hypoxia triggers electron acceptance shifts.';

  @override
  String get ehDenitrification => 'Eh ➔ Denitrification';

  @override
  String get denitLowRedoxDesc => 'Low redox potential drives nitrate reduction to gas.';

  @override
  String get phPLock => 'pH ➔ P-Lock';

  @override
  String get pFixationDesc => 'Phosphorus fixation by minerals based on acidity.';

  @override
  String get activeFormulas => 'Active Formulas (Real-time)';

  @override
  String get vanGenuchtenTitle => 'van Genuchten (Water)';

  @override
  String get vanGenuchtenDesc => 'Governs how much water soil holds at specific suction.';

  @override
  String get millingtonQuirkTitle => 'Millington-Quirk (Gas)';

  @override
  String get millingtonQuirkDesc => 'Calculates gas diffusion through air-filled pore space.';

  @override
  String get nutrientApplicationConsole => 'Nutrient Application Console';

  @override
  String get applyAll => 'Apply All';

  @override
  String nutrientsAppliedSnackBar(int count) {
    return 'Applied $count nutrients to the soil surface.';
  }

  @override
  String get selectNutrients => 'Select Nutrients';

  @override
  String get fertilizationMixHint => 'Tap elements to add or remove them from your fertilization mix.';

  @override
  String get noNutrientsSelected => 'No Nutrients Selected';

  @override
  String get adjustAmountHint => 'Select elements from the periodic table to adjust their application amounts.';

  @override
  String get applicationMix => 'Application Mix';

  @override
  String totalElements(int count) {
    return 'Total Elements: $count';
  }

  @override
  String get clearMix => 'Clear Mix';

  @override
  String get fieldMetrics => 'Field Metrics';

  @override
  String get historyMode => 'History Mode';

  @override
  String get timeline => 'Timeline';

  @override
  String dayLabel(int value) {
    return 'Day $value';
  }

  @override
  String get atmosphereSimulator => 'Soil-Plant-Atmosphere Simulator';

  @override
  String errorLoadingScenarios(String error) {
    return 'Error loading scenarios: $error';
  }

  @override
  String objectivesCount(int count) {
    return '$count Objectives';
  }

  @override
  String get elements => 'Elements';

  @override
  String get depthProfiles => 'Depth Profiles';

  @override
  String get selectElementDetails => 'Select an element to view details';

  @override
  String get atomicMass => 'Atomic Mass';

  @override
  String get soilTextureClassification => 'Soil Texture Classification';

  @override
  String get textureInteractiveHint => 'Interactive: Probe different compositions to see physical parameters';

  @override
  String get usdaTextureClass => 'USDA Texture Class';

  @override
  String get sandFraction => 'Sand Fraction';

  @override
  String get siltFraction => 'Silt Fraction';

  @override
  String get clayFraction => 'Clay Fraction';

  @override
  String get hydraulicParameters => 'Hydraulic Parameters';

  @override
  String get satConductivity => 'Sat. Conductivity (Ksat)';

  @override
  String get satWaterContent => 'Sat. Water Content (θs)';

  @override
  String get vgAlphaLabel => 'VG Alpha (α)';

  @override
  String get vgNLabel => 'VG n';

  @override
  String get resetToActiveLayer => 'Reset to Active Layer';

  @override
  String get mollierChartTitle => 'Psychrometric (Mollier) Chart';

  @override
  String get mollierInteractiveHint => 'Interactive: Explore T/RH relationship and Drying Power (VPD)';

  @override
  String get dryingPower => 'Drying Power';

  @override
  String get airTemperature => 'Air Temperature';

  @override
  String get roleInEcosystem => 'Role in Ecosystem';

  @override
  String get resetToLiveWeather => 'Reset to Live Weather';

  @override
  String get lowVpd => 'LOW (Low Transpiration)';

  @override
  String get optimalVpd => 'OPTIMAL (Ideal Growth)';

  @override
  String get highVpd => 'HIGH (Stomatal Closure Risk)';

  @override
  String get criticalVpd => 'CRITICAL (Severe Wilting)';

  @override
  String get satVaporPressure => 'Sat. Vapor Pressure';

  @override
  String get vpdSeverity => 'VPD Severity';

  @override
  String get soilDepthProfiles => 'Soil Depth Profiles';

  @override
  String get depthProfilesDesc => 'Visualization of physical and chemical gradients across the soil column.';

  @override
  String get scientificAnalyticsTitle => 'Scientific Analytics & Control';

  @override
  String get eventLog => 'Event Log';

  @override
  String get clearLog => 'Clear log';

  @override
  String get objectiveProduceBiomass => 'Produce Biomass';

  @override
  String get objectiveRestoreHealth => 'Restore Soil Health';

  @override
  String get objectivePreventLeaching => 'Prevent Leaching';

  @override
  String get objectiveReachYield => 'Reach Yield Target';

  @override
  String get objectiveUnlockNitrogen => 'Unlock Nitrogen';

  @override
  String get objectiveCropVitality => 'Improve Crop Vitality';

  @override
  String get bulkDensity => 'Bulk Density';

  @override
  String get insight_droughtStress => 'Drought Stress: Low soil water potential is reducing turgor pressure, halting cell expansion (Lockhart Law).';

  @override
  String get insight_vigorousGrowth => 'Vigorous Growth: Optimal turgor and nutrient availability are maximizing biomass accumulation.';

  @override
  String insight_chainReaction(String minEh) {
    return 'Chain Reaction: Saturation -> Oxygen Depletion -> Redox Drop ($minEh mV) -> Denitrification losing Nitrogen.';
  }

  @override
  String insight_phosphateLockup(String ph, String reason) {
    return 'Phosphate Lock-up: Extreme pH ($ph) is causing Phosphorus to be sorbed by $reason, reducing availability for the plant.';
  }

  @override
  String get insight_leachingAlert => 'Leaching Alert: Nitrate is migrating below the root zone due to high downward flux.';

  @override
  String get insight_nitrogenLock => 'Nitrogen Lock: High C/N ratio in organic matter is causing microbes to immobilize mineral Nitrogen, starving the plant.';

  @override
  String get insight_thermalInertia => 'Thermal Inertia: Wet soil has higher heat capacity and lower albedo, leading to slower heating but better heat retention at night.';

  @override
  String get insight_lowAlbedo => 'Low Albedo: Darker surface (due to wetness or mulch) is absorbing more solar radiation, increasing surface energy intake.';

  @override
  String get insight_radiativeCooling => 'Radiative Cooling: Soil is emitting longwave radiation (Stefan-Boltzmann law) but retaining heat better than the air.';

  @override
  String get insight_hungryMicrobes => 'Hungry Microbes: High biomass but low POM! Microbes are mineralizing organic matter quickly.';

  @override
  String get insight_bioGlueActive => 'Bio-Glue: High EPS levels are stabilizing soil aggregates, improving structure and Structure HP.';

  @override
  String get insight_activeCycling => 'Active Cycling: Healthy microbial biomass is actively depolymerizing organic Nitrogen (Schimel & Bennett Law).';

  @override
  String get insight_physicalBarrier => 'Physical Barrier: Surface compaction is causing ponding and limiting deep water infiltration.';

  @override
  String insight_runoffRisk(String rain, String capacity) {
    return 'Runoff Risk: Rain intensity ($rain mm/h) exceeds topsoil infiltration capacity ($capacity mm/h), leading to surface runoff.';
  }

  @override
  String get insight_surfaceSealing => 'Surface Sealing: Low aggregate stability is causing the surface to seal (crust), reducing infiltration by 90%.';

  @override
  String get insight_bioArmor => 'Bio-Armor: Cover crop is protecting the surface from rain-induced slaking and improving structural health.';

  @override
  String get insight_structureCrisis => 'Structure Crisis: Low aggregate stability (Structure HP)! Soil is prone to erosion and compaction. Increase organic matter or fungal activity.';

  @override
  String get insight_resilientStructure => 'Resilient Structure: Strong aggregate stability is protecting the pore space and maximizing water infiltration.';

  @override
  String get insight_biologicalDesert => 'Biological Desert: Very low microbial biomass. Nutrient cycling is stalled. Consider adding organic carbon (POM).';

  @override
  String get insight_metabolicStress => 'Metabolic Stress: High microbial population but low Oxygen! Microbes are switching to anaerobic pathways, causing Redox drop.';

  @override
  String get insight_tillageTradeoff => 'Tillage Trade-off: Improved aeration and conductivity, but fungal networks have been disrupted.';

  @override
  String get process => 'Process';

  @override
  String get source => 'Source';

  @override
  String get significance => 'Significance';

  @override
  String get risk => 'Risk';

  @override
  String get mobility => 'Mobility';

  @override
  String get uptake => 'Uptake';

  @override
  String get type => 'Type';

  @override
  String get deficiencySymptom => 'Deficiency Symptom';

  @override
  String get feature => 'Special Feature';

  @override
  String get role => 'Role';

  @override
  String get climateImpact => 'Climate Impact';

  @override
  String get consequence => 'Consequence';

  @override
  String get helper => 'Helper';

  @override
  String get catalyst => 'Catalyst';

  @override
  String get mechanism => 'Mechanism';

  @override
  String get importance => 'Importance';

  @override
  String get nutrient => 'Nutrient';

  @override
  String get measurement => 'measurement';

  @override
  String get availableNutrient => 'Plant Available';

  @override
  String get limiter => 'Limiter';

  @override
  String get location => 'Location';

  @override
  String get upward => 'Upward';

  @override
  String get intoRoot => 'Into Root';

  @override
  String get intoLeaves => 'Into Leaves';

  @override
  String get aerobicRespiration => 'Aerobic Respiration';

  @override
  String get anaerobicDenitrification => 'Anaerobic Denitrification';

  @override
  String get denitrifiers => 'Denitrifying Bacteria';

  @override
  String get bioturbation => 'Bioturbation';

  @override
  String get improvedInfiltration => 'Improved Infiltration';

  @override
  String get nutrientCycling => 'Nutrient Cycling';

  @override
  String get organicMatterMixing => 'Mixing of Organic Matter';

  @override
  String get veryGood => 'Very Good';

  @override
  String get veryWeak => 'Very Weak';

  @override
  String get moderate => 'Moderate';

  @override
  String get slow => 'Slow';

  @override
  String get activeTransport => 'Active Transport';

  @override
  String get solubleNutrient => 'Soluble Nutrient';

  @override
  String get solubleNutrientDesc => 'Soluble nutrient in the soil solution. Ions move near the roots through diffusion and mass flow.';

  @override
  String get streptomyces => 'Streptomyces';

  @override
  String get decompositionCapacity => 'Decomposition Capacity';

  @override
  String get resistantCompounds => 'Resistant Compounds';

  @override
  String get photosynthateDistribution => 'Photosynthate Distribution';

  @override
  String get microbialEnergySource => 'Microbial Energy Source';

  @override
  String get leachingAfterRain => 'Leaching after rain';

  @override
  String get leafMarginBurn => 'Leaf margin burn';

  @override
  String get noRedistribution => 'No redistribution';

  @override
  String get chlorophyllCenter => 'Center of chlorophyll';

  @override
  String get oldLeafChlorosis => 'Old leaf chlorosis';

  @override
  String get anaerobiosisWaterlogging => 'Anaerobiosis in waterlogging';

  @override
  String get microbialRespiration => 'Microbial Respiration';

  @override
  String get soilBiologicalActivity => 'Soil Biological Activity';

  @override
  String get greenhouseGasEmissions => 'Greenhouse Gas Emissions';

  @override
  String get highAfterRain => 'High after rain';

  @override
  String get groundwaterContamination => 'Groundwater Contamination';

  @override
  String get generalChlorosis => 'General Chlorosis';

  @override
  String get mycorrhizae => 'Mycorrhizae';

  @override
  String get nutrientBank => 'Nutrient Bank';

  @override
  String get heterotrophicMicrobes => 'Heterotrophic Microbes';

  @override
  String get electrostaticBinding => 'Electrostatic Binding';

  @override
  String get preventsLeaching => 'Prevents leaching';

  @override
  String get nutrientRelease => 'Nutrient release';

  @override
  String get especiallyPAndK => 'Especially P and K';

  @override
  String get soilMoisture => 'Soil moisture';

  @override
  String get biogeochemical => 'Biogeochemical';

  @override
  String get soilProfile => 'Soil profile';

  @override
  String get organicHorizon => 'Organic';

  @override
  String get topsoilHorizon => 'Topsoil';

  @override
  String get subsoilHorizon => 'Subsoil';

  @override
  String get parentMaterialHorizon => 'Parent Material';

  @override
  String get bedrockHorizon => 'Bedrock';

  @override
  String get cuticle => 'Cuticle';

  @override
  String get palisade => 'Palisade Mesophyll';

  @override
  String get vein => 'Vein';

  @override
  String get stoma => 'Stoma';

  @override
  String get epidermis => 'Epidermis';

  @override
  String get phloem => 'Phloem';

  @override
  String get cambium => 'Cambium';

  @override
  String get xylem => 'XYLEM';

  @override
  String get rootHair => 'Root Hair';

  @override
  String get cortex => 'Cortex';

  @override
  String get casparianStrip => 'Casparian Strip';

  @override
  String get exudates => 'Exudates';

  @override
  String get flagella => 'Flagella';

  @override
  String get cellWall => 'Cell Wall';

  @override
  String get dna => 'DNA';

  @override
  String get enzymes => 'Enzymes';

  @override
  String get stemCrossSection => 'Stem Cross-Section';

  @override
  String get rootTissue => 'Root Tissue';

  @override
  String get microbialCell => 'Microbial Cell';

  @override
  String get simulationStatus => 'Status';

  @override
  String get runningStatus => 'Running';

  @override
  String get pausedStatus => 'Paused';

  @override
  String get iteration => 'Iteration';

  @override
  String get deltaT => 'Delta T';

  @override
  String get modules => 'Modules';

  @override
  String get noEvents => 'No events';

  @override
  String get heightLabel => 'Height';

  @override
  String get laiLabel => 'LAI';

  @override
  String get turgorPressure => 'Turgor Pressure';

  @override
  String get rootNodesLabel => 'Root Nodes';

  @override
  String get rootDepthLabel => 'Root Depth';

  @override
  String get ionLabel => 'Ion';

  @override
  String get concentrationLabel => 'Concentration';

  @override
  String get chargeLabel => 'Charge';

  @override
  String get bindingLabel => 'Binding';

  @override
  String get layerLabel => 'Layer';

  @override
  String get waterBalance => 'Water Balance';

  @override
  String get stomataLabel => 'Stomata';

  @override
  String get structureLabel => 'Structure';

  @override
  String get phBuffer => 'pH Buffer';

  @override
  String get phEffect => 'pH Effect';

  @override
  String get antagonist => 'Antagonist';

  @override
  String get photosynthesis => 'Photosynthesis';

  @override
  String get photosynthesisDesc => 'Plants convert solar energy, CO2, and water into chemical energy (sugars). This process is the foundation of the ecosystem\'s energy flux.';

  @override
  String get redistribution => 'Redistribution';

  @override
  String get porosityEffect => 'Porosity Effect';

  @override
  String get populationLabel => 'Population';

  @override
  String get gasLabel => 'Gas';

  @override
  String get reactionLabel => 'Reaction';

  @override
  String get stateLabel => 'State';

  @override
  String get immobilized => 'Immobilized';

  @override
  String get velocityLabel => 'Velocity';

  @override
  String get climateEffect => 'Climate Effect';

  @override
  String get airTempLabel => 'Air Temperature';

  @override
  String get nitrogenLoss => 'Nitrogen Loss';

  @override
  String get metabolism => 'Metabolism';

  @override
  String get tempOptimum => 'Temp Optimum';

  @override
  String get moistureOptimum => 'Moisture Optimum';

  @override
  String get specialty => 'Specialty';

  @override
  String get carbonStorage => 'Carbon Storage';

  @override
  String get oxidationReduction => 'Redox';

  @override
  String get organicCarbonLabel => 'Org. Carbon';

  @override
  String get microbialMassLabel => 'Microbial Mass';

  @override
  String get waterStatus => 'Water Status';

  @override
  String get limited => 'Limited';

  @override
  String get mildStress => 'Mild Stress';

  @override
  String get severeStress => 'Severe Stress';

  @override
  String get goodWaterStatus => 'Good Water Status';

  @override
  String get xylemLabel => 'Xylem';

  @override
  String get phloemLabel => 'Phloem';

  @override
  String get waterUp => 'water up';

  @override
  String get sugarsDown => 'sugars down';

  @override
  String get plantDescription => 'Plant water status depends on turgor pressure, which drives cell tension and growth. When soil water potential drops (drought), the plant closes stomata to save water, but at the same time photosynthesis slows down. The root system actively seeks water and nutrients.';

  @override
  String get earthwormDescription => 'Earthworms are ecosystem engineers that improve soil structure by creating macropores (bioturbation). They mix organic matter into the mineral soil, improve water infiltration and aeration. Earthworm burrows also serve as pathways for roots.';

  @override
  String get bubbleCo2Description => 'Soil respiration releases carbon dioxide when microbes and roots decompose organic matter and produce energy. This is a sign of healthy microbial activity. The rate of respiration depends on temperature, moisture, and C content.';

  @override
  String get bubbleN2oDescription => 'Nitrous oxide is released when denitrifying bacteria reduce nitrate in anaerobic (oxygen-free) conditions. This happens especially in waterlogged soil. N2O is a potent greenhouse gas (298x CO2) - a sign of a problem!';

  @override
  String get ionNitrateDescription => 'Nitrate is the most important form of nitrogen for plants. It moves easily in soil water and is therefore prone to leaching. Excessive irrigation or heavy rain can wash nitrate into groundwater - causing eutrophication of water bodies.';

  @override
  String get ionPhosphateDescription => 'Phosphate is a component of ATP and DNA. It binds strongly to iron, aluminum, and calcium, so its mobility is poor. Mycorrhizal fungi help the plant obtain phosphate.';

  @override
  String get ionPotassiumDescription => 'Potassium regulates the opening of stomata and the plant\'s water balance. It binds between clay minerals (CEC) and is released by ion exchange. High potassium levels can interfere with magnesium uptake.';

  @override
  String get ionCalciumDescription => 'Calcium is a binder for pectin in cell walls and acts as a signaling molecule. It does not re-move in the plant, so young plant parts need a continuous supply. Liming raises the soil pH.';

  @override
  String get ionMagnesiumDescription => 'Magnesium is the central atom of chlorophyll - without it, no photosynthesis! It moves well in the plant and moves from old leaves to young ones as needed. High potassium levels can interfere with magnesium uptake.';

  @override
  String get bacteriaDescription => 'Soil bacteria are the fastest decomposers and the engines of nutrient cycling. They operate near the roots (rhizosphere), decompose organic matter and release nutrients to plants. Nitrifying bacteria convert ammonium to nitrate.';

  @override
  String get fungiDescription => 'Fungal mycelia form underground networks that transport water and nutrients over long distances. Mycorrhizae form symbioses with plants. Fungi decompose difficult-to-decompose compounds such as lignin and cellulose.';

  @override
  String get actinomycetesDescription => 'Streptomyces group bacteria that produce antibiotics and decompose difficult-to-decompose compounds. They produce geosmin - the cause of the earthy smell. Slower than bacteria, but more efficient at decomposing difficult compounds.';

  @override
  String get soilTypeLabel => 'Soil Type';

  @override
  String get textureAS => 'Heavy Clay (AS)';

  @override
  String get textureHtS => 'Sandy Clay (HtS)';

  @override
  String get textureHeS => 'Silty Clay (HeS)';

  @override
  String get textureHsS => 'Fine Silty Clay (HsS)';

  @override
  String get textureHt => 'Sand (Ht)';

  @override
  String get textureHe => 'Silt (He)';

  @override
  String get textureHs => 'Fine Silt (Hs)';

  @override
  String get aerationLabel => 'Aeration';

  @override
  String get redoxStateLabel => 'Redox State';

  @override
  String get siltyClay => 'Silty Clay';

  @override
  String get sandyClay => 'Sandy Clay';

  @override
  String get clayLoam => 'Clay Loam';

  @override
  String get sandyClayLoam => 'Sandy Clay Loam';

  @override
  String get siltyClayLoam => 'Silty Clay Loam';

  @override
  String get siltLoam => 'Silt Loam';

  @override
  String get loamySand => 'Loamy Sand';

  @override
  String get sandyLoam => 'Sandy Loam';

  @override
  String get loam => 'Loam';

  @override
  String get goodAeration => 'Good Aeration ✓';

  @override
  String get oxygenDeficiency => 'Oxygen Deficiency ⚠️';

  @override
  String get aerobicState => 'Aerobic';

  @override
  String get anaerobicState => 'Anaerobic ⚠️';

  @override
  String get sufficientAeration => 'Sufficient Aeration';

  @override
  String get poorAeration => 'Poor Aeration ⚠️';

  @override
  String get variableRedox => 'Variable Redox';

  @override
  String get saturated => 'Saturated';

  @override
  String get dry => 'Dry';

  @override
  String get normal => 'Normal';

  @override
  String get acidic => 'Acidic';

  @override
  String get neutral => 'Neutral';

  @override
  String get alkaline => 'Alkaline';

  @override
  String get available => 'Available';

  @override
  String get hardToTake => 'Hard to take';

  @override
  String get mineralizationTitle => 'Mineralization';

  @override
  String get mineralizationDesc => 'Microbes decompose organic matter and release nutrients (N, P, S) into the soil solution.';

  @override
  String get nitrificationTitle => 'Nitrification';

  @override
  String get nitrificationDesc => 'A two-step oxidation reaction: ammonia → nitrite → nitrate. Requires aerobic conditions.';

  @override
  String get denitrificationTitle => 'Denitrification';

  @override
  String get adsorptionTitle => 'Adsorption';

  @override
  String get adsorptionDesc => 'Nutrients bind to the surfaces of soil particles (clay, humus) by electrical forces.';

  @override
  String get desorptionTitle => 'Desorption';

  @override
  String get desorptionDesc => 'Bound nutrients are released back into the soil solution through ion exchange.';

  @override
  String get ionNitrateTitle => 'NITRATE (NO₃⁻)';

  @override
  String get ionNitrateName => 'NO₃⁻ (nitrate)';

  @override
  String get ionPhosphateTitle => 'PHOSPHATE (H₂PO₄⁻)';

  @override
  String get ionPhosphateName => 'H₂PO₄⁻ / HPO₄²⁻';

  @override
  String get ionPotassiumTitle => 'POTASSIUM (K⁺)';

  @override
  String get ionPotassiumName => 'K⁺ (potassium)';

  @override
  String get ionCalciumTitle => 'CALCIUM (Ca²⁺)';

  @override
  String get ionCalciumName => 'Ca²⁺ (calcium)';

  @override
  String get ionMagnesiumTitle => 'MAGNESIUM (Mg²⁺)';

  @override
  String get ionMagnesiumName => 'Mg²⁺ (magnesium)';

  @override
  String negativeCharge(String value) {
    return 'Negative ($value)';
  }

  @override
  String positiveCharge(String value) {
    return 'Positive ($value)';
  }

  @override
  String get leaches => 'Leaches';

  @override
  String get diffusionAndMycorrhiza => 'Diffusion + mycorrhiza';

  @override
  String get energy => 'Energy';

  @override
  String get bound => 'Bound';

  @override
  String get clayMinerals => 'Clay minerals';

  @override
  String get cellWallSignal => 'Cell wall, signal';

  @override
  String get limingRaisesPH => 'Liming raises pH';

  @override
  String get goodRedistribution => 'Good (redistribution)';

  @override
  String get highK => 'High K⁺';

  @override
  String get diffusionTitle => 'Diffusion';

  @override
  String get diffusionDesc => 'Ions move in the direction of the concentration gradient (from high to low).';

  @override
  String get nutrientUptakeTitle => 'Nutrient Uptake';

  @override
  String get nutrientUptakeDesc => 'Roots take up nutrients by active transport (requiring ATP energy) or passive flow.';

  @override
  String get bypassFlowTitle => 'Bypass Flow';

  @override
  String get bypassFlowDesc => 'Water and dissolved nutrients flow rapidly through macropores (wormholes, cracks).';

  @override
  String get soilMoistureTitle => 'Soil Moisture';

  @override
  String get soilMoistureDesc => 'Volumetric water content (θ) tells what part of the soil volume is water.';

  @override
  String get phTitle => 'pH (Acidity)';

  @override
  String get phDesc => 'pH measures the activity of hydrogen ions (H+). it affects nutrient solubility and microbial activity.';

  @override
  String get waterPotentialTitle => 'Water Potential (Ψ)';

  @override
  String get waterPotentialDesc => 'Matrix potential (Ψ) describes the force with which the soil holds water.';

  @override
  String get dissolvedOxygenTitle => 'Dissolved Oxygen (O2)';

  @override
  String get dissolvedOxygenDesc => 'Roots and aerobic microbes need oxygen for cell respiration.';

  @override
  String get nitrogenTitle => 'Nitrogen (N)';

  @override
  String get nitrogenDesc => 'The most important growth nutrient. Building block of proteins, chlorophyll, and nucleic acids.';

  @override
  String get phosphorusTitle => 'Phosphorus (P)';

  @override
  String get phosphorusDesc => 'Component of ATP and DNA. Very poorly mobile - binds to clay and iron oxides.';

  @override
  String get potassiumTitle => 'Potassium (K)';

  @override
  String get potassiumDesc => 'Regulates the opening of stomata, water balance, and enzyme activity.';

  @override
  String get calciumTitle => 'Calcium (Ca)';

  @override
  String get calciumDesc => 'Binder for pectin in cell walls and a signaling molecule. Does not re-move in the plant.';

  @override
  String get magnesiumTitle => 'Magnesium (Mg)';

  @override
  String get magnesiumDesc => 'Central atom of chlorophyll - without magnesium, no photosynthesis.';

  @override
  String get solarRadiationTitle => 'Solar Radiation';

  @override
  String get solarRadiationDesc => 'Light provides energy for photosynthesis. PAR (400-700 nm) is absorbed by chlorophyll.';

  @override
  String get leachingTitle => 'Leaching';

  @override
  String get leachingDesc => 'Nutrients (especially nitrate) leach with rainwater into groundwater. Economic loss and environmental risk.';

  @override
  String get topsoilDesc => 'Topsoil is the most biologically active layer of the soil. Most microbes and soil organisms live here. Organic matter decomposes into humus and nutrients cycle fastest. Roots take up most of their nutrients from this layer.';

  @override
  String get subsoilDesc => 'Oxides of clay, iron, and aluminum accumulate in the enrichment layer from above. This layer is often denser and may limit water permeability. Roots penetrate here in search of water and nutrients, but biological activity is lower.';

  @override
  String get parentMaterialDesc => 'The subsoil is the least weathered soil layer, consisting of material detached from the bedrock. Biological activity is low, but the layer acts as a water reservoir and source of minerals in the long term.';

  @override
  String get genericLayerDesc => 'This soil layer contains different particle sizes and organic matter. The properties of the layer affect water retention capacity, aeration, and root growth.';

  @override
  String get organicHorizonDesc => 'The organic layer consists of decomposing plant and animal material. High carbon content and biological activity.';

  @override
  String get bedrockDesc => 'Bedrock is solid rock that underlies the soil layers. It forms the ultimate boundary for root growth and water movement.';

  @override
  String get sunIndicatorDesc => 'Solar radiation on the surface. PAR (Photosynthetically Active Radiation, 400-700 nm) provides energy for photosynthesis. Beer-Lambert law describes light absorption through plant mass.';

  @override
  String get totalRadiation => 'Total Radiation';

  @override
  String get parFraction => 'PAR Fraction';

  @override
  String get absorbedPar => 'Absorbed PAR';

  @override
  String get transmission => 'Transmission';

  @override
  String get formula => 'Formula';

  @override
  String get routeLabel => 'Route';

  @override
  String get forceLabel => 'Force';

  @override
  String get speedLabel => 'Speed';

  @override
  String get leafLabel => 'Leaf';

  @override
  String get tapToSeeDetails => 'Tap an animation element to see more details';

  @override
  String get inspection => 'Inspection';

  @override
  String get selected => 'Selected';

  @override
  String get measurementData => 'Measurement Data';

  @override
  String get legend => 'Legend';

  @override
  String get fieldCapacity => 'field capacity';

  @override
  String get longTerm => 'Long-term';

  @override
  String get actinomycetesTitle => 'Actinomycetes';

  @override
  String get waterUptakeDesc => 'Water moves from roots to leaves in a perpendicular piping system (xylem). Suction is created by evaporation through stomata - this is called the transpiration stream.';

  @override
  String get carbonCycleDesc => 'Photosynthates (sugars) flow in the phloem from leaves to roots, or the root secretes carbon compounds into the soil for microbial food (exudates).';

  @override
  String get nitrogenUptakeDesc => 'Nitrate (NO3-) or ammonium (NH4+) moves from the soil solution to the root by active transport. Nitrogen is a key factor in growth - a building block of proteins and chlorophyll.';

  @override
  String get phosphorusUptakeDesc => 'Phosphate (H2PO4-) is a poorly mobile nutrient that mycorrhizae help to collect. Essential component of ATP and DNA.';

  @override
  String get potassiumUptakeDesc => 'Potassium (K+) regulates the opening of stomata and the plant\'s water balance. Important maintainer of osmotic pressure.';

  @override
  String get calciumUptakeDesc => 'Calcium (Ca2+) strengthens cell walls and acts as a signaling molecule. It does not re-move in the plant - new leaves need a constant supply.';

  @override
  String get magnesiumUptakeDesc => 'Magnesium (Mg2+) is the central atom of chlorophyll - without it, no photosynthesis. Moves in the plant from old leaves to new ones.';

  @override
  String get oxygenDiffusionDesc => 'Oxygen diffuses from the atmosphere into soil pores, enabling aerobic life. High water content blocks this transport, leading to hypoxia.';

  @override
  String get gasExchangeDesc => 'CO2 and N2O are released from the soil as by-products of microbial respiration. High CO2 emission indicates active microbiology.';

  @override
  String get adsorptionMechanism => 'Electrostatic binding';

  @override
  String get ionExchange => 'Ion exchange';

  @override
  String get downward => 'Downward';

  @override
  String get downwardLoss => 'Downward (loss)';

  @override
  String get downwardDiffusion => 'Downward (diffusion)';

  @override
  String get upwardDiffusion => 'Upward (diffusion)';

  @override
  String get downwardOut => 'Downward/Out';

  @override
  String get bindingOrder => 'Binding Order';

  @override
  String get cecTitle => 'CEC (Cation Exchange Capacity)';

  @override
  String get cecDesc => 'The soil\'s ability to bind and release positively charged ions (cations). Negative charges of clay minerals and humus hold nutrients from leaching.';

  @override
  String get estimatedCec => 'Estimated CEC';

  @override
  String get clayContent => 'Clay Content';

  @override
  String get bindingIons => 'Binding Ions';

  @override
  String get leachingProtection => 'Leaching Protection';

  @override
  String get aerobicProcess => 'Aerobic Process';

  @override
  String get gradientMovement => 'Gradient Movement';

  @override
  String get uptakeLabel => 'Uptake';

  @override
  String get leachingRiskLabel => 'Leaching Risk';

  @override
  String get reactant => 'Reactant';

  @override
  String get product => 'Product';

  @override
  String get organicNProteins => 'Organic N (proteins)';

  @override
  String get ammoniumProduct => 'NH4+ (ammonium)';

  @override
  String get availableP => 'Available P';

  @override
  String get optimalTemp => 'Optimal Temp';

  @override
  String get optimalMoisture => 'Optimal Moisture';

  @override
  String get unit => 'Unit';

  @override
  String get directionLabel => 'Direction';

  @override
  String get consumption => 'Consumption';

  @override
  String get requirement => 'Requirement';

  @override
  String get phOptimum => 'pH Optimum';

  @override
  String get exchangeableK => 'Exchangeable K+';

  @override
  String get solubleCa => 'Soluble Ca2+';

  @override
  String get exchangeableMg => 'Exchangeable Mg2+';

  @override
  String get trigger => 'Trigger';

  @override
  String get surface => 'Surface';

  @override
  String get balance => 'Balance';

  @override
  String get area => 'Area';

  @override
  String get assessment => 'Assessment';

  @override
  String get anecicDesc => 'Anecic (deep burrower)';

  @override
  String get nitrogenAtmosphereLoss => 'Nutrient lost to atmosphere!';

  @override
  String get stomataTurgorRole => 'Stomata regulation, turgor';

  @override
  String get kAntagonistDesc => 'High K+ interferes';

  @override
  String get heavyRainTrigger => 'Heavy rain, saturated soil';

  @override
  String get nutrientLossConsequence => 'Nutrient loss, water body load';

  @override
  String get cnRatioLabel => 'C:N Ratio';

  @override
  String get cnRatioDesc => 'Critical for microbial activity';

  @override
  String get demandLabel => 'Demand';

  @override
  String get highMacronutrient => 'High (macronutrient)';

  @override
  String get airToSoil => 'Air → Soil';

  @override
  String get consumptionLabel => 'Consumption';

  @override
  String get rootRespirationMicrobes => 'Root Respiration + Microbes';

  @override
  String get gasesLabel => 'Gases';

  @override
  String get wavelengthLabel => 'Wavelength';

  @override
  String get absorptionLabel => 'Absorption';

  @override
  String get productLabel => 'Product';

  @override
  String get atpProductDesc => 'ATP + NADPH → Sugars';

  @override
  String get heatFluxTitle => 'Heat Flux';

  @override
  String get heatFluxDesc => 'Thermal energy moves along the temperature gradient. Solar radiation heats the surface, and heat is conducted deeper into the soil.';

  @override
  String get thermalConduction => 'Thermal Conduction';

  @override
  String get governsMetabolism => 'Regulates microbial metabolism';

  @override
  String get alongGradient => 'Along gradient';

  @override
  String get salinityTitle => 'Salinity / EC';

  @override
  String get salinityDesc => 'Dissolved salts and nutrients affect the soil\'s electrical conductivity (EC). High salinity causes osmotic stress to the plant.';

  @override
  String get dissolvedIons => 'Dissolved Ions';

  @override
  String get osmoticStress => 'Osmotic Stress';

  @override
  String get accumulationLeaching => 'Accumulation / Leaching';

  @override
  String get macronutrient => 'Macronutrient';

  @override
  String get energyNutrient => 'Energy Nutrient';

  @override
  String get availablePLabel => 'Available P';

  @override
  String get exchangeableKLabel => 'Exchangeable K+';

  @override
  String get solubleCaLabel => 'Soluble Ca2+';

  @override
  String get exchangeableMgLabel => 'Exchangeable Mg2+';

  @override
  String get reactantLabel => 'Reactant';

  @override
  String get organicNProteinsLabel => 'Organic N (proteins)';

  @override
  String get ammoniumProductLabel => 'NH4+ (ammonium)';

  @override
  String get optimalTempLabel => 'Optimal Temp';

  @override
  String get optimalMoistureLabel => 'Optimal Moisture';

  @override
  String get requirementLabel => 'Requirement';

  @override
  String get aerobicProcessLabel => 'Aerobic Process';

  @override
  String get mechanismLabel => 'Mechanism';

  @override
  String get clayHumusSurface => 'Clay minerals, humus';

  @override
  String get ionExchangeLabel => 'Ion exchange';

  @override
  String get rootHSecretion => 'Root H+ secretion';

  @override
  String get solidToSolution => 'Solid → Solution';

  @override
  String get gradientMovementLabel => 'Gradient movement';

  @override
  String get mycorrhizaeHelper => 'Mycorrhizae';

  @override
  String get rootHairArea => 'Root hairs 100x roots';

  @override
  String get photosynthesisEnergy => '1-2% of photosynthesis';

  @override
  String get heavyRainSaturated => 'Heavy rain, saturated soil';

  @override
  String get macroporeRoute => 'Macropores, cracks';

  @override
  String get fastVelocity => 'Fast (m/h possible)';

  @override
  String get unitMgKg => 'mg/kg';

  @override
  String get unitMolM3 => 'mol/m³';

  @override
  String get unitFraction => 'frac';

  @override
  String get xrayAi => 'X-Ray AI';

  @override
  String get stemDesc => 'The stem transports water and nutrients from roots to leaves (xylem) and sugars from leaves to roots (phloem).';

  @override
  String get rootTissueDesc => 'The root cross-section shows how water and nutrients are filtered through the Casparian strip into the vascular tissue.';

  @override
  String get vascularTissue => 'Vascular tissue';

  @override
  String get transport => 'Transport';

  @override
  String get rhizosphereLocation => 'Around the roots';

  @override
  String get microbialCellDesc => 'A single microbial cell decomposes organic matter using enzymes.';

  @override
  String get metabolismLabel => 'Metabolism';

  @override
  String get fluxLabel => 'Flux';

  @override
  String get veryHigh => 'Very High';

  @override
  String get lawLabel => 'Law';

  @override
  String get passive => 'Passive';

  @override
  String get saturatedZone => 'SATURATED ZONE';

  @override
  String get saturatedZoneDesc => 'A zone where all pore space is filled with water. Lack of oxygen (anoxia) triggers denitrification and restricts root function.';

  @override
  String get surfaceLabel => 'SURFACE (Z=0)';

  @override
  String get co2Flux => 'CO₂ FLUX';

  @override
  String get transpirationLabel => 'H₂O TRANSPIRATION';

  @override
  String get plantTitle => 'Plant';

  @override
  String get physiologyTitle => 'Physiology';

  @override
  String get saturationLabel => 'Saturation Degree';

  @override
  String get wiltingPointLabel => 'Wilting Point';

  @override
  String sensorTitle(Object id) {
    return 'SENSOR: $id';
  }

  @override
  String get sensorDesc => 'Real-time measurement from the soil profile.';

  @override
  String get bindingIonsLabel => 'Binding Ions';

  @override
  String get activeUptake => 'Active (ATP)';

  @override
  String get passiveUptake => 'Passive (Mass flow)';

  @override
  String horizonLabel(Object id) {
    return '$id-Horizon';
  }

  @override
  String get phDependence => 'pH Dependence';

  @override
  String get transpirationSuction => 'Transpiration suction';

  @override
  String get negativePotential => 'Negative water potential (Ψ)';

  @override
  String get optimalPh => 'Optimal pH 6-7';

  @override
  String get stomataRegulation => 'Stomata regulation, turgor';

  @override
  String get soluble => 'Soluble';

  @override
  String get blossomEndRot => 'Blossom end rot';

  @override
  String get chlorophyllAtp => 'Chlorophyll, ATP, enzymes';

  @override
  String get volumetric => 'Volumetric';

  @override
  String get acidicLiming => 'Acidic - liming recommended';

  @override
  String get slightlyAcidic => 'Slightly acidic';

  @override
  String get optimal => 'Optimal';

  @override
  String get aluminumToxicity => 'Al toxicity';

  @override
  String get highRisk => 'High risk';

  @override
  String get lowRisk => 'Low';

  @override
  String get reduced => 'Reduced';

  @override
  String get saturatedFreeWater => 'Saturated (free water)';

  @override
  String get fieldCapacityEasy => 'Field capacity (easy uptake)';

  @override
  String get stressZone => 'Stress zone';

  @override
  String get wiltingPointWarning => 'Wilting point ⚠️';

  @override
  String get hypoxicStress => 'Hypoxic (stress starts)';

  @override
  String get anoxic => 'Anoxic ⚠️';

  @override
  String get disturbed => 'Disturbed';

  @override
  String get blocked => 'Blocked';

  @override
  String get oxidizing => 'Oxidizing';

  @override
  String get reducing => 'Reducing';

  @override
  String get sufficient => 'Sufficient';

  @override
  String get deficiency => 'Deficiency';

  @override
  String get molecularDiffusion => 'Molecular diffusion';

  @override
  String get concentrationDifference => 'Concentration difference';

  @override
  String get organicNReactant => 'Organic N (proteins)';

  @override
  String get optimalConditions => '60% of field capacity';

  @override
  String get none => 'None';

  @override
  String get hexMatrix => 'Hex-Matrix';

  @override
  String get aggregatesLabel => 'Aggregates';

  @override
  String get ecosystemEngineer => 'Ecosystem Engineer';

  @override
  String get infiltration => 'Infiltration';

  @override
  String get aeration => 'Aeration';

  @override
  String get earthworm => 'Earthworm';

  @override
  String get redoxLadderDesc => 'The Redox Ladder shows the sequence of electron acceptors used by microbes as oxygen is depleted. Higher potential (Eh) means more energy for life.';

  @override
  String get potential => 'Potential';

  @override
  String get activeTea => 'Active TEA';

  @override
  String get moleculeAmmoniumTitle => 'AMMONIUM (NH₄⁺)';

  @override
  String get moleculeAmmoniumDesc => 'Positively charged nitrogen ion that sticks to soil colloids electrostatically (CEC). It doesn\'t leach easily and is an important nitrogen source for plants.';

  @override
  String get moleculeNitrateTitle => 'NITRATE (NO₃⁻)';

  @override
  String get moleculeNitrateDesc => 'Negatively charged, highly mobile nitrogen ion. Nitrate moves with water and can leach into groundwater or be lost to the atmosphere through denitrification.';

  @override
  String get moleculeCarbonLabileTitle => 'LABILE CARBON (C)';

  @override
  String get moleculeCarbonLabileDesc => 'Easily decomposable organic carbon (POM) that serves as fuel for soil microbes. Promotes microbial activity and nitrogen cycling.';

  @override
  String get moleculeCarbonStableTitle => 'STABLE CARBON (SOC)';

  @override
  String get moleculeCarbonStableDesc => 'Carbon bound in more permanent forms (MAOM), part of soil humus. Important for soil structure and long-term carbon sequestration.';

  @override
  String get moleculeWaterTitle => 'WATER (H₂O)';

  @override
  String get moleculeWaterDesc => 'A prerequisite for life in soil. Water transports nutrients and acts as a solvent in biochemical reactions.';

  @override
  String get moleculeOxygenTitle => 'OXYGEN (O₂)';

  @override
  String get moleculeOxygenDesc => 'Essential for aerobic respiration. Roots and most microbes need oxygen to produce energy.';

  @override
  String get moleculeCO2Title => 'CARBON DIOXIDE (CO₂)';

  @override
  String get moleculeCO2Desc => 'End product of microbial and root respiration. High CO2 levels in soil indicate active biological activity.';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get soilTempDesc => 'Average kinetic energy of soil particles. Affects all biological rates.';

  @override
  String get valLabel => 'Value';

  @override
  String get heatCapLabel => 'Heat Capacity';

  @override
  String get waterContentLabel => 'Water Content';

  @override
  String get soilWaterDesc => 'Volumetric water content. Essential for transport and cell turgor.';

  @override
  String get volumetricVWC => 'Volumetric (VWC)';

  @override
  String get porosityTitle => 'Porosity';

  @override
  String get carbonLabileLabel => 'Labile (POM)';

  @override
  String get carbonStableLabel => 'Stable (MAOM)';

  @override
  String get cnRatio => 'C/N Ratio';

  @override
  String get cRatioLabel => 'C-RATIO';

  @override
  String get carbonTitle => 'CARBON (C)';

  @override
  String get carbonPoolsDesc => 'POM vs MAOM dynamics and C/N balance.';

  @override
  String get charge => 'Charge';

  @override
  String get symbolLabel => 'Symbol';

  @override
  String get oxygenTitle => 'Oxygen';

  @override
  String get wettingFrontTitle => 'Wetting Front';

  @override
  String get wettingFrontDesc => 'A front describing the downward movement of water during rain or irrigation. Critical for vertical nutrient transport via mass flow.';

  @override
  String get capillaryRiseTitle => 'Capillary Rise';

  @override
  String get capillaryRiseDesc => 'Water rising against gravity into dry upper soil. Helps plants survive drought by pulling water from deep storage into the rhizosphere.';

  @override
  String get evaporationTitle => 'Evaporation';

  @override
  String get evaporationDesc => 'Loss of water from soil surface to atmosphere as vapor. Rate depends on moisture, radiation, and wind (Penman-Monteith).';

  @override
  String get enzymesTitle => 'Enzyme Activity';

  @override
  String get enzymesDesc => 'Microbes and roots secrete enzymes (like urease and phosphatase) to break down complex compounds into plant-available forms.';

  @override
  String get effectLabel => 'Effect';

  @override
  String get modelLabel => 'Model';

  @override
  String get kineticsLabel => 'Kinetics';

  @override
  String get responseLabel => 'Response';

  @override
  String get weatherControl => 'WEATHER CONTROL';

  @override
  String get lightControl => 'LIGHT CONTROL';

  @override
  String get methaneDescription => 'Methane is produced in highly anaerobic conditions when archaea reduce CO2 or acetate. This happens only after other electron acceptors (O2, NO3, Fe, SO4) are depleted.';

  @override
  String get infiltrationTitle => 'Infiltration';

  @override
  String get driverLabel => 'Driver';

  @override
  String get gravitationalPotential => 'Gravitational Potential';

  @override
  String get moistureLoss => 'Moisture Loss';

  @override
  String get energyLabel => 'Energy';

  @override
  String get latentHeat => 'Latent Heat';

  @override
  String get spacDescription => 'The Soil-Plant-Atmosphere Continuum (SPAC) describes the continuous water flow from soil through roots and xylem to leaves, where it evaporates into the air.';

  @override
  String get layerControls => 'Layer Controls';

  @override
  String nutrientsForLayer(Object id) {
    return 'Nutrients for $id';
  }

  @override
  String get nitrateN => 'Nitrate (N)';

  @override
  String get phosphateP => 'Phosphate (P)';

  @override
  String get potassiumK => 'Potassium (K)';

  @override
  String get calciumCa => 'Calcium (Ca)';

  @override
  String get magnesiumMg => 'Magnesium (Mg)';

  @override
  String get labileC => 'Labile Carbon (POM)';

  @override
  String get stableC => 'Stable Carbon (MAOM)';

  @override
  String get soilTexture => 'Soil Texture';

  @override
  String get atmosphereControls => 'Atmosphere Controls';

  @override
  String get precipitation => 'Precipitation';

  @override
  String get atmosphericCO2 => 'Atmospheric CO₂';

  @override
  String get nitrogenN => 'Nitrogen (N)';

  @override
  String get carbonC => 'Carbon (C)';

  @override
  String get methaneCH4 => 'Methane (CH₄)';

  @override
  String get oxygenO2 => 'Oxygen (O₂)';

  @override
  String get sensors => 'Sensors';

  @override
  String get par => 'PAR';

  @override
  String get exudation => 'EXUDATION';

  @override
  String get ionExchangePriming => 'ION EXCHANGE & PRIMING';

  @override
  String get stability => 'Stability';

  @override
  String get pedsAndGranules => 'Peds & Granules';

  @override
  String get dynamicLabel => 'Dynamic';

  @override
  String get logicLabTitle => 'Logic Lab — Biophysics Visualizer';

  @override
  String get buildScenarioTitle => 'Build Scenario';

  @override
  String get parametersTab => 'Parameters';

  @override
  String get actionsTab => 'Actions';

  @override
  String get tutorialTab => 'Tutorial';

  @override
  String get scenarioNameLabel => 'Scenario Name';

  @override
  String get descriptionLabel => 'Description';

  @override
  String simulationLengthDays(int value) {
    return 'Simulation Length: $value days';
  }

  @override
  String get soilType => 'Soil Type';

  @override
  String initialMoisture(String value) {
    return 'Initial Moisture (VWC): $value%';
  }

  @override
  String initialNitrate(String value) {
    return 'Nitrate Content (NO3): $value mg/kg';
  }

  @override
  String get addAction => 'Add to Plan';

  @override
  String get addTutorialStepAction => 'Add Tutorial Step';

  @override
  String get cultivationPlan => 'Cultivation Plan:';

  @override
  String get tutorialBuilt => 'Built Tutorial:';

  @override
  String calculateDays(int value) {
    return 'CALCULATE ($value d)';
  }

  @override
  String get startLive => 'START LIVE';

  @override
  String get selectExample => 'Select Example';

  @override
  String get resetGraph => 'Reset Graph';

  @override
  String get logicLabMixinLabel => 'Tutorial Builder (Logic Lab Mixin)';

  @override
  String get admin => 'Admin';

  @override
  String get closeAction => 'Close';

  @override
  String get inputs => 'Inputs';

  @override
  String get functions => 'Functions';

  @override
  String get soilColumnAnalysis => 'Soil Column Analysis';

  @override
  String layerLabelWithDepth(String id, String depth1, String depth2) {
    return 'Layer $id ($depth1 - $depth2 cm)';
  }

  @override
  String get atomicNumber => 'Atomic Number';

  @override
  String get biologicalRole => 'Biological Role';

  @override
  String get cpkColor => 'CPK Color';

  @override
  String get classification => 'Classification';

  @override
  String get meteorology => 'Meteorology';

  @override
  String get airAndWaterVapor => 'Air and Water Vapor';

  @override
  String get dryBulbTemp => 'Dry Bulb Temp (°C)';

  @override
  String get humidityRatio => 'Humidity Ratio (kg/kg)';

  @override
  String get teachingKey => 'TEACHING KEY';

  @override
  String get xylemTissue => 'Xylem Tissue (Water UP)';

  @override
  String get phloemTissue => 'Phloem Tissue (Sugar DOWN)';

  @override
  String get waterMineralsFlow => 'Water & Minerals Flow';

  @override
  String get energyCarbonFlow => 'Energy & Carbon Flow';

  @override
  String get nNitrateNode => 'N (Nitrate) Node';

  @override
  String get pPhosphateNode => 'P (Phosphate) Node';

  @override
  String get cecSiteLabel => 'CEC (Cation Exchange Site)';

  @override
  String get mmKinetics => 'Michaelis-Menten Kinetics';

  @override
  String get vgWaterRetention => 'van Genuchten Water Retention';

  @override
  String get farquharPhotosynthesis => 'Farquhar-von Caemmerer-Berry C3 Photosynthesis';

  @override
  String get nernstRedox => 'Nernst Equation (Redox)';

  @override
  String get soilTempCelsius => 'Soil Temperature (°C)';

  @override
  String get soilWaterContentPressureHead => 'Soil Water Content / Pressure Head';

  @override
  String get soilWaterSaturation => 'Soil Water Saturation';

  @override
  String get ammoniumContentLabel => 'Ammonium (NH4+) Content';

  @override
  String get nitrateContentLabel => 'Nitrate (NO3-) Content';

  @override
  String get oxygenContentLabel => 'Oxygen (O2) Content';

  @override
  String get co2ContentLabel => 'Carbon Dioxide (CO2)';

  @override
  String get addEvent => 'Add Action';

  @override
  String dayTimeLabel(String value) {
    return 'Time (Day): $value';
  }

  @override
  String get eventTypeLabel => 'Type';

  @override
  String get actionFertilize => 'Fertilization';

  @override
  String get actionTill => 'Tillage';

  @override
  String get actionWater => 'Irrigation';

  @override
  String amountLabel(String value) {
    return 'Amount: $value';
  }

  @override
  String get fullField => 'Full Area';

  @override
  String get tutBuilderTitle => 'Tutorial Builder (Logic Lab Mixin)';

  @override
  String get tutTargetLabel => 'Target (Highlight)';

  @override
  String get tutTargetLeaf => 'Leaves (Transpiration)';

  @override
  String get tutTargetRoot => 'Roots (Uptake)';

  @override
  String get tutTargetRhizosphere => 'Rhizosphere (Microbes)';

  @override
  String get tutTargetSoil => 'Soil Structure';

  @override
  String get tutTitleLabel => 'Tutorial Title';

  @override
  String get tutDescLabel => 'Teaching Text';

  @override
  String get convectiveFlow => 'Convective Flow';

  @override
  String get negativeSuction => 'Negative Suction';

  @override
  String get activeInfiltration => 'Active Infiltration';

  @override
  String get cecDescription => 'Cation Exchange Capacity: The soil\'s ability to hold and exchange nutrients (K+, NH4+, etc).';

  @override
  String get claySite => 'Clay Site';

  @override
  String get organicSite => 'Organic Site';

  @override
  String get hydraulicLift => 'Hydraulic Lift';

  @override
  String get matricPotential => 'Matric Potential';

  @override
  String get rubiscoLimited => 'Rubisco Limited';

  @override
  String get organicPool => 'Organic Pool';

  @override
  String get stablePool => 'Stable Pool';

  @override
  String get fractalFingering => 'Fractal Fingering';

  @override
  String get nutrientAvailability => 'Nutrient Availability';

  @override
  String get greenhouseGas => 'Greenhouse Gas';

  @override
  String get highDivision => 'High Division';

  @override
  String get capacityLabel => 'Capacity';

  @override
  String get processLabel => 'Process';

  @override
  String get sourceLabel => 'Source';

  @override
  String get groundwaterLabel => 'Groundwater';

  @override
  String get efficiencyLabel => 'Efficiency';

  @override
  String get c3Pathway => 'C3 Pathway';

  @override
  String get sugarCompound => 'Sugar (C6H12O6)';

  @override
  String get organicPoolLabel => 'Organic Pool';

  @override
  String get stablePoolLabel => 'Stable Pool';

  @override
  String get microbePoolLabel => 'Microbe Pool';

  @override
  String get cationLabel => 'Cation';

  @override
  String get anionLabel => 'Anion';

  @override
  String get macronutrientLabel => 'Macronutrient';

  @override
  String get regulationLabel => 'Regulation';

  @override
  String get pomNitrogenTitle => 'POM NITROGEN (Particulate Organic N)';

  @override
  String get pomNitrogenDesc => 'Labile organic nitrogen (POM-N). Available to plants through microbial decomposition.';

  @override
  String get micNitrogenTitle => 'MICROBIAL NITROGEN (Microbial Biomass N)';

  @override
  String get micNitrogenDesc => 'Nitrogen within living microbial biomass. Released upon cell death or grazing.';

  @override
  String get maomNitrogenTitle => 'MAOM NITROGEN (Mineral-Associated N)';

  @override
  String get maomNitrogenDesc => 'Long-lived nitrogen bound to clay and silt particles. The largest and most stable nitrogen pool in soil.';

  @override
  String get ammoniumTitle => 'AMMONIUM (NH₄⁺)';

  @override
  String get ammoniumDesc => 'Poorly mobile nitrogen form in soil. Binds to clay particles.';

  @override
  String get nitrateTitle => 'NITRATE (NO₃⁻)';

  @override
  String get nitrateDesc => 'Highly mobile nitrogen form. Dissolves in water and leaches easily.';

  @override
  String get nitrogenTitleLong => 'NITROGEN (N)';

  @override
  String get nitrogenDescLong => 'The most important growth nutrient. Building block for proteins, chlorophyll, and nucleic acids.';

  @override
  String get phosphorusTitleLong => 'PHOSPHORUS (P)';

  @override
  String get phosphorusDescLong => 'Component of ATP and DNA. Very poorly mobile.';

  @override
  String get potassiumTitleLong => 'POTASSIUM (K)';

  @override
  String get potassiumDescLong => 'Regulates stomatal opening and water balance.';

  @override
  String nutrientTitlePrefix(String symbol) {
    return 'NUTRIENT: $symbol';
  }

  @override
  String get biochemistryDesc => 'Important factor in soil biochemistry.';

  @override
  String get potassiumLabel => 'Potassium';

  @override
  String get dynamicsLabel => 'Dynamics';

  @override
  String get optimalLabel => 'Optimal';

  @override
  String get significanceLabel => 'Significance';

  @override
  String get co2UptakeTitle => 'CO₂ UPTAKE';

  @override
  String get o2DiffusionTitle => 'O₂ DIFFUSION';

  @override
  String get n2oEmissionTitle => 'N₂O EMISSION';

  @override
  String get nitrogenLossDenit => 'Nitrogen loss via denitrification';

  @override
  String get riskLabel => 'Risk';

  @override
  String get apicalMeristem => 'APICAL MERISTEM';

  @override
  String get meristemDesc => 'Primary growth zone driven by continuous cell division.';

  @override
  String get tissueLabel => 'Tissue';

  @override
  String get meristematic => 'Meristematic';

  @override
  String get undifferentiated => 'Undifferentiated';

  @override
  String get rateLabel => 'Rate';

  @override
  String get turgorLabel => 'Turgor';

  @override
  String get roleLabel => 'Role';

  @override
  String get locationLabel => 'Location';

  @override
  String get microbialBiomassLabel => 'Microbial Biomass';

  @override
  String get bioActivityLabel => 'Bio-Activity';

  @override
  String get typeLabel => 'Type';

  @override
  String get clayFractionLabel => 'Clay Fraction';

  @override
  String get nitrogenCycle => 'Nitrogen Cycle';

  @override
  String get flows => 'Flows';

  @override
  String get modify => 'Modify';

  @override
  String get off => 'Off';

  @override
  String get turnOffMicroscope => 'Turn off microscope';

  @override
  String get stem => 'Stem';

  @override
  String get hydrogen => 'Hydrogen';

  @override
  String get sulfur => 'Sulfur';
}
