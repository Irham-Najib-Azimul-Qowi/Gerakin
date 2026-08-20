import 'package:objectbox/objectbox.dart';

/// Model ObjectBox Entity untuk postingan komunitas GERAKIN.
@Entity()
class CommunityPost {
  @Id()
  int id;

  final String authorUid;
  final String authorDisplayName;
  final String content;
  final String? imagePath;
  final int likeCount;
  final int commentCount;
  final bool isReported;

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  final String syncStatus; // 'local_only' | 'pending_sync' | 'synced'

  final String? hashtags;

  CommunityPost({
    this.id = 0,
    required this.authorUid,
    required this.authorDisplayName,
    required this.content,
    this.imagePath,
    this.hashtags,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isReported = false,
    required this.createdAt,
    required this.syncStatus,
  });

  CommunityPost copyWith({
    int? id,
    String? authorUid,
    String? authorDisplayName,
    String? content,
    String? imagePath,
    String? hashtags,
    int? likeCount,
    int? commentCount,
    bool? isReported,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorUid: authorUid ?? this.authorUid,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      hashtags: hashtags ?? this.hashtags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isReported: isReported ?? this.isReported,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toSyncData() {
    return {
      'id': id.toString(),
      'authorUid': authorUid,
      'authorDisplayName': authorDisplayName,
      'content': content,
      'imagePath': imagePath,
      'hashtags': hashtags,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isReported': isReported,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  factory CommunityPost.fromSyncData(Map<String, dynamic> data, {int? localId}) {
    return CommunityPost(
      id: localId ?? (int.tryParse(data['id']?.toString() ?? '0') ?? 0),
      authorUid: data['authorUid'] ?? '',
      authorDisplayName: data['authorDisplayName'] ?? 'Pengguna GERAKIN',
      content: data['content'] ?? '',
      imagePath: data['imagePath'],
      hashtags: data['hashtags'],
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      isReported: data['isReported'] ?? false,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      syncStatus: data['syncStatus'] ?? 'synced',
    );
  }
}
