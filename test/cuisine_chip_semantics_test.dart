import 'package:arewecookin/screens/discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('active cuisine chip is announced as a button', (tester) async {
    SharedPreferences.setMockInitialValues({
      'discover_filters_v1': '{"c":"Tümü","u":"Türk Mutfağı","m":null,"d":null}',
    });
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DiscoverScreen())));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final chip = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.button == true && w.properties.hint != null);
    expect(chip, findsWidgets);
    handle.dispose();
  });

  testWidgets('cuisine selector chips tell which cuisine is selected', (tester) async {
    SharedPreferences.setMockInitialValues({
      'discover_filters_v1': '{"c":"Tümü","u":"Türk Mutfağı","m":null,"d":null}',
    });
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DiscoverScreen())));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    bool? selectedOf(String id) {
      final f = find.byKey(Key('cuisine_$id'));
      if (f.evaluate().isEmpty) return null;
      return tester
          .widget<Semantics>(find.ancestor(of: f, matching: find.byWidgetPredicate((w) => w is Semantics && w.properties.selected != null)).first)
          .properties
          .selected;
    }
    expect(selectedOf('Türk Mutfağı'), isTrue);
    expect(selectedOf('Tümü'), isFalse);
    handle.dispose();
  });
}
