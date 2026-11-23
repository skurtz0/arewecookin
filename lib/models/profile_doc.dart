/// A user's public community profile (`profiles/<uid>`): name, bio, photo, pinned posts.
class ProfileDoc {
  static const maxPinned = 3;
  static const maxBio = 150;
  static const maxName = 40;

  final String uid;
  final String displayName;
  final String bio;
  final String? photoUrl;

  /// Ids of up to [maxPinned] posts shown first on the profile.
  final List<String> pinned;

  const ProfileDoc({
    required this.uid,
    this.displayName = '',
    this.bio = '',
    this.photoUrl,
    this.pinned = const [],
  });

  factory ProfileDoc.fromMap(String uid, Map<String, dynamic> m) => ProfileDoc(
        uid: uid,
        displayName: (m['displayName'] ?? '') as String,
        bio: (m['bio'] ?? '') as String,
        photoUrl: m['photoUrl'] as String?,
        pinned: [for (final p in (m['pinned'] as List? ?? const [])) if (p is String) p],
      );
}
