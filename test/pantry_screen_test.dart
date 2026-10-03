import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/screens/pantry_screen.dart';

void main() {
  group('PantryScreen Widget Tests', () {
    testWidgets('renders pantry categories and toggles ingredient chips', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PantryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title & empty state
      expect(find.text('Akıllı Kiler'), findsOneWidget);
      expect(find.text('Kileriniz boş görünüyor'), findsOneWidget);

      // Verify categories
      expect(find.text('Temel Malzemeler'), findsOneWidget);
      expect(find.text('Süt & Kahvaltılık'), findsOneWidget);

      // Tap on 'Un 🌾' chip
      final unChip = find.widgetWithText(FilterChip, 'Un 🌾');
      expect(unChip, findsOneWidget);
      await tester.tap(unChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap on 'Şeker 🍬' chip
      final sekerChip = find.widgetWithText(FilterChip, 'Şeker 🍬');
      expect(sekerChip, findsOneWidget);
      await tester.tap(sekerChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Check that matching recipes appeared and show match percentage
      expect(find.textContaining('%'), findsWidgets);
      expect(find.textContaining('Uyum'), findsWidgets);

      // Verify "Temizle" button clears selections
      final clearButton = find.text('Temizle');
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kileriniz boş görünüyor'), findsOneWidget);
    });

    testWidgets('renders cuisine selection chips and filters matched recipes', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PantryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Cuisine selector title is present
      expect(find.text('Hangi Mutfakta Yemek Pişireceksiniz?'), findsOneWidget);

      // Verify cuisine chips
      expect(find.text('🌍 Tümü'), findsOneWidget);
      expect(find.text('🇹🇷 Türk Mutfağı'), findsOneWidget);
      expect(find.text('🇮🇹 İtalyan'), findsOneWidget);

      // Select 'Domates 🍅' and 'Makarna 🍝'
      final domatesChip = find.widgetWithText(FilterChip, 'Domates 🍅');
      expect(domatesChip, findsOneWidget);
      await tester.tap(domatesChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final makarnaChip = find.widgetWithText(FilterChip, 'Makarna 🍝');
      expect(makarnaChip, findsOneWidget);
      await tester.tap(makarnaChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Filter by 'İtalyan' cuisine
      final italianChip = find.widgetWithText(FilterChip, '🇮🇹 İtalyan');
      expect(italianChip, findsOneWidget);
      await tester.tap(italianChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Check results contain Italian cuisine tag
      expect(find.text('İtalyan Mutfağı'), findsWidgets);

      // Add a custom ingredient via the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'sarimsak');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify only 100% matches button can be toggled
      final fullMatchToggle = find.text('Sadece %100 Hazır');
      expect(fullMatchToggle, findsOneWidget);
      await tester.tap(fullMatchToggle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    });
  });
}
