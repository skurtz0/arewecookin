import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_post.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../services/photo_uploader.dart';
import '../services/social_service.dart';
import 'auth_provider.dart';
import 'moderation_provider.dart';

final socialServiceProvider = Provider<SocialService>((ref) => FirestoreSocialService());

final photoUploaderProvider = Provider<PhotoUploader>((ref) => WorkerPhotoUploader());

/// Opens the photo library; returns (bytes, content type) or null. Replaced in tests.
final photoPickerProvider = Provider<Future<(Uint8List, String)?> Function()>((ref) {
  return () async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1280, imageQuality: 80);
    if (x == null) return null;
    final bytes = await x.readAsBytes();
    final name = x.name.toLowerCase();
    final type = name.endsWith('.png') ? 'image/png' : (name.endsWith('.webp') ? 'image/webp' : 'image/jpeg');
    return (bytes, type);
  };
});

final feedProvider = StreamProvider<List<SocialPost>>(
  (ref) => ref.watch(socialServiceProvider).watchFeed(),
  retry: (_, _) => null,
);

final commentsProvider = StreamProvider.family<List<SocialComment>, String>(
  (ref, postId) => ref.watch(socialServiceProvider).watchComments(postId),
  retry: (_, _) => null,
);

class SocialState {
  final Set<String> liked;
  const SocialState({this.liked = const {}});
}

/// Which posts the signed-in user has liked, plus actions that need a signed-in user.
class SocialNotifier extends Notifier<SocialState> {
  SocialService get _service => ref.read(socialServiceProvider);

  @override
  SocialState build() => const SocialState();

  String? get _uid {
    final u = ref.read(authProvider).user;
    return u.isLoggedIn ? u.id : null;
  }

  Future<void> loadLikes(Iterable<String> postIds) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final liked = await _service.likedPostIds(uid, postIds);
      state = SocialState(liked: {...state.liked, ...liked});
    } catch (_) {}
  }

  Future<void> toggleLike(String postId) async {
    final uid = _uid;
    if (uid == null) return;
    final now = !state.liked.contains(postId);
    state = SocialState(liked: now ? {...state.liked, postId} : ({...state.liked}..remove(postId)));
    try {
      await _service.setLike(postId: postId, uid: uid, liked: now);
    } catch (_) {
      state = SocialState(liked: now ? ({...state.liked}..remove(postId)) : {...state.liked, postId});
    }
  }

  Future<bool> publish({required String title, required String text, Uint8List? photo, String photoType = 'image/jpeg'}) async {
    final user = ref.read(authProvider).user;
    if (!user.isLoggedIn || title.trim().isEmpty) return false;
    try {
      String? photoUrl;
      if (photo != null) {
        photoUrl = await ref.read(photoUploaderProvider).upload(photo, photoType);
        if (photoUrl == null) return false;
      }
      await _service.createPost(SocialPost(
        id: '',
        authorId: user.id,
        authorName: user.displayName,
        title: title.trim(),
        text: text.trim(),
        photoUrl: photoUrl,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    final user = ref.read(authProvider).user;
    if (!user.isLoggedIn) return false;
    try {
      await _service.deletePost(postId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sends a report and hides the post on this device either way.
  Future<void> report(String postId, String reason) async {
    ref.read(moderationProvider.notifier).hidePost(postId);
    final user = ref.read(authProvider).user;
    if (!user.isLoggedIn) return;
    try {
      await _service.reportPost(postId: postId, reporterId: user.id, reason: reason);
    } catch (_) {}
  }

  /// Reports one comment and hides it on this device either way.
  Future<void> reportComment(String postId, String commentId, String reason) async {
    ref.read(moderationProvider.notifier).hidePost('comment:$commentId');
    final user = ref.read(authProvider).user;
    if (!user.isLoggedIn) return;
    try {
      await _service.reportPost(postId: postId, reporterId: user.id, reason: reason, commentId: commentId);
    } catch (_) {}
  }

  Future<bool> comment(String postId, String text) async {
    final user = ref.read(authProvider).user;
    if (!user.isLoggedIn || text.trim().isEmpty) return false;
    try {
      await _service.addComment(
        postId,
        SocialComment(
          id: '',
          authorId: user.id,
          authorName: user.displayName,
          text: text.trim(),
          createdAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final socialProvider = NotifierProvider<SocialNotifier, SocialState>(SocialNotifier.new);
