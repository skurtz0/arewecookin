import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_post.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/moderation_provider.dart';
import '../providers/social_provider.dart';
import '../widgets/readable_width.dart';

/// Community tab: people share recipes as posts, others like and comment.
class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  Future<void> _newPost(BuildContext context, WidgetRef ref, AppStrings strings) async {
    if (!ref.read(authProvider).user.isLoggedIn) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(strings.socialSignInToShare)));
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ComposeSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    ref.listen(feedProvider, (_, next) {
      final posts = next.asData?.value;
      if (posts != null) ref.read(socialProvider.notifier).loadLikes(posts.map((p) => p.id));
    });
    final feed = ref.watch(feedProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.tabSocial)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('social_new_post'),
        onPressed: () => _newPost(context, ref, strings),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(strings.socialNewPost),
      ),
      body: feed.when(
        loading: () => Center(
          child: Semantics(
            label: strings.splashLoading,
            child: const CircularProgressIndicator(),
          ),
        ),
        error: (_, _) => Center(child: Text(strings.socialUnavailable)),
        data: (all) {
          final mod = ref.watch(moderationProvider);
          final posts = all
              .where((p) => !mod.blockedAuthors.contains(p.authorId) && !mod.hiddenPosts.contains(p.id))
              .toList();
          return posts.isEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(strings.socialEmpty, textAlign: TextAlign.center)))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: posts.length,
                  itemBuilder: (_, i) => _PostCard(post: posts[i]),
                );
        },
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final SocialPost post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final liked = ref.watch(socialProvider.select((s) => s.liked.contains(post.id)));
    final shownLikes = post.likeCount;
    final initial = post.authorName.trim().isEmpty ? '?' : post.authorName.trim().characters.first.toUpperCase();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            key: Key('author_${post.id}'),
            leading: ExcludeSemantics(child: CircleAvatar(child: Text(initial))),
            title: Text(post.authorName.isEmpty ? '—' : post.authorName),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => AuthorScreen(authorId: post.authorId, authorName: post.authorName),
            )),
            trailing: _PostMenu(post: post),
          ),
          if (post.photoUrl != null)
            Image.network(
              post.photoUrl!,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              semanticLabel: post.title,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          if (post.text.isNotEmpty)
            Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 0), child: Text(post.text)),
          Row(
            children: [
              IconButton(
                key: Key('like_${post.id}'),
                tooltip: strings.socialLike,
                icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : null),
                onPressed: () {
                  if (!ref.read(authProvider).user.isLoggedIn) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(strings.socialSignInToShare)));
                    return;
                  }
                  ref.read(socialProvider.notifier).toggleLike(post.id);
                },
              ),
              Text('$shownLikes'),
              const SizedBox(width: 8),
              IconButton(
                key: Key('comment_${post.id}'),
                tooltip: strings.socialComments,
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _CommentsSheet(postId: post.id),
                ),
              ),
              Text('${post.commentCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComposeSheet extends ConsumerStatefulWidget {
  const _ComposeSheet();
  @override
  ConsumerState<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends ConsumerState<_ComposeSheet> {
  final _title = TextEditingController();
  final _text = TextEditingController();
  bool _busy = false;
  Uint8List? _photo;
  String _photoType = 'image/jpeg';

  Future<void> _pick() async {
    try {
      final x = await ref.read(photoPickerProvider)();
      if (x == null || !mounted) return;
      setState(() {
        _photo = x.$1;
        _photoType = x.$2;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_busy || _title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final ok = await ref.read(socialProvider.notifier).publish(title: _title.text, text: _text.text, photo: _photo, photoType: _photoType);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ref.read(appStringsProvider).socialUnavailable)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('post_title'),
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: InputDecoration(labelText: strings.socialPostTitleHint),
          ),
          TextField(
            key: const Key('post_text'),
            controller: _text,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 1000,
            maxLines: 4,
            decoration: InputDecoration(labelText: strings.socialPostTextHint),
          ),
          if (_photo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(_photo!, height: 140, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox(height: 140, child: Icon(Icons.broken_image_outlined)))),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                key: const Key('post_pick_photo'),
                onPressed: _busy ? null : _pick,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(strings.socialAddPhoto),
              ),
              FilledButton(
              key: const Key('post_publish'),
              onPressed: _busy ? null : _publish,
              child: Text(strings.socialPublish),
            ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  const _CommentsSheet({required this.postId});
  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final strings = ref.read(appStringsProvider);
    if (!ref.read(authProvider).user.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.socialSignInToShare)));
      return;
    }
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    final ok = await ref.read(socialProvider.notifier).comment(widget.postId, text);
    if (!mounted) return;
    if (ok) {
      _controller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.socialUnavailable)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final comments = ref.watch(commentsProvider(widget.postId));
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.socialComments, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Flexible(
            child: comments.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Text(strings.socialUnavailable),
              data: (list) => ListView(
                shrinkWrap: true,
                children: [
                  for (final c in list)
                    ListTile(dense: true, title: Text(c.authorName), subtitle: Text(c.text)),
                ],
              ),
            ),
          ),
          TextField(
            key: const Key('comment_field'),
            controller: _controller,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            decoration: InputDecoration(
              hintText: strings.socialCommentHint,
              suffixIcon: IconButton(
                key: const Key('comment_send'),
                tooltip: strings.socialCommentHint,
                icon: const Icon(Icons.send),
                onPressed: _send,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostMenu extends ConsumerWidget {
  final SocialPost post;
  const _PostMenu({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final user = ref.watch(authProvider).user;
    final mine = user.isLoggedIn && user.id == post.authorId;
    return PopupMenuButton<String>(
      key: Key('menu_${post.id}'),
      tooltip: strings.socialMore,
      onSelected: (v) async {
        final messenger = ScaffoldMessenger.of(context);
        if (v == 'delete') {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              content: Text(strings.socialDeleteConfirm),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(strings.cancel)),
                TextButton(key: const Key('confirm_delete'), onPressed: () => Navigator.pop(ctx, true), child: Text(strings.socialDelete)),
              ],
            ),
          );
          if (ok == true) await ref.read(socialProvider.notifier).deletePost(post.id);
        } else if (v == 'report') {
          await ref.read(socialProvider.notifier).report(post.id, 'report');
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(strings.socialReported)));
        } else if (v == 'block') {
          ref.read(moderationProvider.notifier).blockAuthor(post.authorId);
        }
      },
      itemBuilder: (_) => [
        if (mine)
          PopupMenuItem(value: 'delete', child: Text(strings.socialDelete))
        else ...[
          PopupMenuItem(value: 'report', child: Text(strings.socialReport)),
          PopupMenuItem(value: 'block', child: Text(strings.socialBlock)),
        ],
      ],
    );
  }
}

/// One author's posts, with block / unblock.
class AuthorScreen extends ConsumerWidget {
  final String authorId;
  final String authorName;
  const AuthorScreen({super.key, required this.authorId, required this.authorName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final mod = ref.watch(moderationProvider);
    final blocked = mod.blockedAuthors.contains(authorId);
    final me = ref.watch(authProvider).user;
    final isMe = me.isLoggedIn && me.id == authorId;
    final posts = ref.watch(feedProvider).asData?.value
            .where((p) => p.authorId == authorId && !mod.hiddenPosts.contains(p.id))
            .toList() ??
        const <SocialPost>[];
    return Scaffold(
      appBar: AppBar(
        title: Text(authorName.isEmpty ? '—' : authorName),
        actions: [
          if (!isMe)
            TextButton(
              key: const Key('author_block_toggle'),
              onPressed: () {
                final n = ref.read(moderationProvider.notifier);
                blocked ? n.unblockAuthor(authorId) : n.blockAuthor(authorId);
              },
              child: Text(blocked ? strings.socialUnblock : strings.socialBlock),
            ),
        ],
      ),
      body: ReadableWidth(
        child: blocked
            ? Center(child: Text(strings.socialBlockedNote))
            : posts.isEmpty
                ? Center(child: Text(strings.socialEmpty))
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (_, i) => _PostCard(post: posts[i]),
                  ),
      ),
    );
  }
}
