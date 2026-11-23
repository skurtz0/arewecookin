/// A recipe post in the community feed (like an Instagram post).
class SocialPost {
  static const maxPhotos = 10;

  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String text;
  /// Up to [maxPhotos] photos, shown as a swipeable gallery. The first one is also
  /// written as `photoUrl` so older app versions still show a picture.
  final List<String> photoUrls;
  final int createdAtMs;
  final int likeCount;
  final int commentCount;

  const SocialPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.text,
    this.photoUrls = const [],
    required this.createdAtMs,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  String? get photoUrl => photoUrls.isEmpty ? null : photoUrls.first;

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'title': title,
        'text': text,
        if (photoUrls.isNotEmpty) 'photoUrl': photoUrls.first,
        if (photoUrls.length > 1) 'photoUrls': photoUrls,
        'createdAtMs': createdAtMs,
        'likeCount': likeCount,
        'commentCount': commentCount,
      };

  factory SocialPost.fromMap(String id, Map<String, dynamic> m) => SocialPost(
        id: id,
        authorId: (m['authorId'] ?? '') as String,
        authorName: (m['authorName'] ?? '') as String,
        title: (m['title'] ?? '') as String,
        text: (m['text'] ?? '') as String,
        photoUrls: _photos(m),
        createdAtMs: (m['createdAtMs'] ?? 0) as int,
        likeCount: (m['likeCount'] ?? 0) as int,
        commentCount: (m['commentCount'] ?? 0) as int,
      );

  static List<String> _photos(Map<String, dynamic> m) {
    final list = m['photoUrls'];
    if (list is List && list.isNotEmpty) return [for (final u in list) if (u is String) u];
    final one = m['photoUrl'];
    return one is String ? [one] : const [];
  }

  SocialPost copyWith({int? likeCount, int? commentCount}) => SocialPost(
        id: id,
        authorId: authorId,
        authorName: authorName,
        title: title,
        text: text,
        photoUrls: photoUrls,
        createdAtMs: createdAtMs,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount ?? this.commentCount,
      );
}

class SocialComment {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final int createdAtMs;

  const SocialComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAtMs,
  });

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'text': text,
        'createdAtMs': createdAtMs,
      };

  factory SocialComment.fromMap(String id, Map<String, dynamic> m) => SocialComment(
        id: id,
        authorId: (m['authorId'] ?? '') as String,
        authorName: (m['authorName'] ?? '') as String,
        text: (m['text'] ?? '') as String,
        createdAtMs: (m['createdAtMs'] ?? 0) as int,
      );
}
