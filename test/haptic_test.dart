import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/screens/shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('ticking a shopping item gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha')]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: ShoppingListScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(calls, isNotEmpty);
    expect(c.read(shoppingListProvider).first.done, isTrue);
  });
}
