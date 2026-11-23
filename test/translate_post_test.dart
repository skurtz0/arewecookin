import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/models/social_post.dart';
import 'package:arewecookin/models/user_profile.dart';
import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/social_provider.dart';
import 'package:arewecookin/screens/social_screen.dart';
import 'package:arewecookin/services/translation_service.dart';
import 'helpers/fake_social.dart';

class _Fake implements TranslationService {
  final bool ok;
  int calls = 0;
  _Fake(this.ok);
  @override
  Future<String?> translate(String text, String target) async {
    calls++;
    return ok ? 'EN:$text' : null;
  }
}

Future<void> _pump(WidgetTester tester, _Fake t) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(ProviderScope(
    overrides: [
      socialServiceProvider.overrideWithValue(FakeSocialService([
        const SocialPost(id: 'a', authorId: 'u2', authorName: 'M', title: 'Menemen', text: 'Soğanlı', createdAtMs: 1),
      ])),
      authServiceProvider.overrideWithValue(FakeAuthService(UserProfile.guest)),
      translationServiceProvider.overrideWithValue(t),
    ],
    child: const MaterialApp(home: SocialScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  test('chunk splits long text under the limit', () {
    final c = MyMemoryTranslationService.chunk('Bir cümle. ' * 100);
    expect(c.every((e) => e.length <= 401), isTrue);
    expect(c.length, greaterThan(1));
  });

  testWidgets('translate toggles translated text and original', (tester) async {
    final t = _Fake(true);
    await _pump(tester, t);
    await tester.tap(find.byKey(const Key('translate_a')));
    await tester.pumpAndSettle();
    expect(find.text('EN:Menemen'), findsOneWidget);
    expect(find.text('EN:Soğanlı'), findsOneWidget);
    await tester.tap(find.byKey(const Key('translate_a')));
    await tester.pumpAndSettle();
    expect(find.text('Menemen'), findsOneWidget);
    await tester.tap(find.byKey(const Key('translate_a')));
    await tester.pumpAndSettle();
    expect(find.text('EN:Menemen'), findsOneWidget);
    expect(t.calls, 2); // cached on the third tap
  });

  testWidgets('failure shows a message and keeps the original', (tester) async {
    await _pump(tester, _Fake(false));
    await tester.tap(find.byKey(const Key('translate_a')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Menemen'), findsOneWidget);
  });
}
