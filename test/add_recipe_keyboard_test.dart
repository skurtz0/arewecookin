import 'package:arewecookin/screens/add_recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('amount field takes a text keyboard so 1/2 can be typed; names capitalise', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AddRecipeScreen())));
    await tester.pumpAndSettle();
    final amount = find.byKey(const Key('ingredient_amount_0'));
    await tester.ensureVisible(amount);
    final field = tester.widget<TextField>(find.descendant(of: amount, matching: find.byType(TextField)));
    expect(field.keyboardType, TextInputType.text);
    await tester.enterText(amount, '1/2');
    expect(find.text('1/2'), findsOneWidget);
  });
}
