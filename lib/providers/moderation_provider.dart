import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModerationState {
  final Set<String> blockedAuthors;
  final Set<String> hiddenPosts;
  const ModerationState({this.blockedAuthors = const {}, this.hiddenPosts = const {}});
}

/// Authors the user blocked and posts the user reported, hidden on this device.
class ModerationNotifier extends Notifier<ModerationState> {
  static const _blockedKey = 'social_blocked_v1';
  static const _hiddenKey = 'social_hidden_v1';
  Future<void> _ready = Future.value();

  @override
  ModerationState build() {
    _ready = _load();
    return const ModerationState();
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
  }

  void unblockAuthor(String uid) {
    state = ModerationState(blockedAuthors: {...state.blockedAuthors}..remove(uid), hiddenPosts: state.hiddenPosts);
    _save();
  }

  void hidePost(String postId) {
    state = ModerationState(blockedAuthors: state.blockedAuthors, hiddenPosts: {...state.hiddenPosts, postId});
    _save();
  }
}

final moderationProvider = NotifierProvider<ModerationNotifier, ModerationState>(ModerationNotifier.new);
