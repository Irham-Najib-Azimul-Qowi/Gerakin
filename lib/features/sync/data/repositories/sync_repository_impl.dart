import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/objectbox_store.dart';
import '../datasources/local_sync_queue_data_source.dart';
import '../datasources/remote_firestore_data_source.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../models/sync_item.dart';
import '../../models/sync_status.dart';
import '../../models/sync_result.dart';

/// Implementasi [SyncRepository] untuk sinkronisasi data offline-first dengan Firestore.
class SyncRepositoryImpl implements SyncRepository {
  final LocalSyncQueueDataSource _localQueue;
  final RemoteFirestoreDataSource _remoteFirestore;

  SyncRepositoryImpl(this._localQueue, this._remoteFirestore);

  @override
  Future<void> queueChange({
    required String collection,
    required String documentId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final item = SyncItem(
      collection: collection,
      documentId: documentId,
      operation: operation,
      payloadJson: jsonEncode(data),
      createdAt: DateTime.now(),
    );
    await _localQueue.enqueue(item);
  }

  @override
  Future<List<SyncItem>> getPendingItems() async {
    return _localQueue.getPendingItems();
  }

  @override
  Future<void> updateItem(SyncItem item) async {
    await _localQueue.updateItem(item);
  }

  @override
  Future<void> deleteItem(int id) async {
    await _localQueue.deleteItem(id);
  }

  @override
  Future<SyncResult> syncItemToRemote(SyncItem item) async {
    try {
      final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;

      if (item.operation == 'delete') {
        await _remoteFirestore.deleteDocument(item.collection, item.documentId);
        return SyncResult(isSuccess: true);
      }

      // Check conflict dengan data jarak jauh
      final remoteDoc = await _remoteFirestore.getDocument(item.collection, item.documentId);
      if (remoteDoc != null) {
        // Last Write Wins
        final localTimeStr = payload['updatedAt'] ?? payload['createdAt'];
        final remoteTimeStr = remoteDoc['updatedAt'] ?? remoteDoc['createdAt'];

        if (localTimeStr != null && remoteTimeStr != null) {
          final localTime = DateTime.parse(localTimeStr);
          final remoteTime = DateTime.parse(remoteTimeStr);

          if (localTime.isBefore(remoteTime)) {
            // Konflik terdeteksi: data remote lebih baru.
            // Selesai dengan hasConflict: true (local wins = false).
            return SyncResult(isSuccess: true, hasConflict: true);
          }
        }
      }

      // Data lokal menang atau tidak ada konflik: Tulis ke cloud
      if (item.operation == 'create') {
        await _remoteFirestore.createDocument(item.collection, item.documentId, payload);
      } else {
        await _remoteFirestore.updateDocument(item.collection, item.documentId, payload);
      }

      return SyncResult(isSuccess: true);
    } catch (e) {
      return SyncResult(isSuccess: false, errorMessage: e.toString());
    }
  }

  @override
  Future<void> saveSyncStatus(SyncStatus status) async {
    await _localQueue.saveSyncStatus(status);
  }

  @override
  Future<SyncStatus> getSyncStatus() async {
    final status = await _localQueue.getSyncStatus();
    if (status != null) return status;
    return SyncStatus(
      lastSyncTime: DateTime.fromMillisecondsSinceEpoch(0),
      status: 'idle',
    );
  }
}

/// Provider untuk instansiasi [LocalSyncQueueDataSource].
final localSyncQueueDataSourceProvider = Provider<LocalSyncQueueDataSource>((ref) {
  final store = ref.watch(objectBoxStoreProvider);
  return LocalSyncQueueDataSourceImpl(store);
});

/// Provider untuk instansiasi [RemoteFirestoreDataSource].
final remoteFirestoreDataSourceProvider = Provider<RemoteFirestoreDataSource>((ref) {
  return RemoteFirestoreDataSourceImpl();
});

/// Provider untuk instansiasi [SyncRepository].
final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final localQ = ref.watch(localSyncQueueDataSourceProvider);
  final remoteFS = ref.watch(remoteFirestoreDataSourceProvider);
  return SyncRepositoryImpl(localQ, remoteFS);
});
