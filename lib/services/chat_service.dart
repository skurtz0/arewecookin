import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';

abstract class ChatService {
  /// Conversations [uid] is in, newest first.
  Stream<List<Chat>> watchChats(String uid);

  /// Returns the id of the direct chat between the two, creating it when needed.
  Future<String> openDm({required String me, required String meName, required String other, required String otherName});

  Future<String> createGroup({required String me, required String meName, required String name, required Map<String, String> others});
  Stream<List<ChatMessage>> watchMessages(String chatId);
  Future<void> send({required String chatId, required String senderId, required String senderName, required String text});

  /// When [uid] last opened the chat (for the unread dot).
  Stream<int> watchReadAt(String chatId, String uid);
  Future<void> markRead(String chatId, String uid);

  Future<void> addMembers(String chatId, Map<String, String> people);
  Future<void> leave(String chatId, String uid);
  Future<void> rename(String chatId, String name);

  /// Reports one message; a copy of it goes with the report for the admin.
  Future<void> reportMessage({required String chatId, required ChatMessage message, required String reporterId});
}

class FirestoreChatService implements ChatService {
  FirebaseFirestore? get _dbOrNull {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  Stream<List<Chat>> watchChats(String uid) {
    final db = _dbOrNull;
    if (db == null) return Stream.value(const []);
    // No orderBy: array-contains plus another field needs an index. Sorted in the app.
    return db.collection('chats').where('members', arrayContains: uid).limit(200).snapshots().map(
          (s) => [for (final d in s.docs) Chat.fromMap(d.id, d.data())]..sort((a, b) => b.sortKey.compareTo(a.sortKey)),
        );
  }

  @override
  Future<String> openDm({required String me, required String meName, required String other, required String otherName}) async {
    final id = Chat.dmId(me, other);
    final ref = _db.collection('chats').doc(id);
    try {
      if ((await ref.get()).exists) return id;
    } catch (_) {
      // A missing chat can't be read before it exists (rules); fall through and create it.
    }
    final members = [me, other]..sort();
    await ref.set({
      'type': 'dm',
      'members': members,
      'names': {me: meName, other: otherName},
      'createdBy': me,
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    });
    return id;
  }

  @override
  Future<String> createGroup({required String me, required String meName, required String name, required Map<String, String> others}) async {
    final ref = _db.collection('chats').doc();
    await ref.set({
      'type': 'group',
      'name': name,
      'members': [me, ...others.keys],
      'names': {me: meName, ...others},
      'createdBy': me,
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    });
    return ref.id;
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    final db = _dbOrNull;
    if (db == null) return Stream.value(const []);
    return db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAtMs', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => [for (final d in s.docs) ChatMessage.fromMap(d.id, d.data())]);
  }

  @override
  Future<void> send({required String chatId, required String senderId, required String senderName, required String text}) {
    final chat = _db.collection('chats').doc(chatId);
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = _db.batch();
    batch.set(chat.collection('messages').doc(), {'senderId': senderId, 'senderName': senderName, 'text': text, 'createdAtMs': now});
    batch.update(chat, {'lastMessage': text.length > 120 ? text.substring(0, 120) : text, 'lastMessageAtMs': now, 'lastSenderId': senderId});
    return batch.commit();
  }

  @override
  Stream<int> watchReadAt(String chatId, String uid) {
    final db = _dbOrNull;
    if (db == null) return Stream.value(0);
    return db.collection('chats').doc(chatId).collection('members').doc(uid).snapshots().map((d) => (d.data()?['readAtMs'] ?? 0) as int);
  }

  @override
  Future<void> markRead(String chatId, String uid) =>
      _db.collection('chats').doc(chatId).collection('members').doc(uid).set({'readAtMs': DateTime.now().millisecondsSinceEpoch});

  @override
  Future<void> addMembers(String chatId, Map<String, String> people) {
    return _db.runTransaction((tx) async {
      final ref = _db.collection('chats').doc(chatId);
      final c = Chat.fromMap(chatId, (await tx.get(ref)).data() ?? {});
      final members = {...c.members, ...people.keys}.toList();
      tx.update(ref, {'members': members, 'names': {...c.names, ...people}});
    });
  }

  @override
  Future<void> leave(String chatId, String uid) {
    return _db.runTransaction((tx) async {
      final ref = _db.collection('chats').doc(chatId);
      final c = Chat.fromMap(chatId, (await tx.get(ref)).data() ?? {});
      tx.update(ref, {
        'members': [for (final m in c.members) if (m != uid) m],
        'names': {for (final e in c.names.entries) if (e.key != uid) e.key: e.value},
      });
    });
  }

  @override
  Future<void> rename(String chatId, String name) => _db.collection('chats').doc(chatId).update({'name': name});

  @override
  Future<void> reportMessage({required String chatId, required ChatMessage message, required String reporterId}) {
    return _db.collection('reports').add({
      'chatId': chatId,
      'messageId': message.id,
      'messageText': message.text,
      'messageSenderId': message.senderId,
      'messageSenderName': message.senderName,
      'postId': '',
      'reporterId': reporterId,
      'reason': 'report',
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
