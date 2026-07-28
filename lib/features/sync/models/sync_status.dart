import 'package:objectbox/objectbox.dart';

@Entity()
class SyncStatus {
  @Id()
  int id;

  @Property(type: PropertyType.date)
  final DateTime lastSyncTime;

  final String status; // 'idle' | 'syncing' | 'error'

  SyncStatus({
    this.id = 0,
    required this.lastSyncTime,
    required this.status,
  });

  SyncStatus copyWith({
    int? id,
    DateTime? lastSyncTime,
    String? status,
  }) {
    return SyncStatus(
      id: id ?? this.id,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      status: status ?? this.status,
    );
  }
}
