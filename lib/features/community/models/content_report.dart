import 'package:objectbox/objectbox.dart';

/// Model ObjectBox Entity untuk laporan pelanggaran konten komunitas.
@Entity()
class ContentReport {
  @Id()
  int id;

  final String targetType; // 'post' | 'comment'
  final int targetId;
  final String reporterUid;
  final String reason;

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  ContentReport({
    this.id = 0,
    required this.targetType,
    required this.targetId,
    required this.reporterUid,
    required this.reason,
    required this.createdAt,
  });

  ContentReport copyWith({
    int? id,
    String? targetType,
    int? targetId,
    String? reporterUid,
    String? reason,
    DateTime? createdAt,
  }) {
    return ContentReport(
      id: id ?? this.id,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reporterUid: reporterUid ?? this.reporterUid,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toSyncData() {
    return {
      'id': id.toString(),
      'targetType': targetType,
      'targetId': targetId,
      'reporterUid': reporterUid,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
