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
  });
}
