/// A recipe post in the community feed (like an Instagram post).
class SocialPost {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String text;
  final String? photoUrl;
  final int createdAtMs;
  final int likeCount;
  final int commentCount;

  const SocialPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.text,
    this.photoUrl,
    required this.createdAtMs,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'title': title,
        'text': text,
        if (photoUrl != null) 'photoUrl': photoUrl,
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
        photoUrl: m['photoUrl'] as String?,
        createdAtMs: (m['createdAtMs'] ?? 0) as int,
        likeCount: (m['likeCount'] ?? 0) as int,
        commentCount: (m['commentCount'] ?? 0) as int,
      );

  SocialPost copyWith({int? likeCount, int? commentCount}) => SocialPost(
        id: id,
        authorId: authorId,
        authorName: authorName,
        title: title,
        text: text,
        photoUrl: photoUrl,
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
