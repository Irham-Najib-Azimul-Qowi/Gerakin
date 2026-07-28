import 'dart:async';
import 'connectivity_monitor.dart';
import 'sync_engine.dart';

/// Layanan sinkronisasi latar belakang otomatis yang memantau perubahan jaringan.
class BackgroundSyncService {
  final SyncEngine _syncEngine;
  final ConnectivityMonitor _connectivityMonitor;
  StreamSubscription<bool>? _subscription;

  BackgroundSyncService(this._syncEngine, this._connectivityMonitor);

  /// Memulai pemantauan konektivitas secara background otomatis.
  void start() {
    _subscription?.cancel();
    _subscription = _connectivityMonitor.onConnectivityChanged.listen((connected) {
      if (connected) {
        _syncEngine.processQueue();
      }
    });
  }

  /// Menghentikan pemantauan.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}
