import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_post.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/social_provider.dart';

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
        data: (posts) => posts.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(strings.socialEmpty, textAlign: TextAlign.center)))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: posts.length,
                itemBuilder: (_, i) => _PostCard(post: posts[i]),
              ),
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
            leading: ExcludeSemantics(child: CircleAvatar(child: Text(initial))),
            title: Text(post.authorName.isEmpty ? '—' : post.authorName),
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

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_busy || _title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final ok = await ref.read(socialProvider.notifier).publish(title: _title.text, text: _text.text);
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
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              key: const Key('post_publish'),
              onPressed: _busy ? null : _publish,
              child: Text(strings.socialPublish),
            ),
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
