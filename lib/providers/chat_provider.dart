import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import 'auth_provider.dart';
import 'moderation_provider.dart';

final chatServiceProvider = Provider<ChatService>((ref) => FirestoreChatService());

/// My conversations, newest first. Direct chats with someone I blocked are left out.
final chatsProvider = StreamProvider.autoDispose<List<Chat>>((ref) {
  final me = ref.watch(authProvider).user;
  if (!me.isLoggedIn) return Stream.value(const []);
  final blocked = ref.watch(moderationProvider).blockedAuthors;
  return ref.watch(chatServiceProvider).watchChats(me.id).map((all) => [
        for (final c in all)
          if (c.isGroup || !blocked.contains(c.otherId(me.id))) c
      ]);
});

final messagesProvider = StreamProvider.autoDispose.family<List<ChatMessage>, String>(
  (ref, id) => ref.watch(chatServiceProvider).watchMessages(id),
);

final readAtProvider = StreamProvider.autoDispose.family<int, String>((ref, chatId) {
  final me = ref.watch(authProvider).user;
  if (!me.isLoggedIn) return Stream.value(0);
  return ref.watch(chatServiceProvider).watchReadAt(chatId, me.id);
});

/// True when the last message is from someone else and newer than my last visit.
bool isUnread(Chat c, String me, int readAtMs) => c.lastMessageAtMs > readAtMs && c.lastSenderId.isNotEmpty && c.lastSenderId != me;

/// Number of conversations with something new, for the badge on the inbox button.
final unreadCountProvider = Provider.autoDispose<int>((ref) {
  final me = ref.watch(authProvider).user;
  final chats = ref.watch(chatsProvider).asData?.value ?? const <Chat>[];
  var n = 0;
  for (final c in chats) {
    final r = ref.watch(readAtProvider(c.id)).asData?.value ?? 0;
    if (isUnread(c, me.id, r)) n++;
  }
  return n;
});
