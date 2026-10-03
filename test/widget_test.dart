import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/main.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:arewecookin/screens/pantry_screen.dart';

void main() {
  testWidgets('App renders main navigation shell in default English and switches tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: AreWeCookinApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    // Verify Navigation bar tabs in default English
    expect(find.byType(DiscoverScreen), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Pantry'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);

    // Tap on Pantry tab
    final pantryTab = find.text('Pantry');
    await tester.tap(pantryTab);
    await tester.pumpAndSettle();

    // Verify Pantry Screen is visible and active
    expect(find.byType(PantryScreen), findsOneWidget);

    // Tap on Account tab
    final accountTab = find.text('Account');
    await tester.tap(accountTab);
    await tester.pumpAndSettle();

    // Verify Account Screen is visible with Google login and preferences
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);

    // Tap back to Discover tab
    final discoverTab = find.text('Discover');
    await tester.tap(discoverTab);
    await tester.pumpAndSettle();

    expect(find.byType(DiscoverScreen), findsOneWidget);
  });
}
