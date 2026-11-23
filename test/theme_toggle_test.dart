import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/main.dart';
import 'package:arewecookin/providers/theme_provider.dart';
import 'package:arewecookin/utils/app_colors.dart';

Future<ProviderContainer> _start(WidgetTester tester, Size size, {Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  addTearDown(() => AppColors.dark = false);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AreWeCookinApp()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 2600));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
  return container;
}

void main() {
  testWidgets('one tap on the side menu button switches light and dark and back', (tester) async {
    final c = await _start(tester, const Size(1400, 900));
    expect(AppColors.dark, isFalse);
    await tester.tap(find.byKey(const Key('theme_toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.read(themeModeProvider), ThemeMode.dark);
    expect(AppColors.dark, isTrue);
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness, Brightness.dark);
    await tester.tap(find.byKey(const Key('theme_toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.read(themeModeProvider), ThemeMode.light);
    expect(AppColors.dark, isFalse);
  });

  testWidgets('phones get the toggle on the Discover screen and the choice is remembered', (tester) async {
    final c = await _start(tester, const Size(400, 900));
    expect(find.byType(NavigationRail), findsNothing);
    await tester.tap(find.byKey(const Key('theme_toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.read(themeModeProvider), ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode_v1'), 'dark');
  });

  testWidgets('a saved dark choice is applied at start', (tester) async {
    final c = await _start(tester, const Size(400, 900), prefs: {'theme_mode_v1': 'dark'});
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.read(themeModeProvider), ThemeMode.dark);
    expect(AppColors.dark, isTrue);
  });

  for (final size in const [Size(360, 800), Size(900, 800), Size(1400, 900)]) {
    testWidgets('dark theme has no overflow at ${size.width.toInt()}px', (tester) async {
      await _start(tester, size, prefs: {'theme_mode_v1': 'dark'});
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  }
}
