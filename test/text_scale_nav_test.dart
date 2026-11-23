import 'package:arewecookin/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('every tab of the main navigation has no overflow at 1.8x text, 360px', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: child!,
        ),
        home: const MainNavigationScreen(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    final destinations = find.byType(NavigationDestination);
    final n = destinations.evaluate().length;
    expect(n, greaterThan(1));
    for (var i = 0; i < n; i++) {
      await tester.tap(destinations.at(i));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull, reason: 'tab $i');
    }
  });
}
