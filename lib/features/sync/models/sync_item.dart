import 'package:objectbox/objectbox.dart';

@Entity()
class SyncItem {
  @Id()
  int id;

  final String collection;
  final String documentId;
  final String operation; // 'create' | 'update' | 'delete'
  final String payloadJson;

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  int retryCount;
  String? lastError;

  SyncItem({
    this.id = 0,
    required this.collection,
    required this.documentId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  SyncItem copyWith({
    int? id,
    String? collection,
    String? documentId,
    String? operation,
    String? payloadJson,
    DateTime? createdAt,
    int? retryCount,
    String? lastError,
  }) {
    return SyncItem(
      id: id ?? this.id,
      collection: collection ?? this.collection,
      documentId: documentId ?? this.documentId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }
}
