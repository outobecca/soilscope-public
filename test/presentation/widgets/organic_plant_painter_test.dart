import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/widgets/organic_plant_painter.dart';

void main() {
  testWidgets('OrganicPlantWidget renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrganicPlantWidget(
              growth: 0.5,
              rootGrowth: 0.5,
              leafCount: 3,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(OrganicPlantWidget), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(OrganicPlantWidget),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('OrganicPlantWidget renders with zero growth', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrganicPlantWidget(
              growth: 0.0,
              rootGrowth: 0.0,
              leafCount: 0,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(OrganicPlantWidget), findsOneWidget);
  });

  testWidgets('OrganicPlantWidget renders with full growth', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrganicPlantWidget(
              growth: 1.0,
              rootGrowth: 1.0,
              leafCount: 10,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(OrganicPlantWidget), findsOneWidget);
  });
}
