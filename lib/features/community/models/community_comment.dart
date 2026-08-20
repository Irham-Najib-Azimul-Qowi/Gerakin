import 'package:objectbox/objectbox.dart';

/// Model ObjectBox Entity untuk komentar postingan komunitas GERAKIN.
@Entity()
class CommunityComment {
  @Id()
  int id;

  final int postId;
  final String authorUid;
  final String authorDisplayName;
  final String content;

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  final String syncStatus; // 'local_only' | 'pending_sync' | 'synced'

  CommunityComment({
    this.id = 0,
    required this.postId,
    required this.authorUid,
    required this.authorDisplayName,
    required this.content,
    required this.createdAt,
    required this.syncStatus,
  });

  CommunityComment copyWith({
    int? id,
    int? postId,
    String? authorUid,
    String? authorDisplayName,
    String? content,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return CommunityComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorUid: authorUid ?? this.authorUid,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toSyncData() {
    return {
      'id': id.toString(),
      'postId': postId,
      'authorUid': authorUid,
      'authorDisplayName': authorDisplayName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  factory CommunityComment.fromSyncData(Map<String, dynamic> data, {int? localId}) {
    return CommunityComment(
      id: localId ?? (int.tryParse(data['id']?.toString() ?? '0') ?? 0),
      postId: data['postId'] ?? 0,
      authorUid: data['authorUid'] ?? '',
      authorDisplayName: data['authorDisplayName'] ?? 'Pengguna GERAKIN',
      content: data['content'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      syncStatus: data['syncStatus'] ?? 'synced',
    );
  }
}
