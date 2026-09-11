import 'package:flutter_test/flutter_test.dart';

import 'package:calculadora_flutter/main.dart';

void main() {
  testWidgets('calculator renders keypad', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(find.text('0'), findsWidgets);
    expect(find.text('AC'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('='), findsOneWidget);
  });

  testWidgets('calculator adds numbers', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('5'), findsWidgets);
  });
}
