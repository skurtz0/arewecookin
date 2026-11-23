import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/moderation_service.dart';
import 'auth_provider.dart';

class ModerationState {
  final Set<String> blockedAuthors;
  final Set<String> hiddenPosts;
  const ModerationState({this.blockedAuthors = const {}, this.hiddenPosts = const {}});
}

final blockSyncServiceProvider = Provider<BlockSyncService>((ref) => FirestoreBlockSyncService());

/// Authors the user blocked and posts the user reported, hidden on this device.
class ModerationNotifier extends Notifier<ModerationState> {
  static const _blockedKey = 'social_blocked_v1';
  static const _hiddenKey = 'social_hidden_v1';
  Future<void> _ready = Future.value();

  @override
  ModerationState build() {
    _ready = _load();
    // A signed-in user's blocks follow the account: merge them in when the user changes.
    ref.listen(authProvider, (prev, next) {
      if (next.user.isLoggedIn && next.user.id != prev?.user.id) _syncFromAccount(next.user.id);
    }, fireImmediately: true);
    return const ModerationState();
  }

  String? get _uid {
    final u = ref.read(authProvider).user;
    return u.isLoggedIn ? u.id : null;
  }

  /// Merges blocks saved on the account with this device's, and uploads the local-only ones.
  Future<void> _syncFromAccount(String uid) async {
    try {
      await _ready;
      final service = ref.read(blockSyncServiceProvider);
      final remote = await service.load(uid);
      final local = {...state.blockedAuthors};
      state = ModerationState(blockedAuthors: {...local, ...remote}, hiddenPosts: state.hiddenPosts);
      await _save();
      for (final id in local.difference(remote)) {
        await service.set(uid, id, true);
      }
    } catch (_) {}
  }

  Future<void> _push(String blockedUid, bool blocked) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await ref.read(blockSyncServiceProvider).set(uid, blockedUid, blocked);
    } catch (_) {}
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = ModerationState(
        blockedAuthors: {...state.blockedAuthors, ...?prefs.getStringList(_blockedKey)},
        hiddenPosts: {...state.hiddenPosts, ...?prefs.getStringList(_hiddenKey)},
      );
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      await _ready;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_blockedKey, state.blockedAuthors.toList());
      await prefs.setStringList(_hiddenKey, state.hiddenPosts.toList());
    } catch (_) {}
  }

  void blockAuthor(String uid) {
    state = ModerationState(blockedAuthors: {...state.blockedAuthors, uid}, hiddenPosts: state.hiddenPosts);
    _save();
    _push(uid, true);
  }

  void unblockAuthor(String uid) {
    state = ModerationState(blockedAuthors: {...state.blockedAuthors}..remove(uid), hiddenPosts: state.hiddenPosts);
    _save();
    _push(uid, false);
  }

  void hidePost(String postId) {
    state = ModerationState(blockedAuthors: state.blockedAuthors, hiddenPosts: {...state.hiddenPosts, postId});
    _save();
  }
}

final moderationProvider = NotifierProvider<ModerationNotifier, ModerationState>(ModerationNotifier.new);
