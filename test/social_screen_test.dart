import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/models/social_post.dart';
import 'package:arewecookin/models/user_profile.dart';
import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/social_provider.dart';
import 'package:arewecookin/screens/social_screen.dart';
import 'package:arewecookin/services/photo_uploader.dart';
import 'helpers/fake_social.dart';

final _png = Uint8List.fromList(const [
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01,
  0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9c, 0x63, 0xf8, 0xff, 0xff, 0x3f, 0x00, 0x05, 0xfe, 0x02, 0xfe, 0xa7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
]);

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

  testWidgets('author can delete their own post after confirming', (tester) async {
    final fake = FakeSocialService([
      const SocialPost(id: 'm', authorId: 'u1', authorName: 'Ayşe', title: 'Benim', text: '', createdAtMs: 1),
    ]);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(ProviderScope(
      overrides: [
        socialServiceProvider.overrideWithValue(fake),
        authServiceProvider.overrideWithValue(FakeAuthService(signedInUser)),
      ],
      child: const MaterialApp(home: SocialScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu_m')));
    await tester.pumpAndSettle();
    expect(find.text('Report'), findsNothing);
    await tester.tap(find.text('Delete post'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_delete')));
    await tester.pumpAndSettle();
    expect(fake.posts, isEmpty);
  });

  testWidgets('reporting hides the post and files a report', (tester) async {
    final fake = await _pump(tester, user: signedInUser);
    await tester.tap(find.byKey(const Key('menu_a')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(fake.reports, ['a:u1:report']);
    expect(find.text('Menemen'), findsNothing);
  });

  testWidgets('reporting a comment hides it and files a report with its id', (tester) async {
    final fake = await _pump(tester, user: signedInUser);
    fake.comments['a'] = [
      const SocialComment(id: 'c9', authorId: 'u2', authorName: 'Can', text: 'kaba yorum', createdAtMs: 1),
    ];
    await tester.tap(find.byKey(const Key('comment_a')));
    await tester.pumpAndSettle();
    expect(find.text('kaba yorum'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cmenu_c9')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(fake.reports, ['a:u1:report:c9']);
    expect(find.text('kaba yorum'), findsNothing);
  });

  testWidgets('blocking an author hides their posts and can be undone from their page', (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const Key('menu_a')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block this user'));
    await tester.pumpAndSettle();
    expect(find.text('Menemen'), findsNothing);
  });

  testWidgets('author page lists only that author\'s posts and can block', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeSocialService([
      _post(),
      const SocialPost(id: 'b', authorId: 'u3', authorName: 'Zeynep', title: 'Baklava', text: '', createdAtMs: 2),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        socialServiceProvider.overrideWithValue(fake),
        authServiceProvider.overrideWithValue(FakeAuthService(UserProfile.guest)),
      ],
      child: const MaterialApp(home: SocialScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('author_a')));
    await tester.pumpAndSettle();
    expect(find.text('Menemen'), findsOneWidget);
    expect(find.text('Baklava'), findsNothing);
    await tester.tap(find.byKey(const Key('author_block_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('You blocked this user'), findsOneWidget);
    await tester.tap(find.byKey(const Key('author_block_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Menemen'), findsOneWidget);
  });

  for (final fails in [false, true]) {
    testWidgets('post with a photo ${fails ? "is not published when the upload fails" : "stores the uploaded URL"}', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final fake = FakeSocialService();
      final uploaded = <int>[];
      await tester.pumpWidget(ProviderScope(
        overrides: [
          socialServiceProvider.overrideWithValue(fake),
          authServiceProvider.overrideWithValue(FakeAuthService(signedInUser)),
          photoPickerProvider.overrideWithValue(() async => (_png, 'image/png')),
          photoUploaderProvider.overrideWithValue(_FakeUploader(fails, uploaded)),
        ],
        child: const MaterialApp(home: SocialScreen()),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('social_new_post')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('post_title')), 'Mantı');
      await tester.tap(find.byKey(const Key('post_pick_photo')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('post_publish')));
      await tester.pumpAndSettle();
      expect(uploaded, [_png.length]);
      if (fails) {
        expect(fake.posts, isEmpty);
        expect(find.byKey(const Key('post_title')), findsOneWidget, reason: 'sheet stays open');
      } else {
        expect(fake.posts.single.photoUrl, 'https://photos.test/x.jpg');
      }
    });
  }

  testWidgets('a post can have several photos: add 3, remove 1, publish 2, gallery swipes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeSocialService();
    final uploaded = <int>[];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        socialServiceProvider.overrideWithValue(fake),
        authServiceProvider.overrideWithValue(FakeAuthService(signedInUser)),
        photoPickerProvider.overrideWithValue(() async => (_png, 'image/png')),
        photoUploaderProvider.overrideWithValue(_NumberedUploader(uploaded)),
      ],
      child: const MaterialApp(home: SocialScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('social_new_post')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('post_title')), 'Çok foto');
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('post_pick_photo')));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key('post_remove_photo_2')), findsOneWidget);
    await tester.tap(find.byKey(const Key('post_remove_photo_1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post_remove_photo_2')), findsNothing);
    await tester.tap(find.byKey(const Key('post_publish')));
    await tester.pumpAndSettle();
    expect(fake.posts.single.photoUrls, ['https://photos.test/1.jpg', 'https://photos.test/2.jpg']);
    expect(fake.posts.single.toMap()['photoUrl'], 'https://photos.test/1.jpg');
    expect(find.byKey(const Key('post_gallery')), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    await tester.drag(find.byKey(const Key('post_gallery')), const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('2/2'), findsOneWidget);
    // On a wide screen the arrows work too (mouse users).
    expect(find.byKey(const Key('gallery_next')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('gallery_prev')));
    await tester.tap(find.byKey(const Key('gallery_prev')));
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('gallery_next')));
    await tester.tap(find.byKey(const Key('gallery_next')));
    await tester.pumpAndSettle();
    expect(find.text('2/2'), findsOneWidget);
  });
}

class _NumberedUploader implements PhotoUploader {
  final List<int> log;
  _NumberedUploader(this.log);
  @override
  Future<String?> upload(Uint8List bytes, String contentType) async {
    log.add(bytes.length);
    return 'https://photos.test/${log.length}.jpg';
  }
}

class _FakeUploader implements PhotoUploader {
  final bool fails;
  final List<int> log;
  _FakeUploader(this.fails, this.log);
  @override
  Future<String?> upload(Uint8List bytes, String contentType) async {
    log.add(bytes.length);
    return fails ? null : 'https://photos.test/x.jpg';
  }
}
