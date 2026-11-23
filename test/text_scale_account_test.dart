import 'package:arewecookin/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final lang in ['tr', 'en']) {
    testWidgets('account screen has no overflow at 1.8x text, 360px ($lang)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.platformDispatcher.localesTestValue = [Locale(lang)];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          builder: (ctx, w) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(textScaler: const TextScaler.linear(1.8)),
            child: w!,
          ),
          home: const AccountScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
