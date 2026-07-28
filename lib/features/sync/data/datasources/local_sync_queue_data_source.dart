import '../../../../objectbox.g.dart';
import '../../models/sync_item.dart';
import '../../models/sync_status.dart';

/// Antarmuka sumber data lokal untuk Sync Queue.
abstract class LocalSyncQueueDataSource {
  Future<int> enqueue(SyncItem item);
  Future<List<SyncItem>> getPendingItems();
  Future<void> updateItem(SyncItem item);
  Future<void> deleteItem(int id);
  Future<void> saveSyncStatus(SyncStatus status);
  Future<SyncStatus?> getSyncStatus();
}

/// Implementasi [LocalSyncQueueDataSource] menggunakan ObjectBox.
class LocalSyncQueueDataSourceImpl implements LocalSyncQueueDataSource {
  final Box<SyncItem> _itemBox;
  final Box<SyncStatus> _statusBox;

  LocalSyncQueueDataSourceImpl(Store store)
      : _itemBox = store.box<SyncItem>(),
        _statusBox = store.box<SyncStatus>();

  @override
  Future<int> enqueue(SyncItem item) async {
    return _itemBox.put(item);
  }

  @override
  Future<List<SyncItem>> getPendingItems() async {
    // Return items sorted by id (FIFO order)
    final query = (_itemBox.query()..order(SyncItem_.id)).build();
    final result = query.find();
    query.close();
    return result;
  }

  @override
  Future<void> updateItem(SyncItem item) async {
    _itemBox.put(item);
  }

  @override
  Future<void> deleteItem(int id) async {
    _itemBox.remove(id);
  }

  @override
  Future<void> saveSyncStatus(SyncStatus status) async {
    // Keep only a single status entry
    _statusBox.removeAll();
    _statusBox.put(status);
  }

  @override
  Future<SyncStatus?> getSyncStatus() async {
    final list = _statusBox.getAll();
    return list.isEmpty ? null : list.first;
  }
}
