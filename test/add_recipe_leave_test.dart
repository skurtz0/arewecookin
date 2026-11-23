import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/screens/add_recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _open(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            key: const Key('open'),
            onPressed: () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const AddRecipeScreen())),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an empty form closes without asking', (tester) async {
    await _open(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(AddRecipeScreen), findsNothing);
  });

  testWidgets('a typed-in form asks before closing; keep editing stays, discard leaves', (tester) async {
    await _open(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Menemen');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('discard_leave')), findsOneWidget);
    await tester.tap(find.byKey(const Key('discard_keep')));
    await tester.pumpAndSettle();
    expect(find.byType(AddRecipeScreen), findsOneWidget);
    expect(find.text('Menemen'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('discard_leave')));
    await tester.pumpAndSettle();
    expect(find.byType(AddRecipeScreen), findsNothing);
  });

  testWidgets('publishing without a name shows the localized validation message', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Publish Recipe').first);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a recipe name'), findsOneWidget);
  });

  testWidgets('zero or negative numbers are kept in a sane range when publishing', (tester) async {
    await _open(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Recipe Title'), 'Test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Ingredient name (e.g. Olive oil)').first, 'Domates');
    await tester.enterText(find.widgetWithText(TextFormField, 'Step instructions...').first, 'Pisir.');
    final fields = find.byType(TextFormField);
    final texts = [for (var i = 0; i < fields.evaluate().length; i++) tester.widget<TextFormField>(fields.at(i)).controller?.text];
    final servingsIdx = texts.indexOf('4');
    expect(servingsIdx, greaterThanOrEqualTo(0));
    await tester.enterText(fields.at(servingsIdx), '0');
    await tester.tap(find.text('Publish Recipe').first);
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)), listen: false);
    final saved = c.read(customRecipesProvider);
    expect(saved, isNotEmpty);
    expect(saved.first.servings, 1);
  });
}
