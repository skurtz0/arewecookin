import 'package:arewecookin/providers/cook_history_provider.dart';
import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final scale in [1.0, 1.8]) {
    testWidgets('pantry match card can save a recipe (${scale}x text, 360px)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          builder: (ctx, w) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scale)),
            child: w!,
          ),
          home: const PantryScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      await c.read(pantryProvider.notifier).addIngredients(['yumurta', 'süt', 'un']);
      await tester.pumpAndSettle();
      final icon = find.byIcon(Icons.bookmark_border_rounded);
      for (var n = 0; n < 15 && icon.evaluate().isEmpty; n++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await tester.pump();
      }
      expect(icon, findsWidgets);
      final btn = icon.first;
      await tester.ensureVisible(btn);
      await tester.pump();
      await tester.tap(btn);
      await tester.pump();
      expect(c.read(savedRecipesProvider).savedIds, isNotEmpty);
      // A cooked recipe gets a "cooked" mark on its card.
      expect(find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith('pantry_cooked_')), findsNothing);
      final shownId = c.read(pantryProvider).matchedRecipes.map((r) => r.id).firstWhere((id) => find.byKey(Key('pantry_save_$id')).evaluate().isNotEmpty);
      c.read(cookHistoryProvider.notifier).markCooked(shownId);
      await tester.pump();
      expect(find.byKey(Key('pantry_cooked_$shownId')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
