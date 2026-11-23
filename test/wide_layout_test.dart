import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/screens/main_navigation_screen.dart';

Future<void> _pump(WidgetTester tester, Size size, {double textScale = 1.0}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const MainNavigationScreen(),
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('wide screens use a side rail and no bottom bar', (tester) async {
    await _pump(tester, const Size(1400, 900));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.descendant(of: find.byType(NavigationRail), matching: find.byIcon(Icons.person_outline_rounded)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('phones keep the bottom bar', (tester) async {
    await _pump(tester, const Size(400, 800));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('content is capped at the maximum width on very wide screens', (tester) async {
    await _pump(tester, const Size(2400, 900));
    final width = tester.getSize(find.byType(IndexedStack)).width;
    expect(width, lessThanOrEqualTo(maxContentWidth));
  });

  for (final size in const [Size(800, 900), Size(1100, 900), Size(1600, 900)]) {
    for (final scale in const [1.0, 1.8]) {
      testWidgets('Discover cards do not overflow at ${size.width.toInt()}px and ${scale}x text', (tester) async {
        await _pump(tester, size, textScale: scale);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
