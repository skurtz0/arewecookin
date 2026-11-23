import 'package:arewecookin/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final code in ['ar', 'ja', 'de', 'ru']) {
    testWidgets('every tab has no overflow in "$code" at 360px and 1.4x text', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.platformDispatcher.localesTestValue = [Locale(code)];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          locale: Locale(code),
          builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.4)),
            child: child!,
          ),
          home: const MainNavigationScreen(),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      final destinations = find.byType(NavigationDestination);
      for (var i = 0; i < destinations.evaluate().length; i++) {
        await tester.tap(destinations.at(i));
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull, reason: '$code tab $i');
      }
    });
  }
}
