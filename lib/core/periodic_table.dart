import 'package:flutter/material.dart';
import 'cpk_standards.dart';

enum ElementCategory {
  nonmetal,
  nobleGas,
  alkaliMetal,
  alkalineEarthMetal,
  metalloid,
  halogen,
  transitionMetal,
  postTransitionMetal,
  lanthanide,
  actinide,
}

class ElementInfo {
  final String symbol;
  final String name;
  final int atomicNumber;
  final double atomicMass;
  final int typicalCharge;
  final ElementCategory category;
  final String soilRole;
  final int group;
  final int period;

  const ElementInfo({
    required this.symbol,
    required this.name,
    required this.atomicNumber,
    required this.atomicMass,
    required this.typicalCharge,
    required this.category,
    required this.soilRole,
    required this.group,
    required this.period,
  });

  /// CPK (Corey-Pauling-Koltun) standard color for this element.
  /// Used for consistent chemical visualization.
  Color get cpkColor => CPKStandards.getColor(symbol);

  /// Default category-based color for the periodic table view.
  Color get color {
    switch (category) {
      case ElementCategory.nonmetal:
        return const Color(0xFF64748B); // Slate
      case ElementCategory.nobleGas:
        return const Color(0xFF94A3B8); // Light Slate
      case ElementCategory.alkaliMetal:
        return const Color(0xFFB91C1C); // Muted Red
      case ElementCategory.alkalineEarthMetal:
        return const Color(0xFFC2410C); // Muted Orange
      case ElementCategory.metalloid:
        return const Color(0xFF0F766E); // Muted Teal
      case ElementCategory.halogen:
        return const Color(0xFF1D4ED8); // Muted Blue
      case ElementCategory.transitionMetal:
        return const Color(0xFF701A75); // Muted Fuchsia
      case ElementCategory.postTransitionMetal:
        return const Color(0xFF334155); // Dark Slate
      case ElementCategory.lanthanide:
        return const Color(0xFF4338CA); // Muted Indigo
      case ElementCategory.actinide:
        return const Color(0xFF581C87); // Muted Purple
    }
  }
}

class PeriodicTable {
  static const Map<String, ElementInfo> elements = {
    'H': ElementInfo(
      symbol: 'H',
      name: 'Hydrogen',
      atomicNumber: 1,
      atomicMass: 1.008,
      typicalCharge: 1,
      category: ElementCategory.nonmetal,
      group: 1,
      period: 1,
      soilRole:
          'Determines soil pH. Essential for all organic molecules and water.',
    ),
    'He': ElementInfo(
      symbol: 'He',
      name: 'Helium',
      atomicNumber: 2,
      atomicMass: 4.0026,
      typicalCharge: 0,
      category: ElementCategory.nobleGas,
      group: 18,
      period: 1,
      soilRole: 'Inert gas. Not involved in soil biological processes.',
    ),
    'Li': ElementInfo(
      symbol: 'Li',
      name: 'Lithium',
      atomicNumber: 3,
      atomicMass: 6.94,
      typicalCharge: 1,
      category: ElementCategory.alkaliMetal,
      group: 1,
      period: 2,
      soilRole: 'Trace element. Can be toxic in high concentrations.',
    ),
    'Be': ElementInfo(
      symbol: 'Be',
      name: 'Beryllium',
      atomicNumber: 4,
      atomicMass: 9.0122,
      typicalCharge: 2,
      category: ElementCategory.alkalineEarthMetal,
      group: 2,
      period: 2,
      soilRole: 'Rare trace element. No known biological role in plants.',
    ),
    'B': ElementInfo(
      symbol: 'B',
      name: 'Boron',
      atomicNumber: 5,
      atomicMass: 10.81,
      typicalCharge: 3,
      category: ElementCategory.metalloid,
      group: 13,
      period: 2,
      soilRole:
          'Essential micronutrient. Critical for cell wall formation and pollen tube growth.',
    ),
    'C': ElementInfo(
      symbol: 'C',
      name: 'Carbon',
      atomicNumber: 6,
      atomicMass: 12.011,
      typicalCharge: 4,
      category: ElementCategory.nonmetal,
      group: 14,
      period: 2,
      soilRole:
          'Backbone of Soil Organic Matter (SOM). Primary energy source for microbes via photosynthesis.',
    ),
    'N': ElementInfo(
      symbol: 'N',
      name: 'Nitrogen',
      atomicNumber: 7,
      atomicMass: 14.007,
      typicalCharge: 5,
      category: ElementCategory.nonmetal,
      group: 15,
      period: 2,
      soilRole:
          'Primary macronutrient. Component of amino acids, proteins, and chlorophyll.',
    ),
    'O': ElementInfo(
      symbol: 'O',
      name: 'Oxygen',
      atomicNumber: 8,
      atomicMass: 15.999,
      typicalCharge: -2,
      category: ElementCategory.nonmetal,
      group: 16,
      period: 2,
      soilRole:
          'Required for root and microbial respiration. Drives soil redox potential.',
    ),
    'F': ElementInfo(
      symbol: 'F',
      name: 'Fluorine',
      atomicNumber: 9,
      atomicMass: 18.998,
      typicalCharge: -1,
      category: ElementCategory.halogen,
      group: 17,
      period: 2,
      soilRole: 'Trace element. Usually present as fluoride in minerals.',
    ),
    'Ne': ElementInfo(
      symbol: 'Ne',
      name: 'Neon',
      atomicNumber: 10,
      atomicMass: 20.180,
      typicalCharge: 0,
      category: ElementCategory.nobleGas,
      group: 18,
      period: 2,
      soilRole: 'Inert noble gas.',
    ),
    'Na': ElementInfo(
      symbol: 'Na',
      name: 'Sodium',
      atomicNumber: 11,
      atomicMass: 22.990,
      typicalCharge: 1,
      category: ElementCategory.alkaliMetal,
      group: 1,
      period: 3,
      soilRole:
          'Non-essential but can substitute for K in some plants. High levels cause sodicity and structural collapse.',
    ),
    'Mg': ElementInfo(
      symbol: 'Mg',
      name: 'Magnesium',
      atomicNumber: 12,
      atomicMass: 24.305,
      typicalCharge: 2,
      category: ElementCategory.alkalineEarthMetal,
      group: 2,
      period: 3,
      soilRole:
          'Macronutrient. Central atom of the chlorophyll molecule and enzyme activator.',
    ),
    'Al': ElementInfo(
      symbol: 'Al',
      name: 'Aluminium',
      atomicNumber: 13,
      atomicMass: 26.982,
      typicalCharge: 3,
      category: ElementCategory.postTransitionMetal,
      group: 13,
      period: 3,
      soilRole:
          'Highly abundant in minerals. Becomes toxic (Al3+) to roots at low pH (< 5.5).',
    ),
    'Si': ElementInfo(
      symbol: 'Si',
      name: 'Silicon',
      atomicNumber: 14,
      atomicMass: 28.085,
      typicalCharge: 4,
      category: ElementCategory.metalloid,
      group: 14,
      period: 3,
      soilRole:
          'Beneficial element. Improves plant structural strength and resistance to stress.',
    ),
    'P': ElementInfo(
      symbol: 'P',
      name: 'Phosphorus',
      atomicNumber: 15,
      atomicMass: 30.974,
      typicalCharge: 5,
      category: ElementCategory.nonmetal,
      group: 15,
      period: 3,
      soilRole:
          'Macronutrient. Critical for energy transfer (ATP), DNA, and root development.',
    ),
    'S': ElementInfo(
      symbol: 'S',
      name: 'Sulfur',
      atomicNumber: 16,
      atomicMass: 32.06,
      typicalCharge: 6,
      category: ElementCategory.nonmetal,
      group: 16,
      period: 3,
      soilRole:
          'Secondary macronutrient. Component of amino acids (methionine, cysteine) and vitamins.',
    ),
    'Cl': ElementInfo(
      symbol: 'Cl',
      name: 'Chlorine',
      atomicNumber: 17,
      atomicMass: 35.45,
      typicalCharge: -1,
      category: ElementCategory.halogen,
      group: 17,
      period: 3,
      soilRole:
          'Micronutrient. Involved in osmosis, ionic balance, and photosynthesis.',
    ),
    'Ar': ElementInfo(
      symbol: 'Ar',
      name: 'Argon',
      atomicNumber: 18,
      atomicMass: 39.948,
      typicalCharge: 0,
      category: ElementCategory.nobleGas,
      group: 18,
      period: 3,
      soilRole: 'Inert gas.',
    ),
    'K': ElementInfo(
      symbol: 'K',
      name: 'Potassium',
      atomicNumber: 19,
      atomicMass: 39.098,
      typicalCharge: 1,
      category: ElementCategory.alkaliMetal,
      group: 1,
      period: 4,
      soilRole:
          'Primary macronutrient. Regulates stomatal opening, enzyme activation, and water potential.',
    ),
    'Ca': ElementInfo(
      symbol: 'Ca',
      name: 'Calcium',
      atomicNumber: 20,
      atomicMass: 40.078,
      typicalCharge: 2,
      category: ElementCategory.alkalineEarthMetal,
      group: 2,
      period: 4,
      soilRole:
          'Secondary macronutrient. Stabilizes cell walls and improves soil structure via flocculation.',
    ),
    'Mn': ElementInfo(
      symbol: 'Mn',
      name: 'Manganese',
      atomicNumber: 25,
      atomicMass: 54.938,
      typicalCharge: 2,
      category: ElementCategory.transitionMetal,
      group: 7,
      period: 4,
      soilRole:
          'Micronutrient. Critical for the oxygen-evolving complex in photosynthesis.',
    ),
    'Fe': ElementInfo(
      symbol: 'Fe',
      name: 'Iron',
      atomicNumber: 26,
      atomicMass: 55.845,
      typicalCharge: 3,
      category: ElementCategory.transitionMetal,
      group: 8,
      period: 4,
      soilRole:
          'Micronutrient. Essential for chlorophyll synthesis and electron transfer (redox).',
    ),
    'Cu': ElementInfo(
      symbol: 'Cu',
      name: 'Copper',
      atomicNumber: 29,
      atomicMass: 63.546,
      typicalCharge: 2,
      category: ElementCategory.transitionMetal,
      group: 11,
      period: 4,
      soilRole:
          'Micronutrient. Component of enzymes involved in lignin synthesis and photosynthesis.',
    ),
    'Zn': ElementInfo(
      symbol: 'Zn',
      name: 'Zinc',
      atomicNumber: 30,
      atomicMass: 65.38,
      typicalCharge: 2,
      category: ElementCategory.transitionMetal,
      group: 12,
      period: 4,
      soilRole:
          'Micronutrient. Required for hormone (auxin) production and enzyme function.',
    ),
    'Mo': ElementInfo(
      symbol: 'Mo',
      name: 'Molybdenum',
      atomicNumber: 42,
      atomicMass: 95.95,
      typicalCharge: 6,
      category: ElementCategory.transitionMetal,
      group: 6,
      period: 5,
      soilRole:
          'Micronutrient. Critical for nitrogen fixation and nitrate reduction.',
    ),
  };

  static ElementInfo getElement(String symbol) {
    return elements[symbol] ?? elements['H']!;
  }
}
