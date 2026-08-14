enum CommunityMediaType { image, video }

/// Model untuk postingan komunitas GERAKIN (Instagram-style).
class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String? authorBadge; // e.g. "Pejuang Sehat", "Fisioterapis", "Top Geraker"
  final String caption;
  final List<String> mediaUrls;
  final CommunityMediaType mediaType;
  final String? workoutTag; // e.g. "Stretching Bahu 15 Mnt"
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLikedByMe;
  final DateTime createdAt;
  final List<String> tags;

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    this.authorBadge,
    required this.caption,
    required this.mediaUrls,
    this.mediaType = CommunityMediaType.image,
    this.workoutTag,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLikedByMe = false,
    required this.createdAt,
    this.tags = const [],
  });

  CommunityPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? authorBadge,
    String? caption,
    List<String>? mediaUrls,
    CommunityMediaType? mediaType,
    String? workoutTag,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLikedByMe,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      authorBadge: authorBadge ?? this.authorBadge,
      caption: caption ?? this.caption,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      workoutTag: workoutTag ?? this.workoutTag,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'authorBadge': authorBadge,
      'caption': caption,
      'mediaUrls': mediaUrls,
      'mediaType': mediaType.name,
      'workoutTag': workoutTag,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }

  factory CommunityPost.fromFirestore(Map<String, dynamic> json, String docId, {String? currentUserId}) {
    final likesList = List<String>.from(json['likedBy'] ?? []);
    final isLiked = currentUserId != null ? likesList.contains(currentUserId) : false;

    return CommunityPost(
      id: docId,
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Pengguna GERAKIN',
      authorAvatarUrl: json['authorAvatarUrl'],
      authorBadge: json['authorBadge'],
      caption: json['caption'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      mediaType: (json['mediaType'] == 'video') ? CommunityMediaType.video : CommunityMediaType.image,
      workoutTag: json['workoutTag'],
      likesCount: json['likesCount'] ?? likesList.length,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      isLikedByMe: isLiked,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
