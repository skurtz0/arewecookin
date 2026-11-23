import 'package:arewecookin/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final size in [const Size(768, 1024), const Size(1024, 768), const Size(1440, 900), const Size(640, 360)]) {
    testWidgets('every tab has no overflow at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: MainNavigationScreen())));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      final destinations = find.byType(NavigationDestination);
      for (var i = 0; i < destinations.evaluate().length; i++) {
        await tester.tap(destinations.at(i));
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull, reason: 'tab $i');
      }
    });
  }
}
