import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_doc.dart';
import '../models/social_post.dart';
import '../services/profile_service.dart';
import 'auth_provider.dart';
import 'social_provider.dart';

final profileServiceProvider = Provider<ProfileService>((ref) => FirestoreProfileService());

final profileProvider = StreamProvider.family<ProfileDoc?, String>(
  (ref, uid) => ref.watch(profileServiceProvider).watchProfile(uid),
);

final followingProvider = StreamProvider.family<Set<String>, String>(
  (ref, uid) => ref.watch(profileServiceProvider).watchFollowing(uid),
);

final followersProvider = StreamProvider.family<Set<String>, String>(
  (ref, uid) => ref.watch(profileServiceProvider).watchFollowers(uid),
);

final authorPostsProvider = StreamProvider.family<List<SocialPost>, String>(
  (ref, uid) => ref.watch(socialServiceProvider).watchPostsBy(uid),
);

/// Posts of the people the signed-in user follows (newest first).
final followingFeedProvider = StreamProvider.autoDispose<List<SocialPost>>((ref) {
  final me = ref.watch(authProvider).user;
  if (!me.isLoggedIn) return Stream.value(const []);
  final ids = ref.watch(followingProvider(me.id)).asData?.value ?? const <String>{};
  return ref.watch(socialServiceProvider).watchFollowingFeed(ids);
});

/// false = everyone, true = only people I follow.
class FeedModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool following) => state = following;
}

final feedModeProvider = NotifierProvider<FeedModeNotifier, bool>(FeedModeNotifier.new);
