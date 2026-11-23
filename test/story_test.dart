import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/models/story.dart';
import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/profile_provider.dart';
import 'package:arewecookin/providers/social_provider.dart';
import 'package:arewecookin/providers/story_provider.dart';
import 'package:arewecookin/screens/social_screen.dart';
import 'package:arewecookin/services/photo_uploader.dart';
import 'helpers/fake_profile.dart';
import 'helpers/fake_social.dart';
import 'helpers/fake_story.dart';

int get _now => DateTime.now().millisecondsSinceEpoch;
Story _s(String id, String author, {int ageMs = 1000}) =>
    Story(id: id, authorId: author, authorName: author.toUpperCase(), photoUrl: 'https://photos.test/$id.jpg', createdAtMs: _now - ageMs);

class _Up implements PhotoUploader {
  @override
  Future<String?> upload(Uint8List bytes, String contentType) async => 'https://photos.test/up.jpg';
}

Future<(FakeStoryService, FakeProfileService)> _pump(WidgetTester tester, List<Story> seed, {double width = 360, double scale = 1}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = Size(width * 3, 800 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final stories = FakeStoryService(seed);
  final profiles = FakeProfileService();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      socialServiceProvider.overrideWithValue(FakeSocialService([])),
      storyServiceProvider.overrideWithValue(stories),
      profileServiceProvider.overrideWithValue(profiles),
      authServiceProvider.overrideWithValue(FakeAuthService(signedInUser)),
      photoPickerProvider.overrideWithValue(() async => (Uint8List.fromList([1, 2, 3]), 'image/png')),
      photoUploaderProvider.overrideWithValue(_Up()),
    ],
    child: MaterialApp(
      builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: w!),
      home: const SocialScreen(),
    ),
  ));
  await tester.pumpAndSettle();
  return (stories, profiles);
}

void main() {
  test('groupStories: mine first, then followed, then the rest; expired and blocked are dropped', () {
    final all = [
      _s('1', 'u9', ageMs: 5000),
      _s('2', 'u2', ageMs: 4000),
      _s('3', 'u1', ageMs: 9000),
      _s('4', 'u3', ageMs: 1000),
      _s('5', 'u4', ageMs: Story.lifetimeMs + 10), // expired
      _s('6', 'u5', ageMs: 100), // blocked
      _s('7', 'u1', ageMs: 2000),
    ];
    final g = groupStories(all, me: 'u1', following: {'u2'}, blocked: {'u5'}, nowMs: _now);
    expect(g.map((e) => e.authorId), ['u1', 'u2', 'u3', 'u9']);
    expect(g.first.stories.map((s) => s.id), ['3', '7'], reason: 'oldest first inside a person');
  });

  testWidgets('strip shows my slot and other people; tapping opens the viewer, marks seen and advances', (tester) async {
    final (stories, _) = await _pump(tester, [_s('a', 'u2'), _s('b', 'u2', ageMs: 500), _s('c', 'u3')]);
    expect(find.text('Your story'), findsOneWidget);
    expect(find.text('U2'), findsOneWidget);
    expect(find.text('U3'), findsOneWidget);
    await tester.tap(find.byKey(const Key('story_u2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('story_next')), findsOneWidget);
    expect(stories.views['a']!.keys, ['u1'], reason: 'the view is recorded for the author');
    await tester.tap(find.byKey(const Key('story_next')));
    await tester.pump();
    await tester.pump();
    expect(stories.views['b']!.keys, ['u1']);
    // next group, then it closes after the last one
    await tester.tap(find.byKey(const Key('story_next')));
    await tester.pump();
    expect(stories.views['c']!.keys, ['u1']);
    await tester.tap(find.byKey(const Key('story_next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('story_next')), findsNothing, reason: 'viewer closed');
  });

  testWidgets('a story advances by itself after 5 seconds', (tester) async {
    final (stories, _) = await _pump(tester, [_s('a', 'u2'), _s('b', 'u2', ageMs: 500)]);
    await tester.tap(find.byKey(const Key('story_u2')));
    await tester.pump();
    await tester.pump();
    expect(stories.views.containsKey('b'), isFalse);
    await tester.pump(const Duration(seconds: 5, milliseconds: 200));
    expect(stories.views.containsKey('b'), isTrue);
    await tester.tap(find.byKey(const Key('story_close')));
    await tester.pumpAndSettle();
  });

  testWidgets('add a story: pick, upload, appears as mine with the viewer showing views and delete', (tester) async {
    final (stories, _) = await _pump(tester, []);
    await tester.tap(find.byKey(const Key('story_add')));
    await tester.pumpAndSettle();
    expect(stories.stories.single.authorId, 'u1');
    expect(stories.stories.single.photoUrl, 'https://photos.test/up.jpg');
    await tester.tap(find.byKey(const Key('story_mine')));
    await tester.pumpAndSettle();
    expect(stories.views, isEmpty, reason: 'own views are not recorded');
    ScaffoldMessenger.of(tester.element(find.byKey(const Key('story_views')))).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story_views')));
    await tester.pumpAndSettle();
    expect(find.text('Viewed by (0)'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story_delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story_confirm_delete')));
    await tester.pumpAndSettle();
    expect(stories.stories, isEmpty);
  });

  for (final (w, scale) in [(320.0, 2.0), (360.0, 1.8), (1400.0, 1.0)]) {
    testWidgets('strip and viewer have no overflow at ${w.toInt()}px, ${scale}x', (tester) async {
      await _pump(tester, [for (var i = 0; i < 8; i++) _s('s$i', 'user$i', ageMs: i * 100), _s('mine', 'u1')], width: w, scale: scale);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('story_mine')));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('story_close')));
      await tester.pumpAndSettle();
    });
  }
}
