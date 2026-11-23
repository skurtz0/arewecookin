import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story.dart';

abstract class StoryService {
  /// Stories of the last 24 hours, oldest first.
  Stream<List<Story>> watchActive();
  Future<void> create(Story story);
  Future<void> delete(String storyId);
  Future<void> markViewed({required String storyId, required String uid, required String name});
  Stream<List<StoryView>> watchViews(String storyId);
}

class FirestoreStoryService implements StoryService {
  FirebaseFirestore? get _dbOrNull {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<Story>> watchActive() {
    final db = _dbOrNull;
    if (db == null) return Stream.value(const []);
    final since = DateTime.now().millisecondsSinceEpoch - Story.lifetimeMs;
    return db
        .collection('stories')
        .where('createdAtMs', isGreaterThan: since)
        .orderBy('createdAtMs')
        .limit(300)
        .snapshots()
        .map((s) => [for (final d in s.docs) Story.fromMap(d.id, d.data())]);
  }

  @override
  Future<void> create(Story story) => FirebaseFirestore.instance.collection('stories').add(story.toMap());

  @override
  Future<void> delete(String storyId) => FirebaseFirestore.instance.collection('stories').doc(storyId).delete();

  @override
  Future<void> markViewed({required String storyId, required String uid, required String name}) {
    return FirebaseFirestore.instance
        .collection('stories')
        .doc(storyId)
        .collection('views')
        .doc(uid)
        .set({'name': name, 'atMs': DateTime.now().millisecondsSinceEpoch});
  }

  @override
  Stream<List<StoryView>> watchViews(String storyId) {
    final db = _dbOrNull;
    if (db == null) return Stream.value(const []);
    return db
        .collection('stories')
        .doc(storyId)
        .collection('views')
        .snapshots()
        .map((s) => [for (final d in s.docs) StoryView(uid: d.id, name: (d.data()['name'] ?? '') as String, atMs: (d.data()['atMs'] ?? 0) as int)]);
  }
}
