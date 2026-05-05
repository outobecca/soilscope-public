import 'dart:math';
import '../models/biophysical_state.dart';
import 'models.dart';

/// Laskentamoottori, joka laskee graafin arvon BiophysicalStaten perusteella.
///
/// Tuetut funktiot:
/// - Q10: Lämpötilakerroin (temp, base)
/// - MM: Michaelis-Menten entsyymikinetiikka (S, Vmax, Km)
/// - VG: van Genuchten vedenpidätys (h, θr, θs, α, n) → θ
/// - Farquhar: Fotosynteesi An (Ci, Vcmax, Kc, O)
/// - Redox: Nernst-yhtälö (pe0, ratio, n)
class LogicEvaluator {
  /// Laskee graafin läpi ja päivittää nodien arvot.
  static LogicGraph evaluate(LogicGraph graph, BiophysicalState state) {
    // Luodaan kopio nodeista, jotta voimme päivittää niiden arvot
    final updatedNodes = List<LogicNode>.from(graph.nodes);

    // 1. Päivitetään input-nodet simulaatiodatalla
    for (int i = 0; i < updatedNodes.length; i++) {
      final node = updatedNodes[i];
      if (node.type == NodeType.input) {
        updatedNodes[i] = node.copyWith(
          value: _getInputValue(node.operation, state),
        );
      }
    }

    // 2. Lasketaan muut nodet järjestyksessä (yksinkertaistettu topologinen laskenta)
    // Tässä prototyypissä käydään läpi n kertaa varmistaen että kaikki päivittyvät.
    for (int iteration = 0; iteration < 5; iteration++) {
      for (int i = 0; i < updatedNodes.length; i++) {
        final node = updatedNodes[i];
        if (node.type == NodeType.math ||
            node.type == NodeType.function ||
            node.type == NodeType.output) {
          final inputs = _getNodeInputs(
            node.id,
            graph.connections,
            updatedNodes,
          );
          updatedNodes[i] = node.copyWith(
            value: _calculateNodeValue(node, inputs),
          );
        }
      }
    }

    return LogicGraph(nodes: updatedNodes, connections: graph.connections);
  }

  /// Hakee simulaatiodatasta arvon operaation nimen perusteella.
  ///
  /// Tuetut inputit:
  ///
  /// **Maaperän fysiikka:**
  /// - temp: Lämpötila (°C)
  /// - moisture: Vesipitoisuus (m³/m³)
  /// - saturation: Kyllästysaste (0-1)
  /// - porosity: Huokoisuus
  /// - ksat: Kyllästysjohtavuus (m/s)
  ///
  /// **Maaperän kemia:**
  /// - ph: pH-arvo
  /// - redox_pe: Redox-potentiaali (pe-yksikössä)
  /// - redox_eh: Redox-potentiaali (mV)
  /// - ec: Sähkönjohtavuus (dS/m)
  /// - cec: Kationinvaihtokapasiteetti (cmol/kg)
  ///
  /// **Typpi:**
  /// - nh4: Ammonium (mg/kg)
  /// - no3: Nitraatti (mg/kg)
  /// - org_n: Orgaaninen typpi (mg/kg)
  /// - mic_n: Mikrobinen typpi (mg/kg)
  ///
  /// **Fosfori & kalium:**
  /// - p_sol: Liukoinen fosfaatti (mg/kg)
  /// - p_sorb: Sorboitunut fosfaatti (mg/kg)
  /// - k_sol: Liukoinen kalium (mg/kg)
  /// - k_exch: Vaihtuva kalium (mg/kg)
  ///
  /// **Hiili & orgaaninen aines:**
  /// - org_c: Orgaaninen hiili
  /// - pom: Partikkelimainen orgaaninen aines (POM)
  /// - maom: Mineraaleihin sitoutunut org. aines (MAOM)
  /// - mic_bio: Mikrobinen biomassa (kg/m³)
  ///
  /// **Kaasut:**
  /// - o2: Happipitoisuus (mol/m³)
  /// - co2: Hiilidioksidipitoisuus (mol/m³)
  /// - co2_atm: Ilmakehän CO₂ (mol/m³)
  ///
  /// **Rakenne:**
  /// - clay: Savipitoisuus (0-1)
  /// - sand: Hiekkapitoisuus (0-1)
  /// - silt: Siltipitoisuus (0-1)
  /// - agg_stab: Aggregaattien stabiilius (0-1)
  /// - macro_poro: Efektiivinen makrohuokoisuus
  ///
  /// **Biologinen:**
  /// - hyphae: Sienirihmaston tiheys
  /// - eps: Ekstrasellulaarinen polysakkaridi
  /// - necro: Nekromassa
  ///
  /// **Kasvi:**
  /// - turgor: Nestejännitys (MPa)
  /// - lai: Lehtialaindeksi
  /// - biomass: Kokonaisbiomassa (mg)
  /// - root_bio: Juuriston biomassa (mg)
  /// - psi_leaf: Lehtien vesipotentiaali (MPa)
  /// - n_uptake: Typen otto
  /// - h2o_uptake: Veden otto
  ///
  /// **Ympäristö:**
  /// - precip: Sademäärä
  /// - air_temp: Ilman lämpötila (°C)
  /// - rh: Suhteellinen kosteus (0-1)
  ///
  /// **Mykoritsa:**
  /// - myc_colon: Kolonisaatioaste (0-1)
  /// - myc_c: C-siirto kasvi→sieni
  /// - myc_p: P-siirto sieni→kasvi
  static double _getInputValue(String? operation, BiophysicalState state) {
    if (state.profile.layers.isEmpty) return 0.0;
    final layer = state.profile.layers.first;

    switch (operation) {
      // === MAAPERÄN FYSIIKKA ===
      case 'temp':
        return layer.temperature - 273.15; // K → °C
      case 'moisture':
        return layer.waterContent;
      case 'saturation':
        return layer.porosity > 0 ? layer.waterContent / layer.porosity : 0.0;
      case 'porosity':
        return layer.porosity;
      case 'ksat':
        return layer.kSat;

      // === MAAPERÄN KEMIA ===
      case 'ph':
        return layer.ph;
      case 'redox_pe':
        return layer.redoxPotential / 59.16; // mV → pe (25°C)
      case 'redox_eh':
        return layer.redoxPotential; // mV
      case 'ec':
        return layer.ec;
      case 'cec':
        return layer.cec;

      // === TYPPI ===
      case 'nh4':
        return layer.ammoniumContent;
      case 'no3':
        return layer.nitrateContent;
      case 'org_n':
        return layer.organicNitrogen;
      case 'mic_n':
        return layer.microbialNitrogen;
      case 'maom_n':
        return layer.maomNitrogen;
      case 'total_n':
        return layer.nitrogenContent;

      // === FOSFORI & KALIUM ===
      case 'p_sol':
        return layer.phosphateContent;
      case 'p_sorb':
        return layer.sorbedPhosphate;
      case 'k_sol':
        return layer.potassiumContent;
      case 'k_exch':
        return layer.exchangeablePotassium;
      case 'ca_sol':
        return layer.solutionCalcium;
      case 'ca_exch':
        return layer.exchangeableCalcium;
      case 'mg_sol':
        return layer.solutionMagnesium;
      case 'mg_exch':
        return layer.exchangeableMagnesium;

      // === HIILI & ORGAANINEN AINES ===
      case 'org_c':
        return layer.organicCarbon;
      case 'pom':
        return layer.particulateOrganicMatter;
      case 'maom':
        return layer.mineralAssociatedOrganicMatter;
      case 'mic_bio':
        return layer.microbialBiomass;

      // === KAASUT ===
      case 'o2':
        return layer.oxygenContent;
      case 'co2':
        return layer.co2Content;
      case 'co2_atm':
        return state.atmCO2;

      // === RAKENNE ===
      case 'clay':
        return layer.clayFraction;
      case 'sand':
        return layer.sandFraction;
      case 'silt':
        return layer.siltFraction;
      case 'agg_stab':
        return layer.aggregateStability;
      case 'macro_poro':
        return layer.effectiveMacroPorosity;

      // === BIOLOGINEN ===
      case 'hyphae':
        return layer.fungalHyphaeDensity;
      case 'eps':
        return layer.epsContent;
      case 'necro':
        return layer.necromass;

      // === KASVI ===
      case 'turgor':
        return state.plant.turgorPressure;
      case 'lai':
        return state.plant.lai;
      case 'biomass':
        return state.plant.totalBiomass;
      case 'root_bio':
        return state.plant.rootBiomass;
      case 'psi_leaf':
        return state.plant.psiLeaf;
      case 'n_uptake':
        return state.plant.nitrogenUptake;
      case 'h2o_uptake':
        return state.plant.waterUptake;
      case 'height':
        return state.plant.height;
      case 'age':
        return state.plant.age;

      // === YMPÄRISTÖ ===
      case 'precip':
        return state.precipitation;
      case 'air_temp':
        return state.airTemperature - 273.15;
      case 'rh':
        return state.relativeHumidity;
      case 'time':
        return state.timeElapsed;

      // === MYKORITSA ===
      case 'myc_colon':
        return state.mycorrhizaState?.rootColonization ?? 0.0;
      case 'myc_c':
        return state.mycorrhizaState?.carbonTransferredToday ?? 0.0;
      case 'myc_p':
        return state.mycorrhizaState?.pTransferredToday ?? 0.0;
      case 'myc_hyphae':
        return state.mycorrhizaState?.totalHyphalLength ?? 0.0;

      default:
        return 0.0;
    }
  }

  /// Hakee kaikkien nodeen tulevien lankojen arvot.
  static List<double> _getNodeInputs(
    String nodeId,
    List<NodeConnection> connections,
    List<LogicNode> nodes,
  ) {
    final values = <double>[];
    final incoming = connections.where((c) => c.toNodeId == nodeId).toList();
    // Järjestetään portti-indeksin mukaan
    incoming.sort((a, b) => a.toPortIndex.compareTo(b.toPortIndex));

    for (final conn in incoming) {
      final fromNode = nodes.firstWhere((n) => n.id == conn.fromNodeId);
      values.add(fromNode.value);
    }
    return values;
  }

  /// Laskee yksittäisen noden arvon sen syötteiden perusteella.
  static double _calculateNodeValue(LogicNode node, List<double> inputs) {
    if (inputs.isEmpty && node.type != NodeType.constant) return node.value;

    switch (node.operation) {
      // === PERUSMATIKKA ===
      case '+':
        return inputs.fold(0.0, (a, b) => a + b);
      case '-':
        return inputs.length >= 2
            ? inputs[0] - inputs[1]
            : (inputs.isNotEmpty ? inputs[0] : 0.0);
      case '*':
        return inputs.fold(1.0, (a, b) => a * b);
      case '/':
        return inputs.length >= 2 && inputs[1] != 0
            ? inputs[0] / inputs[1]
            : 0.0;

      // === BIOFYSIIKAN FUNKTIOT ===

      /// Q10-lämpötilakerroin
      /// Lähde: van't Hoff (1884)
      /// f(T) = Q10^((T - Tref) / 10)
      case 'Q10':
        if (inputs.length < 2) return 1.0;
        final temp = inputs[0]; // Lämpötila °C
        final q10Base = inputs[1]; // Q10-kerroin (tyypillisesti 2.0)
        const tRef = 20.0; // Referenssilämpötila
        return pow(q10Base, (temp - tRef) / 10).toDouble();

      /// Michaelis-Menten entsyymikinetiikka
      /// Lähde: Michaelis & Menten (1913)
      /// v = Vmax × [S] / (Km + [S])
      case 'MM':
        if (inputs.length < 3) return 0.0;
        final s = inputs[0]; // Substraattipitoisuus
        final vmax = inputs[1]; // Maksimireaktionopeus
        final km = inputs[2]; // Michaelis-vakio
        if (km + s <= 0) return 0.0;
        return vmax * (s / (km + s));

      /// van Genuchten vedenpidätyskäyrä
      /// Lähde: van Genuchten (1980)
      /// θ(h) = θr + (θs - θr) / [1 + |αh|^n]^m, missä m = 1 - 1/n
      case 'VG':
        if (inputs.length < 4) return 0.0;
        final h = inputs[0]; // Paine (cm, negatiivinen maassa)
        final thetaR = inputs[1]; // Jäännöskosteus
        final thetaS = inputs[2]; // Kyllästyskosteus (≈ porositeetti)
        final alpha = inputs[3]; // α (1/cm)
        // n tulee viidennestä inputista tai oletus 1.5
        final n = inputs.length >= 5 ? inputs[4] : 1.5;
        final m = 1 - 1 / n;
        final absH = h.abs();
        final term = 1 + pow(alpha * absH, n);
        return thetaR + (thetaS - thetaR) / pow(term, m);

      /// Farquhar-von Caemmerer-Berry C3-fotosynteesi
      /// Lähde: Farquhar et al. (1980)
      /// Ac = Vcmax × (Ci - Γ*) / (Ci + Kc(1 + O/Ko))
      case 'Farquhar':
        if (inputs.length < 4) return 0.0;
        final ci = inputs[0]; // Soluvälin CO₂ (µmol/mol)
        final vcmax = inputs[1]; // Maksimi karboksylaationopeus (µmol/m²/s)
        final kc = inputs[2]; // Michaelis-vakio CO₂:lle (µmol/mol)
        final o = inputs[3]; // Happipitoisuus (mmol/mol)
        const gammaStar = 42.75; // CO₂ kompensaatiopiste (µmol/mol, 25°C)
        const ko = 274.0; // Michaelis-vakio O₂:lle (mmol/mol)
        final denominator = ci + kc * (1 + o / ko);
        if (denominator <= 0 || ci <= gammaStar) return 0.0;
        return vcmax * (ci - gammaStar) / denominator;

      /// Nernst-yhtälö redox-potentiaalille
      /// Lähde: Nernst (1889), Stumm & Morgan (1996)
      /// pe = pe0 - (1/n) × log10([red]/[ox])
      case 'Redox':
        if (inputs.length < 3) return 0.0;
        final pe0 = inputs[0]; // Standardipotentiaali (pe-yksikössä)
        final ratio = inputs[1]; // [red]/[ox] suhde
        final n = inputs[2]; // Elektronien lukumäärä
        if (ratio <= 0 || n == 0) return pe0;
        return pe0 - (1 / n) * log(ratio) / ln10;

      /// Fickin lakiin perustuva kemotaksis
      /// J = -D × (C2 - C1) / dx
      case 'Chemotaxis':
        if (inputs.length < 4) return 0.0;
        final d = inputs[0]; // Diffuusiokerroin
        final c1 = inputs[1]; // Konsentraatio 1
        final c2 = inputs[2]; // Konsentraatio 2
        final dx = inputs[3]; // Etäisyys
        if (dx <= 0) return 0.0;
        return -d * (c2 - c1) / dx;

      /// Vähimmän energian periaate (Cost-Benefit)
      /// A = C / (D + P)
      case 'CostBenefit':
        if (inputs.length < 2) return 0.0;
        final c = inputs[0]; // Konsentraatio (hyöty)
        final d = inputs[1]; // Etäisyys (kustannus)
        final p = inputs.length >= 3 ? inputs[2] : 0.1; // Rangaistus/Kynnys
        if (d + p <= 0) return 0.0;
        return c / (d + p);

      // === LISÄMATIKKA ===

      /// Potenssi: A^B
      case 'pow':
        if (inputs.length < 2) return 0.0;
        return pow(inputs[0], inputs[1]).toDouble();

      /// Neliöjuuri
      case 'sqrt':
        if (inputs.isEmpty || inputs[0] < 0) return 0.0;
        return sqrt(inputs[0]);

      /// e^x
      case 'exp':
        if (inputs.isEmpty) return 1.0;
        return exp(inputs[0]);

      /// Luonnollinen logaritmi
      case 'ln':
        if (inputs.isEmpty || inputs[0] <= 0) return 0.0;
        return log(inputs[0]);

      /// Kymmenkantainen logaritmi
      case 'log10':
        if (inputs.isEmpty || inputs[0] <= 0) return 0.0;
        return log(inputs[0]) / ln10;

      /// Minimi
      case 'min':
        if (inputs.length < 2) return inputs.isNotEmpty ? inputs[0] : 0.0;
        return inputs[0] < inputs[1] ? inputs[0] : inputs[1];

      /// Maksimi
      case 'max':
        if (inputs.length < 2) return inputs.isNotEmpty ? inputs[0] : 0.0;
        return inputs[0] > inputs[1] ? inputs[0] : inputs[1];

      /// Clamp: rajaa arvo välille [min, max]
      case 'clamp':
        if (inputs.length < 3) return inputs.isNotEmpty ? inputs[0] : 0.0;
        final value = inputs[0];
        final minVal = inputs[1];
        final maxVal = inputs[2];
        if (value < minVal) return minVal;
        if (value > maxVal) return maxVal;
        return value;

      /// Itseisarvo
      case 'abs':
        if (inputs.isEmpty) return 0.0;
        return inputs[0].abs();

      // Output passthrough
      case 'out':
      case 'output':
        return inputs.isNotEmpty ? inputs[0] : 0.0;

      default:
        return node.value; // Constant tai tuntematon
    }
  }
}
