import 'package:arewecookin/providers/cook_history_provider.dart';
import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Pantry with results and sort button at 1.8x text, 360px wide', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(cookHistoryProvider);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: child!,
        ),
        home: const PantryScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    await container.read(pantryProvider.notifier).addIngredients(['yumurta', 'süt', 'un']);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('pantry_sort_time')), 400,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pantry_sort_time')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
