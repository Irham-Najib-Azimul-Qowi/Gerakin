import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../models/sync_status.dart';
import '../../services/sync_providers.dart';
import '../../services/manual_sync_service.dart';

/// State untuk indikator status sinkronisasi.
class SyncStatusState {
  final SyncStatus status;
  final int pendingCount;
  final bool isManualSyncing;

  SyncStatusState({
    required this.status,
    required this.pendingCount,
    required this.isManualSyncing,
  });

  SyncStatusState copyWith({
    SyncStatus? status,
    int? pendingCount,
    bool? isManualSyncing,
  }) {
    return SyncStatusState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      isManualSyncing: isManualSyncing ?? this.isManualSyncing,
    );
  }
}

/// Controller (Notifier) untuk mengelola data status sinkronisasi.
class SyncStatusController extends Notifier<SyncStatusState> {
  late final SyncRepository _repository;
  late final ManualSyncService _manualSync;
  Timer? _timer;

  @override
  SyncStatusState build() {
    _repository = ref.watch(syncRepositoryProvider);
    _manualSync = ref.watch(manualSyncServiceProvider);

    // Memulai monitoring sinkronisasi latar belakang otomatis
    ref.read(backgroundSyncServiceProvider).start();

    // Secara berkala memperbarui jumlah antrean tertunda (setiap 3 detik)
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refreshStatus());

    Future.microtask(() => _refreshStatus());

    ref.onDispose(() {
      _timer?.cancel();
    });

    return SyncStatusState(
      status: SyncStatus(lastSyncTime: DateTime.fromMillisecondsSinceEpoch(0), status: 'idle'),
      pendingCount: 0,
      isManualSyncing: false,
    );
  }

  Future<void> _refreshStatus() async {
    try {
      final status = await _repository.getSyncStatus();
      final pending = await _repository.getPendingItems();

      state = state.copyWith(
        status: status,
        pendingCount: pending.length,
      );
    } catch (_) {}
  }

  /// Memicu sinkronisasi manual ke Firebase.
  Future<void> triggerManualSync() async {
    try {
      state = state.copyWith(isManualSyncing: true);
      await _manualSync.triggerSync();
      await _refreshStatus();
    } finally {
      state = state.copyWith(isManualSyncing: false);
    }
  }
}

/// Provider untuk instansiasi [SyncStatusController].
final syncStatusControllerProvider = NotifierProvider<SyncStatusController, SyncStatusState>(
  SyncStatusController.new,
);
