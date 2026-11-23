/// A conversation: a direct message between two people or a group.
class Chat {
  static const maxGroupMembers = 50;
  static const maxMessage = 1000;

  final String id;
  final bool isGroup;
  final String name; // groups only
  final List<String> members;
  final Map<String, String> names; // uid -> display name at the time of joining
  final String createdBy;
  final String lastMessage;
  final int lastMessageAtMs;
  final String lastSenderId;
  final int createdAtMs;

  const Chat({
    required this.id,
    required this.isGroup,
    this.name = '',
    required this.members,
    this.names = const {},
    required this.createdBy,
    this.lastMessage = '',
    this.lastMessageAtMs = 0,
    this.lastSenderId = '',
    this.createdAtMs = 0,
  });

  /// Deterministic id so two people always share one conversation.
  static String dmId(String a, String b) {
    final s = [a, b]..sort();
    return 'dm_${s[0]}_${s[1]}';
  }

  String? otherId(String me) {
    for (final m in members) {
      if (m != me) return m;
    }
    return null;
  }

  String titleFor(String me) {
    if (isGroup) return name;
    final o = otherId(me);
    return (o != null ? names[o] : null) ?? '—';
  }

  int get sortKey => lastMessageAtMs > 0 ? lastMessageAtMs : createdAtMs;

  factory Chat.fromMap(String id, Map<String, dynamic> m) => Chat(
        id: id,
        isGroup: m['type'] == 'group',
        name: (m['name'] ?? '') as String,
        members: [for (final x in (m['members'] as List? ?? const [])) if (x is String) x],
        names: {for (final e in ((m['names'] as Map?) ?? const {}).entries) e.key as String: (e.value ?? '') as String},
        createdBy: (m['createdBy'] ?? '') as String,
        lastMessage: (m['lastMessage'] ?? '') as String,
        lastMessageAtMs: (m['lastMessageAtMs'] ?? 0) as int,
        lastSenderId: (m['lastSenderId'] ?? '') as String,
        createdAtMs: (m['createdAtMs'] ?? 0) as int,
      );
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final int createdAtMs;
  const ChatMessage({required this.id, required this.senderId, required this.senderName, required this.text, required this.createdAtMs});

  factory ChatMessage.fromMap(String id, Map<String, dynamic> m) => ChatMessage(
        id: id,
        senderId: (m['senderId'] ?? '') as String,
        senderName: (m['senderName'] ?? '') as String,
        text: (m['text'] ?? '') as String,
        createdAtMs: (m['createdAtMs'] ?? 0) as int,
      );
}
