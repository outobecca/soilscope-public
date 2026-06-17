import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SoilScope'**
  String get appTitle;

  /// No description provided for @soilStructure.
  ///
  /// In en, this message translates to:
  /// **'Soil Structure'**
  String get soilStructure;

  /// No description provided for @bioActivity.
  ///
  /// In en, this message translates to:
  /// **'Bio-Activity'**
  String get bioActivity;

  /// No description provided for @leachingRisk.
  ///
  /// In en, this message translates to:
  /// **'Leaching Risk'**
  String get leachingRisk;

  /// No description provided for @plantTurgor.
  ///
  /// In en, this message translates to:
  /// **'Plant Turgor: {percentage}%'**
  String plantTurgor(String percentage);

  /// No description provided for @timeElapsed.
  ///
  /// In en, this message translates to:
  /// **'Time: {hours}h'**
  String timeElapsed(String hours);

  /// No description provided for @tillage.
  ///
  /// In en, this message translates to:
  /// **'Tillage'**
  String get tillage;

  /// No description provided for @irrigate.
  ///
  /// In en, this message translates to:
  /// **'Irrigate'**
  String get irrigate;

  /// No description provided for @fertilize.
  ///
  /// In en, this message translates to:
  /// **'Fertilize'**
  String get fertilize;

  /// No description provided for @analysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Layer {id} Analysis'**
  String analysisTitle(String id);

  /// No description provided for @depth.
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get depth;

  /// No description provided for @waterContent.
  ///
  /// In en, this message translates to:
  /// **'Water Content'**
  String get waterContent;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @ph.
  ///
  /// In en, this message translates to:
  /// **'pH'**
  String get ph;

  /// No description provided for @ec.
  ///
  /// In en, this message translates to:
  /// **'EC (Salinity)'**
  String get ec;

  /// No description provided for @redoxPotential.
  ///
  /// In en, this message translates to:
  /// **'Redox (Eh)'**
  String get redoxPotential;

  /// No description provided for @nitrate.
  ///
  /// In en, this message translates to:
  /// **'Nitrate'**
  String get nitrate;

  /// No description provided for @phosphate.
  ///
  /// In en, this message translates to:
  /// **'Phosphate'**
  String get phosphate;

  /// No description provided for @microbialBiomass.
  ///
  /// In en, this message translates to:
  /// **'Microbial Biomass'**
  String get microbialBiomass;

  /// No description provided for @oxygen.
  ///
  /// In en, this message translates to:
  /// **'Oxygen (O2)'**
  String get oxygen;

  /// No description provided for @co2.
  ///
  /// In en, this message translates to:
  /// **'Carbon Dioxide (CO2)'**
  String get co2;

  /// No description provided for @soilRespiration.
  ///
  /// In en, this message translates to:
  /// **'Soil Respiration'**
  String get soilRespiration;

  /// No description provided for @soilEvaporation.
  ///
  /// In en, this message translates to:
  /// **'Soil Evaporation'**
  String get soilEvaporation;

  /// No description provided for @redoxPotentialTitle.
  ///
  /// In en, this message translates to:
  /// **'Redox Potential (Eh)'**
  String get redoxPotentialTitle;

  /// No description provided for @phLabel.
  ///
  /// In en, this message translates to:
  /// **'Acidity / pH'**
  String get phLabel;

  /// No description provided for @phDescription.
  ///
  /// In en, this message translates to:
  /// **'A measure of the acidity or alkalinity of the soil solution.'**
  String get phDescription;

  /// No description provided for @biophysicsInsights.
  ///
  /// In en, this message translates to:
  /// **'Biophysics Insights:'**
  String get biophysicsInsights;

  /// No description provided for @anaerobicWarning.
  ///
  /// In en, this message translates to:
  /// **'Anaerobic conditions detected. Risk of denitrification.'**
  String get anaerobicWarning;

  /// No description provided for @aerobicStatus.
  ///
  /// In en, this message translates to:
  /// **'Aerobic conditions. Healthy microbial activity.'**
  String get aerobicStatus;

  /// No description provided for @tillageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tillage applied! Soil structure loosened.'**
  String get tillageSuccess;

  /// No description provided for @tillageFailure.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL: Tilling wet soil caused structural collapse!'**
  String get tillageFailure;

  /// No description provided for @irrigatingField.
  ///
  /// In en, this message translates to:
  /// **'Irrigating field...'**
  String get irrigatingField;

  /// No description provided for @fertilizerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen & Phosphorus applied to surface.'**
  String get fertilizerSuccess;

  /// No description provided for @selectScenario.
  ///
  /// In en, this message translates to:
  /// **'Select Scenario'**
  String get selectScenario;

  /// No description provided for @startSimulation.
  ///
  /// In en, this message translates to:
  /// **'Start Simulation'**
  String get startSimulation;

  /// No description provided for @compactedClayTitle.
  ///
  /// In en, this message translates to:
  /// **'Compacted Clay Challenge'**
  String get compactedClayTitle;

  /// No description provided for @compactedClayDesc.
  ///
  /// In en, this message translates to:
  /// **'Improve soil structure through tillage and biology.'**
  String get compactedClayDesc;

  /// No description provided for @nitrateLeachingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen Leaching Crisis'**
  String get nitrateLeachingTitle;

  /// No description provided for @nitrateLeachingDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage nutrients during excessive rainfall.'**
  String get nitrateLeachingDesc;

  /// No description provided for @nitrogenLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen Lock Challenge'**
  String get nitrogenLockTitle;

  /// No description provided for @nitrogenLockDesc.
  ///
  /// In en, this message translates to:
  /// **'You added too much straw (high C/N). Save the crop!'**
  String get nitrogenLockDesc;

  /// No description provided for @simulationSettings.
  ///
  /// In en, this message translates to:
  /// **'Simulation Settings'**
  String get simulationSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @finnish.
  ///
  /// In en, this message translates to:
  /// **'Finnish'**
  String get finnish;

  /// No description provided for @nanovisionHint.
  ///
  /// In en, this message translates to:
  /// **'Tap soil layers to activate Nanovision analysis'**
  String get nanovisionHint;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @logicLab.
  ///
  /// In en, this message translates to:
  /// **'Logic Lab'**
  String get logicLab;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @showFormulas.
  ///
  /// In en, this message translates to:
  /// **'Show Formulas'**
  String get showFormulas;

  /// No description provided for @saveScenario.
  ///
  /// In en, this message translates to:
  /// **'Save Scenario'**
  String get saveScenario;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'JSON copied to clipboard!'**
  String get copyToClipboard;

  /// No description provided for @scenarioTitle.
  ///
  /// In en, this message translates to:
  /// **'My Custom Scenario'**
  String get scenarioTitle;

  /// No description provided for @importScenario.
  ///
  /// In en, this message translates to:
  /// **'Import from Clipboard'**
  String get importScenario;

  /// No description provided for @importFromClipboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Load a scenario JSON from your clipboard.'**
  String get importFromClipboardDesc;

  /// No description provided for @clipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty. Copy scenario JSON first.'**
  String get clipboardEmpty;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Scenario imported successfully!'**
  String get importSuccess;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON format.'**
  String get importError;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @scenarioLibrary.
  ///
  /// In en, this message translates to:
  /// **'Scenario library'**
  String get scenarioLibrary;

  /// No description provided for @noScenariosAvailable.
  ///
  /// In en, this message translates to:
  /// **'No scenarios available right now.'**
  String get noScenariosAvailable;

  /// No description provided for @resumeLastSession.
  ///
  /// In en, this message translates to:
  /// **'Resume Last Session'**
  String get resumeLastSession;

  /// No description provided for @resumeLastSessionDesc.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off with your previous soil and plant state.'**
  String get resumeLastSessionDesc;

  /// No description provided for @noSavedSession.
  ///
  /// In en, this message translates to:
  /// **'No saved session found yet.'**
  String get noSavedSession;

  /// No description provided for @resumeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore the saved session.'**
  String get resumeFailed;

  /// No description provided for @openScenario.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openScenario;

  /// No description provided for @teacherMode.
  ///
  /// In en, this message translates to:
  /// **'Teacher Mode'**
  String get teacherMode;

  /// No description provided for @heatWave.
  ///
  /// In en, this message translates to:
  /// **'Heat Wave'**
  String get heatWave;

  /// No description provided for @flashFlood.
  ///
  /// In en, this message translates to:
  /// **'Flash Flood'**
  String get flashFlood;

  /// No description provided for @frost.
  ///
  /// In en, this message translates to:
  /// **'Frost'**
  String get frost;

  /// No description provided for @pestOutbreak.
  ///
  /// In en, this message translates to:
  /// **'Pest Outbreak'**
  String get pestOutbreak;

  /// No description provided for @soilCompaction.
  ///
  /// In en, this message translates to:
  /// **'Heavy Machinery Compaction'**
  String get soilCompaction;

  /// No description provided for @surfaceErosion.
  ///
  /// In en, this message translates to:
  /// **'Intense Erosion'**
  String get surfaceErosion;

  /// No description provided for @aiAdvisor.
  ///
  /// In en, this message translates to:
  /// **'AI Advisor'**
  String get aiAdvisor;

  /// No description provided for @topRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Strategic Advice'**
  String get topRecommendation;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {value}%'**
  String confidence(String value);

  /// No description provided for @rationale.
  ///
  /// In en, this message translates to:
  /// **'Rationale'**
  String get rationale;

  /// No description provided for @coverCrop.
  ///
  /// In en, this message translates to:
  /// **'Cover Crop'**
  String get coverCrop;

  /// No description provided for @coverCropAlreadyActive.
  ///
  /// In en, this message translates to:
  /// **'Cover crop is already active.'**
  String get coverCropAlreadyActive;

  /// No description provided for @coverCropApplied.
  ///
  /// In en, this message translates to:
  /// **'Cover crop planted. Surface protection improved.'**
  String get coverCropApplied;

  /// No description provided for @irrigationStopped.
  ///
  /// In en, this message translates to:
  /// **'Irrigation stopped.'**
  String get irrigationStopped;

  /// No description provided for @autoWeather.
  ///
  /// In en, this message translates to:
  /// **'Auto Weather'**
  String get autoWeather;

  /// No description provided for @dynamicWeatherOn.
  ///
  /// In en, this message translates to:
  /// **'Dynamic weather enabled.'**
  String get dynamicWeatherOn;

  /// No description provided for @dynamicWeatherOff.
  ///
  /// In en, this message translates to:
  /// **'Dynamic weather disabled.'**
  String get dynamicWeatherOff;

  /// No description provided for @drain.
  ///
  /// In en, this message translates to:
  /// **'Drain'**
  String get drain;

  /// No description provided for @drainageOpened.
  ///
  /// In en, this message translates to:
  /// **'Drainage channels opened. Surface is drying.'**
  String get drainageOpened;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @researchDashboard.
  ///
  /// In en, this message translates to:
  /// **'Research Dashboard'**
  String get researchDashboard;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @controls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get controls;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @microscope.
  ///
  /// In en, this message translates to:
  /// **'Microscope'**
  String get microscope;

  /// No description provided for @controlPanel.
  ///
  /// In en, this message translates to:
  /// **'Control Panel'**
  String get controlPanel;

  /// No description provided for @returnToMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Return to menu?'**
  String get returnToMenuTitle;

  /// No description provided for @returnToMenuMessage.
  ///
  /// In en, this message translates to:
  /// **'Simulation will be paused and your current state saved.'**
  String get returnToMenuMessage;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @returnToMenuAction.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnToMenuAction;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed: {value}x'**
  String speed(String value);

  /// No description provided for @atmosphere.
  ///
  /// In en, this message translates to:
  /// **'Atmosphere'**
  String get atmosphere;

  /// No description provided for @systemHealth.
  ///
  /// In en, this message translates to:
  /// **'System Health'**
  String get systemHealth;

  /// No description provided for @productivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// No description provided for @carbonSink.
  ///
  /// In en, this message translates to:
  /// **'Carbon Sink'**
  String get carbonSink;

  /// No description provided for @biodiversity.
  ///
  /// In en, this message translates to:
  /// **'Bio-Diversity'**
  String get biodiversity;

  /// No description provided for @impact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impact;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get reward;

  /// No description provided for @index.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get index;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @hideSidebar.
  ///
  /// In en, this message translates to:
  /// **'Hide Sidebar'**
  String get hideSidebar;

  /// No description provided for @showSidebar.
  ///
  /// In en, this message translates to:
  /// **'Show Sidebar'**
  String get showSidebar;

  /// No description provided for @scienceReference.
  ///
  /// In en, this message translates to:
  /// **'Science Reference'**
  String get scienceReference;

  /// No description provided for @fullScienceReference.
  ///
  /// In en, this message translates to:
  /// **'Full Science Reference'**
  String get fullScienceReference;

  /// No description provided for @selectLayerToView.
  ///
  /// In en, this message translates to:
  /// **'Select a soil layer to view analysis'**
  String get selectLayerToView;

  /// No description provided for @sand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get sand;

  /// No description provided for @silt.
  ///
  /// In en, this message translates to:
  /// **'Silt'**
  String get silt;

  /// No description provided for @clay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get clay;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @root.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get root;

  /// No description provided for @leaf.
  ///
  /// In en, this message translates to:
  /// **'Leaf'**
  String get leaf;

  /// No description provided for @vaporPressureDeficit.
  ///
  /// In en, this message translates to:
  /// **'Vapor Pressure Deficit'**
  String get vaporPressureDeficit;

  /// No description provided for @relativeHumidity.
  ///
  /// In en, this message translates to:
  /// **'Relative Humidity'**
  String get relativeHumidity;

  /// No description provided for @selectElementRole.
  ///
  /// In en, this message translates to:
  /// **'Select an element to see its role in the ecosystem'**
  String get selectElementRole;

  /// No description provided for @concentration.
  ///
  /// In en, this message translates to:
  /// **'Concentration ({id})'**
  String concentration(String id);

  /// No description provided for @semanticZoomLevels.
  ///
  /// In en, this message translates to:
  /// **'Semantic Zoom Levels'**
  String get semanticZoomLevels;

  /// No description provided for @macroZoomTitle.
  ///
  /// In en, this message translates to:
  /// **'1.0x - 2.0x (Macro)'**
  String get macroZoomTitle;

  /// No description provided for @macroZoomDesc.
  ///
  /// In en, this message translates to:
  /// **'General landscape view. Highlights soil moisture levels and layer boundaries.'**
  String get macroZoomDesc;

  /// No description provided for @mesoZoomTitle.
  ///
  /// In en, this message translates to:
  /// **'2.0x - 4.0x (Meso)'**
  String get mesoZoomTitle;

  /// No description provided for @mesoZoomDesc.
  ///
  /// In en, this message translates to:
  /// **'Reveals structural details like cracks, fungal networks, and water infiltration/rise.'**
  String get mesoZoomDesc;

  /// No description provided for @microZoomTitle.
  ///
  /// In en, this message translates to:
  /// **'4.0x - 5.5x (Micro)'**
  String get microZoomTitle;

  /// No description provided for @microZoomDesc.
  ///
  /// In en, this message translates to:
  /// **'Visible microbes, root hairs, and gas bubbles (CO₂/N₂O). Shows thermal heat flow.'**
  String get microZoomDesc;

  /// No description provided for @nanoZoomTitle.
  ///
  /// In en, this message translates to:
  /// **'5.5x+ (Nano)'**
  String get nanoZoomTitle;

  /// No description provided for @nanoZoomDesc.
  ///
  /// In en, this message translates to:
  /// **'Deep-dive into ions (N, P, K), matrix pore gaps, and real-time metabolic math.'**
  String get nanoZoomDesc;

  /// No description provided for @soilStructureTexture.
  ///
  /// In en, this message translates to:
  /// **'Soil Structure & Texture'**
  String get soilStructureTexture;

  /// No description provided for @aggregates.
  ///
  /// In en, this message translates to:
  /// **'Aggregates'**
  String get aggregates;

  /// No description provided for @aggregatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Clusters of soil particles (peds). Only visible in high-stability soil.'**
  String get aggregatesDesc;

  /// No description provided for @sandGrains.
  ///
  /// In en, this message translates to:
  /// **'Sand Grains'**
  String get sandGrains;

  /// No description provided for @sandGrainsDesc.
  ///
  /// In en, this message translates to:
  /// **'Sharp, crystalline particles. Large gaps allow fast water movement.'**
  String get sandGrainsDesc;

  /// No description provided for @waterFlux.
  ///
  /// In en, this message translates to:
  /// **'Water Flux'**
  String get waterFlux;

  /// No description provided for @waterFluxDesc.
  ///
  /// In en, this message translates to:
  /// **'Upward arrows indicate capillary rise; downward indicate infiltration.'**
  String get waterFluxDesc;

  /// No description provided for @plantInteractions.
  ///
  /// In en, this message translates to:
  /// **'Plant Interactions'**
  String get plantInteractions;

  /// No description provided for @rhizosphere.
  ///
  /// In en, this message translates to:
  /// **'Rhizosphere'**
  String get rhizosphere;

  /// No description provided for @rhizosphereDesc.
  ///
  /// In en, this message translates to:
  /// **'Biological hotspot around roots where exudates drive hyper-active microbial life.'**
  String get rhizosphereDesc;

  /// No description provided for @rootExudates.
  ///
  /// In en, this message translates to:
  /// **'Root Exudates'**
  String get rootExudates;

  /// No description provided for @rootExudatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Carbon leaking from roots to feed microbes. Visualized as a green glow.'**
  String get rootExudatesDesc;

  /// No description provided for @transpiration.
  ///
  /// In en, this message translates to:
  /// **'Transpiration'**
  String get transpiration;

  /// No description provided for @transpirationDesc.
  ///
  /// In en, this message translates to:
  /// **'Rising blue particles in the stem showing active water transport from soil to sky.'**
  String get transpirationDesc;

  /// No description provided for @hiddenGasCycles.
  ///
  /// In en, this message translates to:
  /// **'Hidden Gas Cycles'**
  String get hiddenGasCycles;

  /// No description provided for @boundaryFlux.
  ///
  /// In en, this message translates to:
  /// **'Boundary Flux'**
  String get boundaryFlux;

  /// No description provided for @boundaryFluxDesc.
  ///
  /// In en, this message translates to:
  /// **'Water vapor and CO2 rising from the surface; Oxygen falling into the soil.'**
  String get boundaryFluxDesc;

  /// No description provided for @co2Bubbles.
  ///
  /// In en, this message translates to:
  /// **'CO₂ Bubbles'**
  String get co2Bubbles;

  /// No description provided for @co2BubblesDesc.
  ///
  /// In en, this message translates to:
  /// **'Byproduct of healthy respiration. Rises faster when microbes are warm.'**
  String get co2BubblesDesc;

  /// No description provided for @hiddenChemicalDynamics.
  ///
  /// In en, this message translates to:
  /// **'Hidden Chemical Dynamics'**
  String get hiddenChemicalDynamics;

  /// No description provided for @cecSnapping.
  ///
  /// In en, this message translates to:
  /// **'CEC Snapping'**
  String get cecSnapping;

  /// No description provided for @cecSnappingDesc.
  ///
  /// In en, this message translates to:
  /// **'Ions (N, P, K) being captured or released by clay particle exchange sites.'**
  String get cecSnappingDesc;

  /// No description provided for @cationExchange.
  ///
  /// In en, this message translates to:
  /// **'Cation Exchange'**
  String get cationExchange;

  /// No description provided for @cationExchangeDesc.
  ///
  /// In en, this message translates to:
  /// **'Competitive adsorption of K+, Ca²+, and Mg²+ on clay surfaces. High CEC allows for better nutrient retention.'**
  String get cationExchangeDesc;

  /// No description provided for @elementToxicity.
  ///
  /// In en, this message translates to:
  /// **'Element Toxicity'**
  String get elementToxicity;

  /// No description provided for @elementToxicityDesc.
  ///
  /// In en, this message translates to:
  /// **'High Aluminium (Al) at low pH (<5.5) or high Sodium (Na) inhibits root elongation and reduces growth.'**
  String get elementToxicityDesc;

  /// No description provided for @phEmergence.
  ///
  /// In en, this message translates to:
  /// **'pH Emergence'**
  String get phEmergence;

  /// No description provided for @phEmergenceDesc.
  ///
  /// In en, this message translates to:
  /// **'Dynamically calculated based on base saturation (Ca/Mg/K balance) and CO₂ acidification from respiration.'**
  String get phEmergenceDesc;

  /// No description provided for @atmosphereDesc.
  ///
  /// In en, this message translates to:
  /// **'Live weather forcing that drives evapotranspiration and infiltration.'**
  String get atmosphereDesc;

  /// No description provided for @plantCanopy.
  ///
  /// In en, this message translates to:
  /// **'Plant Canopy'**
  String get plantCanopy;

  /// No description provided for @plantCanopyDesc.
  ///
  /// In en, this message translates to:
  /// **'Crop vitality and root-foraging response under current soil conditions.'**
  String get plantCanopyDesc;

  /// No description provided for @layerAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Contextual layer diagnostics at pointer location (no manual panel opening needed).'**
  String get layerAnalysisDesc;

  /// No description provided for @vpd.
  ///
  /// In en, this message translates to:
  /// **'VPD'**
  String get vpd;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get rain;

  /// No description provided for @turgor.
  ///
  /// In en, this message translates to:
  /// **'Turgor'**
  String get turgor;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @lai.
  ///
  /// In en, this message translates to:
  /// **'LAI'**
  String get lai;

  /// No description provided for @rootNodes.
  ///
  /// In en, this message translates to:
  /// **'Root Nodes'**
  String get rootNodes;

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @porosity.
  ///
  /// In en, this message translates to:
  /// **'Porosity'**
  String get porosity;

  /// No description provided for @cracks.
  ///
  /// In en, this message translates to:
  /// **'Cracks'**
  String get cracks;

  /// No description provided for @microbes.
  ///
  /// In en, this message translates to:
  /// **'Microbes'**
  String get microbes;

  /// No description provided for @gasBubbles.
  ///
  /// In en, this message translates to:
  /// **'Gas Bubbles'**
  String get gasBubbles;

  /// No description provided for @ions.
  ///
  /// In en, this message translates to:
  /// **'Ions'**
  String get ions;

  /// No description provided for @cecSites.
  ///
  /// In en, this message translates to:
  /// **'CEC Sites'**
  String get cecSites;

  /// No description provided for @visualKey.
  ///
  /// In en, this message translates to:
  /// **'VISUAL KEY'**
  String get visualKey;

  /// No description provided for @systemAdvisor.
  ///
  /// In en, this message translates to:
  /// **'System Advisor'**
  String get systemAdvisor;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'{value}% Confidence'**
  String confidenceLabel(String value);

  /// No description provided for @fieldDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Field Diagnostics'**
  String get fieldDiagnostics;

  /// No description provided for @redoxEh.
  ///
  /// In en, this message translates to:
  /// **'Redox (Eh)'**
  String get redoxEh;

  /// No description provided for @oxygenLabel.
  ///
  /// In en, this message translates to:
  /// **'Oxygen'**
  String get oxygenLabel;

  /// No description provided for @phLevel.
  ///
  /// In en, this message translates to:
  /// **'pH Level'**
  String get phLevel;

  /// No description provided for @atmosphereLabel.
  ///
  /// In en, this message translates to:
  /// **'Atmosphere:'**
  String get atmosphereLabel;

  /// No description provided for @co2Label.
  ///
  /// In en, this message translates to:
  /// **'CO2'**
  String get co2Label;

  /// No description provided for @vpdLabel.
  ///
  /// In en, this message translates to:
  /// **'VPD (Vapor Pressure Deficit)'**
  String get vpdLabel;

  /// No description provided for @physical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physical;

  /// No description provided for @chemical.
  ///
  /// In en, this message translates to:
  /// **'Chemical'**
  String get chemical;

  /// No description provided for @biological.
  ///
  /// In en, this message translates to:
  /// **'Biological'**
  String get biological;

  /// No description provided for @ammonium.
  ///
  /// In en, this message translates to:
  /// **'Ammonium (NH₄)'**
  String get ammonium;

  /// No description provided for @organicN.
  ///
  /// In en, this message translates to:
  /// **'Organic N (POM)'**
  String get organicN;

  /// No description provided for @organicCarbon.
  ///
  /// In en, this message translates to:
  /// **'Organic Carbon'**
  String get organicCarbon;

  /// No description provided for @denitrification.
  ///
  /// In en, this message translates to:
  /// **'Denitrification'**
  String get denitrification;

  /// No description provided for @mechanical.
  ///
  /// In en, this message translates to:
  /// **'Mechanical'**
  String get mechanical;

  /// No description provided for @fungalHyphae.
  ///
  /// In en, this message translates to:
  /// **'Fungal Hyphae'**
  String get fungalHyphae;

  /// No description provided for @bioGlue.
  ///
  /// In en, this message translates to:
  /// **'Bio-Glue (EPS)'**
  String get bioGlue;

  /// No description provided for @structureHP.
  ///
  /// In en, this message translates to:
  /// **'Structure HP'**
  String get structureHP;

  /// No description provided for @fragile.
  ///
  /// In en, this message translates to:
  /// **'Fragile'**
  String get fragile;

  /// No description provided for @resilient.
  ///
  /// In en, this message translates to:
  /// **'Resilient'**
  String get resilient;

  /// No description provided for @stabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'{value}% Stability'**
  String stabilityLabel(String value);

  /// No description provided for @physicsOverride.
  ///
  /// In en, this message translates to:
  /// **'Physics Override'**
  String get physicsOverride;

  /// No description provided for @constituents.
  ///
  /// In en, this message translates to:
  /// **'Constituents'**
  String get constituents;

  /// No description provided for @microbialEngines.
  ///
  /// In en, this message translates to:
  /// **'Microbial Engines'**
  String get microbialEngines;

  /// No description provided for @liveCalculations.
  ///
  /// In en, this message translates to:
  /// **'Live Calculations'**
  String get liveCalculations;

  /// No description provided for @tempFactor.
  ///
  /// In en, this message translates to:
  /// **'Temp Factor (Q10)'**
  String get tempFactor;

  /// No description provided for @metabolicMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Metabolic multiplier'**
  String get metabolicMultiplier;

  /// No description provided for @waterLimitation.
  ///
  /// In en, this message translates to:
  /// **'Water Limitation'**
  String get waterLimitation;

  /// No description provided for @hydraulicConnectivity.
  ///
  /// In en, this message translates to:
  /// **'Hydraulic connectivity'**
  String get hydraulicConnectivity;

  /// No description provided for @o2Availability.
  ///
  /// In en, this message translates to:
  /// **'O2 Availability'**
  String get o2Availability;

  /// No description provided for @aerobicRespirationPotential.
  ///
  /// In en, this message translates to:
  /// **'Aerobic respiration potential'**
  String get aerobicRespirationPotential;

  /// No description provided for @bioChemicalRates.
  ///
  /// In en, this message translates to:
  /// **'Bio-Chemical Rates'**
  String get bioChemicalRates;

  /// No description provided for @co2ProductionRate.
  ///
  /// In en, this message translates to:
  /// **'CO₂ production rate'**
  String get co2ProductionRate;

  /// No description provided for @nNitrification.
  ///
  /// In en, this message translates to:
  /// **'N-Nitrification'**
  String get nNitrification;

  /// No description provided for @transformationDesc.
  ///
  /// In en, this message translates to:
  /// **'NH₄⁺ ➔ NO₃⁻ transformation'**
  String get transformationDesc;

  /// No description provided for @denitrificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduction of nitrate to gaseous nitrogen (N₂O, N₂) in low oxygen conditions.'**
  String get denitrificationDesc;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inhibited.
  ///
  /// In en, this message translates to:
  /// **'Inhibited'**
  String get inhibited;

  /// No description provided for @zoomNote.
  ///
  /// In en, this message translates to:
  /// **'NOTE: Zoom in further to see individual bacterial colonies and fungal hyphae responding to these factors.'**
  String get zoomNote;

  /// No description provided for @metabolicFlux.
  ///
  /// In en, this message translates to:
  /// **'Metabolic Flux'**
  String get metabolicFlux;

  /// No description provided for @causalPathways.
  ///
  /// In en, this message translates to:
  /// **'Causal Pathways'**
  String get causalPathways;

  /// No description provided for @oxygenRedoxEh.
  ///
  /// In en, this message translates to:
  /// **'Oxygen ➔ Redox (Eh)'**
  String get oxygenRedoxEh;

  /// No description provided for @hypoxiaDesc.
  ///
  /// In en, this message translates to:
  /// **'Hypoxia triggers electron acceptance shifts.'**
  String get hypoxiaDesc;

  /// No description provided for @ehDenitrification.
  ///
  /// In en, this message translates to:
  /// **'Eh ➔ Denitrification'**
  String get ehDenitrification;

  /// No description provided for @denitLowRedoxDesc.
  ///
  /// In en, this message translates to:
  /// **'Low redox potential drives nitrate reduction to gas.'**
  String get denitLowRedoxDesc;

  /// No description provided for @phPLock.
  ///
  /// In en, this message translates to:
  /// **'pH ➔ P-Lock'**
  String get phPLock;

  /// No description provided for @pFixationDesc.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus fixation by minerals based on acidity.'**
  String get pFixationDesc;

  /// No description provided for @activeFormulas.
  ///
  /// In en, this message translates to:
  /// **'Active Formulas (Real-time)'**
  String get activeFormulas;

  /// No description provided for @vanGenuchtenTitle.
  ///
  /// In en, this message translates to:
  /// **'van Genuchten (Water)'**
  String get vanGenuchtenTitle;

  /// No description provided for @vanGenuchtenDesc.
  ///
  /// In en, this message translates to:
  /// **'Governs how much water soil holds at specific suction.'**
  String get vanGenuchtenDesc;

  /// No description provided for @millingtonQuirkTitle.
  ///
  /// In en, this message translates to:
  /// **'Millington-Quirk (Gas)'**
  String get millingtonQuirkTitle;

  /// No description provided for @millingtonQuirkDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculates gas diffusion through air-filled pore space.'**
  String get millingtonQuirkDesc;

  /// No description provided for @nutrientApplicationConsole.
  ///
  /// In en, this message translates to:
  /// **'Nutrient Application Console'**
  String get nutrientApplicationConsole;

  /// No description provided for @applyAll.
  ///
  /// In en, this message translates to:
  /// **'Apply All'**
  String get applyAll;

  /// No description provided for @nutrientsAppliedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Applied {count} nutrients to the soil surface.'**
  String nutrientsAppliedSnackBar(int count);

  /// No description provided for @selectNutrients.
  ///
  /// In en, this message translates to:
  /// **'Select Nutrients'**
  String get selectNutrients;

  /// No description provided for @fertilizationMixHint.
  ///
  /// In en, this message translates to:
  /// **'Tap elements to add or remove them from your fertilization mix.'**
  String get fertilizationMixHint;

  /// No description provided for @noNutrientsSelected.
  ///
  /// In en, this message translates to:
  /// **'No Nutrients Selected'**
  String get noNutrientsSelected;

  /// No description provided for @adjustAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Select elements from the periodic table to adjust their application amounts.'**
  String get adjustAmountHint;

  /// No description provided for @applicationMix.
  ///
  /// In en, this message translates to:
  /// **'Application Mix'**
  String get applicationMix;

  /// No description provided for @totalElements.
  ///
  /// In en, this message translates to:
  /// **'Total Elements: {count}'**
  String totalElements(int count);

  /// No description provided for @clearMix.
  ///
  /// In en, this message translates to:
  /// **'Clear Mix'**
  String get clearMix;

  /// No description provided for @fieldMetrics.
  ///
  /// In en, this message translates to:
  /// **'Field Metrics'**
  String get fieldMetrics;

  /// No description provided for @historyMode.
  ///
  /// In en, this message translates to:
  /// **'History Mode'**
  String get historyMode;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {value}'**
  String dayLabel(int value);

  /// No description provided for @atmosphereSimulator.
  ///
  /// In en, this message translates to:
  /// **'Soil-Plant-Atmosphere Simulator'**
  String get atmosphereSimulator;

  /// No description provided for @errorLoadingScenarios.
  ///
  /// In en, this message translates to:
  /// **'Error loading scenarios: {error}'**
  String errorLoadingScenarios(String error);

  /// No description provided for @objectivesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Objectives'**
  String objectivesCount(int count);

  /// No description provided for @elements.
  ///
  /// In en, this message translates to:
  /// **'Elements'**
  String get elements;

  /// No description provided for @depthProfiles.
  ///
  /// In en, this message translates to:
  /// **'Depth Profiles'**
  String get depthProfiles;

  /// No description provided for @selectElementDetails.
  ///
  /// In en, this message translates to:
  /// **'Select an element to view details'**
  String get selectElementDetails;

  /// No description provided for @atomicMass.
  ///
  /// In en, this message translates to:
  /// **'Atomic Mass'**
  String get atomicMass;

  /// No description provided for @soilTextureClassification.
  ///
  /// In en, this message translates to:
  /// **'Soil Texture Classification'**
  String get soilTextureClassification;

  /// No description provided for @textureInteractiveHint.
  ///
  /// In en, this message translates to:
  /// **'Interactive: Probe different compositions to see physical parameters'**
  String get textureInteractiveHint;

  /// No description provided for @usdaTextureClass.
  ///
  /// In en, this message translates to:
  /// **'USDA Texture Class'**
  String get usdaTextureClass;

  /// No description provided for @sandFraction.
  ///
  /// In en, this message translates to:
  /// **'Sand Fraction'**
  String get sandFraction;

  /// No description provided for @siltFraction.
  ///
  /// In en, this message translates to:
  /// **'Silt Fraction'**
  String get siltFraction;

  /// No description provided for @clayFraction.
  ///
  /// In en, this message translates to:
  /// **'Clay Fraction'**
  String get clayFraction;

  /// No description provided for @hydraulicParameters.
  ///
  /// In en, this message translates to:
  /// **'Hydraulic Parameters'**
  String get hydraulicParameters;

  /// No description provided for @satConductivity.
  ///
  /// In en, this message translates to:
  /// **'Sat. Conductivity (Ksat)'**
  String get satConductivity;

  /// No description provided for @satWaterContent.
  ///
  /// In en, this message translates to:
  /// **'Sat. Water Content (θs)'**
  String get satWaterContent;

  /// No description provided for @vgAlphaLabel.
  ///
  /// In en, this message translates to:
  /// **'VG Alpha (α)'**
  String get vgAlphaLabel;

  /// No description provided for @vgNLabel.
  ///
  /// In en, this message translates to:
  /// **'VG n'**
  String get vgNLabel;

  /// No description provided for @resetToActiveLayer.
  ///
  /// In en, this message translates to:
  /// **'Reset to Active Layer'**
  String get resetToActiveLayer;

  /// No description provided for @mollierChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Psychrometric (Mollier) Chart'**
  String get mollierChartTitle;

  /// No description provided for @mollierInteractiveHint.
  ///
  /// In en, this message translates to:
  /// **'Interactive: Explore T/RH relationship and Drying Power (VPD)'**
  String get mollierInteractiveHint;

  /// No description provided for @dryingPower.
  ///
  /// In en, this message translates to:
  /// **'Drying Power'**
  String get dryingPower;

  /// No description provided for @airTemperature.
  ///
  /// In en, this message translates to:
  /// **'Air Temperature'**
  String get airTemperature;

  /// No description provided for @roleInEcosystem.
  ///
  /// In en, this message translates to:
  /// **'Role in Ecosystem'**
  String get roleInEcosystem;

  /// No description provided for @resetToLiveWeather.
  ///
  /// In en, this message translates to:
  /// **'Reset to Live Weather'**
  String get resetToLiveWeather;

  /// No description provided for @lowVpd.
  ///
  /// In en, this message translates to:
  /// **'LOW (Low Transpiration)'**
  String get lowVpd;

  /// No description provided for @optimalVpd.
  ///
  /// In en, this message translates to:
  /// **'OPTIMAL (Ideal Growth)'**
  String get optimalVpd;

  /// No description provided for @highVpd.
  ///
  /// In en, this message translates to:
  /// **'HIGH (Stomatal Closure Risk)'**
  String get highVpd;

  /// No description provided for @criticalVpd.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL (Severe Wilting)'**
  String get criticalVpd;

  /// No description provided for @satVaporPressure.
  ///
  /// In en, this message translates to:
  /// **'Sat. Vapor Pressure'**
  String get satVaporPressure;

  /// No description provided for @vpdSeverity.
  ///
  /// In en, this message translates to:
  /// **'VPD Severity'**
  String get vpdSeverity;

  /// No description provided for @soilDepthProfiles.
  ///
  /// In en, this message translates to:
  /// **'Soil Depth Profiles'**
  String get soilDepthProfiles;

  /// No description provided for @depthProfilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Visualization of physical and chemical gradients across the soil column.'**
  String get depthProfilesDesc;

  /// No description provided for @scientificAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Scientific Analytics & Control'**
  String get scientificAnalyticsTitle;

  /// No description provided for @eventLog.
  ///
  /// In en, this message translates to:
  /// **'Event Log'**
  String get eventLog;

  /// No description provided for @clearLog.
  ///
  /// In en, this message translates to:
  /// **'Clear log'**
  String get clearLog;

  /// No description provided for @objectiveProduceBiomass.
  ///
  /// In en, this message translates to:
  /// **'Produce Biomass'**
  String get objectiveProduceBiomass;

  /// No description provided for @objectiveRestoreHealth.
  ///
  /// In en, this message translates to:
  /// **'Restore Soil Health'**
  String get objectiveRestoreHealth;

  /// No description provided for @objectivePreventLeaching.
  ///
  /// In en, this message translates to:
  /// **'Prevent Leaching'**
  String get objectivePreventLeaching;

  /// No description provided for @objectiveReachYield.
  ///
  /// In en, this message translates to:
  /// **'Reach Yield Target'**
  String get objectiveReachYield;

  /// No description provided for @objectiveUnlockNitrogen.
  ///
  /// In en, this message translates to:
  /// **'Unlock Nitrogen'**
  String get objectiveUnlockNitrogen;

  /// No description provided for @objectiveCropVitality.
  ///
  /// In en, this message translates to:
  /// **'Improve Crop Vitality'**
  String get objectiveCropVitality;

  /// No description provided for @bulkDensity.
  ///
  /// In en, this message translates to:
  /// **'Bulk Density'**
  String get bulkDensity;

  /// No description provided for @insight_droughtStress.
  ///
  /// In en, this message translates to:
  /// **'Drought Stress: Low soil water potential is reducing turgor pressure, halting cell expansion (Lockhart Law).'**
  String get insight_droughtStress;

  /// No description provided for @insight_vigorousGrowth.
  ///
  /// In en, this message translates to:
  /// **'Vigorous Growth: Optimal turgor and nutrient availability are maximizing biomass accumulation.'**
  String get insight_vigorousGrowth;

  /// No description provided for @insight_chainReaction.
  ///
  /// In en, this message translates to:
  /// **'Chain Reaction: Saturation -> Oxygen Depletion -> Redox Drop ({minEh} mV) -> Denitrification losing Nitrogen.'**
  String insight_chainReaction(String minEh);

  /// No description provided for @insight_phosphateLockup.
  ///
  /// In en, this message translates to:
  /// **'Phosphate Lock-up: Extreme pH ({ph}) is causing Phosphorus to be sorbed by {reason}, reducing availability for the plant.'**
  String insight_phosphateLockup(String ph, String reason);

  /// No description provided for @insight_leachingAlert.
  ///
  /// In en, this message translates to:
  /// **'Leaching Alert: Nitrate is migrating below the root zone due to high downward flux.'**
  String get insight_leachingAlert;

  /// No description provided for @insight_nitrogenLock.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen Lock: High C/N ratio in organic matter is causing microbes to immobilize mineral Nitrogen, starving the plant.'**
  String get insight_nitrogenLock;

  /// No description provided for @insight_thermalInertia.
  ///
  /// In en, this message translates to:
  /// **'Thermal Inertia: Wet soil has higher heat capacity and lower albedo, leading to slower heating but better heat retention at night.'**
  String get insight_thermalInertia;

  /// No description provided for @insight_lowAlbedo.
  ///
  /// In en, this message translates to:
  /// **'Low Albedo: Darker surface (due to wetness or mulch) is absorbing more solar radiation, increasing surface energy intake.'**
  String get insight_lowAlbedo;

  /// No description provided for @insight_radiativeCooling.
  ///
  /// In en, this message translates to:
  /// **'Radiative Cooling: Soil is emitting longwave radiation (Stefan-Boltzmann law) but retaining heat better than the air.'**
  String get insight_radiativeCooling;

  /// No description provided for @insight_hungryMicrobes.
  ///
  /// In en, this message translates to:
  /// **'Hungry Microbes: High biomass but low POM! Microbes are mineralizing organic matter quickly.'**
  String get insight_hungryMicrobes;

  /// No description provided for @insight_bioGlueActive.
  ///
  /// In en, this message translates to:
  /// **'Bio-Glue: High EPS levels are stabilizing soil aggregates, improving structure and Structure HP.'**
  String get insight_bioGlueActive;

  /// No description provided for @insight_activeCycling.
  ///
  /// In en, this message translates to:
  /// **'Active Cycling: Healthy microbial biomass is actively depolymerizing organic Nitrogen (Schimel & Bennett Law).'**
  String get insight_activeCycling;

  /// No description provided for @insight_physicalBarrier.
  ///
  /// In en, this message translates to:
  /// **'Physical Barrier: Surface compaction is causing ponding and limiting deep water infiltration.'**
  String get insight_physicalBarrier;

  /// No description provided for @insight_runoffRisk.
  ///
  /// In en, this message translates to:
  /// **'Runoff Risk: Rain intensity ({rain} mm/h) exceeds topsoil infiltration capacity ({capacity} mm/h), leading to surface runoff.'**
  String insight_runoffRisk(String rain, String capacity);

  /// No description provided for @insight_surfaceSealing.
  ///
  /// In en, this message translates to:
  /// **'Surface Sealing: Low aggregate stability is causing the surface to seal (crust), reducing infiltration by 90%.'**
  String get insight_surfaceSealing;

  /// No description provided for @insight_bioArmor.
  ///
  /// In en, this message translates to:
  /// **'Bio-Armor: Cover crop is protecting the surface from rain-induced slaking and improving structural health.'**
  String get insight_bioArmor;

  /// No description provided for @insight_structureCrisis.
  ///
  /// In en, this message translates to:
  /// **'Structure Crisis: Low aggregate stability (Structure HP)! Soil is prone to erosion and compaction. Increase organic matter or fungal activity.'**
  String get insight_structureCrisis;

  /// No description provided for @insight_resilientStructure.
  ///
  /// In en, this message translates to:
  /// **'Resilient Structure: Strong aggregate stability is protecting the pore space and maximizing water infiltration.'**
  String get insight_resilientStructure;

  /// No description provided for @insight_biologicalDesert.
  ///
  /// In en, this message translates to:
  /// **'Biological Desert: Very low microbial biomass. Nutrient cycling is stalled. Consider adding organic carbon (POM).'**
  String get insight_biologicalDesert;

  /// No description provided for @insight_metabolicStress.
  ///
  /// In en, this message translates to:
  /// **'Metabolic Stress: High microbial population but low Oxygen! Microbes are switching to anaerobic pathways, causing Redox drop.'**
  String get insight_metabolicStress;

  /// No description provided for @insight_tillageTradeoff.
  ///
  /// In en, this message translates to:
  /// **'Tillage Trade-off: Improved aeration and conductivity, but fungal networks have been disrupted.'**
  String get insight_tillageTradeoff;

  /// No description provided for @process.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get process;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @significance.
  ///
  /// In en, this message translates to:
  /// **'Significance'**
  String get significance;

  /// No description provided for @risk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get risk;

  /// No description provided for @mobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get mobility;

  /// No description provided for @uptake.
  ///
  /// In en, this message translates to:
  /// **'Uptake'**
  String get uptake;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @deficiencySymptom.
  ///
  /// In en, this message translates to:
  /// **'Deficiency Symptom'**
  String get deficiencySymptom;

  /// No description provided for @feature.
  ///
  /// In en, this message translates to:
  /// **'Special Feature'**
  String get feature;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @climateImpact.
  ///
  /// In en, this message translates to:
  /// **'Climate Impact'**
  String get climateImpact;

  /// No description provided for @consequence.
  ///
  /// In en, this message translates to:
  /// **'Consequence'**
  String get consequence;

  /// No description provided for @helper.
  ///
  /// In en, this message translates to:
  /// **'Helper'**
  String get helper;

  /// No description provided for @catalyst.
  ///
  /// In en, this message translates to:
  /// **'Catalyst'**
  String get catalyst;

  /// No description provided for @mechanism.
  ///
  /// In en, this message translates to:
  /// **'Mechanism'**
  String get mechanism;

  /// No description provided for @importance.
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get importance;

  /// No description provided for @nutrient.
  ///
  /// In en, this message translates to:
  /// **'Nutrient'**
  String get nutrient;

  /// No description provided for @measurement.
  ///
  /// In en, this message translates to:
  /// **'measurement'**
  String get measurement;

  /// No description provided for @availableNutrient.
  ///
  /// In en, this message translates to:
  /// **'Plant Available'**
  String get availableNutrient;

  /// No description provided for @limiter.
  ///
  /// In en, this message translates to:
  /// **'Limiter'**
  String get limiter;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @upward.
  ///
  /// In en, this message translates to:
  /// **'Upward'**
  String get upward;

  /// No description provided for @intoRoot.
  ///
  /// In en, this message translates to:
  /// **'Atmosphere → Soil'**
  String get intoRoot;

  /// No description provided for @intoLeaves.
  ///
  /// In en, this message translates to:
  /// **'Into Leaves'**
  String get intoLeaves;

  /// No description provided for @aerobicRespiration.
  ///
  /// In en, this message translates to:
  /// **'Aerobic Respiration'**
  String get aerobicRespiration;

  /// No description provided for @anaerobicDenitrification.
  ///
  /// In en, this message translates to:
  /// **'Anaerobic Denitrification'**
  String get anaerobicDenitrification;

  /// No description provided for @denitrifiers.
  ///
  /// In en, this message translates to:
  /// **'Denitrifying Bacteria'**
  String get denitrifiers;

  /// No description provided for @bioturbation.
  ///
  /// In en, this message translates to:
  /// **'Bioturbation'**
  String get bioturbation;

  /// No description provided for @improvedInfiltration.
  ///
  /// In en, this message translates to:
  /// **'Improved Infiltration'**
  String get improvedInfiltration;

  /// No description provided for @nutrientCycling.
  ///
  /// In en, this message translates to:
  /// **'Nutrient Cycling'**
  String get nutrientCycling;

  /// No description provided for @organicMatterMixing.
  ///
  /// In en, this message translates to:
  /// **'Mixing of Organic Matter'**
  String get organicMatterMixing;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get veryGood;

  /// No description provided for @veryWeak.
  ///
  /// In en, this message translates to:
  /// **'Very Weak'**
  String get veryWeak;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slow;

  /// No description provided for @activeTransport.
  ///
  /// In en, this message translates to:
  /// **'Active Transport'**
  String get activeTransport;

  /// No description provided for @solubleNutrient.
  ///
  /// In en, this message translates to:
  /// **'Soluble Nutrient'**
  String get solubleNutrient;

  /// No description provided for @solubleNutrientDesc.
  ///
  /// In en, this message translates to:
  /// **'Soluble nutrient in the soil solution. Ions move near the roots through diffusion and mass flow.'**
  String get solubleNutrientDesc;

  /// No description provided for @streptomyces.
  ///
  /// In en, this message translates to:
  /// **'Streptomyces'**
  String get streptomyces;

  /// No description provided for @decompositionCapacity.
  ///
  /// In en, this message translates to:
  /// **'Decomposition Capacity'**
  String get decompositionCapacity;

  /// No description provided for @resistantCompounds.
  ///
  /// In en, this message translates to:
  /// **'Resistant Compounds'**
  String get resistantCompounds;

  /// No description provided for @photosynthateDistribution.
  ///
  /// In en, this message translates to:
  /// **'Photosynthate Distribution'**
  String get photosynthateDistribution;

  /// No description provided for @microbialEnergySource.
  ///
  /// In en, this message translates to:
  /// **'Microbial Energy Source'**
  String get microbialEnergySource;

  /// No description provided for @leachingAfterRain.
  ///
  /// In en, this message translates to:
  /// **'Leaching after rain'**
  String get leachingAfterRain;

  /// No description provided for @leafMarginBurn.
  ///
  /// In en, this message translates to:
  /// **'Leaf margin burn'**
  String get leafMarginBurn;

  /// No description provided for @noRedistribution.
  ///
  /// In en, this message translates to:
  /// **'No redistribution'**
  String get noRedistribution;

  /// No description provided for @chlorophyllCenter.
  ///
  /// In en, this message translates to:
  /// **'Center of chlorophyll'**
  String get chlorophyllCenter;

  /// No description provided for @oldLeafChlorosis.
  ///
  /// In en, this message translates to:
  /// **'Old leaf chlorosis'**
  String get oldLeafChlorosis;

  /// No description provided for @anaerobiosisWaterlogging.
  ///
  /// In en, this message translates to:
  /// **'Anaerobiosis in waterlogging'**
  String get anaerobiosisWaterlogging;

  /// No description provided for @microbialRespiration.
  ///
  /// In en, this message translates to:
  /// **'Microbial Respiration'**
  String get microbialRespiration;

  /// No description provided for @soilBiologicalActivity.
  ///
  /// In en, this message translates to:
  /// **'Soil Biological Activity'**
  String get soilBiologicalActivity;

  /// No description provided for @greenhouseGasEmissions.
  ///
  /// In en, this message translates to:
  /// **'Greenhouse Gas Emissions'**
  String get greenhouseGasEmissions;

  /// No description provided for @highAfterRain.
  ///
  /// In en, this message translates to:
  /// **'High after rain'**
  String get highAfterRain;

  /// No description provided for @groundwaterContamination.
  ///
  /// In en, this message translates to:
  /// **'Groundwater Contamination'**
  String get groundwaterContamination;

  /// No description provided for @generalChlorosis.
  ///
  /// In en, this message translates to:
  /// **'General Chlorosis'**
  String get generalChlorosis;

  /// No description provided for @mycorrhizae.
  ///
  /// In en, this message translates to:
  /// **'Mycorrhizae'**
  String get mycorrhizae;

  /// No description provided for @nutrientBank.
  ///
  /// In en, this message translates to:
  /// **'Nutrient Bank'**
  String get nutrientBank;

  /// No description provided for @heterotrophicMicrobes.
  ///
  /// In en, this message translates to:
  /// **'Heterotrophic Microbes'**
  String get heterotrophicMicrobes;

  /// No description provided for @electrostaticBinding.
  ///
  /// In en, this message translates to:
  /// **'Electrostatic Binding'**
  String get electrostaticBinding;

  /// No description provided for @preventsLeaching.
  ///
  /// In en, this message translates to:
  /// **'Prevents leaching'**
  String get preventsLeaching;

  /// No description provided for @nutrientRelease.
  ///
  /// In en, this message translates to:
  /// **'Nutrient release'**
  String get nutrientRelease;

  /// No description provided for @especiallyPAndK.
  ///
  /// In en, this message translates to:
  /// **'Especially P and K'**
  String get especiallyPAndK;

  /// No description provided for @soilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture'**
  String get soilMoisture;

  /// No description provided for @biogeochemical.
  ///
  /// In en, this message translates to:
  /// **'Biogeochemical'**
  String get biogeochemical;

  /// No description provided for @soilProfile.
  ///
  /// In en, this message translates to:
  /// **'Soil profile'**
  String get soilProfile;

  /// No description provided for @organicHorizon.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get organicHorizon;

  /// No description provided for @topsoilHorizon.
  ///
  /// In en, this message translates to:
  /// **'Topsoil'**
  String get topsoilHorizon;

  /// No description provided for @subsoilHorizon.
  ///
  /// In en, this message translates to:
  /// **'Soil → Atmosphere'**
  String get subsoilHorizon;

  /// No description provided for @parentMaterialHorizon.
  ///
  /// In en, this message translates to:
  /// **'Parent Material'**
  String get parentMaterialHorizon;

  /// No description provided for @bedrockHorizon.
  ///
  /// In en, this message translates to:
  /// **'Bedrock'**
  String get bedrockHorizon;

  /// No description provided for @cuticle.
  ///
  /// In en, this message translates to:
  /// **'Cuticle'**
  String get cuticle;

  /// No description provided for @palisade.
  ///
  /// In en, this message translates to:
  /// **'Palisade Mesophyll'**
  String get palisade;

  /// No description provided for @vein.
  ///
  /// In en, this message translates to:
  /// **'Vein'**
  String get vein;

  /// No description provided for @stoma.
  ///
  /// In en, this message translates to:
  /// **'Stoma'**
  String get stoma;

  /// No description provided for @epidermis.
  ///
  /// In en, this message translates to:
  /// **'Epidermis'**
  String get epidermis;

  /// No description provided for @phloem.
  ///
  /// In en, this message translates to:
  /// **'Phloem'**
  String get phloem;

  /// No description provided for @cambium.
  ///
  /// In en, this message translates to:
  /// **'Cambium'**
  String get cambium;

  /// No description provided for @xylem.
  ///
  /// In en, this message translates to:
  /// **'XYLEM'**
  String get xylem;

  /// No description provided for @rootHair.
  ///
  /// In en, this message translates to:
  /// **'Root Hair'**
  String get rootHair;

  /// No description provided for @cortex.
  ///
  /// In en, this message translates to:
  /// **'Cortex'**
  String get cortex;

  /// No description provided for @casparianStrip.
  ///
  /// In en, this message translates to:
  /// **'Casparian Strip'**
  String get casparianStrip;

  /// No description provided for @exudates.
  ///
  /// In en, this message translates to:
  /// **'Exudates'**
  String get exudates;

  /// No description provided for @flagella.
  ///
  /// In en, this message translates to:
  /// **'Flagella'**
  String get flagella;

  /// No description provided for @cellWall.
  ///
  /// In en, this message translates to:
  /// **'Cell Wall'**
  String get cellWall;

  /// No description provided for @dna.
  ///
  /// In en, this message translates to:
  /// **'DNA'**
  String get dna;

  /// No description provided for @enzymes.
  ///
  /// In en, this message translates to:
  /// **'Enzymes'**
  String get enzymes;

  /// No description provided for @stemCrossSection.
  ///
  /// In en, this message translates to:
  /// **'Stem Cross-Section'**
  String get stemCrossSection;

  /// No description provided for @rootTissue.
  ///
  /// In en, this message translates to:
  /// **'Root Tissue'**
  String get rootTissue;

  /// No description provided for @microbialCell.
  ///
  /// In en, this message translates to:
  /// **'Microbial Cell'**
  String get microbialCell;

  /// No description provided for @simulationStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get simulationStatus;

  /// No description provided for @runningStatus.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get runningStatus;

  /// No description provided for @pausedStatus.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedStatus;

  /// No description provided for @iteration.
  ///
  /// In en, this message translates to:
  /// **'Iteration'**
  String get iteration;

  /// No description provided for @deltaT.
  ///
  /// In en, this message translates to:
  /// **'Delta T'**
  String get deltaT;

  /// No description provided for @modules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modules;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get noEvents;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @laiLabel.
  ///
  /// In en, this message translates to:
  /// **'LAI'**
  String get laiLabel;

  /// No description provided for @turgorPressure.
  ///
  /// In en, this message translates to:
  /// **'Turgor Pressure'**
  String get turgorPressure;

  /// No description provided for @rootNodesLabel.
  ///
  /// In en, this message translates to:
  /// **'Root Nodes'**
  String get rootNodesLabel;

  /// No description provided for @rootDepthLabel.
  ///
  /// In en, this message translates to:
  /// **'Root Depth'**
  String get rootDepthLabel;

  /// No description provided for @ionLabel.
  ///
  /// In en, this message translates to:
  /// **'Ion'**
  String get ionLabel;

  /// No description provided for @concentrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Concentration'**
  String get concentrationLabel;

  /// No description provided for @chargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get chargeLabel;

  /// No description provided for @bindingLabel.
  ///
  /// In en, this message translates to:
  /// **'Binding'**
  String get bindingLabel;

  /// No description provided for @layerLabel.
  ///
  /// In en, this message translates to:
  /// **'Layer'**
  String get layerLabel;

  /// No description provided for @waterBalance.
  ///
  /// In en, this message translates to:
  /// **'Water Balance'**
  String get waterBalance;

  /// No description provided for @stomataLabel.
  ///
  /// In en, this message translates to:
  /// **'Stomata'**
  String get stomataLabel;

  /// No description provided for @structureLabel.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get structureLabel;

  /// No description provided for @phBuffer.
  ///
  /// In en, this message translates to:
  /// **'pH Buffer'**
  String get phBuffer;

  /// No description provided for @phEffect.
  ///
  /// In en, this message translates to:
  /// **'pH Effect'**
  String get phEffect;

  /// No description provided for @antagonist.
  ///
  /// In en, this message translates to:
  /// **'Antagonist'**
  String get antagonist;

  /// No description provided for @photosynthesis.
  ///
  /// In en, this message translates to:
  /// **'Photosynthesis'**
  String get photosynthesis;

  /// No description provided for @photosynthesisDesc.
  ///
  /// In en, this message translates to:
  /// **'Plants convert solar energy, CO2, and water into chemical energy (sugars). This process is the foundation of the ecosystem\'s energy flux.'**
  String get photosynthesisDesc;

  /// No description provided for @redistribution.
  ///
  /// In en, this message translates to:
  /// **'Redistribution'**
  String get redistribution;

  /// No description provided for @porosityEffect.
  ///
  /// In en, this message translates to:
  /// **'Porosity Effect'**
  String get porosityEffect;

  /// No description provided for @populationLabel.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get populationLabel;

  /// No description provided for @gasLabel.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get gasLabel;

  /// No description provided for @reactionLabel.
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get reactionLabel;

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLabel;

  /// No description provided for @immobilized.
  ///
  /// In en, this message translates to:
  /// **'Immobilized'**
  String get immobilized;

  /// No description provided for @velocityLabel.
  ///
  /// In en, this message translates to:
  /// **'Velocity'**
  String get velocityLabel;

  /// No description provided for @climateEffect.
  ///
  /// In en, this message translates to:
  /// **'Climate Effect'**
  String get climateEffect;

  /// No description provided for @airTempLabel.
  ///
  /// In en, this message translates to:
  /// **'Air Temperature'**
  String get airTempLabel;

  /// No description provided for @nitrogenLoss.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen Loss'**
  String get nitrogenLoss;

  /// No description provided for @metabolism.
  ///
  /// In en, this message translates to:
  /// **'Metabolism'**
  String get metabolism;

  /// No description provided for @tempOptimum.
  ///
  /// In en, this message translates to:
  /// **'Temp Optimum'**
  String get tempOptimum;

  /// No description provided for @moistureOptimum.
  ///
  /// In en, this message translates to:
  /// **'Moisture Optimum'**
  String get moistureOptimum;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @carbonStorage.
  ///
  /// In en, this message translates to:
  /// **'Carbon Storage'**
  String get carbonStorage;

  /// No description provided for @oxidationReduction.
  ///
  /// In en, this message translates to:
  /// **'Redox'**
  String get oxidationReduction;

  /// No description provided for @organicCarbonLabel.
  ///
  /// In en, this message translates to:
  /// **'Org. Carbon'**
  String get organicCarbonLabel;

  /// No description provided for @microbialMassLabel.
  ///
  /// In en, this message translates to:
  /// **'Microbial Mass'**
  String get microbialMassLabel;

  /// No description provided for @waterStatus.
  ///
  /// In en, this message translates to:
  /// **'Water Status'**
  String get waterStatus;

  /// No description provided for @limited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get limited;

  /// No description provided for @mildStress.
  ///
  /// In en, this message translates to:
  /// **'Mild Stress'**
  String get mildStress;

  /// No description provided for @severeStress.
  ///
  /// In en, this message translates to:
  /// **'Severe Stress'**
  String get severeStress;

  /// No description provided for @goodWaterStatus.
  ///
  /// In en, this message translates to:
  /// **'Good Water Status'**
  String get goodWaterStatus;

  /// No description provided for @xylemLabel.
  ///
  /// In en, this message translates to:
  /// **'Xylem'**
  String get xylemLabel;

  /// No description provided for @phloemLabel.
  ///
  /// In en, this message translates to:
  /// **'Phloem'**
  String get phloemLabel;

  /// No description provided for @waterUp.
  ///
  /// In en, this message translates to:
  /// **'water up'**
  String get waterUp;

  /// No description provided for @sugarsDown.
  ///
  /// In en, this message translates to:
  /// **'sugars down'**
  String get sugarsDown;

  /// No description provided for @plantDescription.
  ///
  /// In en, this message translates to:
  /// **'Plant water status depends on turgor pressure, which drives cell tension and growth. When soil water potential drops (drought), the plant closes stomata to save water, but at the same time photosynthesis slows down. The root system actively seeks water and nutrients.'**
  String get plantDescription;

  /// No description provided for @earthwormDescription.
  ///
  /// In en, this message translates to:
  /// **'Earthworms are ecosystem engineers that improve soil structure by creating macropores (bioturbation). They mix organic matter into the mineral soil, improve water infiltration and aeration. Earthworm burrows also serve as pathways for roots.'**
  String get earthwormDescription;

  /// No description provided for @bubbleCo2Description.
  ///
  /// In en, this message translates to:
  /// **'Soil respiration releases carbon dioxide when microbes and roots decompose organic matter and produce energy. This is a sign of healthy microbial activity. The rate of respiration depends on temperature, moisture, and C content.'**
  String get bubbleCo2Description;

  /// No description provided for @bubbleN2oDescription.
  ///
  /// In en, this message translates to:
  /// **'Nitrous oxide is released when denitrifying bacteria reduce nitrate in anaerobic (oxygen-free) conditions. This happens especially in waterlogged soil. N2O is a potent greenhouse gas (298x CO2) - a sign of a problem!'**
  String get bubbleN2oDescription;

  /// No description provided for @ionNitrateDescription.
  ///
  /// In en, this message translates to:
  /// **'Negatively charged, highly mobile nitrogen ion. Nitrate moves with water and can leach into groundwater or be lost to the atmosphere through denitrification.'**
  String get ionNitrateDescription;

  /// No description provided for @ionPhosphateDescription.
  ///
  /// In en, this message translates to:
  /// **'Negatively charged phosphorus ion. Essential for energy (ATP) but moves very slowly in soil due to strong binding to minerals.'**
  String get ionPhosphateDescription;

  /// No description provided for @ionPotassiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Positive ion regulating plant water balance and stomata. Held by soil\'s cation exchange capacity (CEC).'**
  String get ionPotassiumDescription;

  /// No description provided for @ionCalciumDescription.
  ///
  /// In en, this message translates to:
  /// **'Crucial for cell wall stability and signaling. Moves slowly with water flow.'**
  String get ionCalciumDescription;

  /// No description provided for @ionMagnesiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Central part of the chlorophyll molecule. Vital for photosynthesis.'**
  String get ionMagnesiumDescription;

  /// No description provided for @bacteriaDescription.
  ///
  /// In en, this message translates to:
  /// **'Soil bacteria are the fastest decomposers and the engines of nutrient cycling. They operate near the roots (rhizosphere), decompose organic matter and release nutrients to plants. Nitrifying bacteria convert ammonium to nitrate.'**
  String get bacteriaDescription;

  /// No description provided for @fungiDescription.
  ///
  /// In en, this message translates to:
  /// **'Fungal mycelia form underground networks that transport water and nutrients over long distances. Mycorrhizae form symbioses with plants. Fungi decompose difficult-to-decompose compounds such as lignin and cellulose.'**
  String get fungiDescription;

  /// No description provided for @actinomycetesDescription.
  ///
  /// In en, this message translates to:
  /// **'Streptomyces group bacteria that produce antibiotics and decompose difficult-to-decompose compounds. They produce geosmin - the cause of the earthy smell. Slower than bacteria, but more efficient at decomposing difficult compounds.'**
  String get actinomycetesDescription;

  /// No description provided for @soilTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilTypeLabel;

  /// No description provided for @textureAS.
  ///
  /// In en, this message translates to:
  /// **'Heavy Clay (AS)'**
  String get textureAS;

  /// No description provided for @textureHtS.
  ///
  /// In en, this message translates to:
  /// **'Sandy Clay (HtS)'**
  String get textureHtS;

  /// No description provided for @textureHeS.
  ///
  /// In en, this message translates to:
  /// **'Silty Clay (HeS)'**
  String get textureHeS;

  /// No description provided for @textureHsS.
  ///
  /// In en, this message translates to:
  /// **'Fine Silty Clay (HsS)'**
  String get textureHsS;

  /// No description provided for @textureHt.
  ///
  /// In en, this message translates to:
  /// **'Sand (Ht)'**
  String get textureHt;

  /// No description provided for @textureHe.
  ///
  /// In en, this message translates to:
  /// **'Silt (He)'**
  String get textureHe;

  /// No description provided for @textureHs.
  ///
  /// In en, this message translates to:
  /// **'Fine Silt (Hs)'**
  String get textureHs;

  /// No description provided for @aerationLabel.
  ///
  /// In en, this message translates to:
  /// **'Aeration'**
  String get aerationLabel;

  /// No description provided for @redoxStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Redox State'**
  String get redoxStateLabel;

  /// No description provided for @siltyClay.
  ///
  /// In en, this message translates to:
  /// **'Silty Clay'**
  String get siltyClay;

  /// No description provided for @sandyClay.
  ///
  /// In en, this message translates to:
  /// **'Sandy Clay'**
  String get sandyClay;

  /// No description provided for @clayLoam.
  ///
  /// In en, this message translates to:
  /// **'Clay Loam'**
  String get clayLoam;

  /// No description provided for @sandyClayLoam.
  ///
  /// In en, this message translates to:
  /// **'Sandy Clay Loam'**
  String get sandyClayLoam;

  /// No description provided for @siltyClayLoam.
  ///
  /// In en, this message translates to:
  /// **'Silty Clay Loam'**
  String get siltyClayLoam;

  /// No description provided for @siltLoam.
  ///
  /// In en, this message translates to:
  /// **'Silt Loam'**
  String get siltLoam;

  /// No description provided for @loamySand.
  ///
  /// In en, this message translates to:
  /// **'Loamy Sand'**
  String get loamySand;

  /// No description provided for @sandyLoam.
  ///
  /// In en, this message translates to:
  /// **'Sandy Loam'**
  String get sandyLoam;

  /// No description provided for @loam.
  ///
  /// In en, this message translates to:
  /// **'Loam'**
  String get loam;

  /// No description provided for @goodAeration.
  ///
  /// In en, this message translates to:
  /// **'Good Aeration ✓'**
  String get goodAeration;

  /// No description provided for @oxygenDeficiency.
  ///
  /// In en, this message translates to:
  /// **'Oxygen Deficiency ⚠️'**
  String get oxygenDeficiency;

  /// No description provided for @aerobicState.
  ///
  /// In en, this message translates to:
  /// **'Aerobic'**
  String get aerobicState;

  /// No description provided for @anaerobicState.
  ///
  /// In en, this message translates to:
  /// **'Anaerobic ⚠️'**
  String get anaerobicState;

  /// No description provided for @sufficientAeration.
  ///
  /// In en, this message translates to:
  /// **'Sufficient Aeration'**
  String get sufficientAeration;

  /// No description provided for @poorAeration.
  ///
  /// In en, this message translates to:
  /// **'Poor Aeration ⚠️'**
  String get poorAeration;

  /// No description provided for @variableRedox.
  ///
  /// In en, this message translates to:
  /// **'Variable Redox'**
  String get variableRedox;

  /// No description provided for @saturated.
  ///
  /// In en, this message translates to:
  /// **'Saturated'**
  String get saturated;

  /// No description provided for @dry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get dry;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @acidic.
  ///
  /// In en, this message translates to:
  /// **'Acidic'**
  String get acidic;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// No description provided for @alkaline.
  ///
  /// In en, this message translates to:
  /// **'Alkaline'**
  String get alkaline;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @hardToTake.
  ///
  /// In en, this message translates to:
  /// **'Hard to take'**
  String get hardToTake;

  /// No description provided for @mineralizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Mineralization'**
  String get mineralizationTitle;

  /// No description provided for @mineralizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Conversion of organic matter into plant-available inorganic nutrients.'**
  String get mineralizationDesc;

  /// No description provided for @nitrificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Nitrification'**
  String get nitrificationTitle;

  /// No description provided for @nitrificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Transformation of ammonium to nitrate by specialized bacteria.'**
  String get nitrificationDesc;

  /// No description provided for @denitrificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Denitrification'**
  String get denitrificationTitle;

  /// No description provided for @adsorptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Adsorption'**
  String get adsorptionTitle;

  /// No description provided for @adsorptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Binding of nutrients to soil particle surfaces (e.g., CEC).'**
  String get adsorptionDesc;

  /// No description provided for @desorptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Desorption'**
  String get desorptionTitle;

  /// No description provided for @desorptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Bound nutrients are released back into the soil solution through ion exchange.'**
  String get desorptionDesc;

  /// No description provided for @ionNitrateTitle.
  ///
  /// In en, this message translates to:
  /// **'NITRATE (NO₃⁻)'**
  String get ionNitrateTitle;

  /// No description provided for @ionNitrateName.
  ///
  /// In en, this message translates to:
  /// **'Nitrate'**
  String get ionNitrateName;

  /// No description provided for @ionPhosphateTitle.
  ///
  /// In en, this message translates to:
  /// **'PHOSPHATE (H₂PO₄⁻)'**
  String get ionPhosphateTitle;

  /// No description provided for @ionPhosphateName.
  ///
  /// In en, this message translates to:
  /// **'Phosphate'**
  String get ionPhosphateName;

  /// No description provided for @ionPotassiumTitle.
  ///
  /// In en, this message translates to:
  /// **'POTASSIUM (K⁺)'**
  String get ionPotassiumTitle;

  /// No description provided for @ionPotassiumName.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get ionPotassiumName;

  /// No description provided for @ionCalciumTitle.
  ///
  /// In en, this message translates to:
  /// **'CALCIUM (Ca²⁺)'**
  String get ionCalciumTitle;

  /// No description provided for @ionCalciumName.
  ///
  /// In en, this message translates to:
  /// **'Calcium'**
  String get ionCalciumName;

  /// No description provided for @ionMagnesiumTitle.
  ///
  /// In en, this message translates to:
  /// **'MAGNESIUM (Mg²⁺)'**
  String get ionMagnesiumTitle;

  /// No description provided for @ionMagnesiumName.
  ///
  /// In en, this message translates to:
  /// **'Magnesium'**
  String get ionMagnesiumName;

  /// No description provided for @negativeCharge.
  ///
  /// In en, this message translates to:
  /// **'Negative ({value})'**
  String negativeCharge(String value);

  /// No description provided for @positiveCharge.
  ///
  /// In en, this message translates to:
  /// **'Positive ({value})'**
  String positiveCharge(String value);

  /// No description provided for @leaches.
  ///
  /// In en, this message translates to:
  /// **'Leaches'**
  String get leaches;

  /// No description provided for @diffusionAndMycorrhiza.
  ///
  /// In en, this message translates to:
  /// **'Diffusion + mycorrhiza'**
  String get diffusionAndMycorrhiza;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @bound.
  ///
  /// In en, this message translates to:
  /// **'Bound'**
  String get bound;

  /// No description provided for @clayMinerals.
  ///
  /// In en, this message translates to:
  /// **'Clay minerals'**
  String get clayMinerals;

  /// No description provided for @cellWallSignal.
  ///
  /// In en, this message translates to:
  /// **'Cell wall, signal'**
  String get cellWallSignal;

  /// No description provided for @limingRaisesPH.
  ///
  /// In en, this message translates to:
  /// **'Liming raises pH'**
  String get limingRaisesPH;

  /// No description provided for @goodRedistribution.
  ///
  /// In en, this message translates to:
  /// **'Good (redistribution)'**
  String get goodRedistribution;

  /// No description provided for @highK.
  ///
  /// In en, this message translates to:
  /// **'High K⁺'**
  String get highK;

  /// No description provided for @diffusionTitle.
  ///
  /// In en, this message translates to:
  /// **'Diffusion'**
  String get diffusionTitle;

  /// No description provided for @diffusionDesc.
  ///
  /// In en, this message translates to:
  /// **'Ions move in the direction of the concentration gradient (from high to low).'**
  String get diffusionDesc;

  /// No description provided for @nutrientUptakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrient Uptake'**
  String get nutrientUptakeTitle;

  /// No description provided for @nutrientUptakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Roots take up nutrients by active transport (requiring ATP energy) or passive flow.'**
  String get nutrientUptakeDesc;

  /// No description provided for @bypassFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Bypass Flow'**
  String get bypassFlowTitle;

  /// No description provided for @bypassFlowDesc.
  ///
  /// In en, this message translates to:
  /// **'Water and dissolved nutrients flow rapidly through macropores (wormholes, cracks).'**
  String get bypassFlowDesc;

  /// No description provided for @soilMoistureTitle.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture'**
  String get soilMoistureTitle;

  /// No description provided for @soilMoistureDesc.
  ///
  /// In en, this message translates to:
  /// **'Volumetric water content (θ) tells what part of the soil volume is water.'**
  String get soilMoistureDesc;

  /// No description provided for @phTitle.
  ///
  /// In en, this message translates to:
  /// **'pH (Acidity)'**
  String get phTitle;

  /// No description provided for @phDesc.
  ///
  /// In en, this message translates to:
  /// **'pH measures the activity of hydrogen ions (H+). it affects nutrient solubility and microbial activity.'**
  String get phDesc;

  /// No description provided for @waterPotentialTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Potential (Ψ)'**
  String get waterPotentialTitle;

  /// No description provided for @waterPotentialDesc.
  ///
  /// In en, this message translates to:
  /// **'Matrix potential (Ψ) describes the force with which the soil holds water.'**
  String get waterPotentialDesc;

  /// No description provided for @dissolvedOxygenTitle.
  ///
  /// In en, this message translates to:
  /// **'Dissolved Oxygen (O2)'**
  String get dissolvedOxygenTitle;

  /// No description provided for @dissolvedOxygenDesc.
  ///
  /// In en, this message translates to:
  /// **'Roots and aerobic microbes need oxygen for cell respiration.'**
  String get dissolvedOxygenDesc;

  /// No description provided for @nitrogenTitle.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N)'**
  String get nitrogenTitle;

  /// No description provided for @nitrogenDesc.
  ///
  /// In en, this message translates to:
  /// **'The most important growth nutrient. Building block of proteins, chlorophyll, and nucleic acids.'**
  String get nitrogenDesc;

  /// No description provided for @phosphorusTitle.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus (P)'**
  String get phosphorusTitle;

  /// No description provided for @phosphorusDesc.
  ///
  /// In en, this message translates to:
  /// **'Component of ATP and DNA. Very poorly mobile - binds to clay and iron oxides.'**
  String get phosphorusDesc;

  /// No description provided for @potassiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K)'**
  String get potassiumTitle;

  /// No description provided for @potassiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Regulates the opening of stomata, water balance, and enzyme activity.'**
  String get potassiumDesc;

  /// No description provided for @calciumTitle.
  ///
  /// In en, this message translates to:
  /// **'Calcium (Ca)'**
  String get calciumTitle;

  /// No description provided for @calciumDesc.
  ///
  /// In en, this message translates to:
  /// **'Binder for pectin in cell walls and a signaling molecule. Does not re-move in the plant.'**
  String get calciumDesc;

  /// No description provided for @magnesiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Magnesium (Mg)'**
  String get magnesiumTitle;

  /// No description provided for @magnesiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Central atom of chlorophyll - without magnesium, no photosynthesis.'**
  String get magnesiumDesc;

  /// No description provided for @solarRadiationTitle.
  ///
  /// In en, this message translates to:
  /// **'Solar Radiation'**
  String get solarRadiationTitle;

  /// No description provided for @solarRadiationDesc.
  ///
  /// In en, this message translates to:
  /// **'Light provides energy for photosynthesis. PAR (400-700 nm) is absorbed by chlorophyll.'**
  String get solarRadiationDesc;

  /// No description provided for @leachingTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaching'**
  String get leachingTitle;

  /// No description provided for @leachingDesc.
  ///
  /// In en, this message translates to:
  /// **'Nutrients (especially nitrate) leach with rainwater into groundwater. Economic loss and environmental risk.'**
  String get leachingDesc;

  /// No description provided for @topsoilDesc.
  ///
  /// In en, this message translates to:
  /// **'Topsoil is the most biologically active layer of the soil. Most microbes and soil organisms live here. Organic matter decomposes into humus and nutrients cycle fastest. Roots take up most of their nutrients from this layer.'**
  String get topsoilDesc;

  /// No description provided for @subsoilDesc.
  ///
  /// In en, this message translates to:
  /// **'Oxides of clay, iron, and aluminum accumulate in the enrichment layer from above. This layer is often denser and may limit water permeability. Roots penetrate here in search of water and nutrients, but biological activity is lower.'**
  String get subsoilDesc;

  /// No description provided for @parentMaterialDesc.
  ///
  /// In en, this message translates to:
  /// **'The subsoil is the least weathered soil layer, consisting of material detached from the bedrock. Biological activity is low, but the layer acts as a water reservoir and source of minerals in the long term.'**
  String get parentMaterialDesc;

  /// No description provided for @genericLayerDesc.
  ///
  /// In en, this message translates to:
  /// **'This soil layer contains different particle sizes and organic matter. The properties of the layer affect water retention capacity, aeration, and root growth.'**
  String get genericLayerDesc;

  /// No description provided for @organicHorizonDesc.
  ///
  /// In en, this message translates to:
  /// **'The organic layer consists of decomposing plant and animal material. High carbon content and biological activity.'**
  String get organicHorizonDesc;

  /// No description provided for @bedrockDesc.
  ///
  /// In en, this message translates to:
  /// **'Bedrock is solid rock that underlies the soil layers. It forms the ultimate boundary for root growth and water movement.'**
  String get bedrockDesc;

  /// No description provided for @sunIndicatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Solar radiation on the surface. PAR (Photosynthetically Active Radiation, 400-700 nm) provides energy for photosynthesis. Beer-Lambert law describes light absorption through plant mass.'**
  String get sunIndicatorDesc;

  /// No description provided for @totalRadiation.
  ///
  /// In en, this message translates to:
  /// **'Total Radiation'**
  String get totalRadiation;

  /// No description provided for @parFraction.
  ///
  /// In en, this message translates to:
  /// **'PAR Fraction'**
  String get parFraction;

  /// No description provided for @absorbedPar.
  ///
  /// In en, this message translates to:
  /// **'Absorbed PAR'**
  String get absorbedPar;

  /// No description provided for @transmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get transmission;

  /// No description provided for @formula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeLabel;

  /// No description provided for @forceLabel.
  ///
  /// In en, this message translates to:
  /// **'Force'**
  String get forceLabel;

  /// No description provided for @speedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speedLabel;

  /// No description provided for @leafLabel.
  ///
  /// In en, this message translates to:
  /// **'Leaf'**
  String get leafLabel;

  /// No description provided for @tapToSeeDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap an animation element to see more details'**
  String get tapToSeeDetails;

  /// No description provided for @inspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get inspection;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @measurementData.
  ///
  /// In en, this message translates to:
  /// **'Measurement Data'**
  String get measurementData;

  /// No description provided for @legend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  /// No description provided for @fieldCapacity.
  ///
  /// In en, this message translates to:
  /// **'field capacity'**
  String get fieldCapacity;

  /// No description provided for @longTerm.
  ///
  /// In en, this message translates to:
  /// **'Long-term'**
  String get longTerm;

  /// No description provided for @actinomycetesTitle.
  ///
  /// In en, this message translates to:
  /// **'Actinomycetes'**
  String get actinomycetesTitle;

  /// No description provided for @waterUptakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Water moves from roots to leaves in a perpendicular piping system (xylem). Suction is created by evaporation through stomata - this is called the transpiration stream.'**
  String get waterUptakeDesc;

  /// No description provided for @carbonCycleDesc.
  ///
  /// In en, this message translates to:
  /// **'Photosynthates (sugars) flow in the phloem from leaves to roots, or the root secretes carbon compounds into the soil for microbial food (exudates).'**
  String get carbonCycleDesc;

  /// No description provided for @nitrogenUptakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Nitrate (NO3-) or ammonium (NH4+) moves from the soil solution to the root by active transport. Nitrogen is a key factor in growth - a building block of proteins and chlorophyll.'**
  String get nitrogenUptakeDesc;

  /// No description provided for @phosphorusUptakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Phosphate (H2PO4-) is a poorly mobile nutrient that mycorrhizae help to collect. Essential component of ATP and DNA.'**
  String get phosphorusUptakeDesc;

  /// No description provided for @potassiumUptakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K+) regulates the opening of stomata and the plant\'s water balance. Important maintainer of osmotic pressure.'**
  String get potassiumUptakeDesc;

  /// No description provided for @calciumUptakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Calcium (Ca2+) strengthens cell walls and acts as a signaling molecule. It does not re-move in the plant - new leaves need a constant supply.'**
  String get calciumUptakeDesc;

  /// No description provided for @magnesiumUptakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Magnesium (Mg2+) is the central atom of chlorophyll - without it, no photosynthesis. Moves in the plant from old leaves to new ones.'**
  String get magnesiumUptakeDesc;

  /// No description provided for @oxygenDiffusionDesc.
  ///
  /// In en, this message translates to:
  /// **'Oxygen diffuses from the atmosphere into soil pores, enabling aerobic life. High water content blocks this transport, leading to hypoxia.'**
  String get oxygenDiffusionDesc;

  /// No description provided for @gasExchangeDesc.
  ///
  /// In en, this message translates to:
  /// **'CO2 and N2O are released from the soil as by-products of microbial respiration. High CO2 emission indicates active microbiology.'**
  String get gasExchangeDesc;

  /// No description provided for @adsorptionMechanism.
  ///
  /// In en, this message translates to:
  /// **'Electrostatic binding'**
  String get adsorptionMechanism;

  /// No description provided for @ionExchange.
  ///
  /// In en, this message translates to:
  /// **'Ion exchange'**
  String get ionExchange;

  /// No description provided for @downward.
  ///
  /// In en, this message translates to:
  /// **'Downward'**
  String get downward;

  /// No description provided for @downwardLoss.
  ///
  /// In en, this message translates to:
  /// **'Downward (loss)'**
  String get downwardLoss;

  /// No description provided for @downwardDiffusion.
  ///
  /// In en, this message translates to:
  /// **'Downward (diffusion)'**
  String get downwardDiffusion;

  /// No description provided for @upwardDiffusion.
  ///
  /// In en, this message translates to:
  /// **'Upward (diffusion)'**
  String get upwardDiffusion;

  /// No description provided for @downwardOut.
  ///
  /// In en, this message translates to:
  /// **'Downward/Out'**
  String get downwardOut;

  /// No description provided for @bindingOrder.
  ///
  /// In en, this message translates to:
  /// **'Binding Order'**
  String get bindingOrder;

  /// No description provided for @cecTitle.
  ///
  /// In en, this message translates to:
  /// **'CEC (Cation Exchange Capacity)'**
  String get cecTitle;

  /// No description provided for @cecDesc.
  ///
  /// In en, this message translates to:
  /// **'The soil\'s ability to bind and release positively charged ions (cations). Negative charges of clay minerals and humus hold nutrients from leaching.'**
  String get cecDesc;

  /// No description provided for @estimatedCec.
  ///
  /// In en, this message translates to:
  /// **'Estimated CEC'**
  String get estimatedCec;

  /// No description provided for @clayContent.
  ///
  /// In en, this message translates to:
  /// **'Clay Content'**
  String get clayContent;

  /// No description provided for @bindingIons.
  ///
  /// In en, this message translates to:
  /// **'Binding Ions'**
  String get bindingIons;

  /// No description provided for @leachingProtection.
  ///
  /// In en, this message translates to:
  /// **'Leaching Protection'**
  String get leachingProtection;

  /// No description provided for @aerobicProcess.
  ///
  /// In en, this message translates to:
  /// **'Aerobic Process'**
  String get aerobicProcess;

  /// No description provided for @gradientMovement.
  ///
  /// In en, this message translates to:
  /// **'Gradient Movement'**
  String get gradientMovement;

  /// No description provided for @uptakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Uptake'**
  String get uptakeLabel;

  /// No description provided for @leachingRiskLabel.
  ///
  /// In en, this message translates to:
  /// **'Leaching Risk'**
  String get leachingRiskLabel;

  /// No description provided for @reactant.
  ///
  /// In en, this message translates to:
  /// **'Reactant'**
  String get reactant;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @organicNProteins.
  ///
  /// In en, this message translates to:
  /// **'Organic N (proteins)'**
  String get organicNProteins;

  /// No description provided for @ammoniumProduct.
  ///
  /// In en, this message translates to:
  /// **'NH4+ (ammonium)'**
  String get ammoniumProduct;

  /// No description provided for @availableP.
  ///
  /// In en, this message translates to:
  /// **'Available P'**
  String get availableP;

  /// No description provided for @optimalTemp.
  ///
  /// In en, this message translates to:
  /// **'Optimal Temp'**
  String get optimalTemp;

  /// No description provided for @optimalMoisture.
  ///
  /// In en, this message translates to:
  /// **'Optimal Moisture'**
  String get optimalMoisture;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @directionLabel.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get directionLabel;

  /// No description provided for @consumption.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get consumption;

  /// No description provided for @requirement.
  ///
  /// In en, this message translates to:
  /// **'Requirement'**
  String get requirement;

  /// No description provided for @phOptimum.
  ///
  /// In en, this message translates to:
  /// **'pH Optimum'**
  String get phOptimum;

  /// No description provided for @exchangeableK.
  ///
  /// In en, this message translates to:
  /// **'Exchangeable K+'**
  String get exchangeableK;

  /// No description provided for @solubleCa.
  ///
  /// In en, this message translates to:
  /// **'Soluble Ca2+'**
  String get solubleCa;

  /// No description provided for @exchangeableMg.
  ///
  /// In en, this message translates to:
  /// **'Exchangeable Mg2+'**
  String get exchangeableMg;

  /// No description provided for @trigger.
  ///
  /// In en, this message translates to:
  /// **'Trigger'**
  String get trigger;

  /// No description provided for @surface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get surface;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @assessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get assessment;

  /// No description provided for @anecicDesc.
  ///
  /// In en, this message translates to:
  /// **'Anecic (deep burrower)'**
  String get anecicDesc;

  /// No description provided for @nitrogenAtmosphereLoss.
  ///
  /// In en, this message translates to:
  /// **'Nutrient lost to atmosphere!'**
  String get nitrogenAtmosphereLoss;

  /// No description provided for @stomataTurgorRole.
  ///
  /// In en, this message translates to:
  /// **'Stomata regulation, turgor'**
  String get stomataTurgorRole;

  /// No description provided for @kAntagonistDesc.
  ///
  /// In en, this message translates to:
  /// **'High K+ interferes'**
  String get kAntagonistDesc;

  /// No description provided for @heavyRainTrigger.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain, saturated soil'**
  String get heavyRainTrigger;

  /// No description provided for @nutrientLossConsequence.
  ///
  /// In en, this message translates to:
  /// **'Nutrient loss, water body load'**
  String get nutrientLossConsequence;

  /// No description provided for @cnRatioLabel.
  ///
  /// In en, this message translates to:
  /// **'C:N Ratio'**
  String get cnRatioLabel;

  /// No description provided for @cnRatioDesc.
  ///
  /// In en, this message translates to:
  /// **'Critical for microbial activity'**
  String get cnRatioDesc;

  /// No description provided for @demandLabel.
  ///
  /// In en, this message translates to:
  /// **'Demand'**
  String get demandLabel;

  /// No description provided for @highMacronutrient.
  ///
  /// In en, this message translates to:
  /// **'High (macronutrient)'**
  String get highMacronutrient;

  /// No description provided for @airToSoil.
  ///
  /// In en, this message translates to:
  /// **'Air → Soil'**
  String get airToSoil;

  /// No description provided for @consumptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get consumptionLabel;

  /// No description provided for @rootRespirationMicrobes.
  ///
  /// In en, this message translates to:
  /// **'Root Respiration + Microbes'**
  String get rootRespirationMicrobes;

  /// No description provided for @gasesLabel.
  ///
  /// In en, this message translates to:
  /// **'Gases'**
  String get gasesLabel;

  /// No description provided for @wavelengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Wavelength'**
  String get wavelengthLabel;

  /// No description provided for @absorptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Absorption'**
  String get absorptionLabel;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productLabel;

  /// No description provided for @atpProductDesc.
  ///
  /// In en, this message translates to:
  /// **'ATP + NADPH → Sugars'**
  String get atpProductDesc;

  /// No description provided for @heatFluxTitle.
  ///
  /// In en, this message translates to:
  /// **'Heat Flux'**
  String get heatFluxTitle;

  /// No description provided for @heatFluxDesc.
  ///
  /// In en, this message translates to:
  /// **'Thermal energy moves along the temperature gradient. Solar radiation heats the surface, and heat is conducted deeper into the soil.'**
  String get heatFluxDesc;

  /// No description provided for @thermalConduction.
  ///
  /// In en, this message translates to:
  /// **'Thermal Conduction'**
  String get thermalConduction;

  /// No description provided for @governsMetabolism.
  ///
  /// In en, this message translates to:
  /// **'Regulates microbial metabolism'**
  String get governsMetabolism;

  /// No description provided for @alongGradient.
  ///
  /// In en, this message translates to:
  /// **'Along gradient'**
  String get alongGradient;

  /// No description provided for @salinityTitle.
  ///
  /// In en, this message translates to:
  /// **'Salinity / EC'**
  String get salinityTitle;

  /// No description provided for @salinityDesc.
  ///
  /// In en, this message translates to:
  /// **'Dissolved salts and nutrients affect the soil\'s electrical conductivity (EC). High salinity causes osmotic stress to the plant.'**
  String get salinityDesc;

  /// No description provided for @dissolvedIons.
  ///
  /// In en, this message translates to:
  /// **'Dissolved Ions'**
  String get dissolvedIons;

  /// No description provided for @osmoticStress.
  ///
  /// In en, this message translates to:
  /// **'Osmotic Stress'**
  String get osmoticStress;

  /// No description provided for @accumulationLeaching.
  ///
  /// In en, this message translates to:
  /// **'Accumulation / Leaching'**
  String get accumulationLeaching;

  /// No description provided for @macronutrient.
  ///
  /// In en, this message translates to:
  /// **'Macronutrient'**
  String get macronutrient;

  /// No description provided for @energyNutrient.
  ///
  /// In en, this message translates to:
  /// **'Energy Nutrient'**
  String get energyNutrient;

  /// No description provided for @availablePLabel.
  ///
  /// In en, this message translates to:
  /// **'Available P'**
  String get availablePLabel;

  /// No description provided for @exchangeableKLabel.
  ///
  /// In en, this message translates to:
  /// **'Exchangeable K+'**
  String get exchangeableKLabel;

  /// No description provided for @solubleCaLabel.
  ///
  /// In en, this message translates to:
  /// **'Soluble Ca2+'**
  String get solubleCaLabel;

  /// No description provided for @exchangeableMgLabel.
  ///
  /// In en, this message translates to:
  /// **'Exchangeable Mg2+'**
  String get exchangeableMgLabel;

  /// No description provided for @reactantLabel.
  ///
  /// In en, this message translates to:
  /// **'Reactant'**
  String get reactantLabel;

  /// No description provided for @organicNProteinsLabel.
  ///
  /// In en, this message translates to:
  /// **'Organic N (proteins)'**
  String get organicNProteinsLabel;

  /// No description provided for @ammoniumProductLabel.
  ///
  /// In en, this message translates to:
  /// **'NH4+ (ammonium)'**
  String get ammoniumProductLabel;

  /// No description provided for @optimalTempLabel.
  ///
  /// In en, this message translates to:
  /// **'Optimal Temp'**
  String get optimalTempLabel;

  /// No description provided for @optimalMoistureLabel.
  ///
  /// In en, this message translates to:
  /// **'Optimal Moisture'**
  String get optimalMoistureLabel;

  /// No description provided for @requirementLabel.
  ///
  /// In en, this message translates to:
  /// **'Requirement'**
  String get requirementLabel;

  /// No description provided for @aerobicProcessLabel.
  ///
  /// In en, this message translates to:
  /// **'Aerobic Process'**
  String get aerobicProcessLabel;

  /// No description provided for @mechanismLabel.
  ///
  /// In en, this message translates to:
  /// **'Mechanism'**
  String get mechanismLabel;

  /// No description provided for @clayHumusSurface.
  ///
  /// In en, this message translates to:
  /// **'Clay minerals, humus'**
  String get clayHumusSurface;

  /// No description provided for @ionExchangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Ion exchange'**
  String get ionExchangeLabel;

  /// No description provided for @rootHSecretion.
  ///
  /// In en, this message translates to:
  /// **'Root H+ secretion'**
  String get rootHSecretion;

  /// No description provided for @solidToSolution.
  ///
  /// In en, this message translates to:
  /// **'Solid → Solution'**
  String get solidToSolution;

  /// No description provided for @gradientMovementLabel.
  ///
  /// In en, this message translates to:
  /// **'Gradient movement'**
  String get gradientMovementLabel;

  /// No description provided for @mycorrhizaeHelper.
  ///
  /// In en, this message translates to:
  /// **'Mycorrhizae'**
  String get mycorrhizaeHelper;

  /// No description provided for @rootHairArea.
  ///
  /// In en, this message translates to:
  /// **'Root hairs 100x roots'**
  String get rootHairArea;

  /// No description provided for @photosynthesisEnergy.
  ///
  /// In en, this message translates to:
  /// **'1-2% of photosynthesis'**
  String get photosynthesisEnergy;

  /// No description provided for @heavyRainSaturated.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain, saturated soil'**
  String get heavyRainSaturated;

  /// No description provided for @macroporeRoute.
  ///
  /// In en, this message translates to:
  /// **'Macropores, cracks'**
  String get macroporeRoute;

  /// No description provided for @fastVelocity.
  ///
  /// In en, this message translates to:
  /// **'Fast (m/h possible)'**
  String get fastVelocity;

  /// No description provided for @unitMgKg.
  ///
  /// In en, this message translates to:
  /// **'mg/kg'**
  String get unitMgKg;

  /// No description provided for @unitMolM3.
  ///
  /// In en, this message translates to:
  /// **'mol/m³'**
  String get unitMolM3;

  /// No description provided for @unitFraction.
  ///
  /// In en, this message translates to:
  /// **'frac'**
  String get unitFraction;

  /// No description provided for @xrayAi.
  ///
  /// In en, this message translates to:
  /// **'X-Ray AI'**
  String get xrayAi;

  /// No description provided for @stemDesc.
  ///
  /// In en, this message translates to:
  /// **'The stem transports water and nutrients from roots to leaves (xylem) and sugars from leaves to roots (phloem).'**
  String get stemDesc;

  /// No description provided for @rootTissueDesc.
  ///
  /// In en, this message translates to:
  /// **'The root cross-section shows how water and nutrients are filtered through the Casparian strip into the vascular tissue.'**
  String get rootTissueDesc;

  /// No description provided for @vascularTissue.
  ///
  /// In en, this message translates to:
  /// **'Vascular tissue'**
  String get vascularTissue;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @rhizosphereLocation.
  ///
  /// In en, this message translates to:
  /// **'Around the roots'**
  String get rhizosphereLocation;

  /// No description provided for @microbialCellDesc.
  ///
  /// In en, this message translates to:
  /// **'A single microbial cell decomposes organic matter using enzymes.'**
  String get microbialCellDesc;

  /// No description provided for @metabolismLabel.
  ///
  /// In en, this message translates to:
  /// **'Metabolism'**
  String get metabolismLabel;

  /// No description provided for @fluxLabel.
  ///
  /// In en, this message translates to:
  /// **'Flux'**
  String get fluxLabel;

  /// No description provided for @veryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get veryHigh;

  /// No description provided for @lawLabel.
  ///
  /// In en, this message translates to:
  /// **'Law'**
  String get lawLabel;

  /// No description provided for @passive.
  ///
  /// In en, this message translates to:
  /// **'Passive'**
  String get passive;

  /// No description provided for @saturatedZone.
  ///
  /// In en, this message translates to:
  /// **'SATURATED ZONE'**
  String get saturatedZone;

  /// No description provided for @saturatedZoneDesc.
  ///
  /// In en, this message translates to:
  /// **'A zone where all pore space is filled with water. Lack of oxygen (anoxia) triggers denitrification and restricts root function.'**
  String get saturatedZoneDesc;

  /// No description provided for @surfaceLabel.
  ///
  /// In en, this message translates to:
  /// **'SURFACE (Z=0)'**
  String get surfaceLabel;

  /// No description provided for @co2Flux.
  ///
  /// In en, this message translates to:
  /// **'CO₂ FLUX'**
  String get co2Flux;

  /// No description provided for @transpirationLabel.
  ///
  /// In en, this message translates to:
  /// **'H₂O TRANSPIRATION'**
  String get transpirationLabel;

  /// No description provided for @plantTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get plantTitle;

  /// No description provided for @physiologyTitle.
  ///
  /// In en, this message translates to:
  /// **'Physiology'**
  String get physiologyTitle;

  /// No description provided for @saturationLabel.
  ///
  /// In en, this message translates to:
  /// **'Saturation Degree'**
  String get saturationLabel;

  /// No description provided for @wiltingPointLabel.
  ///
  /// In en, this message translates to:
  /// **'Wilting Point'**
  String get wiltingPointLabel;

  /// No description provided for @sensorTitle.
  ///
  /// In en, this message translates to:
  /// **'SENSOR: {id}'**
  String sensorTitle(Object id);

  /// No description provided for @sensorDesc.
  ///
  /// In en, this message translates to:
  /// **'Real-time measurement from the soil profile.'**
  String get sensorDesc;

  /// No description provided for @bindingIonsLabel.
  ///
  /// In en, this message translates to:
  /// **'Binding Ions'**
  String get bindingIonsLabel;

  /// No description provided for @activeUptake.
  ///
  /// In en, this message translates to:
  /// **'Active (ATP)'**
  String get activeUptake;

  /// No description provided for @passiveUptake.
  ///
  /// In en, this message translates to:
  /// **'Passive (Mass flow)'**
  String get passiveUptake;

  /// No description provided for @horizonLabel.
  ///
  /// In en, this message translates to:
  /// **'{id}-Horizon'**
  String horizonLabel(Object id);

  /// No description provided for @phDependence.
  ///
  /// In en, this message translates to:
  /// **'pH Dependence'**
  String get phDependence;

  /// No description provided for @transpirationSuction.
  ///
  /// In en, this message translates to:
  /// **'Transpiration suction'**
  String get transpirationSuction;

  /// No description provided for @negativePotential.
  ///
  /// In en, this message translates to:
  /// **'Negative water potential (Ψ)'**
  String get negativePotential;

  /// No description provided for @optimalPh.
  ///
  /// In en, this message translates to:
  /// **'Optimal pH 6-7'**
  String get optimalPh;

  /// No description provided for @stomataRegulation.
  ///
  /// In en, this message translates to:
  /// **'Stomata regulation, turgor'**
  String get stomataRegulation;

  /// No description provided for @soluble.
  ///
  /// In en, this message translates to:
  /// **'Soluble'**
  String get soluble;

  /// No description provided for @blossomEndRot.
  ///
  /// In en, this message translates to:
  /// **'Blossom end rot'**
  String get blossomEndRot;

  /// No description provided for @chlorophyllAtp.
  ///
  /// In en, this message translates to:
  /// **'Chlorophyll, ATP, enzymes'**
  String get chlorophyllAtp;

  /// No description provided for @volumetric.
  ///
  /// In en, this message translates to:
  /// **'Volumetric'**
  String get volumetric;

  /// No description provided for @acidicLiming.
  ///
  /// In en, this message translates to:
  /// **'Acidic - liming recommended'**
  String get acidicLiming;

  /// No description provided for @slightlyAcidic.
  ///
  /// In en, this message translates to:
  /// **'Slightly acidic'**
  String get slightlyAcidic;

  /// No description provided for @optimal.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get optimal;

  /// No description provided for @aluminumToxicity.
  ///
  /// In en, this message translates to:
  /// **'Al toxicity'**
  String get aluminumToxicity;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get highRisk;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowRisk;

  /// No description provided for @reduced.
  ///
  /// In en, this message translates to:
  /// **'Reduced'**
  String get reduced;

  /// No description provided for @saturatedFreeWater.
  ///
  /// In en, this message translates to:
  /// **'Saturated (free water)'**
  String get saturatedFreeWater;

  /// No description provided for @fieldCapacityEasy.
  ///
  /// In en, this message translates to:
  /// **'Field capacity (easy uptake)'**
  String get fieldCapacityEasy;

  /// No description provided for @stressZone.
  ///
  /// In en, this message translates to:
  /// **'Stress zone'**
  String get stressZone;

  /// No description provided for @wiltingPointWarning.
  ///
  /// In en, this message translates to:
  /// **'Wilting point ⚠️'**
  String get wiltingPointWarning;

  /// No description provided for @hypoxicStress.
  ///
  /// In en, this message translates to:
  /// **'Hypoxic (stress starts)'**
  String get hypoxicStress;

  /// No description provided for @anoxic.
  ///
  /// In en, this message translates to:
  /// **'Anoxic ⚠️'**
  String get anoxic;

  /// No description provided for @disturbed.
  ///
  /// In en, this message translates to:
  /// **'Disturbed'**
  String get disturbed;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @oxidizing.
  ///
  /// In en, this message translates to:
  /// **'Oxidizing'**
  String get oxidizing;

  /// No description provided for @reducing.
  ///
  /// In en, this message translates to:
  /// **'Reducing'**
  String get reducing;

  /// No description provided for @sufficient.
  ///
  /// In en, this message translates to:
  /// **'Sufficient'**
  String get sufficient;

  /// No description provided for @deficiency.
  ///
  /// In en, this message translates to:
  /// **'Deficiency'**
  String get deficiency;

  /// No description provided for @molecularDiffusion.
  ///
  /// In en, this message translates to:
  /// **'Molecular diffusion'**
  String get molecularDiffusion;

  /// No description provided for @concentrationDifference.
  ///
  /// In en, this message translates to:
  /// **'Concentration difference'**
  String get concentrationDifference;

  /// No description provided for @organicNReactant.
  ///
  /// In en, this message translates to:
  /// **'Organic N (proteins)'**
  String get organicNReactant;

  /// No description provided for @optimalConditions.
  ///
  /// In en, this message translates to:
  /// **'60% of field capacity'**
  String get optimalConditions;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @hexMatrix.
  ///
  /// In en, this message translates to:
  /// **'Hex-Matrix'**
  String get hexMatrix;

  /// No description provided for @aggregatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Aggregates'**
  String get aggregatesLabel;

  /// No description provided for @ecosystemEngineer.
  ///
  /// In en, this message translates to:
  /// **'Ecosystem Engineer'**
  String get ecosystemEngineer;

  /// No description provided for @infiltration.
  ///
  /// In en, this message translates to:
  /// **'Infiltration'**
  String get infiltration;

  /// No description provided for @aeration.
  ///
  /// In en, this message translates to:
  /// **'Aeration'**
  String get aeration;

  /// No description provided for @earthworm.
  ///
  /// In en, this message translates to:
  /// **'Earthworm'**
  String get earthworm;

  /// No description provided for @redoxLadderDesc.
  ///
  /// In en, this message translates to:
  /// **'The Redox Ladder shows the sequence of electron acceptors used by microbes as oxygen is depleted. Higher potential (Eh) means more energy for life.'**
  String get redoxLadderDesc;

  /// No description provided for @potential.
  ///
  /// In en, this message translates to:
  /// **'Potential'**
  String get potential;

  /// No description provided for @activeTea.
  ///
  /// In en, this message translates to:
  /// **'Active TEA'**
  String get activeTea;

  /// No description provided for @moleculeAmmoniumTitle.
  ///
  /// In en, this message translates to:
  /// **'AMMONIUM (NH₄⁺)'**
  String get moleculeAmmoniumTitle;

  /// No description provided for @moleculeAmmoniumDesc.
  ///
  /// In en, this message translates to:
  /// **'Positively charged nitrogen ion that sticks to soil colloids electrostatically (CEC). It doesn\'t leach easily and is an important nitrogen source for plants.'**
  String get moleculeAmmoniumDesc;

  /// No description provided for @moleculeNitrateTitle.
  ///
  /// In en, this message translates to:
  /// **'NITRATE (NO₃⁻)'**
  String get moleculeNitrateTitle;

  /// No description provided for @moleculeNitrateDesc.
  ///
  /// In en, this message translates to:
  /// **'Negatively charged, highly mobile nitrogen ion. Nitrate moves with water and can leach into groundwater or be lost to the atmosphere through denitrification.'**
  String get moleculeNitrateDesc;

  /// No description provided for @moleculeCarbonLabileTitle.
  ///
  /// In en, this message translates to:
  /// **'LABILE CARBON (C)'**
  String get moleculeCarbonLabileTitle;

  /// No description provided for @moleculeCarbonLabileDesc.
  ///
  /// In en, this message translates to:
  /// **'Easily decomposable organic carbon (POM) that serves as fuel for soil microbes. Promotes microbial activity and nitrogen cycling.'**
  String get moleculeCarbonLabileDesc;

  /// No description provided for @moleculeCarbonStableTitle.
  ///
  /// In en, this message translates to:
  /// **'STABLE CARBON (SOC)'**
  String get moleculeCarbonStableTitle;

  /// No description provided for @moleculeCarbonStableDesc.
  ///
  /// In en, this message translates to:
  /// **'Carbon bound in more permanent forms (MAOM), part of soil humus. Important for soil structure and long-term carbon sequestration.'**
  String get moleculeCarbonStableDesc;

  /// No description provided for @moleculeWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'WATER (H₂O)'**
  String get moleculeWaterTitle;

  /// No description provided for @moleculeWaterDesc.
  ///
  /// In en, this message translates to:
  /// **'A prerequisite for life in soil. Water transports nutrients and acts as a solvent in biochemical reactions.'**
  String get moleculeWaterDesc;

  /// No description provided for @moleculeOxygenTitle.
  ///
  /// In en, this message translates to:
  /// **'OXYGEN (O₂)'**
  String get moleculeOxygenTitle;

  /// No description provided for @moleculeOxygenDesc.
  ///
  /// In en, this message translates to:
  /// **'Essential for aerobic respiration. Roots and most microbes need oxygen to produce energy.'**
  String get moleculeOxygenDesc;

  /// No description provided for @moleculeCO2Title.
  ///
  /// In en, this message translates to:
  /// **'CARBON DIOXIDE (CO₂)'**
  String get moleculeCO2Title;

  /// No description provided for @moleculeCO2Desc.
  ///
  /// In en, this message translates to:
  /// **'End product of microbial and root respiration. High CO2 levels in soil indicate active biological activity.'**
  String get moleculeCO2Desc;

  /// No description provided for @moleculeOrganicNitrogenTitle.
  ///
  /// In en, this message translates to:
  /// **'ORGANIC NITROGEN (N_org)'**
  String get moleculeOrganicNitrogenTitle;

  /// No description provided for @moleculeOrganicNitrogenDesc.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen bound in organic matter like proteins. Microbes must mineralize it into ammonium before plants can use it.'**
  String get moleculeOrganicNitrogenDesc;

  /// No description provided for @moleculeNitrousOxideTitle.
  ///
  /// In en, this message translates to:
  /// **'NITROUS OXIDE (N₂O)'**
  String get moleculeNitrousOxideTitle;

  /// No description provided for @moleculeNitrousOxideDesc.
  ///
  /// In en, this message translates to:
  /// **'A potent greenhouse gas produced by microbes in wet, anaerobic soil. It has ~300 times the warming potential of CO₂.'**
  String get moleculeNitrousOxideDesc;

  /// No description provided for @moleculeMethaneTitle.
  ///
  /// In en, this message translates to:
  /// **'METHANE (CH₄)'**
  String get moleculeMethaneTitle;

  /// No description provided for @moleculeMethaneDesc.
  ///
  /// In en, this message translates to:
  /// **'Gas produced in flooded, oxygen-free conditions. Significant climate impact.'**
  String get moleculeMethaneDesc;

  /// No description provided for @moleculeWaterVaporTitle.
  ///
  /// In en, this message translates to:
  /// **'WATER VAPOR (H₂O_g)'**
  String get moleculeWaterVaporTitle;

  /// No description provided for @moleculeWaterVaporDesc.
  ///
  /// In en, this message translates to:
  /// **'Gaseous water escaping the soil via evaporation or plant transpiration.'**
  String get moleculeWaterVaporDesc;

  /// No description provided for @microbialClusterTitle.
  ///
  /// In en, this message translates to:
  /// **'MICROBIAL CLUSTER'**
  String get microbialClusterTitle;

  /// No description provided for @microbialClusterDesc.
  ///
  /// In en, this message translates to:
  /// **'Represents a high-density colony of soil microbes performing biochemical decomposition.'**
  String get microbialClusterDesc;

  /// No description provided for @carrotTaprootTitle.
  ///
  /// In en, this message translates to:
  /// **'CARROT TAPROOT'**
  String get carrotTaprootTitle;

  /// No description provided for @fineRootTitle.
  ///
  /// In en, this message translates to:
  /// **'FINE ROOT'**
  String get fineRootTitle;

  /// No description provided for @rootStructureDesc.
  ///
  /// In en, this message translates to:
  /// **'Root structure absorbing water and nutrients.'**
  String get rootStructureDesc;

  /// No description provided for @mobilityVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get mobilityVeryGood;

  /// No description provided for @mobilityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get mobilityGood;

  /// No description provided for @mobilityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get mobilityModerate;

  /// No description provided for @mobilityWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get mobilityWeak;

  /// No description provided for @mobilityVeryWeak.
  ///
  /// In en, this message translates to:
  /// **'Very Weak'**
  String get mobilityVeryWeak;

  /// No description provided for @mobilitySlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get mobilitySlow;

  /// No description provided for @simulatedUnits.
  ///
  /// In en, this message translates to:
  /// **'Simulated Units'**
  String get simulatedUnits;

  /// No description provided for @metabolicActivity.
  ///
  /// In en, this message translates to:
  /// **'Metabolic Activity'**
  String get metabolicActivity;

  /// No description provided for @biomassDensity.
  ///
  /// In en, this message translates to:
  /// **'Biomass Density'**
  String get biomassDensity;

  /// No description provided for @immobilizedNutrients.
  ///
  /// In en, this message translates to:
  /// **'Immobilized Nutrients'**
  String get immobilizedNutrients;

  /// No description provided for @gwpLabel.
  ///
  /// In en, this message translates to:
  /// **'Global Warming Potential (GWP)'**
  String get gwpLabel;

  /// No description provided for @methanogenesis.
  ///
  /// In en, this message translates to:
  /// **'Methanogenesis'**
  String get methanogenesis;

  /// No description provided for @biomassLabel.
  ///
  /// In en, this message translates to:
  /// **'Biomass'**
  String get biomassLabel;

  /// No description provided for @depthLabel.
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get depthLabel;

  /// No description provided for @radiusLabel.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get radiusLabel;

  /// No description provided for @co2UptakeTitle.
  ///
  /// In en, this message translates to:
  /// **'CO₂ UPTAKE'**
  String get co2UptakeTitle;

  /// No description provided for @n2oEmissionTitle.
  ///
  /// In en, this message translates to:
  /// **'N₂O EMISSION'**
  String get n2oEmissionTitle;

  /// No description provided for @o2DiffusionTitle.
  ///
  /// In en, this message translates to:
  /// **'O₂ DIFFUSION'**
  String get o2DiffusionTitle;

  /// No description provided for @sugarCompound.
  ///
  /// In en, this message translates to:
  /// **'Sugar (C6H12O6)'**
  String get sugarCompound;

  /// No description provided for @nitrogenLossDenit.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen loss via denitrification'**
  String get nitrogenLossDenit;

  /// No description provided for @liquid.
  ///
  /// In en, this message translates to:
  /// **'Liquid'**
  String get liquid;

  /// No description provided for @greenhouseGas.
  ///
  /// In en, this message translates to:
  /// **'Greenhouse Gas'**
  String get greenhouseGas;

  /// No description provided for @temperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperatureLabel;

  /// No description provided for @soilTempDesc.
  ///
  /// In en, this message translates to:
  /// **'Average kinetic energy of soil particles. Affects all biological rates.'**
  String get soilTempDesc;

  /// No description provided for @valLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valLabel;

  /// No description provided for @heatCapLabel.
  ///
  /// In en, this message translates to:
  /// **'Heat Capacity'**
  String get heatCapLabel;

  /// No description provided for @waterContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Water Content'**
  String get waterContentLabel;

  /// No description provided for @soilWaterDesc.
  ///
  /// In en, this message translates to:
  /// **'Volumetric water content. Essential for transport and cell turgor.'**
  String get soilWaterDesc;

  /// No description provided for @volumetricVWC.
  ///
  /// In en, this message translates to:
  /// **'Volumetric (VWC)'**
  String get volumetricVWC;

  /// No description provided for @porosityTitle.
  ///
  /// In en, this message translates to:
  /// **'Porosity'**
  String get porosityTitle;

  /// No description provided for @carbonLabileLabel.
  ///
  /// In en, this message translates to:
  /// **'Labile (POM)'**
  String get carbonLabileLabel;

  /// No description provided for @carbonStableLabel.
  ///
  /// In en, this message translates to:
  /// **'Stable (MAOM)'**
  String get carbonStableLabel;

  /// No description provided for @cnRatio.
  ///
  /// In en, this message translates to:
  /// **'C/N Ratio'**
  String get cnRatio;

  /// No description provided for @cRatioLabel.
  ///
  /// In en, this message translates to:
  /// **'C-RATIO'**
  String get cRatioLabel;

  /// No description provided for @carbonTitle.
  ///
  /// In en, this message translates to:
  /// **'CARBON (C)'**
  String get carbonTitle;

  /// No description provided for @carbonPoolsDesc.
  ///
  /// In en, this message translates to:
  /// **'POM vs MAOM dynamics and C/N balance.'**
  String get carbonPoolsDesc;

  /// No description provided for @charge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get charge;

  /// No description provided for @symbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get symbolLabel;

  /// No description provided for @oxygenTitle.
  ///
  /// In en, this message translates to:
  /// **'Oxygen'**
  String get oxygenTitle;

  /// No description provided for @wettingFrontTitle.
  ///
  /// In en, this message translates to:
  /// **'Wetting Front'**
  String get wettingFrontTitle;

  /// No description provided for @wettingFrontDesc.
  ///
  /// In en, this message translates to:
  /// **'A front describing the downward movement of water during rain or irrigation. Critical for vertical nutrient transport via mass flow.'**
  String get wettingFrontDesc;

  /// No description provided for @capillaryRiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Capillary Rise'**
  String get capillaryRiseTitle;

  /// No description provided for @capillaryRiseDesc.
  ///
  /// In en, this message translates to:
  /// **'Water rising against gravity into dry upper soil. Helps plants survive drought by pulling water from deep storage into the rhizosphere.'**
  String get capillaryRiseDesc;

  /// No description provided for @evaporationTitle.
  ///
  /// In en, this message translates to:
  /// **'Evaporation'**
  String get evaporationTitle;

  /// No description provided for @evaporationDesc.
  ///
  /// In en, this message translates to:
  /// **'Loss of water from soil surface to atmosphere as vapor. Rate depends on moisture, radiation, and wind (Penman-Monteith).'**
  String get evaporationDesc;

  /// No description provided for @enzymesTitle.
  ///
  /// In en, this message translates to:
  /// **'Enzyme Activity'**
  String get enzymesTitle;

  /// No description provided for @enzymesDesc.
  ///
  /// In en, this message translates to:
  /// **'Microbes and roots secrete enzymes (like urease and phosphatase) to break down complex compounds into plant-available forms.'**
  String get enzymesDesc;

  /// No description provided for @effectLabel.
  ///
  /// In en, this message translates to:
  /// **'Effect'**
  String get effectLabel;

  /// No description provided for @modelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// No description provided for @kineticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Kinetics'**
  String get kineticsLabel;

  /// No description provided for @responseLabel.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get responseLabel;

  /// No description provided for @weatherControl.
  ///
  /// In en, this message translates to:
  /// **'WEATHER CONTROL'**
  String get weatherControl;

  /// No description provided for @lightControl.
  ///
  /// In en, this message translates to:
  /// **'LIGHT CONTROL'**
  String get lightControl;

  /// No description provided for @methaneDescription.
  ///
  /// In en, this message translates to:
  /// **'Methane is produced in highly anaerobic conditions when archaea reduce CO2 or acetate. This happens only after other electron acceptors (O2, NO3, Fe, SO4) are depleted.'**
  String get methaneDescription;

  /// No description provided for @infiltrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Infiltration'**
  String get infiltrationTitle;

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverLabel;

  /// No description provided for @gravitationalPotential.
  ///
  /// In en, this message translates to:
  /// **'Gravitational Potential'**
  String get gravitationalPotential;

  /// No description provided for @moistureLoss.
  ///
  /// In en, this message translates to:
  /// **'Moisture Loss'**
  String get moistureLoss;

  /// No description provided for @energyLabel.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energyLabel;

  /// No description provided for @latentHeat.
  ///
  /// In en, this message translates to:
  /// **'Latent Heat'**
  String get latentHeat;

  /// No description provided for @spacDescription.
  ///
  /// In en, this message translates to:
  /// **'The Soil-Plant-Atmosphere Continuum (SPAC) describes the continuous water flow from soil through roots and xylem to leaves, where it evaporates into the air.'**
  String get spacDescription;

  /// No description provided for @layerControls.
  ///
  /// In en, this message translates to:
  /// **'Layer Controls'**
  String get layerControls;

  /// No description provided for @nutrientsForLayer.
  ///
  /// In en, this message translates to:
  /// **'Nutrients for {id}'**
  String nutrientsForLayer(Object id);

  /// No description provided for @nitrateN.
  ///
  /// In en, this message translates to:
  /// **'Nitrate (N)'**
  String get nitrateN;

  /// No description provided for @phosphateP.
  ///
  /// In en, this message translates to:
  /// **'Phosphate (P)'**
  String get phosphateP;

  /// No description provided for @potassiumK.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K)'**
  String get potassiumK;

  /// No description provided for @calciumCa.
  ///
  /// In en, this message translates to:
  /// **'Calcium (Ca)'**
  String get calciumCa;

  /// No description provided for @magnesiumMg.
  ///
  /// In en, this message translates to:
  /// **'Magnesium (Mg)'**
  String get magnesiumMg;

  /// No description provided for @labileC.
  ///
  /// In en, this message translates to:
  /// **'Labile Carbon (POM)'**
  String get labileC;

  /// No description provided for @stableC.
  ///
  /// In en, this message translates to:
  /// **'Stable Carbon (MAOM)'**
  String get stableC;

  /// No description provided for @soilTexture.
  ///
  /// In en, this message translates to:
  /// **'Soil Texture'**
  String get soilTexture;

  /// No description provided for @atmosphereControls.
  ///
  /// In en, this message translates to:
  /// **'Atmosphere Controls'**
  String get atmosphereControls;

  /// No description provided for @precipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// No description provided for @atmosphericCO2.
  ///
  /// In en, this message translates to:
  /// **'Atmospheric CO₂'**
  String get atmosphericCO2;

  /// No description provided for @nitrogenN.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N)'**
  String get nitrogenN;

  /// No description provided for @carbonC.
  ///
  /// In en, this message translates to:
  /// **'Carbon (C)'**
  String get carbonC;

  /// No description provided for @methaneCH4.
  ///
  /// In en, this message translates to:
  /// **'Methane (CH₄)'**
  String get methaneCH4;

  /// No description provided for @oxygenO2.
  ///
  /// In en, this message translates to:
  /// **'Oxygen (O₂)'**
  String get oxygenO2;

  /// No description provided for @sensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  /// No description provided for @par.
  ///
  /// In en, this message translates to:
  /// **'PAR'**
  String get par;

  /// No description provided for @exudation.
  ///
  /// In en, this message translates to:
  /// **'EXUDATION'**
  String get exudation;

  /// No description provided for @ionExchangePriming.
  ///
  /// In en, this message translates to:
  /// **'ION EXCHANGE & PRIMING'**
  String get ionExchangePriming;

  /// No description provided for @stability.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get stability;

  /// No description provided for @pedsAndGranules.
  ///
  /// In en, this message translates to:
  /// **'Peds & Granules'**
  String get pedsAndGranules;

  /// No description provided for @dynamicLabel.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get dynamicLabel;

  /// No description provided for @logicLabTitle.
  ///
  /// In en, this message translates to:
  /// **'Logic Lab — Biophysics Visualizer'**
  String get logicLabTitle;

  /// No description provided for @buildScenarioTitle.
  ///
  /// In en, this message translates to:
  /// **'Build Scenario'**
  String get buildScenarioTitle;

  /// No description provided for @parametersTab.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parametersTab;

  /// No description provided for @actionsTab.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsTab;

  /// No description provided for @tutorialTab.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorialTab;

  /// No description provided for @scenarioNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Scenario Name'**
  String get scenarioNameLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @simulationLengthDays.
  ///
  /// In en, this message translates to:
  /// **'Simulation Length: {value} days'**
  String simulationLengthDays(int value);

  /// No description provided for @soilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilType;

  /// No description provided for @initialMoisture.
  ///
  /// In en, this message translates to:
  /// **'Initial Moisture (VWC): {value}%'**
  String initialMoisture(String value);

  /// No description provided for @initialNitrate.
  ///
  /// In en, this message translates to:
  /// **'Nitrate Content (NO3): {value} mg/kg'**
  String initialNitrate(String value);

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add to Plan'**
  String get addAction;

  /// No description provided for @addTutorialStepAction.
  ///
  /// In en, this message translates to:
  /// **'Add Tutorial Step'**
  String get addTutorialStepAction;

  /// No description provided for @cultivationPlan.
  ///
  /// In en, this message translates to:
  /// **'Cultivation Plan:'**
  String get cultivationPlan;

  /// No description provided for @tutorialBuilt.
  ///
  /// In en, this message translates to:
  /// **'Built Tutorial:'**
  String get tutorialBuilt;

  /// No description provided for @calculateDays.
  ///
  /// In en, this message translates to:
  /// **'CALCULATE ({value} d)'**
  String calculateDays(int value);

  /// No description provided for @startLive.
  ///
  /// In en, this message translates to:
  /// **'START LIVE'**
  String get startLive;

  /// No description provided for @selectExample.
  ///
  /// In en, this message translates to:
  /// **'Select Example'**
  String get selectExample;

  /// No description provided for @resetGraph.
  ///
  /// In en, this message translates to:
  /// **'Reset Graph'**
  String get resetGraph;

  /// No description provided for @logicLabMixinLabel.
  ///
  /// In en, this message translates to:
  /// **'Tutorial Builder (Logic Lab Mixin)'**
  String get logicLabMixinLabel;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @inputs.
  ///
  /// In en, this message translates to:
  /// **'Inputs'**
  String get inputs;

  /// No description provided for @functions.
  ///
  /// In en, this message translates to:
  /// **'Functions'**
  String get functions;

  /// No description provided for @soilColumnAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Soil Column Analysis'**
  String get soilColumnAnalysis;

  /// No description provided for @layerLabelWithDepth.
  ///
  /// In en, this message translates to:
  /// **'Layer {id} ({depth1} - {depth2} cm)'**
  String layerLabelWithDepth(String id, String depth1, String depth2);

  /// No description provided for @atomicNumber.
  ///
  /// In en, this message translates to:
  /// **'Atomic Number'**
  String get atomicNumber;

  /// No description provided for @biologicalRole.
  ///
  /// In en, this message translates to:
  /// **'Biological Role'**
  String get biologicalRole;

  /// No description provided for @cpkColor.
  ///
  /// In en, this message translates to:
  /// **'CPK Color'**
  String get cpkColor;

  /// No description provided for @classification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get classification;

  /// No description provided for @meteorology.
  ///
  /// In en, this message translates to:
  /// **'Meteorology'**
  String get meteorology;

  /// No description provided for @airAndWaterVapor.
  ///
  /// In en, this message translates to:
  /// **'Air and Water Vapor'**
  String get airAndWaterVapor;

  /// No description provided for @dryBulbTemp.
  ///
  /// In en, this message translates to:
  /// **'Dry Bulb Temp (°C)'**
  String get dryBulbTemp;

  /// No description provided for @humidityRatio.
  ///
  /// In en, this message translates to:
  /// **'Humidity Ratio (kg/kg)'**
  String get humidityRatio;

  /// No description provided for @teachingKey.
  ///
  /// In en, this message translates to:
  /// **'TEACHING KEY'**
  String get teachingKey;

  /// No description provided for @xylemTissue.
  ///
  /// In en, this message translates to:
  /// **'Xylem Tissue (Water UP)'**
  String get xylemTissue;

  /// No description provided for @phloemTissue.
  ///
  /// In en, this message translates to:
  /// **'Phloem Tissue (Sugar DOWN)'**
  String get phloemTissue;

  /// No description provided for @waterMineralsFlow.
  ///
  /// In en, this message translates to:
  /// **'Water & Minerals Flow'**
  String get waterMineralsFlow;

  /// No description provided for @energyCarbonFlow.
  ///
  /// In en, this message translates to:
  /// **'Energy & Carbon Flow'**
  String get energyCarbonFlow;

  /// No description provided for @nNitrateNode.
  ///
  /// In en, this message translates to:
  /// **'N (Nitrate) Node'**
  String get nNitrateNode;

  /// No description provided for @pPhosphateNode.
  ///
  /// In en, this message translates to:
  /// **'P (Phosphate) Node'**
  String get pPhosphateNode;

  /// No description provided for @cecSiteLabel.
  ///
  /// In en, this message translates to:
  /// **'CEC (Cation Exchange Site)'**
  String get cecSiteLabel;

  /// No description provided for @mmKinetics.
  ///
  /// In en, this message translates to:
  /// **'Michaelis-Menten Kinetics'**
  String get mmKinetics;

  /// No description provided for @vgWaterRetention.
  ///
  /// In en, this message translates to:
  /// **'van Genuchten Water Retention'**
  String get vgWaterRetention;

  /// No description provided for @farquharPhotosynthesis.
  ///
  /// In en, this message translates to:
  /// **'Farquhar-von Caemmerer-Berry C3 Photosynthesis'**
  String get farquharPhotosynthesis;

  /// No description provided for @nernstRedox.
  ///
  /// In en, this message translates to:
  /// **'Nernst Equation (Redox)'**
  String get nernstRedox;

  /// No description provided for @soilTempCelsius.
  ///
  /// In en, this message translates to:
  /// **'Soil Temperature (°C)'**
  String get soilTempCelsius;

  /// No description provided for @soilWaterContentPressureHead.
  ///
  /// In en, this message translates to:
  /// **'Soil Water Content / Pressure Head'**
  String get soilWaterContentPressureHead;

  /// No description provided for @soilWaterSaturation.
  ///
  /// In en, this message translates to:
  /// **'Soil Water Saturation'**
  String get soilWaterSaturation;

  /// No description provided for @ammoniumContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Ammonium (NH4+) Content'**
  String get ammoniumContentLabel;

  /// No description provided for @nitrateContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Nitrate (NO3-) Content'**
  String get nitrateContentLabel;

  /// No description provided for @oxygenContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Oxygen (O2) Content'**
  String get oxygenContentLabel;

  /// No description provided for @co2ContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbon Dioxide (CO2)'**
  String get co2ContentLabel;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Action'**
  String get addEvent;

  /// No description provided for @dayTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time (Day): {value}'**
  String dayTimeLabel(String value);

  /// No description provided for @eventTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get eventTypeLabel;

  /// No description provided for @actionFertilize.
  ///
  /// In en, this message translates to:
  /// **'Fertilization'**
  String get actionFertilize;

  /// No description provided for @actionTill.
  ///
  /// In en, this message translates to:
  /// **'Tillage'**
  String get actionTill;

  /// No description provided for @actionWater.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get actionWater;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount: {value}'**
  String amountLabel(String value);

  /// No description provided for @fullField.
  ///
  /// In en, this message translates to:
  /// **'Full Area'**
  String get fullField;

  /// No description provided for @tutBuilderTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutorial Builder (Logic Lab Mixin)'**
  String get tutBuilderTitle;

  /// No description provided for @tutTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target (Highlight)'**
  String get tutTargetLabel;

  /// No description provided for @tutTargetLeaf.
  ///
  /// In en, this message translates to:
  /// **'Leaves (Transpiration)'**
  String get tutTargetLeaf;

  /// No description provided for @tutTargetRoot.
  ///
  /// In en, this message translates to:
  /// **'Roots (Uptake)'**
  String get tutTargetRoot;

  /// No description provided for @tutTargetRhizosphere.
  ///
  /// In en, this message translates to:
  /// **'Rhizosphere (Microbes)'**
  String get tutTargetRhizosphere;

  /// No description provided for @tutTargetSoil.
  ///
  /// In en, this message translates to:
  /// **'Soil Structure'**
  String get tutTargetSoil;

  /// No description provided for @tutTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Tutorial Title'**
  String get tutTitleLabel;

  /// No description provided for @tutDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Teaching Text'**
  String get tutDescLabel;

  /// No description provided for @convectiveFlow.
  ///
  /// In en, this message translates to:
  /// **'Convective Flow'**
  String get convectiveFlow;

  /// No description provided for @negativeSuction.
  ///
  /// In en, this message translates to:
  /// **'Negative Suction'**
  String get negativeSuction;

  /// No description provided for @activeInfiltration.
  ///
  /// In en, this message translates to:
  /// **'Active Infiltration'**
  String get activeInfiltration;

  /// No description provided for @cecDescription.
  ///
  /// In en, this message translates to:
  /// **'Cation Exchange Capacity: The soil\'s ability to hold and exchange nutrients (K+, NH4+, etc).'**
  String get cecDescription;

  /// No description provided for @claySite.
  ///
  /// In en, this message translates to:
  /// **'Clay Site'**
  String get claySite;

  /// No description provided for @organicSite.
  ///
  /// In en, this message translates to:
  /// **'Organic Site'**
  String get organicSite;

  /// No description provided for @hydraulicLift.
  ///
  /// In en, this message translates to:
  /// **'Hydraulic Lift'**
  String get hydraulicLift;

  /// No description provided for @matricPotential.
  ///
  /// In en, this message translates to:
  /// **'Matric Potential'**
  String get matricPotential;

  /// No description provided for @rubiscoLimited.
  ///
  /// In en, this message translates to:
  /// **'Rubisco Limited'**
  String get rubiscoLimited;

  /// No description provided for @organicPool.
  ///
  /// In en, this message translates to:
  /// **'Organic Pool'**
  String get organicPool;

  /// No description provided for @stablePool.
  ///
  /// In en, this message translates to:
  /// **'Stable Pool'**
  String get stablePool;

  /// No description provided for @fractalFingering.
  ///
  /// In en, this message translates to:
  /// **'Fractal Fingering'**
  String get fractalFingering;

  /// No description provided for @nutrientAvailability.
  ///
  /// In en, this message translates to:
  /// **'Nutrient Availability'**
  String get nutrientAvailability;

  /// No description provided for @highDivision.
  ///
  /// In en, this message translates to:
  /// **'High Division'**
  String get highDivision;

  /// No description provided for @capacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacityLabel;

  /// No description provided for @processLabel.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get processLabel;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @groundwaterLabel.
  ///
  /// In en, this message translates to:
  /// **'Groundwater'**
  String get groundwaterLabel;

  /// No description provided for @efficiencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get efficiencyLabel;

  /// No description provided for @c3Pathway.
  ///
  /// In en, this message translates to:
  /// **'C3 Pathway'**
  String get c3Pathway;

  /// No description provided for @organicPoolLabel.
  ///
  /// In en, this message translates to:
  /// **'Organic Pool'**
  String get organicPoolLabel;

  /// No description provided for @stablePoolLabel.
  ///
  /// In en, this message translates to:
  /// **'Stable Pool'**
  String get stablePoolLabel;

  /// No description provided for @microbePoolLabel.
  ///
  /// In en, this message translates to:
  /// **'Microbe Pool'**
  String get microbePoolLabel;

  /// No description provided for @cationLabel.
  ///
  /// In en, this message translates to:
  /// **'Cation'**
  String get cationLabel;

  /// No description provided for @anionLabel.
  ///
  /// In en, this message translates to:
  /// **'Anion'**
  String get anionLabel;

  /// No description provided for @macronutrientLabel.
  ///
  /// In en, this message translates to:
  /// **'Macronutrient'**
  String get macronutrientLabel;

  /// No description provided for @regulationLabel.
  ///
  /// In en, this message translates to:
  /// **'Regulation'**
  String get regulationLabel;

  /// No description provided for @pomNitrogenTitle.
  ///
  /// In en, this message translates to:
  /// **'POM NITROGEN (Particulate Organic N)'**
  String get pomNitrogenTitle;

  /// No description provided for @pomNitrogenDesc.
  ///
  /// In en, this message translates to:
  /// **'Labile organic nitrogen (POM-N). Available to plants through microbial decomposition.'**
  String get pomNitrogenDesc;

  /// No description provided for @micNitrogenTitle.
  ///
  /// In en, this message translates to:
  /// **'MICROBIAL NITROGEN (Microbial Biomass N)'**
  String get micNitrogenTitle;

  /// No description provided for @micNitrogenDesc.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen within living microbial biomass. Released upon cell death or grazing.'**
  String get micNitrogenDesc;

  /// No description provided for @maomNitrogenTitle.
  ///
  /// In en, this message translates to:
  /// **'MAOM NITROGEN (Mineral-Associated N)'**
  String get maomNitrogenTitle;

  /// No description provided for @maomNitrogenDesc.
  ///
  /// In en, this message translates to:
  /// **'Long-lived nitrogen bound to clay and silt particles. The largest and most stable nitrogen pool in soil.'**
  String get maomNitrogenDesc;

  /// No description provided for @ammoniumTitle.
  ///
  /// In en, this message translates to:
  /// **'AMMONIUM (NH₄⁺)'**
  String get ammoniumTitle;

  /// No description provided for @ammoniumDesc.
  ///
  /// In en, this message translates to:
  /// **'Poorly mobile nitrogen form in soil. Binds to clay particles.'**
  String get ammoniumDesc;

  /// No description provided for @nitrateTitle.
  ///
  /// In en, this message translates to:
  /// **'NITRATE (NO₃⁻)'**
  String get nitrateTitle;

  /// No description provided for @nitrateDesc.
  ///
  /// In en, this message translates to:
  /// **'Highly mobile nitrogen form. Dissolves in water and leaches easily.'**
  String get nitrateDesc;

  /// No description provided for @nitrogenTitleLong.
  ///
  /// In en, this message translates to:
  /// **'NITROGEN (N)'**
  String get nitrogenTitleLong;

  /// No description provided for @nitrogenDescLong.
  ///
  /// In en, this message translates to:
  /// **'The most important growth nutrient. Building block for proteins, chlorophyll, and nucleic acids.'**
  String get nitrogenDescLong;

  /// No description provided for @phosphorusTitleLong.
  ///
  /// In en, this message translates to:
  /// **'PHOSPHORUS (P)'**
  String get phosphorusTitleLong;

  /// No description provided for @phosphorusDescLong.
  ///
  /// In en, this message translates to:
  /// **'Component of ATP and DNA. Very poorly mobile.'**
  String get phosphorusDescLong;

  /// No description provided for @potassiumTitleLong.
  ///
  /// In en, this message translates to:
  /// **'POTASSIUM (K)'**
  String get potassiumTitleLong;

  /// No description provided for @potassiumDescLong.
  ///
  /// In en, this message translates to:
  /// **'Regulates stomatal opening and water balance.'**
  String get potassiumDescLong;

  /// No description provided for @nutrientTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'NUTRIENT: {symbol}'**
  String nutrientTitlePrefix(String symbol);

  /// No description provided for @biochemistryDesc.
  ///
  /// In en, this message translates to:
  /// **'Important factor in soil biochemistry.'**
  String get biochemistryDesc;

  /// No description provided for @potassiumLabel.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get potassiumLabel;

  /// No description provided for @dynamicsLabel.
  ///
  /// In en, this message translates to:
  /// **'Dynamics'**
  String get dynamicsLabel;

  /// No description provided for @optimalLabel.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get optimalLabel;

  /// No description provided for @significanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Significance'**
  String get significanceLabel;

  /// No description provided for @riskLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get riskLabel;

  /// No description provided for @apicalMeristem.
  ///
  /// In en, this message translates to:
  /// **'APICAL MERISTEM'**
  String get apicalMeristem;

  /// No description provided for @meristemDesc.
  ///
  /// In en, this message translates to:
  /// **'Primary growth zone driven by continuous cell division.'**
  String get meristemDesc;

  /// No description provided for @tissueLabel.
  ///
  /// In en, this message translates to:
  /// **'Tissue'**
  String get tissueLabel;

  /// No description provided for @meristematic.
  ///
  /// In en, this message translates to:
  /// **'Meristematic'**
  String get meristematic;

  /// No description provided for @undifferentiated.
  ///
  /// In en, this message translates to:
  /// **'Undifferentiated'**
  String get undifferentiated;

  /// No description provided for @rateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateLabel;

  /// No description provided for @turgorLabel.
  ///
  /// In en, this message translates to:
  /// **'Turgor'**
  String get turgorLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @microbialBiomassLabel.
  ///
  /// In en, this message translates to:
  /// **'Microbial Biomass'**
  String get microbialBiomassLabel;

  /// No description provided for @bioActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio-Activity'**
  String get bioActivityLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @clayFractionLabel.
  ///
  /// In en, this message translates to:
  /// **'Clay Fraction'**
  String get clayFractionLabel;

  /// No description provided for @nitrogenCycle.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen Cycle'**
  String get nitrogenCycle;

  /// No description provided for @flows.
  ///
  /// In en, this message translates to:
  /// **'Flows'**
  String get flows;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modify;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @turnOffMicroscope.
  ///
  /// In en, this message translates to:
  /// **'Turn off microscope'**
  String get turnOffMicroscope;

  /// No description provided for @stem.
  ///
  /// In en, this message translates to:
  /// **'Stem'**
  String get stem;

  /// No description provided for @hydrogen.
  ///
  /// In en, this message translates to:
  /// **'Hydrogen'**
  String get hydrogen;

  /// No description provided for @sulfur.
  ///
  /// In en, this message translates to:
  /// **'Sulfur'**
  String get sulfur;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fi': return AppLocalizationsFi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
