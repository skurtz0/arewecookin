import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social_post.dart';

/// One complaint filed from the community feed.
class ModerationReport {
  final String id;
  final String postId;

  /// Set when the complaint is about a comment, not the post itself.
  final String? commentId;
  final String reporterId;
  final String reason;
  final int createdAtMs;

  /// 'open', 'removed' or 'dismissed'. Old reports without a status are open.
  final String status;

  const ModerationReport({
    required this.id,
    required this.postId,
    this.commentId,
    required this.reporterId,
    required this.reason,
    required this.createdAtMs,
    this.status = 'open',
  });

  bool get isOpen => status == 'open';

  factory ModerationReport.fromMap(String id, Map<String, dynamic> m) => ModerationReport(
        id: id,
        postId: (m['postId'] ?? '') as String,
        commentId: m['commentId'] as String?,
        reporterId: (m['reporterId'] ?? '') as String,
        reason: (m['reason'] ?? '') as String,
        createdAtMs: (m['createdAtMs'] ?? 0) as int,
        status: (m['status'] ?? 'open') as String,
      );
}

/// Admin-only moderation. An admin is a signed-in user who has a document at
/// `admins/<uid>` (created by hand in the Firebase console). The rules enforce it.
abstract class ModerationService {
  Future<bool> isAdmin(String uid);
  Stream<List<ModerationReport>> watchReports();
  Future<SocialPost?> getPost(String postId);
  Future<SocialComment?> getComment(String postId, String commentId);
  Future<void> removePost(ModerationReport report);
  Future<void> dismissReport(ModerationReport report);
}

class FirestoreModerationService implements ModerationService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  Future<bool> isAdmin(String uid) async {
    try {
      return (await _db.collection('admins').doc(uid).get()).exists;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<List<ModerationReport>> watchReports() => _db
      .collection('reports')
      .orderBy('createdAtMs', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => [for (final d in s.docs) ModerationReport.fromMap(d.id, d.data())]);

  @override
  Future<SocialPost?> getPost(String postId) async {
    final d = await _db.collection('posts').doc(postId).get();
    final data = d.data();
    return data == null ? null : SocialPost.fromMap(d.id, data);
  }

  @override
  Future<SocialComment?> getComment(String postId, String commentId) async {
    final d = await _db.collection('posts').doc(postId).collection('comments').doc(commentId).get();
    final data = d.data();
    return data == null ? null : SocialComment.fromMap(d.id, data);
  }

  /// Removes the reported post, or only the reported comment when the report has a commentId.
  @override
  Future<void> removePost(ModerationReport report) async {
    final batch = _db.batch();
    final post = _db.collection('posts').doc(report.postId);
    batch.delete(report.commentId == null ? post : post.collection('comments').doc(report.commentId));
    batch.update(_db.collection('reports').doc(report.id), {'status': 'removed'});
    await batch.commit();
  }

  @override
  Future<void> dismissReport(ModerationReport report) =>
      _db.collection('reports').doc(report.id).update({'status': 'dismissed'});
}

/// Blocked authors kept on the account, so a block follows the user to every device.
/// Stored at `users/<uid>/blocked/<blockedUid>`; the rules let only the owner touch them.
abstract class BlockSyncService {
  Future<Set<String>> load(String uid);
  Future<void> set(String uid, String blockedUid, bool blocked);
}

class FirestoreBlockSyncService implements BlockSyncService {
  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('blocked');

  @override
  Future<Set<String>> load(String uid) async => {for (final d in (await _col(uid).get()).docs) d.id};

  @override
  Future<void> set(String uid, String blockedUid, bool blocked) => blocked
      ? _col(uid).doc(blockedUid).set({'createdAtMs': DateTime.now().millisecondsSinceEpoch})
      : _col(uid).doc(blockedUid).delete();
}
