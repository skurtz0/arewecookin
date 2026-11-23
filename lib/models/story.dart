/// A 24-hour photo story.
class Story {
  static const lifetimeMs = 24 * 60 * 60 * 1000;

  final String id;
  final String authorId;
  final String authorName;
  final String photoUrl;
  final int createdAtMs;

  const Story({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.photoUrl,
    required this.createdAtMs,
  });

  int get expiresAtMs => createdAtMs + lifetimeMs;
  bool isActive(int nowMs) => nowMs < expiresAtMs;

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'photoUrl': photoUrl,
        'createdAtMs': createdAtMs,
        'expiresAtMs': expiresAtMs,
      };

  factory Story.fromMap(String id, Map<String, dynamic> m) => Story(
        id: id,
        authorId: (m['authorId'] ?? '') as String,
        authorName: (m['authorName'] ?? '') as String,
        photoUrl: (m['photoUrl'] ?? '') as String,
        createdAtMs: (m['createdAtMs'] ?? 0) as int,
      );
}

/// Someone who watched a story (only the story's author can read these).
class StoryView {
  final String uid;
  final String name;
  final int atMs;
  const StoryView({required this.uid, required this.name, required this.atMs});
}
