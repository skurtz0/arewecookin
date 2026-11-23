import 'package:arewecookin/screens/add_recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('removing a filled ingredient row can be undone with its text', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AddRecipeScreen())));
    await tester.pumpAndSettle();
    final amount = find.widgetWithText(TextFormField, 'Miktar');
    expect(amount, findsNWidgets(2));
    await tester.enterText(amount.first, '250');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('250'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Miktar'), findsOneWidget);
    await tester.tap(find.byKey(const Key('remove_undo')));
    await tester.pumpAndSettle();
    expect(find.text('250'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Miktar'), findsNWidgets(2));
  });
}
