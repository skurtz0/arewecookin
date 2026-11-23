import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social_post.dart';

/// Storage for the community feed. The app uses [FirestoreSocialService];
/// tests use an in-memory fake.
abstract class SocialService {
  Stream<List<SocialPost>> watchFeed();
  Future<void> createPost(SocialPost post);
  Future<Set<String>> likedPostIds(String uid, Iterable<String> postIds);
  Future<void> setLike({required String postId, required String uid, required bool liked});
  Stream<List<SocialComment>> watchComments(String postId);
  Future<void> addComment(String postId, SocialComment comment);
  Future<void> deletePost(String postId);
  Future<void> reportPost({required String postId, required String reporterId, required String reason, String? commentId});
}

class FirestoreSocialService implements SocialService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _posts => _db.collection('posts');

  @override
  Stream<List<SocialPost>> watchFeed() {
    try {
      return _posts
          .orderBy('createdAtMs', descending: true)
          .limit(50)
          .snapshots()
          .map((s) => [for (final d in s.docs) SocialPost.fromMap(d.id, d.data())]);
    } catch (e) {
      return Stream.error(e);
    }
  }

  @override
  Future<void> createPost(SocialPost post) async {
    await _posts.add(post.toMap());
  }

  @override
  Future<Set<String>> likedPostIds(String uid, Iterable<String> postIds) async {
    final liked = <String>{};
    for (final id in postIds) {
      final doc = await _posts.doc(id).collection('likes').doc(uid).get();
      if (doc.exists) liked.add(id);
    }
    return liked;
  }

  @override
  Future<void> setLike({required String postId, required String uid, required bool liked}) async {
    final post = _posts.doc(postId);
    final like = post.collection('likes').doc(uid);
    await _db.runTransaction((tx) async {
      final exists = (await tx.get(like)).exists;
      if (liked == exists) return;
      if (liked) {
        tx.set(like, {'createdAtMs': DateTime.now().millisecondsSinceEpoch});
      } else {
        tx.delete(like);
      }
      tx.update(post, {'likeCount': FieldValue.increment(liked ? 1 : -1)});
    });
  }

  @override
  Stream<List<SocialComment>> watchComments(String postId) {
    try {
      return _posts
          .doc(postId)
          .collection('comments')
          .orderBy('createdAtMs')
          .limit(100)
          .snapshots()
          .map((s) => [for (final d in s.docs) SocialComment.fromMap(d.id, d.data())]);
    } catch (e) {
      return Stream.error(e);
    }
  }

  @override
  Future<void> addComment(String postId, SocialComment comment) async {
    final post = _posts.doc(postId);
    final ref = post.collection('comments').doc();
    final batch = _db.batch();
    batch.set(ref, comment.toMap());
    batch.update(post, {'commentCount': FieldValue.increment(1)});
    await batch.commit();
  }

  @override
  Future<void> deletePost(String postId) async {
    await _posts.doc(postId).delete();
  }

  @override
  Future<void> reportPost({required String postId, required String reporterId, required String reason, String? commentId}) async {
    await _db.collection('reports').add({
      'commentId': ?commentId,
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
