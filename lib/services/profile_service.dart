import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_doc.dart';

/// Profiles and the follow graph. The app uses [FirestoreProfileService]; tests use a fake.
abstract class ProfileService {
  Stream<ProfileDoc?> watchProfile(String uid);

  /// Writes only the given fields (merge).
  Future<void> saveProfile(String uid, {String? displayName, String? bio, String? photoUrl, List<String>? pinned});

  /// Who [uid] follows.
  Stream<Set<String>> watchFollowing(String uid);

  /// Who follows [uid].
  Stream<Set<String>> watchFollowers(String uid);

  Future<void> setFollow({required String me, required String target, required bool follow});
}

class FirestoreProfileService implements ProfileService {
  FirebaseFirestore? get _dbOrNull {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<ProfileDoc?> watchProfile(String uid) {
    final db = _dbOrNull;
    if (db == null) return Stream.value(null);
    return db.collection('profiles').doc(uid).snapshots().map((d) => d.data() == null ? null : ProfileDoc.fromMap(uid, d.data()!));
  }

  @override
  Future<void> saveProfile(String uid, {String? displayName, String? bio, String? photoUrl, List<String>? pinned}) {
    return FirebaseFirestore.instance.collection('profiles').doc(uid).set({
      'displayName': ?displayName,
      'bio': ?bio,
      'photoUrl': ?photoUrl,
      'pinned': ?pinned,
    }, SetOptions(merge: true));
  }

  Stream<Set<String>> _ids(String field, String value, String idField) {
    final db = _dbOrNull;
    if (db == null) return Stream.value(const {});
    return db
        .collection('follows')
        .where(field, isEqualTo: value)
        .limit(1000)
        .snapshots()
        .map((s) => {for (final d in s.docs) d.data()[idField] as String});
  }

  @override
  Stream<Set<String>> watchFollowing(String uid) => _ids('followerId', uid, 'followeeId');

  @override
  Stream<Set<String>> watchFollowers(String uid) => _ids('followeeId', uid, 'followerId');

  @override
  Future<void> setFollow({required String me, required String target, required bool follow}) {
    final ref = FirebaseFirestore.instance.collection('follows').doc('${me}_$target');
    return follow
        ? ref.set({'followerId': me, 'followeeId': target, 'createdAtMs': DateTime.now().millisecondsSinceEpoch})
        : ref.delete();
  }
}
