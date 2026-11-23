import 'dart:async';
import 'package:arewecookin/models/chat.dart';
import 'package:arewecookin/services/chat_service.dart';

class FakeChatService implements ChatService {
  final Map<String, Chat> chats = {};
  final Map<String, List<ChatMessage>> messages = {};
  final Map<String, Map<String, int>> reads = {};
  final _c = StreamController<void>.broadcast();
  final _r = StreamController<void>.broadcast(); // read markers only, so reading never re-emits messages
  int _n = 0;
  int clock = 1000;

  void _emit() => _c.add(null);

  @override
  Stream<List<Chat>> watchChats(String uid) async* {
    List<Chat> mine() => [for (final c in chats.values) if (c.members.contains(uid)) c]..sort((a, b) => b.sortKey.compareTo(a.sortKey));
    yield mine();
    await for (final _ in _c.stream) {
      yield mine();
    }
  }

  @override
  Future<String> openDm({required String me, required String meName, required String other, required String otherName}) async {
    final id = Chat.dmId(me, other);
    chats.putIfAbsent(id, () => Chat(id: id, isGroup: false, members: [me, other]..sort(), names: {me: meName, other: otherName}, createdBy: me, createdAtMs: clock));
    _emit();
    return id;
  }

  @override
  Future<String> createGroup({required String me, required String meName, required String name, required Map<String, String> others}) async {
    final id = 'g${_n++}';
    chats[id] = Chat(id: id, isGroup: true, name: name, members: [me, ...others.keys], names: {me: meName, ...others}, createdBy: me, createdAtMs: clock);
    _emit();
    return id;
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) async* {
    List<ChatMessage> list() => (messages[chatId] ?? []).reversed.toList();
    yield list();
    await for (final _ in _c.stream) {
      yield list();
    }
  }

  @override
  Future<void> send({required String chatId, required String senderId, required String senderName, required String text}) async {
    clock += 1000;
    messages.putIfAbsent(chatId, () => []).add(ChatMessage(id: 'm${_n++}', senderId: senderId, senderName: senderName, text: text, createdAtMs: clock));
    final c = chats[chatId]!;
    chats[chatId] = Chat(id: c.id, isGroup: c.isGroup, name: c.name, members: c.members, names: c.names, createdBy: c.createdBy, lastMessage: text, lastMessageAtMs: clock, lastSenderId: senderId, createdAtMs: c.createdAtMs);
    _emit();
  }

  @override
  Stream<int> watchReadAt(String chatId, String uid) async* {
    yield reads[chatId]?[uid] ?? 0;
    await for (final _ in _r.stream) {
      yield reads[chatId]?[uid] ?? 0;
    }
  }

  @override
  Future<void> markRead(String chatId, String uid) async {
    reads.putIfAbsent(chatId, () => {})[uid] = clock + 1;
    _r.add(null);
  }

  Chat _upd(Chat c, {String? name, List<String>? members, Map<String, String>? names}) => Chat(
      id: c.id, isGroup: c.isGroup, name: name ?? c.name, members: members ?? c.members, names: names ?? c.names, createdBy: c.createdBy,
      lastMessage: c.lastMessage, lastMessageAtMs: c.lastMessageAtMs, lastSenderId: c.lastSenderId, createdAtMs: c.createdAtMs);

  @override
  Future<void> addMembers(String chatId, Map<String, String> people) async {
    final c = chats[chatId]!;
    chats[chatId] = _upd(c, members: {...c.members, ...people.keys}.toList(), names: {...c.names, ...people});
    _emit();
  }

  @override
  Future<void> leave(String chatId, String uid) async {
    final c = chats[chatId]!;
    chats[chatId] = _upd(c, members: [for (final m in c.members) if (m != uid) m], names: {for (final e in c.names.entries) if (e.key != uid) e.key: e.value});
    _emit();
  }

  @override
  Future<void> rename(String chatId, String name) async {
    chats[chatId] = _upd(chats[chatId]!, name: name);
    _emit();
  }
}
