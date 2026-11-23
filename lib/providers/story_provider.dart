import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';
import '../services/story_service.dart';
import 'auth_provider.dart';
import 'moderation_provider.dart';
import 'profile_provider.dart';

final storyServiceProvider = Provider<StoryService>((ref) => FirestoreStoryService());

final storiesProvider = StreamProvider<List<Story>>(
  (ref) => ref.watch(storyServiceProvider).watchActive(),
  retry: (_, _) => null,
);

final storyViewsProvider = StreamProvider.autoDispose.family<List<StoryView>, String>(
  (ref, id) => ref.watch(storyServiceProvider).watchViews(id),
);

/// One person's active stories (oldest first), shown as a ring in the strip.
class StoryGroup {
  final String authorId;
  final String authorName;
  final List<Story> stories;
  const StoryGroup(this.authorId, this.authorName, this.stories);
  int get newestMs => stories.last.createdAtMs;
}

/// Story rings in strip order: my own first, then people I follow, then the rest; newest first inside
/// each part. Blocked authors are left out. [nowMs] drops stories that just expired.
List<StoryGroup> groupStories(List<Story> all, {required String? me, required Set<String> following, required Set<String> blocked, required int nowMs}) {
  final by = <String, List<Story>>{};
  for (final s in all) {
    if (!s.isActive(nowMs) || blocked.contains(s.authorId)) continue;
    by.putIfAbsent(s.authorId, () => []).add(s);
  }
  final groups = [
    for (final e in by.entries)
      StoryGroup(e.key, e.value.last.authorName, [...e.value]..sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs)))
  ];
  int rank(StoryGroup g) => g.authorId == me ? 0 : (following.contains(g.authorId) ? 1 : 2);
  groups.sort((a, b) {
    final r = rank(a).compareTo(rank(b));
    return r != 0 ? r : b.newestMs.compareTo(a.newestMs);
  });
  return groups;
}

final storyGroupsProvider = Provider<List<StoryGroup>>((ref) {
  final all = ref.watch(storiesProvider).asData?.value ?? const <Story>[];
  final me = ref.watch(authProvider).user;
  final following = me.isLoggedIn ? (ref.watch(followingProvider(me.id)).asData?.value ?? const <String>{}) : const <String>{};
  final blocked = ref.watch(moderationProvider).blockedAuthors;
  return groupStories(all, me: me.isLoggedIn ? me.id : null, following: following, blocked: blocked, nowMs: DateTime.now().millisecondsSinceEpoch);
});

/// Ids of stories this device has already watched (so the ring turns grey).
class SeenStoriesNotifier extends Notifier<Set<String>> {
  static const _key = 'story_seen_v1';
  Future<void> _ready = Future.value();

  @override
  Set<String> build() {
    _ready = _load();
    return const {};
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = {...state, ...?prefs.getStringList(_key)};
    } catch (_) {}
  }

  Future<void> markSeen(String id) async {
    if (state.contains(id)) return;
    state = {...state, id};
    try {
      await _ready;
      final prefs = await SharedPreferences.getInstance();
      // Keep the list from growing forever: only the newest 300 ids.
      final list = state.toList();
      await prefs.setStringList(_key, list.length > 300 ? list.sublist(list.length - 300) : list);
    } catch (_) {}
  }
}

final seenStoriesProvider = NotifierProvider<SeenStoriesNotifier, Set<String>>(SeenStoriesNotifier.new);
