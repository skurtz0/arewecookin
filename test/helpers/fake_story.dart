import 'dart:async';
import 'package:arewecookin/models/story.dart';
import 'package:arewecookin/services/story_service.dart';

class FakeStoryService implements StoryService {
  final List<Story> stories;
  final Map<String, Map<String, StoryView>> views = {};
  final _c = StreamController<void>.broadcast();
  int _n = 0;
  FakeStoryService([List<Story>? seed]) : stories = [...?seed];

  @override
  Stream<List<Story>> watchActive() async* {
    yield List.of(stories);
    await for (final _ in _c.stream) {
      yield List.of(stories);
    }
  }

  @override
  Future<void> create(Story s) async {
    stories.add(Story(id: 'new${_n++}', authorId: s.authorId, authorName: s.authorName, photoUrl: s.photoUrl, createdAtMs: s.createdAtMs));
    _c.add(null);
  }

  @override
  Future<void> delete(String id) async {
    stories.removeWhere((s) => s.id == id);
    _c.add(null);
  }

  @override
  Future<void> markViewed({required String storyId, required String uid, required String name}) async {
    views.putIfAbsent(storyId, () => {})[uid] = StoryView(uid: uid, name: name, atMs: 1);
    _c.add(null);
  }

  @override
  Stream<List<StoryView>> watchViews(String storyId) async* {
    yield (views[storyId] ?? {}).values.toList();
    await for (final _ in _c.stream) {
      yield (views[storyId] ?? {}).values.toList();
    }
  }
}
