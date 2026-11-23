import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/social_provider.dart';
import '../providers/story_provider.dart';
import 'profile_widgets.dart';

/// Row of story rings above the feed: "Your story" first, then the others.
class StoryStrip extends ConsumerWidget {
  const StoryStrip({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final tr = ref.read(appStringsProvider).isTurkish;
    final messenger = ScaffoldMessenger.of(context);
    final user = ref.read(authProvider).user;
    if (!user.isLoggedIn) {
      messenger.showSnackBar(SnackBar(content: Text(ref.read(appStringsProvider).socialSignInToShare)));
      return;
    }
    try {
      final x = await ref.read(photoPickerProvider)();
      if (x == null) return;
      final url = await ref.read(photoUploaderProvider).upload(x.$1, x.$2);
      if (url == null) throw Exception('upload');
      await ref.read(storyServiceProvider).create(Story(
            id: '',
            authorId: user.id,
            authorName: user.displayName,
            photoUrl: url,
            createdAtMs: DateTime.now().millisecondsSinceEpoch,
          ));
      messenger.showSnackBar(SnackBar(content: Text(tr ? 'Hikâyen paylaşıldı.' : 'Your story is up.')));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(tr ? 'Hikâye paylaşılamadı.' : 'Could not share the story.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(appStringsProvider).isTurkish;
    final me = ref.watch(authProvider).user;
    final groups = ref.watch(storyGroupsProvider);
    final seen = ref.watch(seenStoriesProvider);
    final mine = groups.where((g) => me.isLoggedIn && g.authorId == me.id).toList();
    final others = groups.where((g) => !(me.isLoggedIn && g.authorId == me.id)).toList();

    Widget ring({required Widget child, required bool unseen, required VoidCallback onTap, required String label, Key? key, Widget? badge}) {
      return InkWell(
        key: key,
        onTap: onTap,
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: unseen ? const LinearGradient(colors: [Color(0xFFFF5722), Color(0xFFFFC107)]) : null,
                      color: unseen ? null : Colors.grey.shade400,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).scaffoldBackgroundColor),
                      child: child,
                    ),
                  ),
                  if (badge != null) Positioned(right: -2, bottom: -2, child: badge),
                ],
              ),
              const SizedBox(height: 4),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final hasMineUnseen = mine.isNotEmpty && mine.first.stories.any((s) => !seen.contains(s.id));
    final plus = InkWell(
      key: const Key('story_add'),
      onTap: () => _add(context, ref),
      child: const CircleAvatar(radius: 11, backgroundColor: Color(0xFFFF5722), child: Icon(Icons.add, size: 16, color: Colors.white)),
    );
    final items = <Widget>[
      ring(
        key: const Key('story_mine'),
        unseen: hasMineUnseen,
        label: tr ? 'Hikâyen' : 'Your story',
        badge: plus,
        onTap: mine.isEmpty ? () => _add(context, ref) : () => _open(context, groups, 0),
        child: ProfileAvatar(uid: me.isLoggedIn ? me.id : '', name: me.displayName, radius: 28),
      ),
      for (final g in others)
        ring(
          key: Key('story_${g.authorId}'),
          unseen: g.stories.any((s) => !seen.contains(s.id)),
          label: g.authorName.isEmpty ? '—' : g.authorName,
          onTap: () => _open(context, groups, groups.indexOf(g)),
          child: ProfileAvatar(uid: g.authorId, name: g.authorName, radius: 28),
        ),
    ];
    // Avatar ring (66) + gap + one label line at the current text size + list padding.
    final labelH = MediaQuery.textScalerOf(context).scale(12) * 1.7;
    return SizedBox(
      height: 66 + 4 + labelH + 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (_, i) => items[i],
      ),
    );
  }

  void _open(BuildContext context, List<StoryGroup> groups, int index) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => StoryViewer(groups: groups, startGroup: index),
    ));
  }
}

/// Shows stories one after another: tap right/left to skip, auto-advances every 5 seconds.
class StoryViewer extends ConsumerStatefulWidget {
  final List<StoryGroup> groups;
  final int startGroup;
  const StoryViewer({super.key, required this.groups, required this.startGroup});

  @override
  ConsumerState<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends ConsumerState<StoryViewer> {
  static const _tick = Duration(milliseconds: 100);
  static const _perStoryMs = 5000;
  late int _g = widget.startGroup;
  int _i = 0;
  int _elapsed = 0;
  Timer? _timer;
  bool _paused = false;

  StoryGroup get _group => widget.groups[_g];
  Story get _story => _group.stories[_i];

  @override
  void initState() {
    super.initState();
    // Start at the first story the viewer has not seen yet.
    final seen = ref.read(seenStoriesProvider);
    final firstNew = _group.stories.indexWhere((s) => !seen.contains(s.id));
    _i = firstNew < 0 ? 0 : firstNew;
    _timer = Timer.periodic(_tick, (_) {
      if (_paused) return;
      _elapsed += _tick.inMilliseconds;
      if (_elapsed >= _perStoryMs) {
        _next();
      } else {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _seen());
  }

  void _seen() {
    if (!mounted) return;
    ref.read(seenStoriesProvider.notifier).markSeen(_story.id);
    final me = ref.read(authProvider).user;
    if (me.isLoggedIn && me.id != _story.authorId) {
      ref.read(storyServiceProvider).markViewed(storyId: _story.id, uid: me.id, name: me.displayName).catchError((_) {});
    }
  }

  void _go(int g, int i) {
    setState(() {
      _g = g;
      _i = i;
      _elapsed = 0;
    });
    _seen();
  }

  void _next() {
    if (_i + 1 < _group.stories.length) {
      _go(_g, _i + 1);
    } else if (_g + 1 < widget.groups.length) {
      _go(_g + 1, 0);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _prev() {
    if (_i > 0) {
      _go(_g, _i - 1);
    } else if (_g > 0) {
      _go(_g - 1, 0);
    } else {
      setState(() => _elapsed = 0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _showViews() async {
    setState(() => _paused = true);
    final tr = ref.read(appStringsProvider).isTurkish;
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => Consumer(builder: (context, ref, _) {
        final views = ref.watch(storyViewsProvider(_story.id)).asData?.value ?? const <StoryView>[];
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(title: Text(tr ? 'Görüntüleyenler (${views.length})' : 'Viewed by (${views.length})', style: const TextStyle(fontWeight: FontWeight.bold))),
              if (views.isEmpty) ListTile(title: Text(tr ? 'Henüz kimse görmedi.' : 'Nobody yet.')),
              for (final v in views) ListTile(dense: true, leading: ProfileAvatar(uid: v.uid, name: v.name, radius: 16), title: Text(v.name.isEmpty ? '—' : v.name)),
            ],
          ),
        );
      }),
    );
    if (mounted) setState(() => _paused = false);
  }

  Future<void> _delete() async {
    final tr = ref.read(appStringsProvider).isTurkish;
    setState(() => _paused = true);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(tr ? 'Bu hikâye silinsin mi?' : 'Delete this story?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr ? 'Vazgeç' : 'Cancel')),
          TextButton(key: const Key('story_confirm_delete'), onPressed: () => Navigator.pop(ctx, true), child: Text(tr ? 'Sil' : 'Delete')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(storyServiceProvider).delete(_story.id);
      } catch (_) {}
      if (mounted) Navigator.of(context).maybePop();
    } else if (mounted) {
      setState(() => _paused = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(appStringsProvider).isTurkish;
    final me = ref.watch(authProvider).user;
    final mine = me.isLoggedIn && me.id == _story.authorId;
    final story = _story;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    story.photoUrl,
                    key: ValueKey(story.id),
                    fit: BoxFit.contain,
                    semanticLabel: story.authorName,
                    errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48)),
                  ),
                ),
                Positioned.fill(
                  child: Row(children: [
                    Expanded(child: GestureDetector(key: const Key('story_prev'), behavior: HitTestBehavior.translucent, onTap: _prev, onLongPressStart: (_) => setState(() => _paused = true), onLongPressEnd: (_) => setState(() => _paused = false))),
                    Expanded(child: GestureDetector(key: const Key('story_next'), behavior: HitTestBehavior.translucent, onTap: _next, onLongPressStart: (_) => setState(() => _paused = true), onLongPressEnd: (_) => setState(() => _paused = false))),
                  ]),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Column(
                    children: [
                      Row(children: [
                        for (var k = 0; k < _group.stories.length; k++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: LinearProgressIndicator(
                                minHeight: 3,
                                value: k < _i ? 1 : (k == _i ? _elapsed / _perStoryMs : 0),
                                backgroundColor: Colors.white24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        ProfileAvatar(uid: story.authorId, name: story.authorName, radius: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(story.authorName.isEmpty ? '—' : story.authorName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        IconButton(key: const Key('story_close'), tooltip: tr ? 'Kapat' : 'Close', icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).maybePop()),
                      ]),
                    ],
                  ),
                ),
                if (mine)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(children: [
                      TextButton.icon(
                        key: const Key('story_views'),
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        onPressed: _showViews,
                        icon: const Icon(Icons.visibility_outlined),
                        label: Text(tr ? 'Görüntüleyenler' : 'Viewers'),
                      ),
                      const Spacer(),
                      IconButton(key: const Key('story_delete'), tooltip: tr ? 'Sil' : 'Delete', icon: const Icon(Icons.delete_outline, color: Colors.white), onPressed: _delete),
                    ]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
