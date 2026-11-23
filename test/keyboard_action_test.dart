import 'package:arewecookin/screens/discover_screen.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('search fields show a search key, the pantry field a done key', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: Scaffold(body: DiscoverScreen()))));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<TextField>(find.byKey(const Key('discover_search_field'))).textInputAction,
      TextInputAction.search,
    );
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PantryScreen())));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byKey(const Key('pantry_custom_field'))).textInputAction,
      TextInputAction.done,
    );
  });
}
