/// Model untuk komentar pada postingan komunitas GERAKIN (Twitter/X style with nested replies).
class CommunityComment {
  final String id;
  final String postId;
  final String? parentId; // null jika komentar tingkat atas, atau ID komentar induk jika balasan
  final String? replyToAuthorName; // Nama pengguna yang dibalas, contoh: "Dr. Sarah"
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final bool isLikedByMe;

  const CommunityComment({
    required this.id,
    required this.postId,
    this.parentId,
    this.replyToAuthorName,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.isLikedByMe = false,
  });

  CommunityComment copyWith({
    String? id,
    String? postId,
    String? parentId,
    String? replyToAuthorName,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? text,
    DateTime? createdAt,
    int? likesCount,
    bool? isLikedByMe,
  }) {
    return CommunityComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      parentId: parentId ?? this.parentId,
      replyToAuthorName: replyToAuthorName ?? this.replyToAuthorName,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'postId': postId,
      'parentId': parentId,
      'replyToAuthorName': replyToAuthorName,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
    };
  }

  factory CommunityComment.fromFirestore(Map<String, dynamic> json, String docId) {
    return CommunityComment(
      id: docId,
      postId: json['postId'] ?? '',
      parentId: json['parentId'],
      replyToAuthorName: json['replyToAuthorName'],
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Pengguna GERAKIN',
      authorAvatarUrl: json['authorAvatarUrl'],
      text: json['text'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      likesCount: json['likesCount'] ?? 0,
    );
  }
}
