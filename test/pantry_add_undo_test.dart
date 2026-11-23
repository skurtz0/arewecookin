import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('typing ingredients adds them with a confirmation that can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), 'sarimsak, misir');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.read(pantryProvider).selectedKeys, containsAll(['sarimsak', 'misir']));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2 ingredients added to pantry'), findsOneWidget);
    tester.widget<SnackBarAction>(find.byKey(const Key('pantry_add_undo'))).onPressed();
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.read(pantryProvider).selectedKeys, isEmpty);
  });
}
