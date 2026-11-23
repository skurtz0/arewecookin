import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/models/chat.dart';
import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/chat_provider.dart';
import 'package:arewecookin/providers/moderation_provider.dart';
import 'package:arewecookin/providers/profile_provider.dart';
import 'package:arewecookin/screens/chat_screens.dart';
import 'package:arewecookin/services/moderation_service.dart';
import 'helpers/fake_chat.dart';
import 'helpers/fake_profile.dart';
import 'helpers/fake_social.dart';

class _NoBlocks implements BlockSyncService {
  @override
  Future<Set<String>> load(String uid) async => {};
  @override
  Future<void> set(String uid, String blockedUid, bool blocked) async {}
}

Future<(FakeChatService, FakeProfileService)> _pump(WidgetTester tester, Widget home, {double width = 360, double scale = 1, void Function(FakeChatService, FakeProfileService)? seed}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = Size(width * 3, 800 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final chats = FakeChatService();
  final profiles = FakeProfileService();
  seed?.call(chats, profiles);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      chatServiceProvider.overrideWithValue(chats),
      profileServiceProvider.overrideWithValue(profiles),
      blockSyncServiceProvider.overrideWithValue(_NoBlocks()),
      authServiceProvider.overrideWithValue(FakeAuthService(signedInUser)),
    ],
    child: MaterialApp(
      builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: w!),
      home: home,
    ),
  ));
  await tester.pumpAndSettle();
  return (chats, profiles);
}

void main() {
  test('dm id is the same for both people and sorted', () {
    expect(Chat.dmId('b', 'a'), 'dm_a_b');
    expect(Chat.dmId('a', 'b'), 'dm_a_b');
  });

  testWidgets('empty inbox, then a new direct chat from the people I follow; messages are sent and shown', (tester) async {
    final (chats, profiles) = await _pump(tester, const ChatsScreen(), seed: (c, p) {
      p.follows.add('u1_u2');
    });
    expect(find.textContaining('No conversations'), findsOneWidget);
    await profiles.saveProfile('u2', displayName: 'Can');
    await tester.tap(find.byKey(const Key('chat_new')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick_u2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat_start')));
    await tester.pumpAndSettle();
    expect(chats.chats.keys, ['dm_u1_u2']);
    expect(find.text('Can'), findsWidgets);
    await tester.enterText(find.byKey(const Key('chat_input')), 'Merhaba');
    await tester.tap(find.byKey(const Key('chat_send')));
    await tester.pumpAndSettle();
    expect(find.text('Merhaba'), findsOneWidget);
    expect(chats.chats['dm_u1_u2']!.lastMessage, 'Merhaba');
  });

  testWidgets('inbox lists chats newest first with unread marked bold, opening clears the unread dot', (tester) async {
    final (chats, _) = await _pump(tester, const ChatsScreen(), seed: (c, p) {
      c.clock = 10000;
      c.chats['dm_u1_u2'] = Chat(id: 'dm_u1_u2', isGroup: false, members: ['u1', 'u2'], names: {'u1': 'Ayşe', 'u2': 'Can'}, createdBy: 'u1', lastMessage: 'selam', lastMessageAtMs: 5000, lastSenderId: 'u2', createdAtMs: 1);
      c.chats['g1'] = Chat(id: 'g1', isGroup: true, name: 'Mutfak', members: ['u1', 'u2', 'u3'], names: {}, createdBy: 'u1', lastMessage: 'eski', lastMessageAtMs: 2000, lastSenderId: 'u1', createdAtMs: 1);
    });
    expect(tester.getTopLeft(find.byKey(const Key('chat_dm_u1_u2'))).dy, lessThan(tester.getTopLeft(find.byKey(const Key('chat_g1'))).dy));
    expect(find.byIcon(Icons.circle), findsOneWidget, reason: 'only the chat with a new message from someone else');
    await tester.tap(find.byKey(const Key('chat_dm_u1_u2')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.circle), findsNothing);
    expect(chats.reads['dm_u1_u2']!['u1'], isNotNull);
  });

  testWidgets('group: two or more people need a name; admin adds, renames; member leaves', (tester) async {
    final (chats, profiles) = await _pump(tester, const ChatsScreen(), seed: (c, p) {
      p.follows..add('u1_u2')..add('u1_u3')..add('u1_u4');
    });
    await profiles.saveProfile('u2', displayName: 'Can');
    await profiles.saveProfile('u3', displayName: 'Deniz');
    await profiles.saveProfile('u4', displayName: 'Ece');
    await tester.tap(find.byKey(const Key('chat_new')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick_u2')));
    await tester.tap(find.byKey(const Key('pick_u3')));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byKey(const Key('chat_start'))).onPressed, isNull, reason: 'a group needs a name');
    await tester.enterText(find.byKey(const Key('group_name')), 'Mutfak');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat_start')));
    await tester.pumpAndSettle();
    final id = chats.chats.keys.single;
    expect(chats.chats[id]!.members, ['u1', 'u2', 'u3']);
    await tester.tap(find.byKey(const Key('group_info')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('group_add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick_u4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('group_add_ok')));
    await tester.pumpAndSettle();
    expect(chats.chats[id]!.members, contains('u4'));
    await tester.tap(find.byKey(const Key('group_rename')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('group_rename_field')), 'Mutfak 2');
    await tester.tap(find.byKey(const Key('group_rename_ok')));
    await tester.pumpAndSettle();
    expect(chats.chats[id]!.name, 'Mutfak 2');
    await tester.tap(find.byKey(const Key('group_leave')));
    await tester.pumpAndSettle();
    expect(chats.chats[id]!.members, isNot(contains('u1')));
  });

  testWidgets('messages from a blocked person are hidden and their direct chat is not listed', (tester) async {
    final (chats, _) = await _pump(tester, const ChatsScreen(), seed: (c, p) {
      c.chats['dm_u1_u2'] = Chat(id: 'dm_u1_u2', isGroup: false, members: ['u1', 'u2'], names: {'u2': 'Can'}, createdBy: 'u1', lastMessage: 'x', lastMessageAtMs: 5, lastSenderId: 'u2');
      c.chats['g1'] = Chat(id: 'g1', isGroup: true, name: 'Mutfak', members: ['u1', 'u2', 'u3'], createdBy: 'u3', lastMessage: 'y', lastMessageAtMs: 4, lastSenderId: 'u2');
      c.messages['g1'] = [
        const ChatMessage(id: 'a', senderId: 'u2', senderName: 'Can', text: 'kaba mesaj', createdAtMs: 1),
        const ChatMessage(id: 'b', senderId: 'u3', senderName: 'Deniz', text: 'güzel mesaj', createdAtMs: 2),
      ];
    });
    expect(find.byKey(const Key('chat_dm_u1_u2')), findsOneWidget);
    final container = ProviderScope.containerOf(tester.element(find.byType(ChatsScreen)));
    container.read(moderationProvider.notifier).blockAuthor('u2');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chat_dm_u1_u2')), findsNothing);
    await tester.tap(find.byKey(const Key('chat_g1')));
    await tester.pumpAndSettle();
    expect(find.text('güzel mesaj'), findsOneWidget);
    expect(find.text('kaba mesaj'), findsNothing);
    expect(chats.chats.length, 2);
  });

  testWidgets('long-press on someone else\'s message: report hides it and files a report with a copy; block hides the person', (tester) async {
    final (chats, _) = await _pump(tester, const ChatsScreen(), seed: (c, p) {
      c.chats['g1'] = Chat(id: 'g1', isGroup: true, name: 'Mutfak', members: ['u1', 'u2', 'u3'], createdBy: 'u3', lastMessage: 'y', lastMessageAtMs: 4, lastSenderId: 'u2');
      c.messages['g1'] = [
        const ChatMessage(id: 'a', senderId: 'u2', senderName: 'Can', text: 'kaba mesaj', createdAtMs: 1),
        const ChatMessage(id: 'b', senderId: 'u3', senderName: 'Deniz', text: 'baska mesaj', createdAtMs: 2),
        const ChatMessage(id: 'c', senderId: 'u1', senderName: 'Ayşe', text: 'benim mesajim', createdAtMs: 3),
      ];
    });
    await tester.tap(find.byKey(const Key('chat_g1')));
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const Key('bubble_c')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('msg_report')), findsNothing, reason: 'no menu on my own message');
    await tester.longPress(find.byKey(const Key('bubble_a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('msg_report')));
    await tester.pumpAndSettle();
    expect(chats.reported, ['g1:a:u1']);
    expect(find.text('kaba mesaj'), findsNothing);
    await tester.longPress(find.byKey(const Key('bubble_b')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('msg_block')));
    await tester.pumpAndSettle();
    expect(find.text('baska mesaj'), findsNothing);
    expect(find.text('benim mesajim'), findsOneWidget);
  });

  for (final (w, scale) in [(320.0, 2.0), (360.0, 1.8), (1400.0, 1.0)]) {
    testWidgets('inbox, chat and group info have no overflow at ${w.toInt()}px, ${scale}x', (tester) async {
      await _pump(tester, const ChatsScreen(), width: w, scale: scale, seed: (c, p) {
        c.chats['g1'] = Chat(id: 'g1', isGroup: true, name: 'Çok uzun bir grup adı burada yazıyor' * 2, members: ['u1', 'u2', 'u3'], names: {'u1': 'Ayşe', 'u2': 'Can ' * 6, 'u3': 'D'}, createdBy: 'u1', lastMessage: 'Uzun bir mesaj ' * 10, lastMessageAtMs: 5, lastSenderId: 'u2');
        c.messages['g1'] = [for (var i = 0; i < 6; i++) ChatMessage(id: 'm$i', senderId: i.isEven ? 'u1' : 'u2', senderName: 'Can ' * 6, text: 'Uzun uzun bir mesaj ' * 8, createdAtMs: i)];
      });
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('chat_g1')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('group_info')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
