import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('missing ingredients of a pantry match can be sent to the shopping list', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    await container.read(pantryProvider.notifier).addIngredient('yumurta');
    await tester.pumpAndSettle();
    final buttons = find.byWidgetPredicate((w) => w.key.toString().contains('add_missing_'));
    expect(buttons, findsWidgets);
    await tester.ensureVisible(buttons.first);
    await tester.pumpAndSettle();
    await tester.tap(buttons.first);
    await tester.pump();
    expect(container.read(shoppingListProvider), isNotEmpty);
  });

  testWidgets('custom ingredient hint follows the app language (English by default)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PantryScreen())));
    await tester.pumpAndSettle();
    expect(find.textContaining('Add another ingredient'), findsOneWidget);
    expect(find.textContaining('Farklı malzeme ekle'), findsNothing);
  });

  testWidgets('clearing the pantry can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    await container.read(pantryProvider.notifier).addIngredient('yumurta');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear All'));
    await tester.pumpAndSettle();
    expect(container.read(pantryProvider).selectedKeys, isEmpty);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(container.read(pantryProvider).selectedKeys, {'yumurta'});
  });

  testWidgets('a failing match shows an error with retry that recovers', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = _FlakyRepository();
    final container = ProviderContainer(overrides: [recipeRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    await container.read(pantryProvider.notifier).addIngredient('yumurta');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pantry_error')), findsOneWidget);
    repo.fail = false;
    await tester.tap(find.byKey(const Key('pantry_retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pantry_error')), findsNothing);
  });

  testWidgets('custom ingredient field accepts several comma separated ingredients', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '').first, 'Mantar, Patlıcan ; sucuk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(container.read(pantryProvider).selectedKeys, {'mantar', 'patlıcan', 'sucuk'});
  });
}

class _FlakyRepository extends RecipeRepository {
  bool fail = true;

  @override
  Future<List<Recipe>> matchRecipesByPantry({
    required List<String> userIngredientKeys,
    String? cuisine,
    int limit = 50,
  }) async {
    if (fail) throw Exception('offline');
    return const [];
  }
}
