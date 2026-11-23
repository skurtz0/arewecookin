import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/models/social_post.dart';
import 'package:arewecookin/providers/admin_provider.dart';
import 'package:arewecookin/screens/moderation_screen.dart';
import 'package:arewecookin/services/moderation_service.dart';

class _FakeModeration implements ModerationService {
  final reports = StreamController<List<ModerationReport>>.broadcast();
  final removed = <String>[];
  final dismissed = <String>[];

  @override
  Future<bool> isAdmin(String uid) async => true;
  @override
  Stream<List<ModerationReport>> watchReports() => reports.stream;
  @override
  Future<SocialPost?> getPost(String postId) async => postId == 'gone'
      ? null
      : SocialPost(id: postId, authorId: 'u1', authorName: 'Ayşe', title: 'Kötü gönderi', text: 'metin', createdAtMs: 1);
  @override
  Future<void> removePost(ModerationReport r) async => removed.add(r.id);
  @override
  Future<void> dismissReport(ModerationReport r) async => dismissed.add(r.id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('open reports are listed first and can be removed or dismissed', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final fake = _FakeModeration();
    await tester.pumpWidget(ProviderScope(
      overrides: [adminServiceProvider.overrideWithValue(fake)],
      child: const MaterialApp(home: ModerationScreen()),
    ));
    fake.reports.add(const [
      ModerationReport(id: 'old', postId: 'gone', reporterId: 'r', reason: 'spam', createdAtMs: 5, status: 'dismissed'),
      ModerationReport(id: 'new', postId: 'p1', reporterId: 'r', reason: 'hakaret', createdAtMs: 1),
    ]);
    await tester.pumpAndSettle();

    // Open one is first, handled one has no buttons.
    expect(find.textContaining('hakaret'), findsOneWidget);
    expect(find.text('Post no longer exists.'), findsOneWidget);
    expect(find.text('Remove post'), findsOneWidget);
    expect(tester.getTopLeft(find.textContaining('hakaret')).dy,
        lessThan(tester.getTopLeft(find.textContaining('spam')).dy));

    await tester.tap(find.text('Remove post'));
    await tester.pump();
    expect(fake.removed, ['new']);
    await tester.tap(find.text('Dismiss'));
    await tester.pump();
    expect(fake.dismissed, ['new']);
  });

  testWidgets('empty list shows a message, no overflow at 1.8x text', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeModeration();
    await tester.pumpWidget(ProviderScope(
      overrides: [adminServiceProvider.overrideWithValue(fake)],
      child: MaterialApp(
        builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.8)), child: w!),
        home: const ModerationScreen(),
      ),
    ));
    fake.reports.add(const []);
    await tester.pumpAndSettle();
    expect(find.text('No reports.'), findsOneWidget);
  });
}
