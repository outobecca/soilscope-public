// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'SoilScope';

  @override
  String get soilStructure => 'Maan rakenne';

  @override
  String get bioActivity => 'Bio-aktiivisuus';

  @override
  String get leachingRisk => 'Huuhtoutumisriski';

  @override
  String plantTurgor(String percentage) {
    return 'Kasvin turgor: $percentage%';
  }

  @override
  String timeElapsed(String hours) {
    return 'Aika: ${hours}h';
  }

  @override
  String get tillage => 'Muokkaus';

  @override
  String get irrigate => 'Kastelu';

  @override
  String get fertilize => 'Lannoitus';

  @override
  String analysisTitle(String id) {
    return 'Kerros $id Analyysi';
  }

  @override
  String get depth => 'Syvyys';

  @override
  String get waterContent => 'Vesipitoisuus';

  @override
  String get temperature => 'Lämpötila';

  @override
  String get ph => 'pH';

  @override
  String get ec => 'Johtokyky (EC)';

  @override
  String get redoxPotential => 'Redox (Eh)';

  @override
  String get nitrate => 'Nitraatti';

  @override
  String get phosphate => 'Fosfaatti';

  @override
  String get microbialBiomass => 'Mikrobien biomassa';

  @override
  String get oxygen => 'Happi (O2)';

  @override
  String get co2 => 'Hiilidioksidi (CO2)';

  @override
  String get soilRespiration => 'Maan hengitys';

  @override
  String get soilEvaporation => 'Maaperän haihdunta';

  @override
  String get redoxPotentialTitle => 'Hapetus-pelkistyspotentiaali (Eh)';

  @override
  String get phLabel => 'Happamuus / pH';

  @override
  String get phDescription => 'Maaliuoksen happamuuden tai emäksisyyden mitta.';

  @override
  String get biophysicsInsights => 'Biofysikaaliset havainnot:';

  @override
  String get anaerobicWarning => 'Hapettomat olosuhteet havaittu. Denitrifikaatioriski.';

  @override
  String get aerobicStatus => 'Aerobiset olosuhteet. Terve mikrobitoiminta.';

  @override
  String get tillageSuccess => 'Muokkaus suoritettu! Maan rakenne kuohkeutui.';

  @override
  String get tillageFailure => 'KRIITTISTÄ: Märän maan muokkaus romutti rakenteen!';

  @override
  String get irrigatingField => 'Kastellaan peltoa...';

  @override
  String get fertilizerSuccess => 'Typpeä ja fosforia lisätty pintaan.';

  @override
  String get selectScenario => 'Valitse skenaario';

  @override
  String get startSimulation => 'Aloita simulaatio';

  @override
  String get compactedClayTitle => 'Tiivistynyt savi -haaste';

  @override
  String get compactedClayDesc => 'Paranna maan rakennetta muokkauksella ja biologialla.';

  @override
  String get nitrateLeachingTitle => 'Typen huuhtoutumiskriisi';

  @override
  String get nitrateLeachingDesc => 'Hallitse ravinteita rankkasateiden aikana.';

  @override
  String get nitrogenLockTitle => 'Typpilukko-haaste';

  @override
  String get nitrogenLockDesc => 'Lisäsit liikaa olkea (korkea C/N). Pelasta sato!';

  @override
  String get simulationSettings => 'Simulaation asetukset';

  @override
  String get language => 'Kieli';

  @override
  String get english => 'Englanti';

  @override
  String get finnish => 'Suomi';

  @override
  String get nanovisionHint => 'Napauta maakerroksia aktivoidaksesi Nanovision-analyysin';

  @override
  String get play => 'Toista';

  @override
  String get pause => 'Tauko';

  @override
  String get logicLab => 'Logiikkalabra';

  @override
  String get science => 'Tiede';

  @override
  String get showFormulas => 'Näytä kaavat';

  @override
  String get saveScenario => 'Tallenna skenaario';

  @override
  String get copyToClipboard => 'JSON kopioitu leikepöydälle!';

  @override
  String get scenarioTitle => 'Oma skenaario';

  @override
  String get importScenario => 'Tuo leikepöydältä';

  @override
  String get importFromClipboardDesc => 'Lataa skenaario-JSON leikepöydältäsi.';

  @override
  String get clipboardEmpty => 'Leikepöytä on tyhjä. Kopioi skenaario-JSON ensin.';

  @override
  String get importSuccess => 'Skenaario tuotu onnistuneesti!';

  @override
  String get importError => 'Virheellinen JSON-muoto.';

  @override
  String get quickActions => 'Pikatoiminnot';

  @override
  String get scenarioLibrary => 'Skenaariokirjasto';

  @override
  String get noScenariosAvailable => 'Ei skenaarioita saatavilla juuri nyt.';

  @override
  String get resumeLastSession => 'Jatka edellistä istuntoa';

  @override
  String get resumeLastSessionDesc => 'Jatka siitä mihin jäit edellisessä maaperän ja kasvin tilassa.';

  @override
  String get noSavedSession => 'Ei tallennettua istuntoa löytynyt.';

  @override
  String get resumeFailed => 'Istunnon palauttaminen epäonnistui.';

  @override
  String get openScenario => 'Avaa';

  @override
  String get teacherMode => 'Opettajatila';

  @override
  String get heatWave => 'Helleaalto';

  @override
  String get flashFlood => 'Salaman tulva';

  @override
  String get frost => 'Halla';

  @override
  String get pestOutbreak => 'Tuholaisepidemia';

  @override
  String get soilCompaction => 'Raskaan koneistuksen tiivistyminen';

  @override
  String get surfaceErosion => 'Voimakas eroosio';

  @override
  String get aiAdvisor => 'AI-neuvonantaja';

  @override
  String get topRecommendation => 'Strateginen neuvo';

  @override
  String confidence(String value) {
    return 'Luottamus: $value%';
  }

  @override
  String get rationale => 'Perustelu';

  @override
  String get coverCrop => 'Kerääjäkasvi';

  @override
  String get coverCropAlreadyActive => 'Kerääjäkasvi on jo aktiivinen.';

  @override
  String get coverCropApplied => 'Kerääjäkasvi kylvetty. Pintasuojaus parantunut.';

  @override
  String get irrigationStopped => 'Kastelu lopetettu.';

  @override
  String get autoWeather => 'Automaattinen Sää';

  @override
  String get dynamicWeatherOn => 'Dynaaminen sää käytössä.';

  @override
  String get dynamicWeatherOff => 'Dynaaminen sää pois käytöstä.';

  @override
  String get drain => 'Salaojitus';

  @override
  String get drainageOpened => 'Salaojat avattu. Pinta kuivuu.';

  @override
  String get analytics => 'Analytiikka';

  @override
  String get researchDashboard => 'Tutkimuspaneeli';

  @override
  String get menu => 'Valikko';

  @override
  String get controls => 'Ohjaimet';

  @override
  String get lightMode => 'Vaalea';

  @override
  String get darkMode => 'Tumma';

  @override
  String get microscope => 'Mikroskooppi';

  @override
  String get controlPanel => 'Ohjauspaneeli';

  @override
  String get returnToMenuTitle => 'Palaa valikkoon?';

  @override
  String get returnToMenuMessage => 'Simulaatio keskeytetään ja nykyinen tila tallennetaan.';

  @override
  String get cancelAction => 'Peruuta';

  @override
  String get returnToMenuAction => 'Palaa';

  @override
  String speed(String value) {
    return 'Nopeus: ${value}x';
  }

  @override
  String get atmosphere => 'Ilmakehä';

  @override
  String get systemHealth => 'Järjestelmän terveys';

  @override
  String get productivity => 'Tuottavuus';

  @override
  String get carbonSink => 'Hiilinielu';

  @override
  String get biodiversity => 'Luonnon monimuotoisuus';

  @override
  String get impact => 'Vaikutus';

  @override
  String get reward => 'Palkkio';

  @override
  String get index => 'Indeksi';

  @override
  String get dashboard => 'Kojelauta';

  @override
  String get hideSidebar => 'Piilota sivupalkki';

  @override
  String get showSidebar => 'Näytä sivupalkki';

  @override
  String get scienceReference => 'Tiedeviite';

  @override
  String get fullScienceReference => 'Koko tiedeviite';

  @override
  String get selectLayerToView => 'Valitse maakerros nähdäksesi analyysin';

  @override
  String get sand => 'Hieta ja hiekka';

  @override
  String get silt => 'Hiesu';

  @override
  String get clay => 'Savi';

  @override
  String get water => 'Vesi';

  @override
  String get root => 'Juuri';

  @override
  String get leaf => 'Lehti';

  @override
  String get vaporPressureDeficit => 'Höyrynpainealijäämä (VPD)';

  @override
  String get relativeHumidity => 'Suhteellinen kosteus';

  @override
  String get selectElementRole => 'Valitse elementti nähdäksesi sen roolin ekosysteemissä';

  @override
  String concentration(String id) {
    return 'Pitoisuus ($id)';
  }

  @override
  String get semanticZoomLevels => 'Semanttiset zoom-tasot';

  @override
  String get macroZoomTitle => '1.0x - 2.0x (Makro)';

  @override
  String get macroZoomDesc => 'Yleisnäkymä maisemaan. Korostaa maaperän kosteustasoja ja kerrosrajoja.';

  @override
  String get mesoZoomTitle => '2.0x - 4.0x (Meso)';

  @override
  String get mesoZoomDesc => 'Paljastaa rakenteelliset yksityiskohdat, kuten halkeamat, sieniverkostot ja veden liikkeen.';

  @override
  String get microZoomTitle => '4.0x - 5.5x (Mikro)';

  @override
  String get microZoomDesc => 'Näkyvät mikrobit, juurikarvat ja kaasukuplat (CO2/N2O). Näyttää lämpövirran.';

  @override
  String get nanoZoomTitle => '5.5x+ (Nano)';

  @override
  String get nanoZoomDesc => 'Syväsukellus ioneihin (N, P, K), huokosväleihin ja reaaliaikaiseen metaboliseen laskentaan.';

  @override
  String get soilStructureTexture => 'Maaperän rakenne ja tekstuuri';

  @override
  String get aggregates => 'Aggregaatit';

  @override
  String get aggregatesDesc => 'Maapartikkelien klusterit (muruset). Näkyvissä vain vakaassa maaperässä.';

  @override
  String get sandGrains => 'Hiekanjyvät';

  @override
  String get sandGrainsDesc => 'Terävät, kiteiset partikkelit. Suuret välit sallivat veden nopean liikkeen.';

  @override
  String get waterFlux => 'Veden virtaus';

  @override
  String get waterFluxDesc => 'Ylöspäin osoittavat nuolet kuvaavat kapillaarista nousua, alaspäin suodatusta.';

  @override
  String get plantInteractions => 'Kasvien vuorovaikutus';

  @override
  String get rhizosphere => 'Ritsosfääri';

  @override
  String get rhizosphereDesc => 'Biologinen hotspot juurten ympärillä, missä eritteet ruokkivat hyperaktiivista mikrobielämää.';

  @override
  String get rootExudates => 'Juurieritteet';

  @override
  String get rootExudatesDesc => 'Hiiltä, joka vuotaa juurista mikrobien ravinnoksi. Visualisoitu vihreänä hehkuna.';

  @override
  String get transpiration => 'Transpiraatio';

  @override
  String get transpirationDesc => 'Nousevat siniset hiukkaset varressa kuvaavat aktiivista veden kuljetusta maasta ilmaan.';

  @override
  String get hiddenGasCycles => 'Piilotetut kaasukierrot';

  @override
  String get boundaryFlux => 'Rajapinnan fluksi';

  @override
  String get boundaryFluxDesc => 'Vesihöyry ja CO2 nousevat pinnasta; happi laskeutuu maaperään.';

  @override
  String get co2Bubbles => 'CO₂-kuplat';

  @override
  String get co2BubblesDesc => 'Terveen hengityksen sivutuote. Nousee nopeammin, kun mikrobit ovat lämpimiä.';

  @override
  String get hiddenChemicalDynamics => 'Piilotettu kemiallinen dynamiikka';

  @override
  String get cecSnapping => 'CEC-kiinnittyminen';

  @override
  String get cecSnappingDesc => 'Ionit (N, P, K), jotka tarttuvat savipartikkelien vaihtopaikoille tai vapautuvat niistä.';

  @override
  String get cationExchange => 'Kationinvaihto';

  @override
  String get cationExchangeDesc => 'K+, Ca²+ ja Mg²+ kilpaileva adsorptio savipinnoille. Korkea CEC sallii paremman ravinteiden pidättymisen.';

  @override
  String get elementToxicity => 'Alkuainemyrkyllisyys';

  @override
  String get elementToxicityDesc => 'Korkea alumiini (Al) alhaisessa pH:ssa (<5.5) tai korkea natrium (Na) estää juurten kasvua.';

  @override
  String get phEmergence => 'pH:n muodostuminen';

  @override
  String get phEmergenceDesc => 'Lasketaan dynaamisesti emässaturaation (Ca/Mg/K-tasapaino) ja hengityksen CO2-happamoitumisen perusteella.';

  @override
  String get atmosphereDesc => 'Live-sääolosuhteet, jotka ohjaavat evapotranspiraatiota ja infiltraatiota.';

  @override
  String get plantCanopy => 'Kasvusto';

  @override
  String get plantCanopyDesc => 'Kasvin elinvoima ja juurten hakeutumisvaste nykyisissä maaperäoloissa.';

  @override
  String get layerAnalysisDesc => 'Kontekstuaalinen kerrosdiagnostiikka osoittimen kohdalla (ei vaadi paneelien avaamista).';

  @override
  String get vpd => 'VPD';

  @override
  String get rain => 'Sade';

  @override
  String get turgor => 'Turgor';

  @override
  String get height => 'Korkeus';

  @override
  String get lai => 'LAI';

  @override
  String get rootNodes => 'Juurisolmut';

  @override
  String get saturation => 'Kyllästysaste';

  @override
  String get porosity => 'Huokoisuus';

  @override
  String get cracks => 'Halkeamat';

  @override
  String get microbes => 'Mikrobit';

  @override
  String get gasBubbles => 'Kaasukuplat';

  @override
  String get ions => 'Ionit';

  @override
  String get cecSites => 'Kationinvaihtopaikat';

  @override
  String get visualKey => 'SELITE';

  @override
  String get systemAdvisor => 'Järjestelmän neuvonantaja';

  @override
  String confidenceLabel(String value) {
    return '$value% Luottamus';
  }

  @override
  String get fieldDiagnostics => 'Kenttädiagnostiikka';

  @override
  String get redoxEh => 'Redox (Eh)';

  @override
  String get oxygenLabel => 'Happi';

  @override
  String get phLevel => 'pH-taso';

  @override
  String get atmosphereLabel => 'Ilmakehä:';

  @override
  String get co2Label => 'CO2';

  @override
  String get vpdLabel => 'VPD (Höyrynpaine-alijäämä)';

  @override
  String get physical => 'Fysikaalinen';

  @override
  String get chemical => 'Kemiallinen';

  @override
  String get biological => 'Biologinen';

  @override
  String get ammonium => 'Ammonium (NH₄)';

  @override
  String get organicN => 'Org. typpi (POM)';

  @override
  String get organicCarbon => 'Org. hiili';

  @override
  String get denitrification => 'Denitrifikaatio';

  @override
  String get mechanical => 'Mekaaninen';

  @override
  String get fungalHyphae => 'Sienirihmasto';

  @override
  String get bioGlue => 'Bio-liima (EPS)';

  @override
  String get structureHP => 'Rakenteen kestävyys';

  @override
  String get fragile => 'Hauras';

  @override
  String get resilient => 'Kestävä';

  @override
  String stabilityLabel(String value) {
    return '$value% Vakaus';
  }

  @override
  String get physicsOverride => 'Fysiikan ohitus';

  @override
  String get constituents => 'Ainesosat';

  @override
  String get microbialEngines => 'Mikrobimoottorit';

  @override
  String get liveCalculations => 'Live-laskenta';

  @override
  String get tempFactor => 'Lämpökerroin (Q10)';

  @override
  String get metabolicMultiplier => 'Metabolinen kerroin';

  @override
  String get waterLimitation => 'Vesirajoite';

  @override
  String get hydraulicConnectivity => 'Hydraulinen jatkuvuus';

  @override
  String get o2Availability => 'Hapen saatavuus';

  @override
  String get aerobicRespirationPotential => 'Aerobisen hengityksen potentiaali';

  @override
  String get bioChemicalRates => 'Biokemialliset nopeudet';

  @override
  String get co2ProductionRate => 'CO₂-tuotantonopeus';

  @override
  String get nNitrification => 'N-nitrifikaatio';

  @override
  String get transformationDesc => 'NH₄⁺ ➔ NO₃⁻ transformaatio';

  @override
  String get denitrificationDesc => 'Nitraatin pelkistyminen kaasumaiseksi typeksi (N₂O, N₂) hapettomissa olosuhteissa.';

  @override
  String get active => 'Aktiivinen';

  @override
  String get inhibited => 'Estynyt';

  @override
  String get zoomNote => 'HUOM: Zoomaa lähemmäs nähdäksesi yksittäiset bakteeripesäkkeet ja sienirihmastot.';

  @override
  String get metabolicFlux => 'Metabolinen fluksi';

  @override
  String get causalPathways => 'Kausaliteettiväylät';

  @override
  String get oxygenRedoxEh => 'Happi ➔ Redox (Eh)';

  @override
  String get hypoxiaDesc => 'Hapenpuute laukaisee elektronivastaanottajien vaihdon.';

  @override
  String get ehDenitrification => 'Eh ➔ Denitrifikaatio';

  @override
  String get denitLowRedoxDesc => 'Matala redox-potentiaali ajaa nitraatin pelkistymistä kaasuksi.';

  @override
  String get phPLock => 'pH ➔ P-lukko';

  @override
  String get pFixationDesc => 'Fosforin sitoutuminen mineraaleihin happamuuden perusteella.';

  @override
  String get activeFormulas => 'Aktiiviset kaavat (Reaaliaikainen)';

  @override
  String get vanGenuchtenTitle => 'van Genuchten (Vesi)';

  @override
  String get vanGenuchtenDesc => 'Määrittää, kuinka paljon vettä maa pidättää tietyllä imulla.';

  @override
  String get millingtonQuirkTitle => 'Millington-Quirk (Kaasu)';

  @override
  String get millingtonQuirkDesc => 'Laskee kaasun diffuusion ilmalla täyttyneessä huokostilassa.';

  @override
  String get nutrientApplicationConsole => 'Ravinnelisäyspaneeli';

  @override
  String get applyAll => 'Lisää kaikki';

  @override
  String nutrientsAppliedSnackBar(int count) {
    return 'Lisätty $count ravinnetta maan pinnalle.';
  }

  @override
  String get selectNutrients => 'Valitse ravinteet';

  @override
  String get fertilizationMixHint => 'Napauta alkuaineita lisätäksesi ne lannoitusseokseen.';

  @override
  String get noNutrientsSelected => 'Ei ravinteita valittuna';

  @override
  String get adjustAmountHint => 'Valitse alkuaineet jaksollisesta järjestelmästä säätääksesi määriä.';

  @override
  String get applicationMix => 'Lannoitusseos';

  @override
  String totalElements(int count) {
    return 'Alkuaineita yhteensä: $count';
  }

  @override
  String get clearMix => 'Tyhjennä seos';

  @override
  String get fieldMetrics => 'Kenttämittaukset';

  @override
  String get historyMode => 'Historiatila';

  @override
  String get timeline => 'Aikajana';

  @override
  String dayLabel(int value) {
    return 'Päivä $value';
  }

  @override
  String get atmosphereSimulator => 'Maaperä-Kasvi-Ilmakehä Simulaattori';

  @override
  String errorLoadingScenarios(String error) {
    return 'Virhe ladattaessa skenaarioita: $error';
  }

  @override
  String objectivesCount(int count) {
    return '$count Tavoitetta';
  }

  @override
  String get elements => 'Alkuaineet';

  @override
  String get depthProfiles => 'Syvyysprofiilit';

  @override
  String get selectElementDetails => 'Valitse alkuaine nähdäksesi tiedot';

  @override
  String get atomicMass => 'Atomimassa';

  @override
  String get soilTextureClassification => 'Maalajin luokitus';

  @override
  String get textureInteractiveHint => 'Interaktiivinen: Kokeile eri koostumuksia nähdäksesi parametrit';

  @override
  String get usdaTextureClass => 'USDA-maalaji';

  @override
  String get sandFraction => 'Hiekan osuus';

  @override
  String get siltFraction => 'Hiesun osuus';

  @override
  String get clayFraction => 'Saven osuus';

  @override
  String get hydraulicParameters => 'Hydrauliset parametrit';

  @override
  String get satConductivity => 'Kyllästynyt johtavuus (Ksat)';

  @override
  String get satWaterContent => 'Kyllästynyt vesipitoisuus (θs)';

  @override
  String get vgAlphaLabel => 'VG Alpha (α)';

  @override
  String get vgNLabel => 'VG n';

  @override
  String get resetToActiveLayer => 'Palauta aktiivinen kerros';

  @override
  String get mollierChartTitle => 'Psykrometrinen (Mollier) kaavio';

  @override
  String get mollierInteractiveHint => 'Interaktiivinen: Tutki T/RH-suhdetta ja haihdutusvoimaa (VPD)';

  @override
  String get dryingPower => 'Haihdutusvoima';

  @override
  String get airTemperature => 'Ilman lämpötila';

  @override
  String get roleInEcosystem => 'Rooli ekosysteemissä';

  @override
  String get resetToLiveWeather => 'Palauta vallitseva sää';

  @override
  String get lowVpd => 'MATALA (Heikko haihdunta)';

  @override
  String get optimalVpd => 'OPTIMAALINEN (Ihanteellinen kasvu)';

  @override
  String get highVpd => 'KORKEA (Ilmarakojen sulkeutumisriski)';

  @override
  String get criticalVpd => 'KRIITTINEN (Voimakas lakastuminen)';

  @override
  String get satVaporPressure => 'Kyllästyshöyrynpaine';

  @override
  String get vpdSeverity => 'VPD-vakavuus';

  @override
  String get soilDepthProfiles => 'Maaperän syvyysprofiilit';

  @override
  String get depthProfilesDesc => 'Fysikaalisten ja kemiallisten gradienttien visualisointi maaprofiilissa.';

  @override
  String get scientificAnalyticsTitle => 'Tieteellinen analytiikka ja hallinta';

  @override
  String get eventLog => 'Tapahtumaloki';

  @override
  String get clearLog => 'Tyhjennä loki';

  @override
  String get objectiveProduceBiomass => 'Tuota biomassaa';

  @override
  String get objectiveRestoreHealth => 'Palauta maan terveys';

  @override
  String get objectivePreventLeaching => 'Estä huuhtoutuminen';

  @override
  String get objectiveReachYield => 'Saavuta satotavoite';

  @override
  String get objectiveUnlockNitrogen => 'Vapauta typpi';

  @override
  String get objectiveCropVitality => 'Paranna kasvuston elinvoimaa';

  @override
  String get bulkDensity => 'Irtotiheys';

  @override
  String get insight_droughtStress => 'Kuivuusstressi: Matala vesipotentiaali laskee turgoria ja pysäyttää solukasvun (Lockhartin laki).';

  @override
  String get insight_vigorousGrowth => 'Voimakas kasvu: Optimaalinen turgor ja ravinteet maksimoivat biomassan kertymän.';

  @override
  String insight_chainReaction(String minEh) {
    return 'Ketjureaktio: Kyllästyminen -> Hapenpuute -> Redox-pudotus ($minEh mV) -> Denitrifikaatio hukkaa typpeä.';
  }

  @override
  String insight_phosphateLockup(String ph, String reason) {
    return 'Fosfaattilukko: Äärimmäinen pH ($ph) saa fosforin sitoutumaan $reason, vähentäen saatavuutta.';
  }

  @override
  String get insight_leachingAlert => 'Huuhtoutumisvaroitus: Nitraatti vaeltaa juuriston alapuolelle voimakkaan alaspäin suuntautuvan virtauksen vuoksi.';

  @override
  String get insight_nitrogenLock => 'Typpilukko: Orgaanisen aineksen korkea C/N-suhde saa mikrobit sitomaan mineraalityppeä, jolloin kasvi kärsii puutteesta.';

  @override
  String get insight_thermalInertia => 'Lämpöinertia: Märällä maalla on korkeampi lämpökapasiteetti ja matalampi albedo, mikä johtaa hitaaseen lämpenemiseen.';

  @override
  String get insight_lowAlbedo => 'Matala albedo: Tumma pinta (kosteus tai kate) imee enemmän aurinkosäteilyä, lisäten pintaenergiaa.';

  @override
  String get insight_radiativeCooling => 'Säteilyjäähtyminen: Maa lähettää pitkäaaltoista säteilyä (Stefan-Boltzmann), mutta pidättää lämpöä ilmaa paremmin.';

  @override
  String get insight_hungryMicrobes => 'Nälkäiset mikrobit: Korkea biomassa, mutta vähän POM! Mikrobit mineralisoivat orgaanista ainesta nopeasti.';

  @override
  String get insight_bioGlueActive => 'Bio-liima: Korkea EPS-taso stabiloi aggregaatteja, parantaen maan rakennetta ja kestävyyttä.';

  @override
  String get insight_activeCycling => 'Aktiivinen kierto: Terve mikrobisto pilkkoo aktiivisesti orgaanista typpeä (Schimel & Bennettin laki).';

  @override
  String get insight_physicalBarrier => 'Fysikaalinen este: Pinnan tiivistyminen aiheuttaa lammikoitumista ja rajoittaa veden imeytymistä syvälle.';

  @override
  String insight_runoffRisk(String rain, String capacity) {
    return 'Valuntariski: Sateen intensiteetti ($rain mm/h) ylittää pinnan imeytymiskyvyn ($capacity mm/h), johtaen pintavaluntaan.';
  }

  @override
  String get insight_surfaceSealing => 'Pinnan kuorettuminen: Matala aggregaattien vakaus saa pinnan liettymään, vähentäen imeytymistä 90 %.';

  @override
  String get insight_bioArmor => 'Bio-panssari: Kerääjäkasvi suojaa pintaa sateen vaikutuksilta ja parantaa rakenteellista terveyttä.';

  @override
  String get insight_structureCrisis => 'Rakennekriisi: Matala aggregaattien vakaus! Maa on altis eroosiolle ja tiivistymiselle. Lisää orgaanista ainesta.';

  @override
  String get insight_resilientStructure => 'Kestävä rakenne: Vahva aggregaattien vakaus suojaa huokostilaa ja maksimoi veden imeytymisen.';

  @override
  String get insight_biologicalDesert => 'Biologinen autiomaa: Erittäin matala mikrobien biomassa. Ravinteiden kierto on pysähtynyt. Lisää hiiltä (POM).';

  @override
  String get insight_metabolicStress => 'Metabolinen stressi: Suuri mikrobipopulaatio, mutta vähän happea! Mikrobit vaihtavat anaerobisiin reitteihin.';

  @override
  String get insight_tillageTradeoff => 'Muokkauksen vaihtokauppa: Parempi ilmanvaihto ja johtavuus, mutta sieniverkostot ovat vaurioituneet.';

  @override
  String get process => 'Prosessi';

  @override
  String get source => 'Lähde';

  @override
  String get significance => 'Merkitys';

  @override
  String get risk => 'Riski';

  @override
  String get mobility => 'Liikkuvuus';

  @override
  String get uptake => 'Otto';

  @override
  String get type => 'Tyyppi';

  @override
  String get deficiencySymptom => 'Puutosoire';

  @override
  String get feature => 'Erikoispiirre';

  @override
  String get role => 'Rooli';

  @override
  String get climateImpact => 'Ilmastovaikutus';

  @override
  String get consequence => 'Seuraus';

  @override
  String get helper => 'Auttaja';

  @override
  String get catalyst => 'Katalyytti';

  @override
  String get mechanism => 'Mekanismi';

  @override
  String get importance => 'Tärkeys';

  @override
  String get nutrient => 'Ravintoaine';

  @override
  String get measurement => 'mittaus';

  @override
  String get availableNutrient => 'Kasville käyttökelpoinen';

  @override
  String get limiter => 'Rajoite';

  @override
  String get location => 'Sijainti';

  @override
  String get upward => 'Ylöspäin';

  @override
  String get intoRoot => 'Juureen';

  @override
  String get intoLeaves => 'Lehtiin';

  @override
  String get aerobicRespiration => 'Aerobinen hengitys';

  @override
  String get anaerobicDenitrification => 'Anaerobinen denitrifikaatio';

  @override
  String get denitrifiers => 'Denitrifikaatiobakteerit';

  @override
  String get bioturbation => 'Bioturbaatio';

  @override
  String get improvedInfiltration => 'Parempi infiltraatio';

  @override
  String get nutrientCycling => 'Ravinteiden kierto';

  @override
  String get organicMatterMixing => 'Orgaanisen aineen sekoittuminen';

  @override
  String get veryGood => 'Erittäin hyvä';

  @override
  String get veryWeak => 'Erittäin heikko';

  @override
  String get moderate => 'Kohtalainen';

  @override
  String get slow => 'Hidas';

  @override
  String get activeTransport => 'Aktiivinen kuljetus';

  @override
  String get solubleNutrient => 'Liukoinen ravinne';

  @override
  String get solubleNutrientDesc => 'Maaliuokseen liuennut ravinne. Ionit liikkuvat juurten lähelle diffuusion ja massavirtauksen avulla.';

  @override
  String get streptomyces => 'Sädesienet';

  @override
  String get decompositionCapacity => 'Hajotuskapasiteetti';

  @override
  String get resistantCompounds => 'Vaikeasti hajoavat yhdisteet';

  @override
  String get photosynthateDistribution => 'Yhteyttämistuotteiden jako';

  @override
  String get microbialEnergySource => 'Mikrobien energianlähde';

  @override
  String get leachingAfterRain => 'Huuhtoutuminen sateen jälkeen';

  @override
  String get leafMarginBurn => 'Lehden reunojen polte';

  @override
  String get noRedistribution => 'Ei uudelleenkuljetusta';

  @override
  String get chlorophyllCenter => 'Klorofyllin keskus';

  @override
  String get oldLeafChlorosis => 'Vanhojen lehtien kloroosi';

  @override
  String get anaerobiosisWaterlogging => 'Anaerobioosi märkyydessä';

  @override
  String get microbialRespiration => 'Mikrobihengitys';

  @override
  String get soilBiologicalActivity => 'Maan biologinen aktiivisuus';

  @override
  String get greenhouseGasEmissions => 'Kasvihuonekaasupäästöt';

  @override
  String get highAfterRain => 'Korkea sateen jälkeen';

  @override
  String get groundwaterContamination => 'Pohjaveden saastuminen';

  @override
  String get generalChlorosis => 'Yleinen kloroosi';

  @override
  String get mycorrhizae => 'Mykoritsat';

  @override
  String get nutrientBank => 'Ravinnepankki';

  @override
  String get heterotrophicMicrobes => 'Heterotrofiset mikrobit';

  @override
  String get electrostaticBinding => 'Sähköstaattinen sitoutuminen';

  @override
  String get preventsLeaching => 'Estää huuhtoutumista';

  @override
  String get nutrientRelease => 'Ravinteiden vapautuminen';

  @override
  String get especiallyPAndK => 'Erityisesti P ja K';

  @override
  String get soilMoisture => 'Maan kosteus';

  @override
  String get biogeochemical => 'Biogeokemiallinen';

  @override
  String get soilProfile => 'Maaprofiili';

  @override
  String get organicHorizon => 'Orgaaninen';

  @override
  String get topsoilHorizon => 'Ruokamulta';

  @override
  String get subsoilHorizon => 'Jankko';

  @override
  String get parentMaterialHorizon => 'Pohjamaa';

  @override
  String get bedrockHorizon => 'Kallio';

  @override
  String get cuticle => 'Vahakerros';

  @override
  String get palisade => 'Pylväsolukko';

  @override
  String get vein => 'Lehtisuoni';

  @override
  String get stoma => 'Ilmarako';

  @override
  String get epidermis => 'Päällysketto';

  @override
  String get phloem => 'Nila';

  @override
  String get cambium => 'Jälsi';

  @override
  String get xylem => 'XYLEEMI';

  @override
  String get rootHair => 'Juurikarva';

  @override
  String get cortex => 'Kuorisolukko';

  @override
  String get casparianStrip => 'Casparyn vyö';

  @override
  String get exudates => 'Eritteet';

  @override
  String get flagella => 'Värekarvat';

  @override
  String get cellWall => 'Soluseinä';

  @override
  String get dna => 'DNA';

  @override
  String get enzymes => 'Entsyymit';

  @override
  String get stemCrossSection => 'Varren poikkileikkaus';

  @override
  String get rootTissue => 'Juuren solukko';

  @override
  String get microbialCell => 'Mikrobisolu';

  @override
  String get simulationStatus => 'Tila';

  @override
  String get runningStatus => 'Käynnissä';

  @override
  String get pausedStatus => 'Tauolla';

  @override
  String get iteration => 'Iteraatio';

  @override
  String get deltaT => 'Aika-askel';

  @override
  String get modules => 'Moduulit';

  @override
  String get noEvents => 'Ei tapahtumia';

  @override
  String get heightLabel => 'Korkeus';

  @override
  String get laiLabel => 'LAI';

  @override
  String get turgorPressure => 'Turgorpaine';

  @override
  String get rootNodesLabel => 'Juurisolmut';

  @override
  String get rootDepthLabel => 'Juurisyvyys';

  @override
  String get ionLabel => 'Ioni';

  @override
  String get concentrationLabel => 'Pitoisuus';

  @override
  String get chargeLabel => 'Varaus';

  @override
  String get bindingLabel => 'Sidonta';

  @override
  String get layerLabel => 'Kerros';

  @override
  String get waterBalance => 'Vesitase';

  @override
  String get stomataLabel => 'Ilmaraot';

  @override
  String get structureLabel => 'Rakenne';

  @override
  String get phBuffer => 'pH-puskuri';

  @override
  String get phEffect => 'pH-vaikutus';

  @override
  String get antagonist => 'Antagonisti';

  @override
  String get photosynthesis => 'Fotosynteesi';

  @override
  String get photosynthesisDesc => 'Kasvit muuttavat aurinkoenergiaa, hiilidioksidia ja vettä kemialliseksi energiaksi (sokereiksi). Tämä prosessi on ekosysteemin energiavirran perusta.';

  @override
  String get redistribution => 'Uudelleenkuljetus';

  @override
  String get porosityEffect => 'Huokoisuusvaikutus';

  @override
  String get populationLabel => 'Populaatio';

  @override
  String get gasLabel => 'Kaasu';

  @override
  String get reactionLabel => 'Reaktio';

  @override
  String get stateLabel => 'Tila';

  @override
  String get immobilized => 'Pidättynyt';

  @override
  String get velocityLabel => 'Nopeus';

  @override
  String get climateEffect => 'Ilmastovaikutus';

  @override
  String get airTempLabel => 'Ilman lämpö';

  @override
  String get nitrogenLoss => 'Typpihävikki';

  @override
  String get metabolism => 'Metabolia';

  @override
  String get tempOptimum => 'Lämpöoptimi';

  @override
  String get moistureOptimum => 'Kosteusoptimi';

  @override
  String get specialty => 'Erikoisala';

  @override
  String get carbonStorage => 'Hiilen varastointi';

  @override
  String get oxidationReduction => 'Hapetus-pelkistys';

  @override
  String get organicCarbonLabel => 'Org. hiili';

  @override
  String get microbialMassLabel => 'Mikrobimassa';

  @override
  String get waterStatus => 'Vesitila';

  @override
  String get limited => 'Rajoittunut';

  @override
  String get mildStress => 'Lievä stressi';

  @override
  String get severeStress => 'Voimakas stressi';

  @override
  String get goodWaterStatus => 'Hyvä vesitila';

  @override
  String get xylemLabel => 'Ksyleemi';

  @override
  String get phloemLabel => 'Floeemi';

  @override
  String get waterUp => 'vesi ylös';

  @override
  String get sugarsDown => 'sokerit alas';

  @override
  String get plantDescription => 'Kasvin vesitila riippuu turgorpaineesta, joka ajaa solujen jännitystä ja kasvua. Maan vesipotentiaalin lasku (kuivuus) saa kasvin sulkemaan ilmaraot säästääkseen vettä, mutta samalla fotosynteesi hidastuu. Juuristo etsii aktiivisesti vettä ja ravinteita.';

  @override
  String get earthwormDescription => 'Lierot ovat ekosysteemi-insinöörejä, jotka parantavat maan rakennetta luomalla makrohuokosia (bioturbaatio). Ne sekoittavat orgaanista ainesta kivennäismaahan, parantavat veden imeytymistä ja ilmanvaihtoa. Lieron käytävät toimivat myös juurten väylinä.';

  @override
  String get bubbleCo2Description => 'Maaperän hengitys vapauttaa hiilidioksidia, kun mikrobit ja juuret hajottavat orgaanista ainesta ja tuottavat energiaa. Tämä on merkki terveestä mikrobitoiminnasta. Hengitysnopeus riippuu lämpötilasta, kosteudesta ja C-pitoisuudesta.';

  @override
  String get bubbleN2oDescription => 'Typpioksiduulia vapautuu, kun denitrifikaatiobakteerit pelkistävät nitraattia hapettomissa olosuhteissa. Tätä tapahtuu erityisesti vettyneessä maassa. N2O on voimakas kasvihuonekaasu (298x CO2) - merkki ongelmasta!';

  @override
  String get ionNitrateDescription => 'Negatiivisesti varautunut, erittäin liikkuva typpi-ioni. Nitraatti liikkuu veden mukana ja voi huuhtoutua tai poistua kaasuna.';

  @override
  String get ionPhosphateDescription => 'Negatiivisesti varautunut fosfori-ioni. Välttämätön energialle (ATP), mutta liikkuu maassa erittäin hitaasti vahvan sitoutumisen vuoksi.';

  @override
  String get ionPotassiumDescription => 'Positiivinen ioni, joka säätelee kasvin vesitasapainoa ja ilmarakoja. Pysyy maassa kationinvaihtokapasiteetin (CEC) avulla.';

  @override
  String get ionCalciumDescription => 'Keskeinen soluseinien vakaudelle ja viestinnälle. Liikkuu hitaasti veden virtauksen mukana.';

  @override
  String get ionMagnesiumDescription => 'Lehtivihreämolekyylin keskusosa. Elintärkeä fotosynteesille.';

  @override
  String get bacteriaDescription => 'Maaperän bakteerit ovat nopeimpia hajottajia ja ravinteiden kierron moottoreita. Ne toimivat juurten lähellä (ritsosfääri), hajottavat orgaanista ainesta ja vapauttavat ravinteita kasveille. Nitrifikaatiobakteerit muuttavat ammoniumin nitraatiksi.';

  @override
  String get fungiDescription => 'Sienirihmastot muodostavat maanalaisia verkostoja, jotka kuljettavat vettä ja ravinteita pitkien matkojen päähän. Mykoritsat muodostavat symbioosin kasvien kanssa. Sienet hajottavat vaikeasti hajoavia yhdisteitä, kuten ligniiniä ja selluloosaa.';

  @override
  String get actinomycetesDescription => 'Streptomyces-ryhmän bakteereita, jotka tuottavat antibiootteja ja hajottavat vaikeasti hajoavia yhdisteitä. Ne tuottavat geosmiinia - syy maan tuoksuun. Hitaampia kuin bakteerit, mutta tehokkaampia vaikeiden yhdisteiden pilkkojia.';

  @override
  String get soilTypeLabel => 'Maalaji';

  @override
  String get textureAS => 'Aitosavi (AS)';

  @override
  String get textureHtS => 'Hietasavi (HtS)';

  @override
  String get textureHeS => 'Hiuesavi (HeS)';

  @override
  String get textureHsS => 'Hiesusavi (HsS)';

  @override
  String get textureHt => 'Hieta (Ht)';

  @override
  String get textureHe => 'Hiue (He)';

  @override
  String get textureHs => 'Hiesu (Hs)';

  @override
  String get aerationLabel => 'Ilmanvaihto';

  @override
  String get redoxStateLabel => 'Redox-tila';

  @override
  String get siltyClay => 'Hiesusavi';

  @override
  String get sandyClay => 'Hiekkasavi';

  @override
  String get clayLoam => 'Savimoreeni';

  @override
  String get sandyClayLoam => 'Hiekkasavimoreeni';

  @override
  String get siltyClayLoam => 'Hiesusavimoreeni';

  @override
  String get siltLoam => 'Hiesumoreeni';

  @override
  String get loamySand => 'Hiekkainen multa';

  @override
  String get sandyLoam => 'Hietamoreeni';

  @override
  String get loam => 'Hieta';

  @override
  String get goodAeration => 'Hyvä ilmanvaihto ✓';

  @override
  String get oxygenDeficiency => 'Hapenpuute ⚠️';

  @override
  String get aerobicState => 'Aerobinen';

  @override
  String get anaerobicState => 'Anaerobinen ⚠️';

  @override
  String get sufficientAeration => 'Riittävä ilmanvaihto';

  @override
  String get poorAeration => 'Heikko ilmanvaihto ⚠️';

  @override
  String get variableRedox => 'Vaihteleva redox';

  @override
  String get saturated => 'Märkä';

  @override
  String get dry => 'Kuiva';

  @override
  String get normal => 'Normaali';

  @override
  String get acidic => 'Hapan';

  @override
  String get neutral => 'Neutraali';

  @override
  String get alkaline => 'Emäksinen';

  @override
  String get available => 'Käyttökelpoinen';

  @override
  String get hardToTake => 'Vaikeasti otettava';

  @override
  String get mineralizationTitle => 'Mineralisaatio';

  @override
  String get mineralizationDesc => 'Orgaanisen aineen muuntuminen kasveille käyttökelpoisiksi epäorgaanisiksi ravinteiksi.';

  @override
  String get nitrificationTitle => 'Nitrifikaatio';

  @override
  String get nitrificationDesc => 'Ammoniumtypen muuntuminen nitraatiksi erikoistuneiden bakteerien toimesta.';

  @override
  String get denitrificationTitle => 'Denitrifikaatio';

  @override
  String get adsorptionTitle => 'Adsorptio';

  @override
  String get adsorptionDesc => 'Ravinteiden sitoutuminen maahiukkasten pinnoille (esim. kationinvaihtokapasiteetti CEC).';

  @override
  String get desorptionTitle => 'Desorptio';

  @override
  String get desorptionDesc => 'Sitoutuneet ravinteet vapautuvat takaisin maaliuokseen ionivaihdon kautta.';

  @override
  String get ionNitrateTitle => 'NITRAATTI (NO₃⁻)';

  @override
  String get ionNitrateName => 'Nitraatti';

  @override
  String get ionPhosphateTitle => 'FOSFAATTI (H₂PO₄⁻)';

  @override
  String get ionPhosphateName => 'Fosfaatti';

  @override
  String get ionPotassiumTitle => 'KALIUM (K⁺)';

  @override
  String get ionPotassiumName => 'Kalium';

  @override
  String get ionCalciumTitle => 'KALSIUM (Ca²⁺)';

  @override
  String get ionCalciumName => 'Kalsium';

  @override
  String get ionMagnesiumTitle => 'MAGNESIUM (Mg²⁺)';

  @override
  String get ionMagnesiumName => 'Magnesium';

  @override
  String negativeCharge(String value) {
    return 'Negatiivinen ($value)';
  }

  @override
  String positiveCharge(String value) {
    return 'Positiivinen ($value)';
  }

  @override
  String get leaches => 'Huuhtoutuu';

  @override
  String get diffusionAndMycorrhiza => 'Diffuusio + mykorritsa';

  @override
  String get energy => 'Energia';

  @override
  String get bound => 'Sitoutunut';

  @override
  String get clayMinerals => 'Savimineraalit';

  @override
  String get cellWallSignal => 'Soluseinä, viestintä';

  @override
  String get limingRaisesPH => 'Kalkitus nostaa pH:ta';

  @override
  String get goodRedistribution => 'Hyvä (uudelleensiirto)';

  @override
  String get highK => 'Korkea K⁺';

  @override
  String get diffusionTitle => 'Diffuusio';

  @override
  String get diffusionDesc => 'Ionit liikkuvat pitoisuuseron suuntaan (korkeammasta matalampaan).';

  @override
  String get nutrientUptakeTitle => 'Ravinteiden otto';

  @override
  String get nutrientUptakeDesc => 'Juuret ottavat ravinteita aktiivisella kuljetuksella (vaatii ATP-energiaa) tai passiivisesti.';

  @override
  String get bypassFlowTitle => 'Oikovirtaus';

  @override
  String get bypassFlowDesc => 'Vesi ja liukoiset ravinteet kulkevat nopeasti makrohuokosten (lieronkäytävät, halkeamat) läpi.';

  @override
  String get soilMoistureTitle => 'Maankosteus';

  @override
  String get soilMoistureDesc => 'Voluuminen vesipitoisuus (θ) kertoo, mikä osa maan tilavuudesta on vettä.';

  @override
  String get phTitle => 'pH (Happamuus)';

  @override
  String get phDesc => 'pH mittaa vetyionien (H+) aktiivisuutta. Se vaikuttaa ravinteiden liukoisuuteen ja mikrobitoimintaan.';

  @override
  String get waterPotentialTitle => 'Vesipotentiaali (Ψ)';

  @override
  String get waterPotentialDesc => 'Matricapotentiaali (Ψ) kuvaa voimaa, jolla maa pidättää vettä.';

  @override
  String get dissolvedOxygenTitle => 'Liuennut happi (O2)';

  @override
  String get dissolvedOxygenDesc => 'Juuret ja aerobiset mikrobit tarvitsevat happea soluhengitykseen.';

  @override
  String get nitrogenTitle => 'Typpi (N)';

  @override
  String get nitrogenDesc => 'Tärkein kasvuravinne. Proteiinien, lehtivihreän ja nukleiinihappojen rakennusaine.';

  @override
  String get phosphorusTitle => 'Fosfori (P)';

  @override
  String get phosphorusDesc => 'ATP:n ja DNA:n komponentti. Erittäin heikosti liikkuva - sitoutuu saveen ja rautaoksideihin.';

  @override
  String get potassiumTitle => 'Kalium (K)';

  @override
  String get potassiumDesc => 'Säätelee ilmarakojen avautumista, vesitasapainoa ja entsyymiaktiivisuutta.';

  @override
  String get calciumTitle => 'Kalsium (Ca)';

  @override
  String get calciumDesc => 'Soluseinien pektiinin sidosaine ja viestimolekyyli. Ei liiku kasvissa uudelleen.';

  @override
  String get magnesiumTitle => 'Magnesium (Mg)';

  @override
  String get magnesiumDesc => 'Lehtivihreän keskusatomi - ilman magnesiumia ei ole fotosynteesiä.';

  @override
  String get solarRadiationTitle => 'Aurinkosäteily';

  @override
  String get solarRadiationDesc => 'Valo tarjoaa energian fotosynteesiin. Klorofylli absorboi PAR-säteilyä (400-700 nm).';

  @override
  String get leachingTitle => 'Huuhtoutuminen';

  @override
  String get leachingDesc => 'Ravinteet (erityisesti nitraatti) huuhtoutuvat sadeveden mukana pohjaveteen. Taloudellinen tappio ja ympäristöriski.';

  @override
  String get topsoilDesc => 'Ruokamulta on maan biologisesti aktiivisin kerros. Suurin osa mikrobeista ja maaperäeliöistä elää täällä. Orgaaninen aines hajoaa humukseksi ja ravinteet kiertävät nopeimmin. Juuret ottavat suurimman osan ravinteistaan tästä kerroksesta.';

  @override
  String get subsoilDesc => 'Jankkoon kertyy ylhäältä huuhtoutuneita savi-, rauta- ja alumiinioksideja. Kerros on usein tiiviimpi ja saattaa rajoittaa veden läpäisevyyttä. Juuret tunkeutuvat tänne etsiessään vettä ja ravinteita, mutta biologinen aktiivisuus on vähäisempää.';

  @override
  String get parentMaterialDesc => 'Pohjamaa on vähiten rapautunut maakerros, joka koostuu kallioperästä irronneesta aineksesta. Biologinen aktiivisuus on vähäistä, mutta kerros toimii varastona vedelle ja mineraalien lähteenä pitkällä aikavälillä.';

  @override
  String get genericLayerDesc => 'Tämä maakerros sisältää eri raekokoja ja orgaanista ainesta. Kerroksen ominaisuudet vaikuttavat vedenpidätyskykyyn, ilmanvaihtoon ja juurten kasvuun.';

  @override
  String get organicHorizonDesc => 'Orgaaninen kerros koostuu hajoavasta kasvi- ja eläinaineksesta. Korkea hiilipitoisuus ja biologinen aktiivisuus.';

  @override
  String get bedrockDesc => 'Kallio on kiinteää kiveä, joka sijaitsee maakerrosten alla. Se muodostaa lopullisen rajan juurten kasvulle ja veden liikkeelle.';

  @override
  String get sunIndicatorDesc => 'Aurinkosäteily pinnalla. PAR (400-700 nm) tarjoaa energian fotosynteesiin. Beer-Lambertin laki kuvaa valon imeytymistä kasvuston läpi.';

  @override
  String get totalRadiation => 'Kokonaissäteily';

  @override
  String get parFraction => 'PAR-osuus';

  @override
  String get absorbedPar => 'Absorboitunut PAR';

  @override
  String get transmission => 'Läpäisy';

  @override
  String get formula => 'Kaava';

  @override
  String get routeLabel => 'Reitti';

  @override
  String get forceLabel => 'Voima';

  @override
  String get speedLabel => 'Nopeus';

  @override
  String get leafLabel => 'Lehti';

  @override
  String get tapToSeeDetails => 'Napauta animaation elementtiä nähdäksesi lisätietoja';

  @override
  String get inspection => 'Tarkastelu';

  @override
  String get selected => 'Valittu';

  @override
  String get measurementData => 'Mittaustieto';

  @override
  String get legend => 'Selite';

  @override
  String get fieldCapacity => 'kenttäkapasiteetti';

  @override
  String get longTerm => 'Pitkäaikainen';

  @override
  String get actinomycetesTitle => 'Sädesienet';

  @override
  String get waterUptakeDesc => 'Vesi liikkuu juurista lehtiin pystysuorassa putkistossa (ksyleemi). Imu syntyy haihdunnan kautta ilmarakojen kautta - tätä kutsutaan transpiraatiovirraksi.';

  @override
  String get carbonCycleDesc => 'Yhteyttämistuotteet (sokerit) virtaavat nilassa lehdistä juuriin, tai juuri erittää hiiliyhdisteitä maahan mikrobien ravinnoksi (eritteet).';

  @override
  String get nitrogenUptakeDesc => 'Nitraatti (NO3-) tai ammonium (NH4+) siirtyy maaliuoksesta juureen aktiivisella kuljetuksella. Typpi on kasvun avaintekijä - proteiinien ja lehtivihreän rakennusaine.';

  @override
  String get phosphorusUptakeDesc => 'Fosfaatti (H2PO4-) on heikosti liikkuva ravinne, jota mykoritsat auttavat keräämään. Välttämätön ATP:n ja DNA:n komponentti.';

  @override
  String get potassiumUptakeDesc => 'Kalium (K+) säätelee ilmarakojen avautumista ja kasvin vesitasapainoa. Tärkeä osmoottisen paineen ylläpitäjä.';

  @override
  String get calciumUptakeDesc => 'Kalsium (Ca2+) vahvistaa soluseiniä ja toimii viestimolekyylinä. Se ei liiku kasvissa uudelleen - uudet lehdet tarvitsevat jatkuvaa saantia.';

  @override
  String get magnesiumUptakeDesc => 'Magnesium (Mg2+) on lehtivihreän keskusatomi - ilman sitä ei ole fotosynteesiä. Liikkuu kasvissa vanhoista lehdistä nuoriin.';

  @override
  String get oxygenDiffusionDesc => 'Happi diffundoituu ilmasta maan huokosiin, mikä mahdollistaa aerobisen elämän. Vettyminen estää hapen kulkeutumisen.';

  @override
  String get gasExchangeDesc => 'Maasta vapautuu CO2 ja N2O mikrobien hengityksen sivutuotteena. Korkea CO2-päästö kertoo aktiivisesta mikrobiologiasta.';

  @override
  String get adsorptionMechanism => 'Sähköstaattinen sidonta';

  @override
  String get ionExchange => 'Ioninvaihto';

  @override
  String get downward => 'Alaspäin';

  @override
  String get downwardLoss => 'Alaspäin (hävikki)';

  @override
  String get downwardDiffusion => 'Alaspäin (diffuusio)';

  @override
  String get upwardDiffusion => 'Ylöspäin (diffuusio)';

  @override
  String get downwardOut => 'Alaspäin/Ulos';

  @override
  String get bindingOrder => 'Sitoutumisjärjestys';

  @override
  String get cecTitle => 'CEC (Kationinvaihtokapasiteetti)';

  @override
  String get cecDesc => 'Maan kyky sitoa ja vapauttaa positiivisesti varautuneita ioneja (kationeja). Savimineraalien ja humuksen negatiiviset varaukset pitävät ravinteita huuhtoutumiselta.';

  @override
  String get estimatedCec => 'Arvioitu CEC';

  @override
  String get clayContent => 'Savipitoisuus';

  @override
  String get bindingIons => 'Sitoutuneet ionit';

  @override
  String get leachingProtection => 'Huuhtoutumissuoja';

  @override
  String get aerobicProcess => 'Aerobinen prosessi';

  @override
  String get gradientMovement => 'Gradientin mukainen liike';

  @override
  String get uptakeLabel => 'Otto';

  @override
  String get leachingRiskLabel => 'Huuhtoutumisriski';

  @override
  String get reactant => 'Reaktiivinen aine';

  @override
  String get product => 'Tuote';

  @override
  String get organicNProteins => 'Org. typpi (proteiinit)';

  @override
  String get ammoniumProduct => 'NH4+ (ammonium)';

  @override
  String get availableP => 'Käyttökelpoinen P';

  @override
  String get optimalTemp => 'Lämpöoptimi';

  @override
  String get optimalMoisture => 'Kosteusoptimi';

  @override
  String get unit => 'Yksikkö';

  @override
  String get directionLabel => 'Suunta';

  @override
  String get consumption => 'Kulutus';

  @override
  String get requirement => 'Vaatimus';

  @override
  String get phOptimum => 'pH-optimi';

  @override
  String get exchangeableK => 'Vaihtuva K+';

  @override
  String get solubleCa => 'Liukoinen Ca2+';

  @override
  String get exchangeableMg => 'Vaihtuva Mg2+';

  @override
  String get trigger => 'Laukaisija';

  @override
  String get surface => 'Pinta';

  @override
  String get balance => 'Tasapaino';

  @override
  String get area => 'Pinta-ala';

  @override
  String get assessment => 'Arvio';

  @override
  String get anecicDesc => 'Anekkinen (pystysuora)';

  @override
  String get nitrogenAtmosphereLoss => 'Ravintoaine menetetty ilmakehään!';

  @override
  String get stomataTurgorRole => 'Ilmarakojen säätö, turgor';

  @override
  String get kAntagonistDesc => 'Korkea K+ häiritsee';

  @override
  String get heavyRainTrigger => 'Kova sade, kyllästynyt maa';

  @override
  String get nutrientLossConsequence => 'Ravinteiden hävikki, vesistökuorma';

  @override
  String get cnRatioLabel => 'C/N-suhde';

  @override
  String get cnRatioDesc => 'Kriittinen mikrobitoiminnalle';

  @override
  String get demandLabel => 'Kysyntä';

  @override
  String get highMacronutrient => 'Suuri (makroravinne)';

  @override
  String get airToSoil => 'Ilma → Maa';

  @override
  String get consumptionLabel => 'Kulutus';

  @override
  String get rootRespirationMicrobes => 'Juurihengitys + mikrobit';

  @override
  String get gasesLabel => 'Kaasut';

  @override
  String get wavelengthLabel => 'Aallonpituus';

  @override
  String get absorptionLabel => 'Absorptio';

  @override
  String get productLabel => 'Tuote';

  @override
  String get atpProductDesc => 'ATP + NADPH → Sokerit';

  @override
  String get heatFluxTitle => 'Lämpövirta';

  @override
  String get heatFluxDesc => 'Lämpöenergia liikkuu lämpötilaeron suuntaan. Aurinko lämmittää pintaa, ja lämpö johtuu syvemmälle maahan.';

  @override
  String get thermalConduction => 'Lämmönjohtuminen';

  @override
  String get governsMetabolism => 'Säätelee mikrobien metaboliaa';

  @override
  String get alongGradient => 'Gradientin mukaisesti';

  @override
  String get salinityTitle => 'Suolaisuus / EC';

  @override
  String get salinityDesc => 'Liuenneet suolat ja ravinteet vaikuttavat maan sähkönjohtavuuteen (EC). Korkea suolaisuus aiheuttaa osmoottista stressiä kasville.';

  @override
  String get dissolvedIons => 'Liuenneet ionit';

  @override
  String get osmoticStress => 'Osmoottinen stressi';

  @override
  String get accumulationLeaching => 'Kertyminen / Huuhtoutuminen';

  @override
  String get macronutrient => 'Makroravinne';

  @override
  String get energyNutrient => 'Energiaravintoaine';

  @override
  String get availablePLabel => 'Käyttökelpoinen P';

  @override
  String get exchangeableKLabel => 'Vaihtuva K+';

  @override
  String get solubleCaLabel => 'Liukoinen Ca2+';

  @override
  String get exchangeableMgLabel => 'Vaihtuva Mg2+';

  @override
  String get reactantLabel => 'Lähtöaine';

  @override
  String get organicNProteinsLabel => 'Org. typpi (proteiinit)';

  @override
  String get ammoniumProductLabel => 'NH4+ (ammonium)';

  @override
  String get optimalTempLabel => 'Lämpöoptimi';

  @override
  String get optimalMoistureLabel => 'Kosteusoptimi';

  @override
  String get requirementLabel => 'Vaatimus';

  @override
  String get aerobicProcessLabel => 'Aerobinen prosessi';

  @override
  String get mechanismLabel => 'Mekanismi';

  @override
  String get clayHumusSurface => 'Savimineraalit, humus';

  @override
  String get ionExchangeLabel => 'Ioninvaihto';

  @override
  String get rootHSecretion => 'Juuren H+ eritys';

  @override
  String get solidToSolution => 'Kiinteä → Liuos';

  @override
  String get gradientMovementLabel => 'Gradientin mukainen liike';

  @override
  String get mycorrhizaeHelper => 'Mykoritsat';

  @override
  String get rootHairArea => 'Juurikarvat 100x juuret';

  @override
  String get photosynthesisEnergy => '1-2% fotosynteesistä';

  @override
  String get heavyRainSaturated => 'Kova sade, kyllästynyt maa';

  @override
  String get macroporeRoute => 'Makrohuokoset, halkeamat';

  @override
  String get fastVelocity => 'Nopea (m/h mahdollinen)';

  @override
  String get unitMgKg => 'mg/kg';

  @override
  String get unitMolM3 => 'mol/m³';

  @override
  String get unitFraction => 'osuus';

  @override
  String get xrayAi => 'Röntgen-AI';

  @override
  String get stemDesc => 'Varsi kuljettaa vettä ja ravinteita juurista lehtiin (ksyleemi) ja sokereita lehdistä juuriin (floeemi).';

  @override
  String get rootTissueDesc => 'Juuren poikkileikkaus näyttää, miten vesi ja ravinteet suodattuvat Casparyn vyön läpi johtosolukkoon.';

  @override
  String get vascularTissue => 'Johtosolukko';

  @override
  String get transport => 'Kuljetus';

  @override
  String get rhizosphereLocation => 'Juurten ympärillä';

  @override
  String get microbialCellDesc => 'Yksittäinen mikrobisolu hajottaa orgaanista ainesta entsyymien avulla.';

  @override
  String get metabolismLabel => 'Metabolia';

  @override
  String get fluxLabel => 'Fluksi';

  @override
  String get veryHigh => 'Erittäin korkea';

  @override
  String get lawLabel => 'Laki';

  @override
  String get passive => 'Passiivinen';

  @override
  String get saturatedZone => 'KYLLÄSTYNYT VYÖHYKE';

  @override
  String get saturatedZoneDesc => 'Vyöhyke, jossa kaikki huokostila on täyttynyt vedellä. Hapenpuute (anoksia) käynnistää denitrifikaation ja hidastaa juurten toimintaa.';

  @override
  String get surfaceLabel => 'PINTA (Z=0)';

  @override
  String get co2Flux => 'CO₂-FLUKSI';

  @override
  String get transpirationLabel => 'H₂O-TRANSPIRAATIO';

  @override
  String get plantTitle => 'Kasvi';

  @override
  String get physiologyTitle => 'Fysiologia';

  @override
  String get saturationLabel => 'Kyllästysaste';

  @override
  String get wiltingPointLabel => 'Lakastumispiste';

  @override
  String sensorTitle(Object id) {
    return 'ANTURI: $id';
  }

  @override
  String get sensorDesc => 'Reaaliaikainen mittaus maaprofiilista.';

  @override
  String get bindingIonsLabel => 'Sitoutuneet ionit';

  @override
  String get activeUptake => 'Aktiivinen (ATP)';

  @override
  String get passiveUptake => 'Passiivinen (massavirta)';

  @override
  String horizonLabel(Object id) {
    return '$id-horisontti';
  }

  @override
  String get phDependence => 'pH-riippuvuus';

  @override
  String get transpirationSuction => 'Haihdutusimu';

  @override
  String get negativePotential => 'Negatiivinen vesipotentiaali (Ψ)';

  @override
  String get optimalPh => 'Optimi-pH 6-7';

  @override
  String get stomataRegulation => 'Ilmarakojen säätely';

  @override
  String get soluble => 'Liukoinen';

  @override
  String get blossomEndRot => 'Latvamätä';

  @override
  String get chlorophyllAtp => 'Lehtivihreä, ATP, entsyymit';

  @override
  String get volumetric => 'Tilavuuspohjainen';

  @override
  String get acidicLiming => 'Hapan - kalkitus suositeltava';

  @override
  String get slightlyAcidic => 'Hieman hapan';

  @override
  String get optimal => 'Optimaalinen';

  @override
  String get aluminumToxicity => 'Al-toksisuus';

  @override
  String get highRisk => 'Korkea riski';

  @override
  String get lowRisk => 'Matala riski';

  @override
  String get reduced => 'Pelkistynyt';

  @override
  String get saturatedFreeWater => 'Kyllästynyt (vapaa vesi)';

  @override
  String get fieldCapacityEasy => 'Kenttäkapasiteetti (helppo otto)';

  @override
  String get stressZone => 'Stressivyöhyke';

  @override
  String get wiltingPointWarning => 'Lakastumispiste ⚠️';

  @override
  String get hypoxicStress => 'Hypoksinen (stressi alkaa)';

  @override
  String get anoxic => 'Anoksinen ⚠️';

  @override
  String get disturbed => 'Häiriintynyt';

  @override
  String get blocked => 'Estynyt';

  @override
  String get oxidizing => 'Hapettava';

  @override
  String get reducing => 'Pelkistävä';

  @override
  String get sufficient => 'Riittävä';

  @override
  String get deficiency => 'Puutos';

  @override
  String get molecularDiffusion => 'Molekyylidiffuusio';

  @override
  String get concentrationDifference => 'Pitoisuusero';

  @override
  String get organicNReactant => 'Org. typpi (proteiinit)';

  @override
  String get optimalConditions => '60% kenttäkapasiteetista';

  @override
  String get none => 'Ei mitään';

  @override
  String get hexMatrix => 'Heksa-matriisi';

  @override
  String get aggregatesLabel => 'Aggregaatit';

  @override
  String get ecosystemEngineer => 'Ekosysteemi-insinööri';

  @override
  String get infiltration => 'Infiltraatio';

  @override
  String get aeration => 'Ilmanvaihto';

  @override
  String get earthworm => 'Liero';

  @override
  String get redoxLadderDesc => 'Redox-tikkaat näyttävät elektronivastaanottajien järjestyksen hapen kuluessa. Korkeampi potentiaali (Eh) tarkoittaa enemmän energiaa elämälle.';

  @override
  String get potential => 'Potentiaali';

  @override
  String get activeTea => 'Aktiivinen TEA';

  @override
  String get moleculeAmmoniumTitle => 'AMMONIUM (NH₄⁺)';

  @override
  String get moleculeAmmoniumDesc => 'Positiivisesti varautunut typpi-ioni, joka tarttuu maahiukkasiin sähköstaattisesti (CEC). Ei huuhtoudu helposti ja on tärkeä typenlähde.';

  @override
  String get moleculeNitrateTitle => 'NITRAATTI (NO₃⁻)';

  @override
  String get moleculeNitrateDesc => 'Negatiivisesti varautunut, erittäin liikkuva typpi-ioni. Nitraatti liikkuu veden mukana ja voi huuhtoutua tai poistua kaasuna.';

  @override
  String get moleculeCarbonLabileTitle => 'LABIILI HIILI (C)';

  @override
  String get moleculeCarbonLabileDesc => 'Helposti hajoava orgaaninen hiili (POM), joka toimii mikrobien polttoaineena. Edistää mikrobitoimintaa ja typen kiertoa.';

  @override
  String get moleculeCarbonStableTitle => 'STABIILI HIILI (SOC)';

  @override
  String get moleculeCarbonStableDesc => 'Pysyvämpiin muotoihin (MAOM) sitoutunut hiili, osa maan humusta. Tärkeä maan rakenteelle ja hiilen varastoinnille.';

  @override
  String get moleculeWaterTitle => 'VESI (H₂O)';

  @override
  String get moleculeWaterDesc => 'Elämän edellytys maaperässä. Vesi kuljettaa ravinteita ja toimii liuottimena biokemiallisissa reaktioissa.';

  @override
  String get moleculeOxygenTitle => 'HAPPI (O₂)';

  @override
  String get moleculeOxygenDesc => 'Välttämätön aerobiselle hengitykselle. Juuret ja useimmat mikrobit tarvitsevat happea tuottaakseen energiaa.';

  @override
  String get moleculeCO2Title => 'HIILIDIOKSIDI (CO₂)';

  @override
  String get moleculeCO2Desc => 'Mikrobien ja juurten hengityksen lopputuote. Korkea CO2-taso maassa kertoo aktiivisesta biologiasta.';

  @override
  String get moleculeOrganicNitrogenTitle => 'ORGAANINEN TYPPI (N_org)';

  @override
  String get moleculeOrganicNitrogenDesc => 'Orgaaniseen aineeseen, kuten proteiineihin, sitoutunut typpi. Mikrobien on mineralisoitava se ammoniumiksi ennen kuin kasvit voivat käyttää sitä.';

  @override
  String get moleculeNitrousOxideTitle => 'DITYPPIOKSIDI (N₂O)';

  @override
  String get moleculeNitrousOxideDesc => 'Voimakas kasvihuonekaasu, jota mikrobit tuottavat märässä, hapettomassa maassa. Sillä on n. 300-kertainen lämmitysvaikutus hiilidioksidiin verrattuna.';

  @override
  String get moleculeMethaneTitle => 'METAANI (CH₄)';

  @override
  String get moleculeMethaneDesc => 'Kaasu, jota syntyy hapettomissa oloissa. Merkittävä ilmastovaikutus.';

  @override
  String get moleculeWaterVaporTitle => 'VESIHÖYRY (H₂O_g)';

  @override
  String get moleculeWaterVaporDesc => 'Kaasumainen vesi, joka poistuu maasta haihdunnan tai kasvin transpiraation kautta.';

  @override
  String get microbialClusterTitle => 'MIKROBIKESKTYMÄ';

  @override
  String get microbialClusterDesc => 'Edustaa maaperän mikrobien tiheää pesäkettä, joka suorittaa biokemiallista hajotusta.';

  @override
  String get carrotTaprootTitle => 'PORKKANAN PÄÄJUURI';

  @override
  String get fineRootTitle => 'HIENOJUURI';

  @override
  String get rootStructureDesc => 'Juuren rakenne, joka ottaa vettä ja ravinteita.';

  @override
  String get mobilityVeryGood => 'Erittäin hyvä';

  @override
  String get mobilityGood => 'Hyvä';

  @override
  String get mobilityModerate => 'Kohtalainen';

  @override
  String get mobilityWeak => 'Heikko';

  @override
  String get mobilityVeryWeak => 'Erittäin heikko';

  @override
  String get mobilitySlow => 'Hidas';

  @override
  String get simulatedUnits => 'Simuloidut yksiköt';

  @override
  String get metabolicActivity => 'Metabolinen aktiivisuus';

  @override
  String get biomassDensity => 'Biomassan tiheys';

  @override
  String get immobilizedNutrients => 'Sitoutuneet ravinteet';

  @override
  String get gwpLabel => 'Ilmaston lämmitysvaikutus (GWP)';

  @override
  String get methanogenesis => 'Metanogeneesi';

  @override
  String get biomassLabel => 'Biomassa';

  @override
  String get depthLabel => 'Syvyys';

  @override
  String get radiusLabel => 'Säde';

  @override
  String get co2UptakeTitle => 'CO₂-OTTO';

  @override
  String get n2oEmissionTitle => 'N₂O-PÄÄSTÖ';

  @override
  String get o2DiffusionTitle => 'O₂-DIFFUUSIO';

  @override
  String get sugarCompound => 'Sokeri (C6H12O6)';

  @override
  String get nitrogenLossDenit => 'Typpihävikki denitrifikaation kautta';

  @override
  String get liquid => 'Neste';

  @override
  String get greenhouseGas => 'Kasvihuonekaasu';

  @override
  String get temperatureLabel => 'Lämpötila';

  @override
  String get soilTempDesc => 'Maahiukkasten keskimääräinen kineettinen energia. Vaikuttaa biologisiin nopeuksiin.';

  @override
  String get valLabel => 'Arvo';

  @override
  String get heatCapLabel => 'Lämpökapasiteetti';

  @override
  String get waterContentLabel => 'Vesipitoisuus';

  @override
  String get soilWaterDesc => 'Volumetrinen vesipitoisuus. Välttämätön kuljetukselle ja turgorille.';

  @override
  String get volumetricVWC => 'Volumetrinen (VWC)';

  @override
  String get porosityTitle => 'Huokoisuus';

  @override
  String get carbonLabileLabel => 'Labiili (POM)';

  @override
  String get carbonStableLabel => 'Stabiili (MAOM)';

  @override
  String get cnRatio => 'C/N-suhde';

  @override
  String get cRatioLabel => 'C-SUHDE';

  @override
  String get carbonTitle => 'HIILI (C)';

  @override
  String get carbonPoolsDesc => 'POM vs MAOM dynamiikka ja C/N-tasapaino.';

  @override
  String get charge => 'Varaus';

  @override
  String get symbolLabel => 'Symboli';

  @override
  String get oxygenTitle => 'Happi';

  @override
  String get wettingFrontTitle => 'KOSTUTUSRINTAMA';

  @override
  String get wettingFrontDesc => 'Rintama, joka kuvaa kastelun tai sateen etenemistä maassa. Se on kriittinen ravinteiden pystysuoralle kuljetukselle massavirtauksen avulla.';

  @override
  String get capillaryRiseTitle => 'KAPILLAARINEN NOUSU';

  @override
  String get capillaryRiseDesc => 'Veden nousu painovoimaa vastaan kuivassa maassa. Auttaa kasveja selviytymään kuivuudesta nostamalla vettä syvemmältä ritsosfääriin.';

  @override
  String get evaporationTitle => 'HAIHDUNTA';

  @override
  String get evaporationDesc => 'Veden poistuminen maan pinnalta höyrynä. Nopeus riippuu kosteudesta, säteilystä ja tuulesta (Penman-Monteith).';

  @override
  String get enzymesTitle => 'ENTSYYMIAKTIIVISUUS';

  @override
  String get enzymesDesc => 'Mikrobit ja juuret erittävät entsyymejä (kuten ureaasi ja fosfataasi) pilkkomaan monimutkaisia yhdisteitä kasveille käyttökelpoiseen muotoon.';

  @override
  String get effectLabel => 'Vaikutus';

  @override
  String get modelLabel => 'Malli';

  @override
  String get kineticsLabel => 'Kinetiikka';

  @override
  String get responseLabel => 'Vaste';

  @override
  String get weatherControl => 'SÄÄN HALLINTA';

  @override
  String get lightControl => 'VALON HALLINTA';

  @override
  String get methaneDescription => 'Metaani syntyy erittäin hapettomissa oloissa, kun arkeonit pelkistävät CO2:ta tai asetaattia. Tämä tapahtuu vasta kun kaikki muut elektroninvastaanottajat (O2, NO3, Fe, SO4) on käytetty.';

  @override
  String get infiltrationTitle => 'Suodanta';

  @override
  String get driverLabel => 'Ajuri';

  @override
  String get gravitationalPotential => 'Painovoimapotentiaali';

  @override
  String get moistureLoss => 'Kosteushävikki';

  @override
  String get energyLabel => 'Energia';

  @override
  String get latentHeat => 'Latentti lämpö';

  @override
  String get spacDescription => 'Maaperä-Kasvi-Ilmakehä-jatkumo (SPAC) kuvaa veden jatkuvaa virtausta maasta juurten ja ksyleemin kautta lehtiin, josta se haihtuu ilmaan.';

  @override
  String get layerControls => 'Kerroskohtaiset säädöt';

  @override
  String nutrientsForLayer(Object id) {
    return 'Ravinteet kerrokselle $id';
  }

  @override
  String get nitrateN => 'Nitraatti (N)';

  @override
  String get phosphateP => 'Fosfaatti (P)';

  @override
  String get potassiumK => 'Kalium (K)';

  @override
  String get calciumCa => 'Kalsium (Ca)';

  @override
  String get magnesiumMg => 'Magnesium (Mg)';

  @override
  String get labileC => 'Labiili hiili (POM)';

  @override
  String get stableC => 'Stabiili hiili (MAOM)';

  @override
  String get soilTexture => 'Maalaji / Tekstuuri';

  @override
  String get atmosphereControls => 'Ilmakehän säädöt';

  @override
  String get precipitation => 'Sadanta';

  @override
  String get atmosphericCO2 => 'Ilmakehän CO₂';

  @override
  String get nitrogenN => 'Typpi (N)';

  @override
  String get carbonC => 'Hiili (C)';

  @override
  String get methaneCH4 => 'Metaani (CH₄)';

  @override
  String get oxygenO2 => 'Happi (O₂)';

  @override
  String get sensors => 'Anturit';

  @override
  String get par => 'PAR';

  @override
  String get exudation => 'ERITYS';

  @override
  String get ionExchangePriming => 'IONINVAIHTO & PRIMING';

  @override
  String get stability => 'Stabiilisuus';

  @override
  String get pedsAndGranules => 'Mureet & Granulaatit';

  @override
  String get dynamicLabel => 'Dynaaminen';

  @override
  String get logicLabTitle => 'Logiikka-laboratorio — Biofysiikan visualisointi';

  @override
  String get buildScenarioTitle => 'Rakenna skenaario';

  @override
  String get parametersTab => 'Parametrit';

  @override
  String get actionsTab => 'Toimenpiteet';

  @override
  String get tutorialTab => 'Tutoriaali';

  @override
  String get scenarioNameLabel => 'Skenaarion nimi';

  @override
  String get descriptionLabel => 'Kuvaus';

  @override
  String simulationLengthDays(int value) {
    return 'Simulaation pituus: $value päivää';
  }

  @override
  String get soilType => 'Maalaji';

  @override
  String initialMoisture(String value) {
    return 'Alkukosteus (VWC): $value%';
  }

  @override
  String initialNitrate(String value) {
    return 'Nitraattipitoisuus (NO3): $value mg/kg';
  }

  @override
  String get addAction => 'Lisää suunnitelmaan';

  @override
  String get addTutorialStepAction => 'Lisää tutoriaalivaihe';

  @override
  String get cultivationPlan => 'Viljelysuunnitelma:';

  @override
  String get tutorialBuilt => 'Rakennettu tutoriaali:';

  @override
  String calculateDays(int value) {
    return 'LASKE ($value pv)';
  }

  @override
  String get startLive => 'ALOITA LIVE';

  @override
  String get selectExample => 'Valitse esimerkki';

  @override
  String get resetGraph => 'Nollaa kaavio';

  @override
  String get logicLabMixinLabel => 'Tutoriaalin rakennustyökalu (Logic Lab Mixin)';

  @override
  String get admin => 'Ylläpitäjä';

  @override
  String get closeAction => 'Sulje';

  @override
  String get inputs => 'Inputit';

  @override
  String get functions => 'Funktiot';

  @override
  String get soilColumnAnalysis => 'Maaprofiilin analyysi';

  @override
  String layerLabelWithDepth(String id, String depth1, String depth2) {
    return 'Kerros $id ($depth1 - $depth2 cm)';
  }

  @override
  String get atomicNumber => 'Järjestysluku';

  @override
  String get biologicalRole => 'Biologinen rooli';

  @override
  String get cpkColor => 'CPK-väri';

  @override
  String get classification => 'Luokittelu';

  @override
  String get meteorology => 'Meteorologia';

  @override
  String get airAndWaterVapor => 'Ilma ja vesihöyry';

  @override
  String get dryBulbTemp => 'Kuivalämpötila (°C)';

  @override
  String get humidityRatio => 'Kosteussuhde (kg/kg)';

  @override
  String get teachingKey => 'OPETUSLEGENDA';

  @override
  String get xylemTissue => 'Xyleemi (Vesi YLÖS)';

  @override
  String get phloemTissue => 'Floeemi (Sokeri ALAS)';

  @override
  String get waterMineralsFlow => 'Vesi & Ravinnevirtaus';

  @override
  String get energyCarbonFlow => 'Energia & Hiilivirtaus';

  @override
  String get nNitrateNode => 'N (Nitraatti) -solmu';

  @override
  String get pPhosphateNode => 'P (Fosfaatti) -solmu';

  @override
  String get cecSiteLabel => 'CEC (Ioninvaihtopaikka)';

  @override
  String get mmKinetics => 'Michaelis-Menten-kinetiikka';

  @override
  String get vgWaterRetention => 'van Genuchten -vedenpidätys';

  @override
  String get farquharPhotosynthesis => 'Farquhar-von Caemmerer-Berry C3 -fotosynteesi';

  @override
  String get nernstRedox => 'Nernstin yhtälö (Redox)';

  @override
  String get soilTempCelsius => 'Maan lämpötila (°C)';

  @override
  String get soilWaterContentPressureHead => 'Maan vesipitoisuus / painekorkeus';

  @override
  String get soilWaterSaturation => 'Maan vesikyllästys';

  @override
  String get ammoniumContentLabel => 'Ammoniumin (NH4+) pitoisuus';

  @override
  String get nitrateContentLabel => 'Nitraatin (NO3-) pitoisuus';

  @override
  String get oxygenContentLabel => 'Hapen (O2) pitoisuus';

  @override
  String get co2ContentLabel => 'Hiilidioksidin (CO2) pitoisuus';

  @override
  String get addEvent => 'Lisää toimenpide';

  @override
  String dayTimeLabel(String value) {
    return 'Aika (Päivä): $value';
  }

  @override
  String get eventTypeLabel => 'Tyyppi';

  @override
  String get actionFertilize => 'Lannoitus';

  @override
  String get actionTill => 'Muokkaus';

  @override
  String get actionWater => 'Kastelu';

  @override
  String amountLabel(String value) {
    return 'Määrä: $value';
  }

  @override
  String get fullField => 'Koko ala';

  @override
  String get tutBuilderTitle => 'Tutoriaalin Rakennustyökalu (Logic Lab Mixin)';

  @override
  String get tutTargetLabel => 'Kohde (Highlight)';

  @override
  String get tutTargetLeaf => 'Lehdet (Transpiraatio)';

  @override
  String get tutTargetRoot => 'Juuret (Uptake)';

  @override
  String get tutTargetRhizosphere => 'Ritsosfääri (Mikrobit)';

  @override
  String get tutTargetSoil => 'Maaperän rakenne';

  @override
  String get tutTitleLabel => 'Tutoriaalin otsikko';

  @override
  String get tutDescLabel => 'Opetusteksti';

  @override
  String get convectiveFlow => 'Konvektiivinen virtaus';

  @override
  String get negativeSuction => 'Negatiivinen imu';

  @override
  String get activeInfiltration => 'Aktiivinen infiltraatio';

  @override
  String get cecDescription => 'Kationinvaihtokapasiteetti: Maan kyky pidättää ja vaihtaa ravinteita (K+, NH4+, jne).';

  @override
  String get claySite => 'Savipaikka';

  @override
  String get organicSite => 'Orgaaninen paikka';

  @override
  String get hydraulicLift => 'Hydraulinen noste';

  @override
  String get matricPotential => 'Matriisipotentiaali';

  @override
  String get rubiscoLimited => 'Rubisco-rajoitteinen';

  @override
  String get organicPool => 'Orgaaninen pooli';

  @override
  String get stablePool => 'Vakaa pooli';

  @override
  String get fractalFingering => 'Fraktaalisormitus';

  @override
  String get nutrientAvailability => 'Ravinteiden saatavuus';

  @override
  String get highDivision => 'Nopea jakautuminen';

  @override
  String get capacityLabel => 'Kapasiteetti';

  @override
  String get processLabel => 'Prosessi';

  @override
  String get sourceLabel => 'Lähde';

  @override
  String get groundwaterLabel => 'Pohjavesi';

  @override
  String get efficiencyLabel => 'Tehokkuus';

  @override
  String get c3Pathway => 'C3-reitti';

  @override
  String get organicPoolLabel => 'Orgaaninen pooli';

  @override
  String get stablePoolLabel => 'Vakaa pooli';

  @override
  String get microbePoolLabel => 'Mikrobipooli';

  @override
  String get cationLabel => 'Kationi';

  @override
  String get anionLabel => 'Anioni';

  @override
  String get macronutrientLabel => 'Makroravinne';

  @override
  String get regulationLabel => 'Säätely';

  @override
  String get pomNitrogenTitle => 'POM-TYPPI (Particulate Organic N)';

  @override
  String get pomNitrogenDesc => 'Labili eloperäinen typpi (POM-N). Kasveille käyttökelpoista mikrobien hajotustoiminnan kautta.';

  @override
  String get micNitrogenTitle => 'MIKROBITYPPI (Microbial Biomass N)';

  @override
  String get micNitrogenDesc => 'Elävässä mikrobimassassa oleva typpi. Vapautuu mikrobien kuollessa tai laidunnuksen kautta.';

  @override
  String get maomNitrogenTitle => 'MAOM-TYPPI (Mineral-Associated N)';

  @override
  String get maomNitrogenDesc => 'Savi- ja hiesupartikkeleihin sitoutunut pitkäikäinen typpi. Maaperän suurin ja vakain typpivarasto.';

  @override
  String get ammoniumTitle => 'AMMONIUM (NH₄⁺)';

  @override
  String get ammoniumDesc => 'Maaperässä heikosti liikkuva typpimuoto. Sitoutuu savihiukkasiin.';

  @override
  String get nitrateTitle => 'NITRAATTI (NO₃⁻)';

  @override
  String get nitrateDesc => 'Erittäin liikkuva typpimuoto. Liukenee veteen ja huuhtoutuu helposti.';

  @override
  String get nitrogenTitleLong => 'TYPPI (N)';

  @override
  String get nitrogenDescLong => 'Tärkein kasvuravinne. Proteiinien, klorofyllin ja nukleiinihappojen rakennusaine.';

  @override
  String get phosphorusTitleLong => 'FOSFORI (P)';

  @override
  String get phosphorusDescLong => 'ATP:n ja DNA:n komponentti. Erittäin heikosti liikkuva.';

  @override
  String get potassiumTitleLong => 'KALIUM (K)';

  @override
  String get potassiumDescLong => 'Säätelee stomien avautumista ja vesitasapainoa.';

  @override
  String nutrientTitlePrefix(String symbol) {
    return 'RAVINNE: $symbol';
  }

  @override
  String get biochemistryDesc => 'Tärkeä osatekijä maaperän biokemiassa.';

  @override
  String get potassiumLabel => 'Kalium';

  @override
  String get dynamicsLabel => 'Dynamiikka';

  @override
  String get optimalLabel => 'Optimi';

  @override
  String get significanceLabel => 'Merkitys';

  @override
  String get riskLabel => 'Riski';

  @override
  String get apicalMeristem => 'Kärkimeristeemi';

  @override
  String get meristemDesc => 'Pääkasvuvyöhyke, joka perustuu jatkuvaan solunjakautumiseen.';

  @override
  String get tissueLabel => 'Kudos';

  @override
  String get meristematic => 'Meristemaattinen';

  @override
  String get undifferentiated => 'Eilaistunut';

  @override
  String get rateLabel => 'Nopeus';

  @override
  String get turgorLabel => 'Turgor';

  @override
  String get roleLabel => 'Rooli';

  @override
  String get locationLabel => 'Sijainti';

  @override
  String get microbialBiomassLabel => 'Mikrobimassa';

  @override
  String get bioActivityLabel => 'Bio-aktiivisuus';

  @override
  String get typeLabel => 'Tyyppi';

  @override
  String get clayFractionLabel => 'Savipitoisuus';

  @override
  String get nitrogenCycle => 'Typenkierto';

  @override
  String get flows => 'Virtaukset';

  @override
  String get modify => 'Muokkaa';

  @override
  String get off => 'Pois';

  @override
  String get turnOffMicroscope => 'Sammuta mikroskooppi';

  @override
  String get stem => 'Varsi';

  @override
  String get hydrogen => 'Vety';

  @override
  String get sulfur => 'Rikki';

  @override
  String get runoff => 'Valunta';

  @override
  String get diffuseFlow => 'Diffuusiovirtaus';

  @override
  String get interflow => 'Pintakerrosvalunta';

  @override
  String get surfaceRunoff => 'Pintavalunta';

  @override
  String get groundwaterFlow => 'Pohjavesivalunta';

  @override
  String get evaporation => 'Haihdunta';

  @override
  String get validation => 'Validointi';

  @override
  String get inspectionBadge => 'TARKASTELU';

  @override
  String get previewBadge => 'ESIKATSELU';

  @override
  String get preparingSimulation => 'VALMISTELLAAN SIMULAATIOTA...';

  @override
  String get launchingEngine => 'Käynnistetään simulaatiomoottoria...';

  @override
  String get loadingSimulation => 'Ladataan simulaatiota...';

  @override
  String get preparingSoil => 'VALMISTELLAAN MAAPERÄÄ...';

  @override
  String get continueButton => 'JATKA';

  @override
  String get schematic => 'Kaavio';

  @override
  String get observation => 'Havainnot';

  @override
  String get macronutrients => 'Pääravinteet';

  @override
  String get micronutrients => 'Hivenravinteet';

  @override
  String get beneficialElements => 'Hyödylliset';

  @override
  String get toxicElements => 'Raskasmetallit & Myrkyt';

  @override
  String get allElements => 'Kaikki alkuaineet';

  @override
  String get structuralElements => 'Rakenteelliset & Kaasut';

  @override
  String get searchElement => 'Hae alkuainetta (nimi, merkki, järjestysluku)...';

  @override
  String get gridView => 'Taulukkonäkymä';

  @override
  String get listView => 'Korttinäkymä';

  @override
  String get openScienceReference => 'Avaa tiedeviite';

  @override
  String get scienceReferenceDesc => 'Tutki jaksollista järjestelmää, maaperäfysiikkaa, ilmakehää ja validointituloksia.';

  @override
  String get gatheringData => 'Kerätään tietoja...';

  @override
  String get minStepsForValidation => 'Anna simulaation pyöriä vähintään 5 askelta nähdäksesi tieteellisen validoinnin.';

  @override
  String get variableSpecificResults => 'MUUTTUJAKOHTAISET TULOKSET';

  @override
  String get scientificValidation => 'Tieteellinen validointi';

  @override
  String get validationModelRef => 'Malli verrattuna FLUXNET/LUCAS -referenssidataan.';

  @override
  String get overallScore => 'YLEISARVOSANA';

  @override
  String get assessmentExcellent => 'Erinomainen';

  @override
  String get assessmentGood => 'Hyvä';

  @override
  String get assessmentSatisfactory => 'Tyydyttävä';

  @override
  String get assessmentAcceptable => 'Hyväksyttävä';

  @override
  String get assessmentPoor => 'Heikko';

  @override
  String get rmseLabel => 'RMSE (Keskivirhe)';

  @override
  String get maeLabel => 'MAE (Absoluuttinen virhe)';

  @override
  String get r2Label => 'R² (Selitysaste)';

  @override
  String get biasLabel => 'Bias (Harha)';

  @override
  String get ioaLabel => 'Yhteensopivuusindeksi (d)';

  @override
  String get groupPeriod => 'Ryhmä / Jakso';

  @override
  String get mass => 'Massa';

  @override
  String get createNewScenario => 'Luo uusi skenaario';

  @override
  String get createNewScenarioDesc => 'Säädä parametrit ja rakenna oma opettavainen skenaario.';

  @override
  String dayPrefix(String day) {
    return 'Päivä $day';
  }

  @override
  String get precipitationLabel => 'SADEMÄÄRÄ';

  @override
  String get co2ConcentrationLabel => 'CO₂-PISTOISUUS';

  @override
  String get methanogenicState => 'METANOGENEESI';

  @override
  String get sulfateReductionState => 'SULFAATIN PELKISTYS';

  @override
  String get ironReductionState => 'RAUDAN PELKISTYS';

  @override
  String get denitrifyingState => 'DENITRIFIKAATIO';

  @override
  String get aerobicStateUpper => 'AEROBINEN';

  @override
  String get visualizedElements => 'VISUALISOIDUT ALKUAINEET';

  @override
  String get microscopeHotspots => 'MIKROSKOOPIN KOHTEET';

  @override
  String get precipAbbr => 'SADE';

  @override
  String get selectElement => 'Valitse alkuaine';

  @override
  String get elementDetails => 'Alkuaineen tiedot';

  @override
  String get clearSelection => 'Tyhjennä valinta';

  @override
  String get parSunlight => 'PAR (AURINGONVALO)';

  @override
  String get gasEmissionsKey => 'KAASUPÄÄSTÖT (N₂O/CH₄)';

  @override
  String get activeGrowth => 'AKTIIVINEN KASVU';

  @override
  String get stressedState => 'STRESSITILA';

  @override
  String get rootTipLabel => 'JUUREN KÄRKI';

  @override
  String get activeCellDivision => 'AKTIIVINEN SOLUNJAKAUTUMINEN';

  @override
  String get primordia => 'LEHTIAIHEET';

  @override
  String get stemCells => 'KANTASOLUT';

  @override
  String get apicalDome => 'KÄRKIKUPU';

  @override
  String get nanovisionTitle => 'NANOVISION-MIKROSKOOPPI';

  @override
  String get magnification => 'Suurennos';

  @override
  String get moreInfo => 'Lisätietoja';

  @override
  String get rootExudation => 'Juurieritys';

  @override
  String get activity => 'Aktiivisuus';

  @override
  String get decompositionDesc => 'Orgaanisen aineksen hajoaminen ja mikrobien mineralisaatio.';

  @override
  String get mineralization => 'Mineralisaatio';

  @override
  String get tutorialTitle => 'SoilScope-käyttöopas';

  @override
  String tutorialStepCounter(Object current, Object total) {
    return 'VAIHE $current / $total';
  }

  @override
  String get tutorialNext => 'Seuraava';

  @override
  String get tutorialPrev => 'Edellinen';

  @override
  String get tutorialSkip => 'Ohita opastus';

  @override
  String get tutorialFinish => 'Aloita tutkiminen';

  @override
  String get tutorialQuickGuide => 'Pikaopas';

  @override
  String get tutorialStartTour => 'Käynnistä tutoriaali';

  @override
  String get tutorialRestart => 'Aloita opastus uudelleen';

  @override
  String get tutorialHelpTooltip => 'Sovelluksen käyttöohjeet ja tutoriaali';

  @override
  String get tutorialWelcomeTitle => 'Tervetuloa SoilScopeen!';

  @override
  String get tutorialWelcomeDesc => 'SoilScope on tieteellinen maaperä-kasvi-ilmakehä-jatkumon (SPAC) simulaattori. Tässä opastuksessa tutustumme sovelluksen tärkeimpiin toimintoihin, jotta voit hallita simulaatiota ja tulkita biokemiallisia prosesseja vaivattomasti.';

  @override
  String get tutorialWelcomePoint1 => 'Kasvin verson kasvu heijastaa juuriston veden ja ravinteiden ottoa.';

  @override
  String get tutorialWelcomePoint2 => 'Vesi ja ionit liikkuvat maaprofiilissa fysiikan lakien (Richards-yhtälö) mukaisesti.';

  @override
  String get tutorialWelcomePoint3 => 'Maaperän mikrobit ja sienijuuret (mykorritsa) muuntavat ravinteita kasville sopivaan muotoon.';

  @override
  String get tutorialCanvasTitle => 'Simulaationäkymä & Tarkastelupisteet';

  @override
  String get tutorialCanvasDesc => 'Päänäkymässä näet 2D-fysiikkamaailman: kasvin verson, juuriston kasvun ja maannoskerrokset sekä ravinnehiukkasten dynaamisen virtauksen.';

  @override
  String get tutorialCanvasPoint1 => 'Klikkaa maassa ja kasvissa hehkuvia kohdepisteitä (hotspots) avataksesi mikroskooppisen analyysin.';

  @override
  String get tutorialCanvasPoint2 => 'Vie hiiri minkä tahansa elementin päälle nähdäksesi reaaliaikaisia tieteellisiä arvoja ja kaavoja.';

  @override
  String get tutorialDashboardTitle => 'Tilannekeskus (HUD Dashboard)';

  @override
  String get tutorialDashboardDesc => 'Vasemman reunan tilannekeskuksesta pääset tarkastelemaan maaprofiilin fysiikkaa ja biokemiaa syvällisesti.';

  @override
  String get tutorialDashboardPoint1 => 'Tarkastele kerroskohtaista kosteutta (θ), lämpötilaa, pH-arvoa, redokspotentiaalia ja sähkönjohtavuutta.';

  @override
  String get tutorialDashboardPoint2 => 'Maalajikolmio (Texture Triangle) näyttää saven, hiedan ja hiekan jakauman.';

  @override
  String get tutorialDashboardPoint3 => 'Seuraa orgaanisen aineksen MAOM- ja POM-hiilivarastoja sekä mikrobien aktiivisuutta.';

  @override
  String get tutorialControlsTitle => 'Hallintapaneeli & Toimenpiteet';

  @override
  String get tutorialControlsDesc => 'Oikean reunan hallintapaneelista säädät ympäristöä ja suoritat viljelytoimenpiteitä.';

  @override
  String get tutorialControlsPoint1 => 'Säädä säätilaa: auringon PAR-valosäteily, sade, ilman lämpötila ja CO₂-pitoisuus.';

  @override
  String get tutorialControlsPoint2 => 'Viljelytoimenpiteet: kastelu, typpi- ja fosforilannoitus, kerääjäkasvit sekä maan muokkaus (kyntö).';

  @override
  String get tutorialControlsPoint3 => 'Huomioi: Liiallinen muokkaus tuhoaa sienirihmastoja ja ylilannoitus voi aiheuttaa nitraattihuuhtoutumaa.';

  @override
  String get tutorialTimelineTitle => 'Aikajana & Simulaationopeus';

  @override
  String get tutorialTimelineDesc => 'Hallitse ajan kulkua ja tarkkaile maaperän dynaamisia reaktioita lyhyellä ja pitkällä aikavälillä.';

  @override
  String get tutorialTimelinePoint1 => 'Pysäytä simulaatio analysoidaksesi maaperän profiilia tietyllä ajanhetkellä.';

  @override
  String get tutorialTimelinePoint2 => 'Muuta nopeutta (1x, 2x, 5x, 10x) nopeuttaaksesi kasvin kasvua ja ravinteiden suotautumista.';

  @override
  String get tutorialTimelinePoint3 => 'Kelaa aikajanaa tarkastellaksesi aiempia päiviä ja säähäiriöiden vaikutuksia.';

  @override
  String get tutorialObservationTitle => 'Havainnointitilat & Nanovision';

  @override
  String get tutorialObservationDesc => 'Alapalkin pikapainikkeilla eristät ravinnekiertoja ja siirryt solutason mikroskooppiin.';

  @override
  String get tutorialObservationPoint1 => 'Typen kierto: Korosta ammonium- ja nitraattipartikkelit sekä denitrifikaation kaasupäästöt.';

  @override
  String get tutorialObservationPoint2 => 'Nanovision: Tutki lehtien ilmarakoja, juuren kärkimeristeemiä ja maaperän huokosia jopa 1200x suurennoksella.';

  @override
  String get tutorialObservationPoint3 => 'Kytke hiukkasvirtauslinjat päälle tai pois tarpeen mukaan.';

  @override
  String get tutorialGamificationTitle => 'Kestävyys & Tehtävätavoitteet';

  @override
  String get tutorialGamificationDesc => 'Yläpalkki arvioi ekologista kestävyyttä ja opastaa skenaarioiden haasteissa.';

  @override
  String get tutorialGamificationPoint1 => 'Seuraa maan terveysindeksiä, vesikyllästeisyyttä, mikrobiston tilaa ja kasvin vitaliteettia.';

  @override
  String get tutorialGamificationPoint2 => 'Suorita skenaarion tavoitteet (esim. hiilensidonta tai ravinnehukkien minimointi) ansaitaksesi pisteitä.';

  @override
  String get tutorialGamificationPoint3 => 'Saavuta uusia tasoja toimimalla kestävän viljelyn ja ekofysiologian periaatteiden mukaisesti.';

  @override
  String get quickGuideTabUI => 'Käyttöliittymä';

  @override
  String get quickGuideTabScience => 'SPAC-Tiede';

  @override
  String get quickGuideTabTips => 'Käytännön vinkit';

  @override
  String get quickGuideTitle => 'SoilScope-Pikaopas';

  @override
  String get stepCompactedClay1Title => 'Havaitse kyntöantura ja tiivistymä';

  @override
  String get stepCompactedClay1Desc => 'Tarkastele maaprofiilin A2- ja B1-kerroksia: huokoisuus on pudonnut kriittiselle tasolle ja tiheys on koholla (1700-1800 kg/m³). Vesi ei pääse imeytymään syvemmälle, mikä hidastaa juurten kasvua.';

  @override
  String get stepCompactedClay2Title => 'Maan kuohkeutus ja syväjuuriset kasvit';

  @override
  String get stepCompactedClay2Desc => 'Avaa oikea hallintapaneeli ja suorita mekaaninen muokkaus pintakerroksen avaamiseksi. Kokeile myös kylvää syväjuurista aluskasvia (sinimailanen tai öljyretikka), joka luo bioporeja.';

  @override
  String get stepCompactedClay3Title => 'Seuraa juuriston tunkeutumista';

  @override
  String get stepCompactedClay3Desc => 'Tarkkaile juuriston kasvua Nanovision- tai mikroskooppitilassa. Juuret erittävät orgaanisia happoja ja limaa (EPS), jotka murustavat maata ja parantavat vedenjohtavuutta.';

  @override
  String get stepNitrateLeach1Title => 'Vaarallinen nitraattipitoisuus';

  @override
  String get stepNitrateLeach1Desc => 'A-kerroksen nitraattipitoisuus (NO₃⁻) on vaarallisen korkea (100 mg/kg) ja rankkasade lähestyy. Koska nitraatti on negatiivisesti varautunut anioni, se ei sitoudu maahiukkasiin vaan huuhtoutuu vapaan veden mukana pohjaveteen.';

  @override
  String get stepNitrateLeach2Title => 'Kylvä kerääjäkasveja ja säädä kastelua';

  @override
  String get stepNitrateLeach2Desc => 'Avaa hallintapaneeli. Vältä lisälannoitusta ja ota käyttöön kerääjäkasveja, joiden aktiivinen transpirointi sitoo vapaata nitraattia kasvimassaan ennen kuin sade huuhtoo sen pohjamaahan.';

  @override
  String get stepNitrateLeach3Title => 'Ravinteiden hyödyntäminen lehdistössä';

  @override
  String get stepNitrateLeach3Desc => 'Tarkkaile lehtien fotosynteesiä ja ilmarakojen johtavuutta. Terve ja tiheä kasvillisuus nostaa vettä maasta transpiraatiovirralla, mikä estää liuoksen perkolointia syvempiin kerroksiin.';

  @override
  String get stepNitrogenLock1Title => 'Mikrobien typpilukko (High C/N)';

  @override
  String get stepNitrogenLock1Desc => 'Maahan on lisätty runsaasti hiilipitoista olkea (korkea C/N-suhde). Mikrobit hajottavat hiiltä kiivaasti ja sitovat kaiken saatavilla olevan mineraalitypen (immobilisaatio), jolloin viljelykasvi alkaa kärsiä kloroosista.';

  @override
  String get stepNitrogenLock2Title => 'Täydennyslannoitus tai typensitojakasvit';

  @override
  String get stepNitrogenLock2Desc => 'Purkaa typpilukko lisäämällä hallintapaneelista kohdennettu typpilannoitus mikrobien tarpeen tyydyttämiseksi tai lisäämällä typensitojakasveja (apila/palkokasvit), jotka hyödyntävät ilmakehän typpeä symbioosissa.';

  @override
  String get stepNitrogenLock3Title => 'Seuraa mineralisaation käynnistymistä';

  @override
  String get stepNitrogenLock3Desc => 'Kun mikrobisto saavuttaa kyllästyspisteen, immobilisaatio kääntyy netto-mineralisaatioksi. Mineraalityppi (ammonium ja nitraatti) vapautuu jälleen kasvin juurten käyttöön ja MAOM-varasto karttuu.';

  @override
  String get stepWaterlogging1Title => 'Maan hapenpuute ja vesiylijäämä';

  @override
  String get stepWaterlogging1Desc => 'Pohjavesipinta on noussut ja maahuokoset ovat täysin veden vallassa (kyllästystila). Kaasunvaihto ilmakehään on estynyt, maaperän happi (O₂) kuluu loppuun ja redox-potentiaali (Eh) romahtaa kohti anaerobisia lukemia.';

  @override
  String get stepWaterlogging2Title => 'Hapettomat juuret ja tukehtuminen';

  @override
  String get stepWaterlogging2Desc => 'Kasvien juuret tarvitsevat happea soluhengitykseen ja ATP-tuotantoon. Ilman happea aktiivinen veden ja ravinteiden otto loppuu, ilmaraot sulkeutuvat ja kasvi nuutuu vaikka vettä on ylenmäärin.';

  @override
  String get stepWaterlogging3Title => 'Avaa ojitusta ja aktivoi haihduntaa';

  @override
  String get stepWaterlogging3Desc => 'Hallitse vesitilannetta: vähennä sadetusta, lisää salaojitusta/kuivatusta ja varmista kasvilajit jotka sietävät tulvimista tai muodostavat aerenkyymisolukkoa ilman kuljettamiseksi juuriin.';

  @override
  String get waterloggingTitle => 'Hapeton tulva-alue -haaste';

  @override
  String get waterloggingDesc => 'Hallitse hapenpuutetta ja ravinteiden huuhtoutumista tulvivassa maassa.';

  @override
  String get objectiveMaintainTurgor => 'Ylläpidä kasvin turgoria';

  @override
  String get objectiveRestoreAerobic => 'Palauta aerobiset olot';

  @override
  String get fluxAtmosphereToSoil => 'Ilmakehä → Maa';

  @override
  String get fluxSoilToAtmosphere => 'Maa → Ilmakehä';

  @override
  String get tutorialActionOpenDashboard => 'Avaa tilannekeskus';

  @override
  String get tutorialActionOpenControls => 'Avaa hallintapaneeli';

  @override
  String get tutorialActionTryPlayback => 'Kokeile toistoa';

  @override
  String get tutorialActionOpenNanovision => 'Avaa Nanovision';

  @override
  String get missionBriefingTitle => 'TEHTÄVÄNANTO';

  @override
  String get missionScenarioBadge => 'SKENAARIO';

  @override
  String get missionSubtitle => 'Tehtävän kuvaus ja tieteellinen tausta';

  @override
  String get missionChallengeTitle => 'Haasteen kuvaus';

  @override
  String get missionRecommendationsTitle => 'Toimenpidesuositukset';

  @override
  String get missionScienceTitle => 'SPAC-Biofysiikan tausta';

  @override
  String get missionObjectivesTitle => 'Tavoitteet';

  @override
  String get missionStatusAchieved => 'SAAVUTETTU';

  @override
  String get missionStatusPending => 'KESKEN';

  @override
  String get missionOpenQuickGuide => 'Avaa pikaopas';

  @override
  String get missionStartActions => 'Aloita toimenpiteet';

  @override
  String get missionNoActiveScenario => 'Ei aktiivista skenaariota';

  @override
  String get briefingCompactionProblem => 'Maan rakenne on raskaasti tiivistynyt: tilavuuspaino on kohonnut jopa 1700 kg/m³ ja huokoisuus on pudonnut alle 30 %. Vesi ei pääse imeytymään syvempiin kerroksiin vaan muodostaa pintaan lammikoita. Kasvin juuret eivät läpäise kovaa savikerrosta mekaanisen vastuksen vuoksi.';

  @override
  String get briefingCompactionStep1 => 'Avaa oikean reunan hallintapaneeli ja suorita pintamaan muokkaus (äestys) murustamaan tiivistymää.';

  @override
  String get briefingCompactionStep2 => 'Kylvä syväjuurinen kerääjäkasvi (Cover Crop), jonka pääjuuret kairaavat makrohuokosia pohjamaahan.';

  @override
  String get briefingCompactionStep3 => 'Vältä rankkasateita: pidä sademäärä maltillisena, jotta maahan jää riittävästi ilmatilaa ja vesi ei lietä pintaa.';

  @override
  String get briefingCompactionStep4 => 'Seuraa vasemmasta tilannekeskuksesta kyllästyneen vedenjohtavuuden (kSat) ja huokoisuuden kehitystä.';

  @override
  String get briefingCompactionScience => 'van Genuchten -mallin ja 1D Richards -yhtälön mukaisesti tiivistyneessä maassa vedenjohtavuus romahtaa useita kertalukuja. Juuriston pituuskasvu pysähtyy, kun maan leikkauslujuus ylittää juuren soluturgorin.';

  @override
  String get briefingLeachingProblem => 'Karkeassa hietamaassa (70 % hiekkaa) on suuri määrä vapaata nitraattia (100 mg/kg). Koska hiekan kationinvaihtokapasiteetti (CEC) ja vedenpidätyskyky ovat hyvin matalia, rankkasateet huuhtovat nitraatin suoraan pohjavesikerrokseen aiheuttaen ravinnehukkaa ja rehevöitymistä.';

  @override
  String get briefingLeachingStep1 => 'Kylvä nopeasti biomassaa tuottava kasvi ottamaan vapaa nitraatti talteen ennen voimakasta sadetta.';

  @override
  String get briefingLeachingStep2 => 'Pidä sademäärä pienenä tai säädä autoWeather pois päältä estääksesi massiivisen suotautumisen.';

  @override
  String get briefingLeachingStep3 => 'Lisää orgaanista ainesta nostamaan mikrobiston hiilimäärää, mikä laukaisee nitraatin sitomisen mikrobimassaan (immobilisaatio).';

  @override
  String get briefingLeachingStep4 => 'Kytke alapalkista Typen kierto päälle nähdäksesi nitraatti-ionien virtausvektorit.';

  @override
  String get briefingLeachingScience => 'Nitraatti (NO₃⁻) on negatiivisesti varautunut anioni, jota savimineraalit ja humus eivät sido sähköstaattisesti. Kulkeutuminen tapahtuu advektio-dispersio -yhtälön mukaisesti veden mukana.';

  @override
  String get briefingLockProblem => 'Maahan lisättiin suuri määrä hiilirikasta olkea, jolloin maaperän C/N-suhde nousi yli kriittisen arvon 25. Heterotrofiset maaperämikrobit kuluttavat kaiken vapaan typen (ammoniumin ja nitraatin) hajottaakseen hiiltä, jolloin viljelykasvi kärsii ankarasta typenpuutteesta.';

  @override
  String get briefingLockStep1 => 'Suorita typpilannoitus (Fertilize) hallintapaneelista täydentämään kasveille heti käyttökelpoista typpeä.';

  @override
  String get briefingLockStep2 => 'Nosta lämpötilaa tai optimoi kosteus kiihdyttämään mikrobien hengitystä ja hajotustyötä.';

  @override
  String get briefingLockStep3 => 'Avaa Nanovision-mikroskooppi ja tarkastele lehden ilmarakojen ja yhteyttämisen elpymistä.';

  @override
  String get briefingLockStep4 => 'Seuraa tilannekeskuksesta C/N-suhdetta ja mikrobien kuoleman kautta vapautuvaa typpeä (nekromassa).';

  @override
  String get briefingLockScience => 'Mikrobien biomassalla on kiinteä C/N-suhde (n. 8:1). Kun saatavilla on ylimäärin hiiltä, mikrobit immobilisoivat kaiken epäorgaanisen typen. Vapautuminen (mineralisaatio) käynnistyy vasta, kun orgaanisen aineksen C/N laskee alle 20:n.';

  @override
  String get briefingWaterloggingProblem => 'Maaperä on täysin veden kyllästämä ja ilmatila huokosissa on loppunut. Koska kaasujen diffuusio vedessä on 10 000 kertaa ilmaa hitaampaa, maaperän happi loppuu tunneissa. Redox-potentiaali putoaa syvälle negatiiviseksi (-150 mV), mikä käynnistää denitrifikaation ja metanogeneesin.';

  @override
  String get briefingWaterloggingStep1 => 'Pysäytä välittömästi kaikki kastelu ja varmista, että sademäärä on 0 mm.';

  @override
  String get briefingWaterloggingStep2 => 'Nosta auringonvaloa (PAR) ja ilman lämpötilaa kiihdyttämään maaveden haihduntaa (evapotranspiraatio).';

  @override
  String get briefingWaterloggingStep3 => 'Tarkkaile tilannekeskuksesta kaasupäästöjä (N₂O ja CH₄) sekä redox-potentiaalin nousua kohti aerobista aluetta (> 300 mV).';

  @override
  String get briefingWaterloggingStep4 => 'Tarkastele juuristoa: vältä juurimätää ja hapenpuutteen aiheuttamaa solukuolemaa.';

  @override
  String get briefingWaterloggingScience => 'Nernst-yhtälön mukainen redox-asteikko (TEA-redox-tikapuut) osoittaa, että hapen (O₂) kuluttua elektronit ohjautuvat nitraatille (NO₃⁻ → N₂O/N₂), mangaani- ja rautaoksideille ja lopulta metaaniksi (CH₄).';

  @override
  String get briefingDefaultProblem => 'Tasapainota maaperän fysiikka ja biokemia kasvin terveen kasvun varmistamiseksi.';

  @override
  String get briefingDefaultStep1 => 'Tarkastele maaprofiilin tilaa vasemmasta tilannekeskuksesta.';

  @override
  String get briefingDefaultStep2 => 'Säädä säätilaa ja toimenpiteitä oikeasta hallintapaneelista.';

  @override
  String get briefingDefaultStep3 => 'Seuraa kestävyyspisteitä ja suorita skenaarion tavoitteet.';

  @override
  String get briefingDefaultScience => 'SPAC-jatkumo yhdistää maaperän huokoisuuden, kasvin fysiologian ja ilmakehän haihduntapaineen.';

  @override
  String get quickGuideTabBiochemistry => 'Biokemia';

  @override
  String get quickGuideTabGlossary => 'Sanakirja';

  @override
  String get quickGuideSubtitle => 'SPAC-simulaattorin toiminnot ja tieteellinen perusta';

  @override
  String get quickGuideClose => 'Sulje opas';

  @override
  String get quickGuideCardUiDashboardTitle => 'Tilannekeskus (Dashboard - Vasen palkki)';

  @override
  String get quickGuideCardUiDashboardBody => 'Avaa maaperän kerroskohtaiset mittarit: vesipitoisuus (θ), lämpötila, pH, sähkönjohtavuus (EC) ja redokspotentiaali (Eh). Sisältää myös maalajikolmion (Texture Triangle), jolla näet maannoksen koostumuksen.';

  @override
  String get quickGuideCardUiControlsTitle => 'Hallintapaneeli & Viljely (Oikea palkki)';

  @override
  String get quickGuideCardUiControlsBody => 'Säädä sääolosuhteita (sade, auringonpaiste PAR, lämpötila, CO₂) sekä viljelytoimenpiteitä kuten kastelu, typpi- ja fosforilannoitus, kerääjäkasvit ja maan muokkaus.';

  @override
  String get quickGuideCardUiTimelineTitle => 'Aikajana & Nopeudensäätö (Alhaalla)';

  @override
  String get quickGuideCardUiTimelineBody => 'Pysäytä simulaatio hetkeksi tarkastelua varten, valitse nopeus (1x, 2x, 5x, 10x) tai kelaa päiviä taaksepäin nähdäksesi toimenpiteiden aiheuttaman kehityskulun.';

  @override
  String get quickGuideCardUiNanovisionTitle => 'Nanovision-mikroskooppi (Alhaalla / Hotspots)';

  @override
  String get quickGuideCardUiNanovisionBody => 'Syvenny solutason biofysiikkaan: tarkastele lehtien ilmarakoja (400x), verson ksyleemiä (200x), kärkimeristeemiä (800x), juuren solurakenteita (400x), ritsosfääriä (600x) ja mikrobeja (1200x).';

  @override
  String get quickGuideCardSciSpacTitle => 'SPAC — Maaperä-Kasvi-Ilmakehä -jatkumo';

  @override
  String get quickGuideCardSciSpacBody => 'Vesi liikkuu laskevan vesipotentiaalin (ψ) ajamana maasta (ψ ≈ -0,03 MPa) juuriin, edelleen ksyleemiin ja haihtuu ilmarakojen kautta ilmakehään (ψ ≈ -100 MPa).';

  @override
  String get quickGuideCardSciHydraulicsTitle => 'Richards-yhtälö & van Genuchten';

  @override
  String get quickGuideCardSciHydraulicsBody => 'Määrittää veden virtauksen kyllästymättömässä huokosverkostossa. Kuvaa kapillaarista imupainetta ja painovoiman vaikutusta.';

  @override
  String get quickGuideCardSciBeerLambertTitle => 'Säteilyn vaimeneminen (Beer-Lambert)';

  @override
  String get quickGuideCardSciBeerLambertBody => 'Auringon säteily vaimenee kasvustossa eksponentiaalisesti lehtiala-indeksin (LAI) ja sammumiskertoimen (k) funktiona.';

  @override
  String get quickGuideCardBioSomTitle => 'Hiilen dynamiikka: MAOM vs POM';

  @override
  String get quickGuideCardBioSomBody => 'MAOM (Mineral-Associated Organic Matter) on mineraalien pintoihin suojattua pysyvää humusta. POM on karkeaa, nopeasti kiertävää kasvijätettä.';

  @override
  String get quickGuideCardBioCnTitle => 'C/N-suhde ja Typpilukko';

  @override
  String get quickGuideCardBioCnBody => 'Määrää typen mineralisaation ja immobilisaation. Kun C/N > 25 (olki), mikrobit sitovat kaiken vapaan typen. Kun C/N < 20 (apila/lanta), typpeä vapautuu kasville.';

  @override
  String get quickGuideCardBioRedoxTitle => 'Redox-potentiaali (Eh) & Elektroninsiirto';

  @override
  String get quickGuideCardBioRedoxBody => 'Aerobinen soluhengitys vaatii Eh > +300 mV (O₂). Hapen ehtyessä siirrytään nitraatin pelkistykseen, rauta/mangaanioksideihin ja metanogeneesiin (-150 mV).';

  @override
  String get quickGuideCardTipWateringTitle => 'Kastelun ajoitus ja määrä';

  @override
  String get quickGuideCardTipWateringBody => 'Vältä liikakastelua savimailla estääksesi liettymistä ja juuriston tukehtumista. Pidä kosteus kenttäkapasiteetin ja lakastumisrajan välissä.';

  @override
  String get quickGuideCardTipFertilizationTitle => 'Jaettu lannoitus';

  @override
  String get quickGuideCardTipFertilizationBody => 'Kohdista typpilannoitus kasvin aktiivisimpaan kasvuvaiheeseen välttääksesi nitraatin huuhtoutumista pohjaveteen rankkasateilla.';

  @override
  String get quickGuideCardTipCoverCropsTitle => 'Hyödynnä kerääjäkasveja';

  @override
  String get quickGuideCardTipCoverCropsBody => 'Kerääjäkasvit sitovat ylimääräistä nitraattia, luovat syviä bioporeja ja kerryttävät orgaanista hiiltä.';

  @override
  String get quickGuideCardGlosLaiTitle => 'LAI — Lehtialaindeksi';

  @override
  String get quickGuideCardGlosLaiBody => 'Kasvuston lehtipinta-alan suhde maan pinta-alaan (m²/m²).';

  @override
  String get quickGuideCardGlosVpdTitle => 'VPD — Höyrynpainealijäämä (kPa)';

  @override
  String get quickGuideCardGlosVpdBody => 'Ilman kyllästys- ja todellisen höyrynpaineen erotus. Ohjaa ilmakehän haihdutuskysyntää.';

  @override
  String get quickGuideCardGlosCecTitle => 'CEC — Kationinvaihtokapasiteetti';

  @override
  String get quickGuideCardGlosCecBody => 'Maan kyky pidättää positiivisesti varautuneita kationeja savi- ja humuspartikkeleiden pinnoilla.';

  @override
  String get quickGuideCardGlosParTitle => 'PAR — Fotosynteettisesti aktiivinen säteily';

  @override
  String get quickGuideCardGlosParBody => 'Valon aallonpituusalue 400–700 nm, jota lehtivihreä hyödyntää yhteyttämisessä.';

  @override
  String get quickGuideCardGlosStomataTitle => 'Ilmarakojen johtavuus (gs)';

  @override
  String get quickGuideCardGlosStomataBody => 'Ilmarakojen kyky päästää CO₂:ta sisään ja vesihöyryä ulos; reagoi lehtien soluturgoriin.';

  @override
  String get quickGuideCardGlosEcTitle => 'EC — Sähkönjohtavuus (dS/m)';

  @override
  String get quickGuideCardGlosEcBody => 'Maaliuoksen liukoisten suolojen ja ionien kokonaismäärän mittari.';

  @override
  String get briefingButton => 'OHJE';

  @override
  String get quickGuideUiDashboardTitle => 'Tilannekeskus (Dashboard - Vasen palkki)';

  @override
  String get quickGuideUiDashboardBody => 'Avaa maaperän kerroskohtaiset mittarit: vesipitoisuus (θ), lämpötila, pH, sähkönjohtavuus (EC) ja redokspotentiaali (Eh). Sisältää myös maalajikolmion (Texture Triangle), jolla näet maannoksen koostumuksen.';

  @override
  String get quickGuideUiControlsTitle => 'Hallintapaneeli & Viljely (Oikea palkki)';

  @override
  String get quickGuideUiControlsBody => 'Säädä sääolosuhteita (sade, auringonpaiste PAR, lämpötila, CO₂) sekä viljelytoimenpiteitä kuten kastelu, typpi- ja fosforilannoitus, kerääjäkasvit ja maan muokkaus.';

  @override
  String get quickGuideUiTimelineTitle => 'Aikajana & Nopeudensäätö (Alhaalla)';

  @override
  String get quickGuideUiTimelineBody => 'Pysäytä simulaatio hetkeksi tarkastelua varten, valitse nopeus (1x, 2x, 5x, 10x) tai kelaa päiviä taaksepäin nähdäksesi toimenpiteiden aiheuttaman kehityskulun.';

  @override
  String get quickGuideUiNanovisionTitle => 'Nanovision-mikroskooppi (Alhaalla / Hotspots)';

  @override
  String get quickGuideUiNanovisionBody => 'Syvenny solutason biofysiikkaan: tarkastele lehtien ilmarakoja (400x), verson ksyleemiä (200x), kärkimeristeemiä (800x), juuren solurakenteita (400x), ritsosfääriä (600x) ja mikrobeja (1200x).';

  @override
  String get quickGuideSciRichardsTitle => '1D Richards-yhtälö & Kapillaarisuus';

  @override
  String get quickGuideSciRichardsBody => 'Veden virtaus maassa perustuu paine-eroihin ja maaveden potentiaaliin (van Genuchten -malli). Vesi suotautuu alaspäin painovoiman ja imuvoiman ajamana, mutta kuivassa maassa kapillaarivoimat nostavat vettä kohti haihtumispintaa.';

  @override
  String get quickGuideSciPhotosynthesisTitle => 'FvCB-fotosynteesi & Tardieu-ilmarakomalli';

  @override
  String get quickGuideSciPhotosynthesisBody => 'Kasvin yhteyttämisteho määräytyy auringon säteilyn (PAR), lehtien sisäisen CO₂-pitoisuuden ja veden saatavuuden kautta. Kun maaperä kuivuu, kasvi sulkee ilmaraot estääkseen kuivumisen, mikä hidastaa kasvua.';

  @override
  String get quickGuideSciSpacTitle => 'SPAC-jatkumo (Soil-Plant-Atmosphere Continuum)';

  @override
  String get quickGuideSciSpacBody => 'Vesi muodostaa katkeamattoman nestejatkumon maaperän huokosista juuren endodermiksen ja verson johtosolukon kautta lehtien ilmarakoihin ja ilmakehään veden potentiaaligradientin mukaisesti.';

  @override
  String get quickGuideBioNitrogenTitle => 'Typen kierto: Mineralisaatio & Nitrifikaatio';

  @override
  String get quickGuideBioNitrogenBody => 'Orgaaninen typpi muuttuu mikrobien toimesta ammoniumiksi (NH₄⁺), joka nitrifioituu nitraatiksi (NO₃⁻). Nitraatti on kasveille helppokäyttöistä, mutta suotautuu helposti pohjaveteen rankkasateilla.';

  @override
  String get quickGuideBioRedoxTitle => 'Anaerobia, Redoksitila & Denitrifikaatio';

  @override
  String get quickGuideBioRedoxBody => 'Maan vettyessä hapen määrä romahtaa. Mikrobit alkavat käyttää elektroneja nitraatille ja muille yhdisteille (TEA Redox-tikapuut), jolloin muodostuu typpioksiduulia (N₂O) ja metaania (CH₄).';

  @override
  String get quickGuideBioCarbonTitle => 'Hiilipumppu & Mykorritsa (POM / MAOM)';

  @override
  String get quickGuideBioCarbonBody => 'Kasvien juurieritteet aktivoivat mikrobit (Priming Effect). Sienijuuret vaihtavat kasvin hiiltä maaperän fosforiin ja typpeen. Osa mikrobijätteestä sitoutuu pysyvästi mineraalipinnoille stabiiliksi hiileksi (MAOM).';

  @override
  String get quickGuideTipCompactionTitle => 'Tiivistyneen savimaan hoito';

  @override
  String get quickGuideTipCompactionBody => 'Käytä kevyttä muokkausta pintakerroksen avaamiseen ja kylvä syväjuurinen kerääjäkasvi. Vältä raskaiden koneiden käyttöä märällä maalla ja tue mikrobistoa orgaanisella aineksella.';

  @override
  String get quickGuideTipLeachingTitle => 'Nitraatin huuhtoutumisen esto';

  @override
  String get quickGuideTipLeachingBody => 'Vältä suuria kertalannoituksia ennen ennustettua sadetta. Yhdistä mineraalityppi orgaaniseen ainekseen ja käytä syyskasveja tai aluskasveja sitomaan ylimääräinen typpi juuristovyöhykkeeseen.';

  @override
  String get quickGuideTipLogicLabTitle => 'Logic Lab & Tieteelliset kaavat';

  @override
  String get quickGuideTipLogicLabBody => 'Voit kokeilla matemaattisia kaavoja ja biofysiikan riippuvuuksia avaamalla Logic Lab -valikon yläreunan valikosta. Siellä näet mm. Michaelis-Menten -kinetiikan ja Nernst-yhtälön livenä!';

  @override
  String get quickGuideGlosThetaTitle => 'θ — Maaveden tilavuuspitoisuus (m³/m³)';

  @override
  String get quickGuideGlosThetaBody => 'Maan vesipitoisuus suhteessa kokonaistilavuuteen. 0.05 = erittäin kuiva maa (lakastumisraja), 0.25 - 0.35 = optimaalinen kenttäkapasiteetti, > 0.45 = lähes kyllästynyt tai hapeton tulvatila.';

  @override
  String get quickGuideGlosKsatTitle => 'kSat — Kyllästynyt vedenjohtavuus (m/s)';

  @override
  String get quickGuideGlosKsatBody => 'Maan kyky johtaa vettä kyllästystilassa. Karkealla hiekalla suuri (10⁻⁴ m/s = vesi valuu heti läpi), tiivistyneellä savella hyvin pieni (10⁻⁷ - 10⁻⁹ m/s = vesi seisoo pinnalla aiheuttaen pintalietettä).';

  @override
  String get quickGuideGlosEhTitle => 'Eh — Redokspotentiaali (mV)';

  @override
  String get quickGuideGlosEhBody => 'Kuvaa maaperän hapetus-pelkistystilaa. Aerobinen maaperä (+400...+600 mV) tukee normaalia juurihengitystä ja nitrifikaatiota. Anaerobisessa maassa (< +200 mV) denitrifikaatio, raudan pelkistys ja metanogeneesi (-150 mV) käynnistyvät.';

  @override
  String get quickGuideGlosSomTitle => 'MAOM vs. POM — Orgaanisen hiilen jakeet';

  @override
  String get quickGuideGlosSomBody => 'MAOM (Mineral-Associated Organic Matter) on mineraalipinnoille suojautunutta mikrobijohdannaista hiiltä, joka säilyy maassa vuosikymmeniä. POM (Particulate Organic Matter) on karkeaa, nopeasti kiertävää kasvijätettä.';

  @override
  String get quickGuideGlosCnTitle => 'C/N-suhde — Hiili-typpisuhde';

  @override
  String get quickGuideGlosCnBody => 'Määrää typen mineralisaation ja immobilisaation tasapainon. Kun C/N > 25 (esim. olki), mikrobit sitovat kaiken vapaan typen (typpilukko). Kun C/N < 20 (esim. apila tai lanta), typpeä vapautuu kasville.';

  @override
  String get quickGuideGlosParTitle => 'PAR — Fotosynteettinen säteily (µmol m⁻² s⁻¹)';

  @override
  String get quickGuideGlosParBody => 'Aallonpituusalue 400–700 nm, jota lehtien klorofylli käyttää yhteyttämiseen (FvCB-malli). Suora kesäaurinko vastaa n. 1500–2000 µmol m⁻² s⁻¹.';

  @override
  String get quickGuideGlosStomataTitle => 'Stomataali-konduktanssi & Turgor';

  @override
  String get quickGuideGlosStomataBody => 'Ilmarakojen johtavuus säätelee transpiraatiota ja CO₂:n ottoa. Tardieu-mallin mukaisesti vesistressissä solujen turgorpaine laskee, jolloin ilmaraot sulkeutuvat estääkseen kuivumisen.';

  @override
  String get quickGuideGlosRichardsTitle => 'Richards-yhtälö & van Genuchten';

  @override
  String get quickGuideGlosRichardsBody => 'Epälineaarinen osittaisdifferentiaaliyhtälö maaveden virtaukselle kyllästymättömässä huokosverkostossa. Yhdistää painovoiman ja kapillaarisen imupaineen (van Genuchten -käyrä).';

  @override
  String get meterSoilHealth => 'MAA TERVEYS';

  @override
  String get meterMoisture => 'KOSTEUS';

  @override
  String get meterMicrobes => 'MIKROBIT';

  @override
  String get meterPlantVitality => 'KASVI VITALITEETTI';

  @override
  String get meterSoilHealthShort => 'MAA';

  @override
  String get meterMoistureShort => 'VESI';

  @override
  String get meterMicrobesShort => 'MIKR';

  @override
  String get meterPlantVitalityShort => 'KASVI';

  @override
  String get tutorialGuideCardTitle => 'SoilScope-opastus & Käyttöopas';

  @override
  String get tutorialGuideCardDesc => 'Tutustu sovelluksen toimintaan, SPAC-fysiikkaan ja viljelytoimenpiteisiin.';

  @override
  String get tutorialTryAction => 'Kokeile toimintoa:';

  @override
  String get scenarioMissionGuideBadge => 'SKENAARIOTEHTÄVÄ & OHJE';
}
