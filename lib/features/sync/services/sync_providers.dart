import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/sync_repository_impl.dart';
import 'connectivity_monitor.dart';
import 'sync_engine.dart';
import 'background_sync_service.dart';
import 'manual_sync_service.dart';

/// Provider untuk instansiasi [ConnectivityMonitor].
final connectivityMonitorProvider = Provider<ConnectivityMonitor>((ref) {
  return ConnectivityMonitor();
});

/// Provider untuk instansiasi [SyncEngine].
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final repo = ref.watch(syncRepositoryProvider);
  final monitor = ref.watch(connectivityMonitorProvider);
  return SyncEngine(repo, monitor);
});

/// Provider untuk instansiasi [BackgroundSyncService].
final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final engine = ref.watch(syncEngineProvider);
  final monitor = ref.watch(connectivityMonitorProvider);
  return BackgroundSyncService(engine, monitor);
});

/// Provider untuk instansiasi [ManualSyncService].
final manualSyncServiceProvider = Provider<ManualSyncService>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return ManualSyncService(engine);
});
