import 'dart:async';
import 'package:arewecookin/models/profile_doc.dart';
import 'package:arewecookin/services/profile_service.dart';

class FakeProfileService implements ProfileService {
  final Map<String, ProfileDoc> profiles = {};
  final Set<String> follows = {}; // '<me>_<target>'
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<ProfileDoc?> watchProfile(String uid) async* {
    yield profiles[uid];
    await for (final _ in _changes.stream) {
      yield profiles[uid];
    }
  }

  @override
  Future<void> saveProfile(String uid, {String? displayName, String? bio, String? photoUrl, List<String>? pinned}) async {
    final c = profiles[uid];
    profiles[uid] = ProfileDoc(
      uid: uid,
      displayName: displayName ?? c?.displayName ?? '',
      bio: bio ?? c?.bio ?? '',
      photoUrl: photoUrl ?? c?.photoUrl,
      pinned: pinned ?? c?.pinned ?? const [],
    );
    _changes.add(null);
  }

  Set<String> _following(String uid) => {for (final f in follows) if (f.startsWith('${uid}_')) f.substring(uid.length + 1)};
  Set<String> _followers(String uid) => {for (final f in follows) if (f.endsWith('_$uid')) f.substring(0, f.length - uid.length - 1)};

  @override
  Stream<Set<String>> watchFollowing(String uid) async* {
    yield _following(uid);
    await for (final _ in _changes.stream) {
      yield _following(uid);
    }
  }

  @override
  Stream<Set<String>> watchFollowers(String uid) async* {
    yield _followers(uid);
    await for (final _ in _changes.stream) {
      yield _followers(uid);
    }
  }

  @override
  Future<void> setFollow({required String me, required String target, required bool follow}) async {
    follow ? follows.add('${me}_$target') : follows.remove('${me}_$target');
    _changes.add(null);
  }
}
