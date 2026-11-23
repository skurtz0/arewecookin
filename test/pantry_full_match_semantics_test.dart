import 'dart:ui';
import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('100% match chip is a toggle button for screen readers', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(pantryProvider.notifier).addIngredients(['tomato']);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.text('100% Match Only'));
    final flags = node.getSemanticsData();
    expect(flags.flagsCollection.isButton, isTrue);
    expect(flags.flagsCollection.isToggled != Tristate.none, isTrue);
    handle.dispose();
  });
}
