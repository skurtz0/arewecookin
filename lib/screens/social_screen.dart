import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_post.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/moderation_provider.dart';
import '../providers/social_provider.dart';
import '../models/profile_doc.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_widgets.dart';
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
    ref.listen(followingFeedProvider, (_, next) {
      final posts = next.asData?.value;
      if (posts != null) ref.read(socialProvider.notifier).loadLikes(posts.map((p) => p.id));
    });
    final following = ref.watch(feedModeProvider);
    final feed = following ? ref.watch(followingFeedProvider) : ref.watch(feedProvider);
    final tr = strings.isTurkish;
    return Scaffold(
      appBar: AppBar(title: Text(strings.tabSocial)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('social_new_post'),
        onPressed: () => _newPost(context, ref, strings),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(strings.socialNewPost),
      ),
      body: ReadableWidth(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  key: const Key('feed_mode'),
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ChoiceChip(
                      label: Text(tr ? 'Herkes' : 'Everyone'),
                      selected: !following,
                      onSelected: (_) => ref.read(feedModeProvider.notifier).set(false),
                    ),
                    ChoiceChip(
                      label: Text(tr ? 'Takip ettiklerim' : 'Following'),
                      selected: following,
                      onSelected: (_) => ref.read(feedModeProvider.notifier).set(true),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: feed.when(
                loading: () => Center(
                  child: Semantics(label: strings.splashLoading, child: const CircularProgressIndicator()),
                ),
                error: (_, _) => Center(child: Text(strings.socialUnavailable)),
                data: (all) {
                  final mod = ref.watch(moderationProvider);
                  final posts = all
                      .where((p) => !mod.blockedAuthors.contains(p.authorId) && !mod.hiddenPosts.contains(p.id))
                      .toList();
                  final emptyText = following
                      ? (tr ? 'Henüz kimseyi takip etmiyorsun ya da takip ettiklerin paylaşım yapmadı.' : 'You follow nobody yet, or they have not posted.')
                      : strings.socialEmpty;
                  return posts.isEmpty
                      ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(emptyText, textAlign: TextAlign.center)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: posts.length,
                          itemBuilder: (_, i) => _PostCard(post: posts[i]),
                        );
                },
              ),
            ),
          ],
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            key: Key('author_${post.id}'),
            leading: ProfileAvatar(uid: post.authorId, name: post.authorName),
            title: Text(post.authorName.isEmpty ? '—' : post.authorName),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => AuthorScreen(authorId: post.authorId, authorName: post.authorName),
            )),
            trailing: _PostMenu(post: post),
          ),
          if (post.photoUrls.isNotEmpty) _PhotoGallery(urls: post.photoUrls, label: post.title),
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
  final List<(Uint8List, String)> _photos = [];

  Future<void> _pick() async {
    if (_photos.length >= SocialPost.maxPhotos) return;
    try {
      final x = await ref.read(photoPickerProvider)();
      if (x == null || !mounted) return;
      setState(() => _photos.add((x.$1, x.$2)));
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
    final ok = await ref.read(socialProvider.notifier).publish(title: _title.text, text: _text.text, photos: _photos);
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
          if (_photos.isNotEmpty)
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_photos[i].$1,
                          width: 96, height: 96, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox(width: 96, height: 96, child: Icon(Icons.broken_image_outlined))),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        key: Key('post_remove_photo_$i'),
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: _busy ? null : () => setState(() => _photos.removeAt(i)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                key: const Key('post_pick_photo'),
                onPressed: _busy ? null : _pick,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(_photos.isEmpty ? strings.socialAddPhoto : '${strings.socialAddPhoto} (${_photos.length}/${SocialPost.maxPhotos})'),
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
    final mod = ref.watch(moderationProvider);
    final user = ref.watch(authProvider).user;
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
                    if (!mod.blockedAuthors.contains(c.authorId) && !mod.hiddenPosts.contains('comment:${c.id}'))
                      ListTile(
                        dense: true,
                        title: Text(c.authorName),
                        subtitle: Text(c.text),
                        trailing: (user.isLoggedIn && user.id != c.authorId)
                            ? PopupMenuButton<String>(
                                key: Key('cmenu_${c.id}'),
                                tooltip: strings.socialMore,
                                onSelected: (v) {
                                  if (v == 'report') {
                                    ref.read(socialProvider.notifier).reportComment(widget.postId, c.id, 'report');
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(SnackBar(content: Text(strings.socialReported)));
                                  } else {
                                    ref.read(moderationProvider.notifier).blockAuthor(c.authorId);
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(value: 'report', child: Text(strings.socialReport)),
                                  PopupMenuItem(value: 'block', child: Text(strings.socialBlock)),
                                ],
                              )
                            : null,
                      ),
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
        } else if (v == 'pin' || v == 'unpin') {
          final tr = strings.isTurkish;
          final pinned = ref.read(profileProvider(user.id)).asData?.value?.pinned ?? const <String>[];
          if (v == 'pin' && pinned.length >= ProfileDoc.maxPinned) {
            messenger.showSnackBar(SnackBar(content: Text(tr ? 'En çok ${ProfileDoc.maxPinned} gönderi sabitlenebilir.' : 'You can pin up to ${ProfileDoc.maxPinned} posts.')));
          } else {
            try {
              await ref.read(profileServiceProvider).saveProfile(
                    user.id,
                    pinned: v == 'pin' ? [...pinned, post.id] : [for (final id in pinned) if (id != post.id) id],
                  );
            } catch (_) {
              messenger.showSnackBar(SnackBar(content: Text(strings.socialUnavailable)));
            }
          }
        }
      },
      itemBuilder: (_) => [
        if (mine) ...[
          PopupMenuItem(
            value: ref.read(profileProvider(user.id)).asData?.value?.pinned.contains(post.id) == true ? 'unpin' : 'pin',
            child: Text(ref.read(profileProvider(user.id)).asData?.value?.pinned.contains(post.id) == true
                ? (strings.isTurkish ? 'Sabitlemeyi kaldır' : 'Unpin from profile')
                : (strings.isTurkish ? 'Profile sabitle' : 'Pin to profile')),
          ),
          PopupMenuItem(value: 'delete', child: Text(strings.socialDelete)),
        ] else ...[
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
    final profile = ref.watch(profileProvider(authorId)).asData?.value;
    final pinned = profile?.pinned ?? const <String>[];
    final posts = (ref.watch(authorPostsProvider(authorId)).asData?.value ?? const <SocialPost>[])
        .where((p) => !mod.hiddenPosts.contains(p.id))
        .toList()
      ..sort((a, b) {
        final pa = pinned.contains(a.id), pb = pinned.contains(b.id);
        if (pa != pb) return pa ? -1 : 1;
        return b.createdAtMs.compareTo(a.createdAtMs);
      });
    final name = (profile?.displayName.isNotEmpty == true) ? profile!.displayName : authorName;
    return Scaffold(
      appBar: AppBar(
        title: Text(name.isEmpty ? '—' : name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (!isMe)
            TextButton(
              key: const Key('author_block_toggle'),
              onPressed: () {
                final n = ref.read(moderationProvider.notifier);
                blocked ? n.unblockAuthor(authorId) : n.blockAuthor(authorId);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(blocked ? strings.socialUnblock : strings.socialBlock, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
        ],
      ),
      body: ReadableWidth(
        child: blocked
            ? Center(child: Text(strings.socialBlockedNote))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _ProfileHeader(authorId: authorId, name: name, profile: profile, isMe: isMe, postCount: posts.length),
                  ),
                  if (posts.isEmpty)
                    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(strings.socialEmpty))))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(4),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _PostTile(post: posts[i], pinned: pinned.contains(posts[i].id)),
                          childCount: posts.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final String authorId;
  final String name;
  final ProfileDoc? profile;
  final bool isMe;
  final int postCount;
  const _ProfileHeader({required this.authorId, required this.name, required this.profile, required this.isMe, required this.postCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(appStringsProvider).isTurkish;
    final me = ref.watch(authProvider).user;
    final followers = ref.watch(followersProvider(authorId)).asData?.value ?? const <String>{};
    final following = ref.watch(followingProvider(authorId)).asData?.value ?? const <String>{};
    final iFollow = me.isLoggedIn && followers.contains(me.id);
    Widget stat(String label, int n, {Key? key}) => Expanded(
          child: Column(children: [
            Text('$n', key: key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          ]),
        );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            ProfileAvatar(uid: authorId, name: name, radius: 40),
            const SizedBox(width: 16),
            stat(tr ? 'Gönderi' : 'Posts', postCount, key: const Key('stat_posts')),
            stat(tr ? 'Takipçi' : 'Followers', followers.length, key: const Key('stat_followers')),
            stat(tr ? 'Takip' : 'Following', following.length, key: const Key('stat_following')),
          ]),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (profile?.bio.isNotEmpty == true) Padding(padding: const EdgeInsets.only(top: 4), child: Text(profile!.bio)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: isMe
                ? OutlinedButton(
                    key: const Key('profile_edit'),
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => EditProfileSheet(current: profile),
                    ),
                    child: Text(tr ? 'Profili düzenle' : 'Edit profile'),
                  )
                : (iFollow
                    ? OutlinedButton(
                        key: const Key('profile_follow'),
                        onPressed: () => ref.read(profileServiceProvider).setFollow(me: me.id, target: authorId, follow: false),
                        child: Text(tr ? 'Takibi bırak' : 'Unfollow'),
                      )
                    : FilledButton(
                        key: const Key('profile_follow'),
                        onPressed: () {
                          if (!me.isLoggedIn) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(content: Text(ref.read(appStringsProvider).socialSignInToShare)));
                            return;
                          }
                          ref.read(profileServiceProvider).setFollow(me: me.id, target: authorId, follow: true);
                        },
                        child: Text(tr ? 'Takip et' : 'Follow'),
                      )),
          ),
        ],
      ),
    );
  }
}

/// One square in the profile grid: first photo (or the title for a text post). Tap opens the full post.
class _PostTile extends StatelessWidget {
  final SocialPost post;
  final bool pinned;
  const _PostTile({required this.post, required this.pinned});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      key: Key('tile_${post.id}'),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
          body: ReadableWidth(child: SingleChildScrollView(child: _PostCard(post: post))),
        ),
      )),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (post.photoUrl != null)
            Image.network(post.photoUrl!, fit: BoxFit.cover, semanticLabel: post.title,
                errorBuilder: (_, _, _) => ColoredBox(color: cs.surfaceContainerHighest, child: const Icon(Icons.broken_image_outlined)))
          else
            ColoredBox(
              color: cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Center(child: Text(post.title, maxLines: 4, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)),
              ),
            ),
          if (pinned) const Positioned(top: 4, left: 4, child: Icon(Icons.push_pin, size: 18, color: Colors.white, shadows: [Shadow(blurRadius: 4)])),
          if (post.photoUrls.length > 1)
            const Positioned(top: 4, right: 4, child: Icon(Icons.collections, size: 18, color: Colors.white, shadows: [Shadow(blurRadius: 4)])),
        ],
      ),
    );
  }
}

/// Swipeable photo gallery of a post with page dots. Square-ish, never taller than the screen allows.
class _PhotoGallery extends StatefulWidget {
  final List<String> urls;
  final String label;
  const _PhotoGallery({required this.urls, required this.label});

  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final many = widget.urls.length > 1;
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          PageView.builder(
            key: const Key('post_gallery'),
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Image.network(
              widget.urls[i],
              width: double.infinity,
              fit: BoxFit.cover,
              semanticLabel: widget.label,
              errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black12, child: Center(child: Icon(Icons.broken_image_outlined))),
            ),
          ),
          if (many)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.urls.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 8 : 6,
                      height: i == _page ? 8 : 6,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: i == _page ? Colors.white : Colors.white54),
                    ),
                ],
              ),
            ),
          if (many)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                child: Text('${_page + 1}/${widget.urls.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}
