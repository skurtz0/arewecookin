import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/moderation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_widgets.dart';
import '../widgets/readable_width.dart';

/// Chat rules are live (verified with three test users); set false to hide the feature.
const bool kChatEnabled = true;

String _t(WidgetRef ref, String tr, String en) => ref.read(appStringsProvider).isTurkish ? tr : en;

/// Opens (or creates) the direct chat with [otherId] and shows it.
Future<void> openDirectChat(BuildContext context, WidgetRef ref, {required String otherId, required String otherName}) async {
  final me = ref.read(authProvider).user;
  final messenger = ScaffoldMessenger.of(context);
  final nav = Navigator.of(context);
  if (!me.isLoggedIn) {
    messenger.showSnackBar(SnackBar(content: Text(ref.read(appStringsProvider).socialSignInToShare)));
    return;
  }
  try {
    final id = await ref.read(chatServiceProvider).openDm(me: me.id, meName: me.displayName, other: otherId, otherName: otherName);
    nav.push(MaterialPageRoute<void>(builder: (_) => ChatScreen(chatId: id)));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(_t(ref, 'Sohbet açılamadı.', 'Could not open the chat.'))));
  }
}

/// Inbox button for the app bar, with a dot count of conversations with something new.
class InboxButton extends ConsumerWidget {
  const InboxButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kChatEnabled) return const SizedBox.shrink();
    final n = ref.watch(unreadCountProvider);
    return IconButton(
      key: const Key('inbox_button'),
      tooltip: _t(ref, 'Mesajlar', 'Messages'),
      icon: Badge(isLabelVisible: n > 0, label: Text('$n'), child: const Icon(Icons.send_outlined)),
      onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ChatsScreen())),
    );
  }
}

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).user;
    final chats = ref.watch(chatsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_t(ref, 'Mesajlar', 'Messages'))),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('chat_new'),
        onPressed: () {
          if (!me.isLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ref.read(appStringsProvider).socialSignInToShare)));
            return;
          }
          showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const NewChatSheet());
        },
        icon: const Icon(Icons.edit_outlined),
        label: Text(_t(ref, 'Yeni', 'New')),
      ),
      body: ReadableWidth(
        child: !me.isLoggedIn
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(ref.watch(appStringsProvider).socialSignInToShare, textAlign: TextAlign.center)))
            : chats.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(ref.watch(appStringsProvider).socialUnavailable)),
                data: (list) => list.isEmpty
                    ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_t(ref, 'Henüz sohbet yok. Yeni düğmesiyle başla.', 'No conversations yet. Tap New to start one.'), textAlign: TextAlign.center)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _ChatTile(chat: list[i]),
                      ),
              ),
      ),
    );
  }
}

class _ChatTile extends ConsumerWidget {
  final Chat chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).user;
    final readAt = ref.watch(readAtProvider(chat.id)).asData?.value ?? 0;
    final unread = isUnread(chat, me.id, readAt);
    final title = chat.titleFor(me.id);
    return ListTile(
      key: Key('chat_${chat.id}'),
      leading: chat.isGroup ? const CircleAvatar(child: Icon(Icons.group)) : ProfileAvatar(uid: chat.otherId(me.id) ?? '', name: title),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: unread ? FontWeight.bold : null)),
      subtitle: Text(chat.lastMessage.isEmpty ? _t(ref, 'Sohbeti başlat', 'Say hello') : chat.lastMessage,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: unread ? FontWeight.bold : null)),
      trailing: unread ? const Icon(Icons.circle, size: 12, color: Color(0xFFFF5722)) : null,
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ChatScreen(chatId: chat.id))),
    );
  }
}

/// Pick people I follow: one person starts a direct chat, two or more start a group.
class NewChatSheet extends ConsumerStatefulWidget {
  const NewChatSheet({super.key});

  @override
  ConsumerState<NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends ConsumerState<NewChatSheet> {
  final Map<String, String> _picked = {};
  final _name = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final me = ref.read(authProvider).user;
    if (_busy || _picked.isEmpty) return;
    if (_picked.length > 1 && _name.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final nav = Navigator.of(context);
    try {
      final svc = ref.read(chatServiceProvider);
      final String id;
      if (_picked.length == 1) {
        id = await svc.openDm(me: me.id, meName: me.displayName, other: _picked.keys.first, otherName: _picked.values.first);
      } else {
        id = await svc.createGroup(me: me.id, meName: me.displayName, name: _name.text.trim(), others: _picked);
      }
      nav.pop();
      nav.push(MaterialPageRoute<void>(builder: (_) => ChatScreen(chatId: id)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t(ref, 'Sohbet oluşturulamadı.', 'Could not create the chat.'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authProvider).user;
    final following = (ref.watch(followingProvider(me.id)).asData?.value ?? const <String>{}).toList()..sort();
    final blocked = ref.watch(moderationProvider).blockedAuthors;
    final people = [for (final u in following) if (!blocked.contains(u)) u];
    final group = _picked.length > 1;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t(ref, 'Kimlerle konuşmak istiyorsun?', 'Who do you want to talk to?'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(_t(ref, 'Takip ettiklerinden seç. Bir kişi = mesaj, iki ve üstü = grup. Başkasına mesaj için profiline gir.', 'Pick from people you follow. One person = a message, two or more = a group. To message someone else, open their profile.'),
              style: const TextStyle(fontSize: 12)),
          Flexible(
            child: people.isEmpty
                ? Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text(_t(ref, 'Henüz kimseyi takip etmiyorsun.', 'You do not follow anyone yet.')))
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final uid in people)
                        _PersonTile(
                          uid: uid,
                          selected: _picked.containsKey(uid),
                          onChanged: (name, on) => setState(() => on ? _picked[uid] = name : _picked.remove(uid)),
                        ),
                    ],
                  ),
          ),
          if (group)
            TextField(
              key: const Key('group_name'),
              controller: _name,
              maxLength: 40,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: _t(ref, 'Grup adı', 'Group name')),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              key: const Key('chat_start'),
              onPressed: (_busy || _picked.isEmpty || (group && _name.text.trim().isEmpty)) ? null : _go,
              child: Text(group ? _t(ref, 'Grubu oluştur', 'Create group') : _t(ref, 'Mesaj yaz', 'Message')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonTile extends ConsumerWidget {
  final String uid;
  final bool selected;
  final void Function(String name, bool selected) onChanged;
  const _PersonTile({required this.uid, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileProvider(uid)).asData?.value?.displayName;
    final shown = (name != null && name.isNotEmpty) ? name : '…${uid.length > 6 ? uid.substring(uid.length - 6) : uid}';
    return CheckboxListTile(
      key: Key('pick_$uid'),
      dense: true,
      value: selected,
      onChanged: (v) => onChanged(shown, v ?? false),
      secondary: ProfileAvatar(uid: uid, name: shown, radius: 18),
      title: Text(shown, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _read());
  }

  void _read() {
    final me = ref.read(authProvider).user;
    if (!mounted || !me.isLoggedIn) return;
    ref.read(chatServiceProvider).markRead(widget.chatId, me.id).catchError((_) {});
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final me = ref.read(authProvider).user;
    final t = _text.text.trim();
    if (_sending || t.isEmpty || !me.isLoggedIn) return;
    setState(() => _sending = true);
    try {
      await ref.read(chatServiceProvider).send(chatId: widget.chatId, senderId: me.id, senderName: me.displayName, text: t);
      _text.clear();
      _read();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t(ref, 'Mesaj gönderilemedi (engellenmiş olabilirsin).', 'Message not sent (you may be blocked).'))));
      }
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authProvider).user;
    final chat = ref.watch(chatsProvider).asData?.value.where((c) => c.id == widget.chatId).firstOrNull;
    final msgs = ref.watch(messagesProvider(widget.chatId));
    final blocked = ref.watch(moderationProvider).blockedAuthors;
    // New messages arriving while the chat is open count as read.
    ref.listen(messagesProvider(widget.chatId), (_, next) => _read());
    final title = chat?.titleFor(me.id) ?? '…';
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (chat != null && chat.isGroup)
            IconButton(
              key: const Key('group_info'),
              tooltip: _t(ref, 'Grup bilgisi', 'Group info'),
              icon: const Icon(Icons.info_outline),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GroupInfoScreen(chatId: widget.chatId))),
            ),
        ],
      ),
      body: ReadableWidth(
        child: Column(
          children: [
            Expanded(
              child: msgs.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(ref.watch(appStringsProvider).socialUnavailable)),
                data: (all) {
                  final list = [for (final m in all) if (!blocked.contains(m.senderId)) m];
                  if (list.isEmpty) return Center(child: Text(_t(ref, 'Henüz mesaj yok.', 'No messages yet.')));
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _Bubble(message: list[i], mine: list[i].senderId == me.id, showName: chat?.isGroup == true && list[i].senderId != me.id),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('chat_input'),
                        controller: _text,
                        maxLength: Chat.maxMessage,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(hintText: _t(ref, 'Mesaj yaz…', 'Write a message…'), counterText: ''),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    IconButton(
                      key: const Key('chat_send'),
                      tooltip: _t(ref, 'Gönder', 'Send'),
                      icon: const Icon(Icons.send),
                      onPressed: _sending ? null : _send,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;
  final bool showName;
  const _Bubble({required this.message, required this.mine, required this.showName});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8 > 520 ? 520 : MediaQuery.sizeOf(context).width * 0.8),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: mine ? cs.primaryContainer : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showName) Text(message.senderName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              Text(message.text),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupInfoScreen extends ConsumerWidget {
  final String chatId;
  const GroupInfoScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).user;
    final chat = ref.watch(chatsProvider).asData?.value.where((c) => c.id == chatId).firstOrNull;
    final owner = chat != null && chat.createdBy == me.id;
    return Scaffold(
      appBar: AppBar(title: Text(chat?.name ?? '…', maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ReadableWidth(
        child: chat == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  ListTile(title: Text(_t(ref, 'Üyeler (${chat.members.length}/${Chat.maxGroupMembers})', 'Members (${chat.members.length}/${Chat.maxGroupMembers})'), style: const TextStyle(fontWeight: FontWeight.bold))),
                  for (final uid in chat.members)
                    ListTile(
                      dense: true,
                      leading: ProfileAvatar(uid: uid, name: chat.names[uid] ?? '', radius: 16),
                      title: Text(chat.names[uid] ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: uid == chat.createdBy ? Text(_t(ref, 'Yönetici', 'Admin')) : null,
                    ),
                  if (owner && chat.members.length < Chat.maxGroupMembers)
                    ListTile(
                      key: const Key('group_add'),
                      leading: const Icon(Icons.person_add_alt),
                      title: Text(_t(ref, 'Üye ekle', 'Add members')),
                      onTap: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _AddMembersSheet(chat: chat)),
                    ),
                  if (owner)
                    ListTile(
                      key: const Key('group_rename'),
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(_t(ref, 'Grup adını değiştir', 'Rename group')),
                      onTap: () => _rename(context, ref, chat),
                    ),
                  ListTile(
                    key: const Key('group_leave'),
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(_t(ref, 'Gruptan ayrıl', 'Leave group'), style: const TextStyle(color: Colors.red)),
                    onTap: () async {
                      final nav = Navigator.of(context);
                      await ref.read(chatServiceProvider).leave(chatId, me.id);
                      nav.popUntil((r) => r.isFirst);
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Chat chat) async {
    final c = TextEditingController(text: chat.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: TextField(key: const Key('group_rename_field'), controller: c, maxLength: 40),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_t(ref, 'Vazgeç', 'Cancel'))),
          TextButton(key: const Key('group_rename_ok'), onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(_t(ref, 'Kaydet', 'Save'))),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) await ref.read(chatServiceProvider).rename(chat.id, name);
  }
}

class _AddMembersSheet extends ConsumerStatefulWidget {
  final Chat chat;
  const _AddMembersSheet({required this.chat});

  @override
  ConsumerState<_AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends ConsumerState<_AddMembersSheet> {
  final Map<String, String> _picked = {};

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authProvider).user;
    final blocked = ref.watch(moderationProvider).blockedAuthors;
    final room = Chat.maxGroupMembers - widget.chat.members.length;
    final people = [
      for (final u in (ref.watch(followingProvider(me.id)).asData?.value ?? const <String>{}).toList()..sort())
        if (!widget.chat.members.contains(u) && !blocked.contains(u)) u
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: people.isEmpty
                ? Padding(padding: const EdgeInsets.all(24), child: Text(_t(ref, 'Eklenecek kimse yok.', 'Nobody to add.')))
                : ListView(shrinkWrap: true, children: [
                    for (final uid in people)
                      _PersonTile(uid: uid, selected: _picked.containsKey(uid), onChanged: (n, on) => setState(() {
                            if (on && _picked.length < room) {
                              _picked[uid] = n;
                            } else if (!on) {
                              _picked.remove(uid);
                            }
                          })),
                  ]),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              key: const Key('group_add_ok'),
              onPressed: _picked.isEmpty
                  ? null
                  : () async {
                      final nav = Navigator.of(context);
                      await ref.read(chatServiceProvider).addMembers(widget.chat.id, _picked);
                      nav.pop();
                    },
              child: Text(_t(ref, 'Ekle', 'Add')),
            ),
          ),
        ],
      ),
    );
  }
}
