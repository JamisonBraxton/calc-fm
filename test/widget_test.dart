import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(Key('key-$key'));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('buttons calculate and AC clears', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    for (final key in ['2', '+', '3', '×', '4', '=']) {
      await tap(tester, key);
    }
    expect(tester.widget<Text>(find.byKey(const Key('display'))).data, '20');
    await tap(tester, 'AC');
    expect(tester.widget<Text>(find.byKey(const Key('display'))).data, '0');
  });

  testWidgets('theme changes without clearing the current operation', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());
    await tap(tester, '7');
    await tap(tester, '+');
    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    await tap(tester, '2');
    await tap(tester, '=');
    expect(tester.widget<Text>(find.byKey(const Key('display'))).data, '9');
    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });

  testWidgets('zero division has visible recovery guidance', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    for (final key in ['8', '÷', '0', '=']) {
      await tap(tester, key);
    }
    expect(tester.widget<Text>(find.byKey(const Key('display'))).data, 'Error');
    expect(
      tester.widget<Text>(find.byKey(const Key('message'))).data,
      contains('AC'),
    );
    await tap(tester, 'AC');
    expect(tester.widget<Text>(find.byKey(const Key('display'))).data, '0');
  });
  testWidgets('announce committed totals instead of each digit', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const CalculatorApp());
      for (final key in ['2', '+', '3']) {
        await tap(tester, key);
      }
      expect(find.bySemanticsLabel('Calculator ready'), findsOneWidget);
      await tap(tester, '×');
      expect(find.bySemanticsLabel('Running total 5'), findsOneWidget);
      await tap(tester, '4');
      expect(find.bySemanticsLabel('Running total 5'), findsOneWidget);
      await tap(tester, '=');
      expect(find.bySemanticsLabel('Result 20'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('layout remains usable at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const CalculatorApp());
      expect(tester.takeException(), isNull);
      for (final key in ['9', '÷', '3', '=']) {
        await tap(tester, key);
        expect(tester.takeException(), isNull);
      }
      expect(tester.widget<Text>(find.byKey(const Key('display'))).data, '3');
    });
  }
}
