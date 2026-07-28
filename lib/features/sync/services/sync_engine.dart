import 'dart:async';
import '../domain/repositories/sync_repository.dart';
import '../models/sync_status.dart';
import 'connectivity_monitor.dart';
import 'retry_manager.dart';

/// Engine utama untuk mengelola proses sinkronisasi antrean data secara berkala.
class SyncEngine {
  final SyncRepository _repository;
  final ConnectivityMonitor _connectivityMonitor;
  final RetryManager _retryManager = RetryManager();
  bool _isSyncing = false;

  SyncEngine(this._repository, this._connectivityMonitor);

  bool get isSyncing => _isSyncing;

  /// Memulai sinkronisasi seluruh antrean secara asinkron.
  Future<void> processQueue() async {
    if (_isSyncing) return;

    final connected = await _connectivityMonitor.isConnected;
    if (!connected) return;

    _isSyncing = true;
    await _repository.saveSyncStatus(SyncStatus(
      lastSyncTime: DateTime.now(),
      status: 'syncing',
    ));

    try {
      final pendingItems = await _repository.getPendingItems();
      for (final item in pendingItems) {
        final stillConnected = await _connectivityMonitor.isConnected;
        if (!stillConnected) break;

        final result = await _repository.syncItemToRemote(item);
        if (result.isSuccess) {
          await _repository.deleteItem(item.id);
        } else {
          item.retryCount++;
          item.lastError = result.errorMessage;

          if (_retryManager.shouldRetry(item.retryCount)) {
            await _repository.updateItem(item);
            final delayMs = _retryManager.calculateBackoffDelay(item.retryCount);
            await Future.delayed(Duration(milliseconds: delayMs));
          } else {
            await _repository.updateItem(item);
          }
        }
      }

      await _repository.saveSyncStatus(SyncStatus(
        lastSyncTime: DateTime.now(),
        status: 'idle',
      ));
    } catch (e) {
      await _repository.saveSyncStatus(SyncStatus(
        lastSyncTime: DateTime.now(),
        status: 'error',
      ));
    } finally {
      _isSyncing = false;
    }
  }
}
