import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/main.dart';
import 'package:arewecookin/screens/account_screen.dart';

void main() {
  group('AccountScreen & Auth & Localization Widget Tests', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize = const Size(1000, 2400);
      binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
      binding.platformDispatcher.localesTestValue = const [Locale('tr')];
    });

    testWidgets('renders account screen with Google one-tap, email form, and language toggle', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('tr')];
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AccountScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header and language toggle
      expect(find.text('Hesabım'), findsOneWidget);
      expect(find.text('🇹🇷 TR'), findsWidgets);
      expect(find.text('🇬🇧 EN'), findsWidgets);

      // Verify Google one-tap login button
      expect(find.text('Google ile Otomatik Giriş'), findsOneWidget);

      // Verify email/password fields
      expect(find.byType(TextFormField), findsNWidgets(2)); // email & password
      expect(find.text('Giriş Yap'), findsWidgets);
    });

    testWidgets('Google one-tap sign-in logs user in, displays profile card and sign out button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AccountScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Google one-tap button
      final googleButton = find.text('Google ile Otomatik Giriş');
      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      // Verify signed in state
      expect(find.text('Ahmet Şef (Google)'), findsOneWidget);
      expect(find.text('Google Hesabı'), findsOneWidget);
      expect(find.text('Çıkış Yap'), findsOneWidget);

      // Tap Sign Out
      final signOutBtn = find.text('Çıkış Yap');
      await tester.tap(signOutBtn);
      await tester.pumpAndSettle();

      // Verify back to guest view
      expect(find.text('Google ile Otomatik Giriş'), findsOneWidget);
    });

    testWidgets('language toggle dynamically switches locale between Turkish and English', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AreWeCookinApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Hesabım tab
      await tester.tap(find.text('Hesabım'));
      await tester.pumpAndSettle();

      expect(find.text('Hesabım'), findsWidgets);

      // Tap 🇬🇧 EN button
      final enButton = find.text('🇬🇧 EN').first;
      await tester.tap(enButton);
      await tester.pumpAndSettle();

      // Verify English strings are rendered dynamically
      expect(find.text('My Account'), findsWidgets);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Pantry'), findsOneWidget);

      // Tap back to 🇹🇷 TR button
      final trButton = find.text('🇹🇷 TR').first;
      await tester.tap(trButton);
      await tester.pumpAndSettle();

      // Verify Turkish strings are restored
      expect(find.text('Hesabım'), findsWidgets);
      expect(find.text('Google ile Otomatik Giriş'), findsOneWidget);
      expect(find.text('Keşfet'), findsOneWidget);
    });
  });
}
