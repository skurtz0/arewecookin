import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/screens/splash_screen.dart';
import 'package:arewecookin/screens/add_recipe_screen.dart';
import 'package:arewecookin/screens/account_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SplashScreen Tests', () {
    testWidgets('renders logo and tagline', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Bugün ne pişiriyoruz?'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();
    });
  });

  group('AddRecipeScreen Tests', () {
    testWidgets('renders all form fields and submits custom recipe', (tester) async {
      tester.view.physicalSize = const Size(1000, 2500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AddRecipeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Yeni Tarif Paylaş'), findsOneWidget);
      expect(find.text('Tarif Adı'), findsOneWidget);
      expect(find.text('Gerekli Malzemeler'), findsOneWidget);
      expect(find.text('Pişirme Adımları'), findsOneWidget);

      // Enter recipe title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Tarif Adı'),
        'Özel Menemen',
      );

      // Enter first ingredient
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Malzeme adı').first,
        'Domates',
      );

      // Enter first step instruction
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Adım açıklaması / talimatı...').first,
        'Domatesleri küp küp doğrayıp tavada soteleyin.',
      );

      // Tap publish
      await tester.tap(find.text('Tarifi Yayınla').first);
      await tester.pumpAndSettle();

      // Verify custom recipe was added
      final customList = container.read(customRecipesProvider);
      expect(customList.any((r) => r.title == 'Özel Menemen'), isTrue);
    });
  });

  group('Phone Auth & Account Management Tests', () {
    testWidgets('switches to phone auth, sends OTP and enters code', (tester) async {
      tester.view.physicalSize = const Size(1000, 2500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AccountScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Telefon auth method
      final phoneTab = find.text('Telefon');
      expect(phoneTab, findsOneWidget);
      await tester.tap(phoneTab);
      await tester.pumpAndSettle();

      expect(find.text('Doğrulama Kodu Gönder'), findsOneWidget);

      // Enter phone number
      await tester.enterText(find.byType(TextFormField).first, '+905551234567');
      await tester.tap(find.text('Doğrulama Kodu Gönder'));
      await tester.pumpAndSettle();

      // Verify OTP screen
      expect(find.text('Kodu Onayla ve Giriş Yap'), findsOneWidget);

      // Enter 6 digit code
      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.tap(find.text('Kodu Onayla ve Giriş Yap'));
      await tester.pumpAndSettle();

      // Verify logged in view
      expect(find.text('Telefon Doğrulamalı'), findsOneWidget);
      expect(find.text('Kaydettiğim Tarifler (0)'), findsOneWidget);
      expect(find.text('Eklediğim Tarifler (0)'), findsOneWidget);
    });

    test('auth provider handles changePassword, changeEmail, and deleteAccount', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Sign in with email first
      await container.read(authProvider.notifier).signInWithEmail('test@arewecookin.com', '123456');
      expect(container.read(authProvider).user.isLoggedIn, isTrue);

      // Update name
      await container.read(authProvider.notifier).updateDisplayName('Usta Şef');
      expect(container.read(authProvider).user.displayName, 'Usta Şef');

      // Change email
      await container.read(authProvider.notifier).changeEmail('yeni@arewecookin.com');
      expect(container.read(authProvider).user.email, 'yeni@arewecookin.com');

      // Change password
      await container.read(authProvider.notifier).changePassword('654321');
      expect(container.read(authProvider).errorMessage, isNull);

      // Delete account
      await container.read(authProvider.notifier).deleteAccount();
      expect(container.read(authProvider).user.isLoggedIn, isFalse);
    });
  });

  group('Saved Recipes Tests', () {
    test('toggles save/unsave recipes correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const sample = Recipe(
        id: 'rec_fav_1',
        title: 'Favori Tarif',
        category: 'Tatlı',
        prepTime: 10,
        cookTime: 20,
        difficulty: 'Kolay',
        ingredientKeys: ['seker'],
        ingredients: [Ingredient(name: 'Şeker', amount: '1', unit: 'bardak')],
        substitutions: [],
        steps: [
          CookingStep(
            order: 1,
            title: 'Karıştır',
            instruction: 'Hepsini karıştırın.',
            toolIcon: 'spoon',
          ),
        ],
      );

      final notifier = container.read(savedRecipesProvider.notifier);
      expect(container.read(savedRecipesProvider).isSaved('rec_fav_1'), isFalse);

      final saved = await notifier.toggleSave(sample);
      expect(saved, isTrue);
      expect(container.read(savedRecipesProvider).isSaved('rec_fav_1'), isTrue);
      expect(container.read(savedRecipesProvider).recipes.length, 1);

      final removed = await notifier.toggleSave(sample);
      expect(removed, isFalse);
      expect(container.read(savedRecipesProvider).isSaved('rec_fav_1'), isFalse);
      expect(container.read(savedRecipesProvider).recipes.isEmpty, isTrue);
    });
  });
}
