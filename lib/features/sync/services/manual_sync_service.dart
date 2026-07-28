import 'sync_engine.dart';

/// Layanan untuk memicu proses sinkronisasi secara manual atas permintaan pengguna.
class ManualSyncService {
  final SyncEngine _syncEngine;

  ManualSyncService(this._syncEngine);

  /// Memicu proses sinkronisasi secara manual.
  Future<void> triggerSync() async {
    await _syncEngine.processQueue();
  }
}
