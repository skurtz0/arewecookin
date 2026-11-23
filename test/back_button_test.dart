import 'package:arewecookin/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('back on another tab returns to Discover instead of leaving', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: MainNavigationScreen())));
    await tester.pump(const Duration(milliseconds: 500));
    final nav = find.byType(NavigationBar);
    expect(tester.widget<NavigationBar>(nav).selectedIndex, 0);
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.widget<NavigationBar>(nav).selectedIndex, 2);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.widget<NavigationBar>(nav).selectedIndex, 0);
  });
}
