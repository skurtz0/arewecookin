import 'dart:async';
import 'package:arewecookin/models/social_post.dart';
import 'package:arewecookin/models/user_profile.dart';
import 'package:arewecookin/services/auth_service.dart';
import 'package:arewecookin/services/social_service.dart';

class FakeSocialService implements SocialService {
  final List<SocialPost> posts;
  final Map<String, Set<String>> likes = {};
  final Map<String, List<SocialComment>> comments = {};
  final List<String> reports = [];
  final _feed = StreamController<List<SocialPost>>.broadcast();
  int _n = 0;

  FakeSocialService([List<SocialPost>? seed]) : posts = [...?seed];

  void _emit() => _feed.add(List.of(posts));

  @override
  Stream<List<SocialPost>> watchFeed() async* {
    yield List.of(posts);
    yield* _feed.stream;
  }

  @override
  Future<void> createPost(SocialPost post) async {
    posts.insert(0, SocialPost.fromMap('p${_n++}', post.toMap()));
    _emit();
  }

  @override
  Future<Set<String>> likedPostIds(String uid, Iterable<String> postIds) async =>
      {for (final id in postIds) if (likes[id]?.contains(uid) ?? false) id};

  @override
  Future<void> setLike({required String postId, required String uid, required bool liked}) async {
    final set = likes.putIfAbsent(postId, () => {});
    final changed = liked ? set.add(uid) : set.remove(uid);
    if (!changed) return;
    final i = posts.indexWhere((p) => p.id == postId);
    posts[i] = posts[i].copyWith(likeCount: posts[i].likeCount + (liked ? 1 : -1));
    _emit();
  }

  @override
  Stream<List<SocialComment>> watchComments(String postId) async* {
    yield List.of(comments[postId] ?? []);
  }

  @override
  Future<void> addComment(String postId, SocialComment comment) async {
    comments.putIfAbsent(postId, () => []).add(comment);
    final i = posts.indexWhere((p) => p.id == postId);
    posts[i] = posts[i].copyWith(commentCount: posts[i].commentCount + 1);
    _emit();
  }

  @override
  Future<void> reportPost({required String postId, required String reporterId, required String reason, String? commentId}) async {
    reports.add('$postId:$reporterId:$reason${commentId == null ? '' : ':$commentId'}');
  }

  @override
  Future<void> deletePost(String postId) async {
    posts.removeWhere((p) => p.id == postId);
    _emit();
  }
}

class FakeAuthService extends AuthService {
  final UserProfile user;
  FakeAuthService(this.user);
  @override
  UserProfile get currentUser => user;
}

const signedInUser = UserProfile(
  id: 'u1',
  email: 'a@b.c',
  displayName: 'Ayşe',
  authProvider: 'password',
  isLoggedIn: true,
);
