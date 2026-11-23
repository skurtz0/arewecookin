import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:arewecookin/screens/shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final entry in {
    'shopping_add_field': const ShoppingListScreen(),
    'pantry_custom_field': const PantryScreen(),
  }.entries) {
    testWidgets('${entry.key} starts sentences with a capital letter', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: entry.value)));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byKey(Key(entry.key)));
      expect(field.textCapitalization, TextCapitalization.sentences);
    });
  }
}
