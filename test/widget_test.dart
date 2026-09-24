import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/main.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:arewecookin/screens/pantry_screen.dart';

void main() {
  testWidgets('App renders main navigation shell and switches tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: AreWeCookinApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Verify Discover Screen is active initially
    expect(find.byType(DiscoverScreen), findsOneWidget);
    expect(find.text('AreWeCookin'), findsOneWidget);
    expect(find.text('Keşfet'), findsOneWidget);
    expect(find.text('Kilerim'), findsOneWidget);

    // Tap on Kilerim tab
    final kilerTab = find.text('Kilerim');
    await tester.tap(kilerTab);
    await tester.pumpAndSettle();

    // Verify Pantry Screen is visible and active
    expect(find.byType(PantryScreen), findsOneWidget);
    expect(find.text('Akıllı Kiler'), findsOneWidget);

    // Tap back to Keşfet tab
    final kesfetTab = find.text('Keşfet');
    await tester.tap(kesfetTab);
    await tester.pumpAndSettle();

    expect(find.byType(DiscoverScreen), findsOneWidget);
  });
}
