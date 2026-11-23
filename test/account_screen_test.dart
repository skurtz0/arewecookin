import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/main.dart';
import 'package:arewecookin/providers/cook_history_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/screens/account_screen.dart';

void main() {
  group('AccountScreen & Auth & Localization Widget Tests', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize = const Size(1000, 2400);
      binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
      binding.platformDispatcher.localesTestValue = const [Locale('tr')];
    });

    testWidgets('password visibility button has a tooltip for screen readers', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AccountScreen())));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Show / hide password'), findsOneWidget);
    });

    testWidgets('sign-in fields offer autofill and a next key', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AccountScreen())));
      await tester.pumpAndSettle();
      final email = tester.widget<TextField>(
          find.descendant(of: find.byKey(const Key('auth_email_field')), matching: find.byType(TextField)));
      final pass = tester.widget<TextField>(
          find.descendant(of: find.byKey(const Key('auth_password_field')), matching: find.byType(TextField)));
      expect(email.autofillHints, contains(AutofillHints.email));
      expect(email.textInputAction, TextInputAction.next);
      expect(pass.autofillHints, contains(AutofillHints.password));
    });

    testWidgets('sign-up name field capitalizes each word', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AccountScreen())));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up').first);
      await tester.pumpAndSettle();
      final name = tester.widgetList<TextField>(find.byType(TextField)).firstWhere(
          (f) => f.decoration?.labelText == 'Full Name');
      expect(name.textCapitalization, TextCapitalization.words);
    });

    testWidgets('divider text follows the app language', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AccountScreen())));
      await tester.pumpAndSettle();
      expect(find.text('or other options'), findsOneWidget);
      expect(find.text('veya diğer seçenekler'), findsNothing);
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

    testWidgets('profile shows the real number of cooked dishes', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(cookHistoryProvider.notifier).markCooked('a');
      container.read(cookHistoryProvider.notifier).markCooked('a');
      container.read(cookHistoryProvider.notifier).markCooked('b');
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AccountScreen()),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Google ile Otomatik Giriş'));
      await tester.pumpAndSettle();
      final stat = find.byKey(const Key('cooked_total_stat'));
      expect(stat, findsOneWidget);
      expect(find.descendant(of: stat, matching: find.text('3')), findsOneWidget);
      expect(find.text('185'), findsNothing);
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
