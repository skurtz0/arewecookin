import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/models/social_post.dart';
import 'package:arewecookin/models/user_profile.dart';
import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/social_provider.dart';
import 'package:arewecookin/screens/social_screen.dart';
import 'helpers/fake_social.dart';

SocialPost _post() => const SocialPost(
      id: 'a',
      authorId: 'u2',
      authorName: 'Mehmet',
      title: 'Menemen',
      text: 'Soğanlı',
      createdAtMs: 1,
    );

Future<FakeSocialService> _pump(WidgetTester tester, {UserProfile? user}) async {
  SharedPreferences.setMockInitialValues({});
  final fake = FakeSocialService([_post()]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      socialServiceProvider.overrideWithValue(fake),
      authServiceProvider.overrideWithValue(FakeAuthService(user ?? UserProfile.guest)),
    ],
    child: const MaterialApp(home: SocialScreen()),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('feed shows posts and a guest is asked to sign in to like', (tester) async {
    final fake = await _pump(tester);
    expect(find.text('Menemen'), findsOneWidget);
    await tester.tap(find.byKey(const Key('like_a')));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(fake.posts.first.likeCount, 0);
  });

  testWidgets('signed-in user can like, unlike and the count follows', (tester) async {
    final fake = await _pump(tester, user: signedInUser);
    await tester.tap(find.byKey(const Key('like_a')));
    await tester.pumpAndSettle();
    expect(fake.posts.first.likeCount, 1);
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('like_a')));
    await tester.pumpAndSettle();
    expect(fake.posts.first.likeCount, 0);
  });

  testWidgets('signed-in user can publish a post', (tester) async {
    final fake = await _pump(tester, user: signedInUser);
    await tester.tap(find.byKey(const Key('social_new_post')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('post_title')), 'Sütlaç');
    await tester.tap(find.byKey(const Key('post_publish')));
    await tester.pumpAndSettle();
    expect(fake.posts.first.title, 'Sütlaç');
    expect(fake.posts.first.authorId, 'u1');
    expect(find.text('Sütlaç'), findsOneWidget);
  });

  testWidgets('signed-in user can comment', (tester) async {
    final fake = await _pump(tester, user: signedInUser);
    await tester.tap(find.byKey(const Key('comment_a')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('comment_field')), 'Harika');
    await tester.tap(find.byKey(const Key('comment_send')));
    await tester.pumpAndSettle();
    expect(fake.comments['a']!.single.text, 'Harika');
    expect(fake.posts.first.commentCount, 1);
  });

  testWidgets('guest cannot open the compose sheet', (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const Key('social_new_post')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post_title')), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
