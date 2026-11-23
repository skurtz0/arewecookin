import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/models/social_post.dart';
import 'package:arewecookin/models/user_profile.dart';
import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/profile_provider.dart';
import 'package:arewecookin/providers/social_provider.dart';
import 'package:arewecookin/screens/social_screen.dart';
import 'helpers/fake_profile.dart';
import 'helpers/fake_social.dart';

SocialPost _p(String id, String author, String title, int t, {List<String> photos = const []}) =>
    SocialPost(id: id, authorId: author, authorName: author, title: title, text: '', photoUrls: photos, createdAtMs: t);

Future<(FakeSocialService, FakeProfileService)> _pump(WidgetTester tester, Widget home, {bool signedIn = true, List<SocialPost>? seed}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final social = FakeSocialService(seed ?? [
    _p('a', 'u2', 'Menemen', 3),
    _p('b', 'u2', 'Mantı', 2, photos: ['https://photos.test/1.jpg', 'https://photos.test/2.jpg']),
    _p('c', 'u3', 'Pilav', 1),
  ]);
  final profiles = FakeProfileService();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      socialServiceProvider.overrideWithValue(social),
      profileServiceProvider.overrideWithValue(profiles),
      authServiceProvider.overrideWithValue(FakeAuthService(signedIn ? signedInUser : UserProfile.guest)),
    ],
    child: MaterialApp(home: home),
  ));
  await tester.pumpAndSettle();
  return (social, profiles);
}

void main() {
  testWidgets('follow / unfollow changes the button and the follower count', (tester) async {
    final (_, profiles) = await _pump(tester, const AuthorScreen(authorId: 'u2', authorName: 'Can'));
    expect(find.text('Follow'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2)); // followers and following
    await tester.tap(find.byKey(const Key('profile_follow')));
    await tester.pumpAndSettle();
    expect(profiles.follows, {'u1_u2'});
    expect(find.text('Unfollow'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('stat_followers'))).data, '1');
    await tester.tap(find.byKey(const Key('profile_follow')));
    await tester.pumpAndSettle();
    expect(profiles.follows, isEmpty);
  });

  testWidgets('profile shows a grid of the author\'s posts with pinned first and a photo-count badge', (tester) async {
    final (_, profiles) = await _pump(tester, const AuthorScreen(authorId: 'u2', authorName: 'Can'));
    expect(tester.widget<Text>(find.byKey(const Key('stat_posts'))).data, '2');
    expect(find.byKey(const Key('tile_c')), findsNothing, reason: 'other author');
    // newest first: a, then b
    expect(tester.getTopLeft(find.byKey(const Key('tile_a'))).dx, lessThan(tester.getTopLeft(find.byKey(const Key('tile_b'))).dx));
    expect(find.byIcon(Icons.collections), findsOneWidget);
    await profiles.saveProfile('u2', pinned: ['b']);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(const Key('tile_b'))).dx, lessThan(tester.getTopLeft(find.byKey(const Key('tile_a'))).dx));
    expect(find.byIcon(Icons.push_pin), findsOneWidget);
  });

  testWidgets('own profile: edit name and bio', (tester) async {
    final (_, profiles) = await _pump(tester, const AuthorScreen(authorId: 'u1', authorName: 'Ayşe'));
    expect(find.byKey(const Key('profile_follow')), findsNothing);
    await tester.tap(find.byKey(const Key('profile_edit')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile_name')), 'Ayşe Hanım');
    await tester.enterText(find.byKey(const Key('profile_bio')), 'Mantı ustası');
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pumpAndSettle();
    expect(profiles.profiles['u1']!.displayName, 'Ayşe Hanım');
    expect(profiles.profiles['u1']!.bio, 'Mantı ustası');
    expect(find.text('Mantı ustası'), findsOneWidget);
  });

  testWidgets('feed has an Everyone / Following switch; Following shows only followed authors', (tester) async {
    final (_, profiles) = await _pump(tester, const SocialScreen());
    expect(find.text('Menemen'), findsOneWidget);
    expect(find.text('Pilav'), findsOneWidget);
    await tester.tap(find.text('Following'));
    await tester.pumpAndSettle();
    expect(find.textContaining('follow nobody'), findsOneWidget);
    await profiles.setFollow(me: 'u1', target: 'u3', follow: true);
    await tester.pumpAndSettle();
    expect(find.text('Pilav'), findsOneWidget);
    expect(find.text('Menemen'), findsNothing);
  });

  testWidgets('own post menu pins and unpins, at most 3', (tester) async {
    final (_, profiles) = await _pump(tester, const SocialScreen(),
        seed: [for (var i = 0; i < 4; i++) _p('m$i', 'u1', 'Benim $i', 10 - i)]);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(Key('menu_m$i')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pin to profile'));
      await tester.pumpAndSettle();
    }
    expect(profiles.profiles['u1']!.pinned, ['m0', 'm1', 'm2']);
    await tester.tap(find.byKey(const Key('menu_m3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pin to profile'));
    await tester.pumpAndSettle();
    expect(profiles.profiles['u1']!.pinned.length, 3);
    expect(find.textContaining('up to 3'), findsOneWidget);
    await tester.tap(find.byKey(const Key('menu_m0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unpin from profile'));
    await tester.pumpAndSettle();
    expect(profiles.profiles['u1']!.pinned, ['m1', 'm2']);
  });

  for (final (w, scale) in [(320.0, 2.0), (360.0, 1.8), (1400.0, 1.0)]) {
    testWidgets('profile and feed have no overflow at ${w.toInt()}px, ${scale}x text', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = Size(w * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final profiles = FakeProfileService();
      await profiles.saveProfile('u2', displayName: 'Çok uzun bir kullanıcı adı burada', bio: 'Uzun bir biyografi ' * 6, pinned: ['a']);
      final social = FakeSocialService([_p('a', 'u2', 'Menemen ' * 8, 3), _p('b', 'u2', 'Mantı', 2, photos: ['https://photos.test/1.jpg', 'https://photos.test/2.jpg'])]);
      for (final home in [const AuthorScreen(authorId: 'u2', authorName: 'Can'), const SocialScreen()]) {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            socialServiceProvider.overrideWithValue(social),
            profileServiceProvider.overrideWithValue(profiles),
            authServiceProvider.overrideWithValue(FakeAuthService(signedInUser)),
          ],
          child: MaterialApp(
            builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
            home: home,
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: home.runtimeType.toString());
      }
    });
  }
}
