import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/core/periodic_table.dart';
import 'package:soilscope/core/cpk_standards.dart';

void main() {
  group('PeriodicTable Core & Agronomy Tests', () {
    test('Periodic table contains expanded elements covering periods 1-5 and key period 6 elements', () {
      expect(PeriodicTable.elements.length, greaterThanOrEqualTo(61));
      
      // Verify key agricultural elements are present
      final requiredElements = [
        'H', 'C', 'N', 'O', 'P', 'K', 'Ca', 'Mg', 'S', // Macronutrients & structural
        'Fe', 'Mn', 'Zn', 'Cu', 'B', 'Mo', 'Cl', 'Ni', 'Co', // Micronutrients
        'Si', 'Na', 'Se', 'Al', // Beneficial / Soil minerals
        'Cd', 'Pb', 'As', 'Hg', // Toxic heavy metals
      ];

      for (final symbol in requiredElements) {
        final element = PeriodicTable.getBySymbol(symbol);
        expect(element, isNotNull, reason: 'Element $symbol should exist');
        expect(element!.nameFi.isNotEmpty, isTrue, reason: '$symbol must have Finnish name');
        expect(element.nameEn.isNotEmpty, isTrue, reason: '$symbol must have English name');
        expect(element.soilRoleFi.isNotEmpty, isTrue, reason: '$symbol must have Finnish soil role');
        expect(element.soilRoleEn.isNotEmpty, isTrue, reason: '$symbol must have English soil role');
        expect(element.atomicMass, greaterThan(0));
      }
    });

    test('O(1) coordinate lookup PeriodicTable.getByPosition returns accurate elements', () {
      // Period 1, Group 1: Hydrogen
      final h = PeriodicTable.getByPosition(1, 1);
      expect(h?.symbol, equals('H'));

      // Period 1, Group 18: Helium
      final he = PeriodicTable.getByPosition(1, 18);
      expect(he?.symbol, equals('He'));

      // Period 4, Group 1: Potassium
      final k = PeriodicTable.getByPosition(4, 1);
      expect(k?.symbol, equals('K'));

      // Period 4, Group 2: Calcium
      final ca = PeriodicTable.getByPosition(4, 2);
      expect(ca?.symbol, equals('Ca'));

      // Period 4, Group 8: Iron
      final fe = PeriodicTable.getByPosition(4, 8);
      expect(fe?.symbol, equals('Fe'));

      // Invalid position returns null
      expect(PeriodicTable.getByPosition(1, 2), isNull);
      expect(PeriodicTable.getByPosition(99, 99), isNull);
    });

    test('Agronomic role classifications correctly group nutrients and contaminants', () {
      final nitrogen = PeriodicTable.getBySymbol('N')!;
      expect(nitrogen.agronomicRole, equals(ElementAgronomicRole.macronutrient));

      final phosphorus = PeriodicTable.getBySymbol('P')!;
      expect(phosphorus.agronomicRole, equals(ElementAgronomicRole.macronutrient));

      final zinc = PeriodicTable.getBySymbol('Zn')!;
      expect(zinc.agronomicRole, equals(ElementAgronomicRole.micronutrient));

      final silicon = PeriodicTable.getBySymbol('Si')!;
      expect(silicon.agronomicRole, equals(ElementAgronomicRole.beneficial));

      final lead = PeriodicTable.getBySymbol('Pb')!;
      expect(lead.agronomicRole, equals(ElementAgronomicRole.toxic));
    });

    test('CPK Standards provide distinct colors for soil elements', () {
      final hColor = CPKStandards.getColor('H');
      final cColor = CPKStandards.getColor('C');
      final nColor = CPKStandards.getColor('N');
      final oColor = CPKStandards.getColor('O');
      final pColor = CPKStandards.getColor('P');
      final kColor = CPKStandards.getColor('K');

      expect(hColor, isNotNull);
      expect(cColor, isNotNull);
      expect(nColor, isNotNull);
      expect(oColor, isNotNull);
      expect(pColor, isNotNull);
      expect(kColor, isNotNull);
      
      // Ensure different elements have distinct colors where expected
      expect(hColor, isNot(equals(cColor)));
      expect(nColor, isNot(equals(pColor)));
    });
  });
}
