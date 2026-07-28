import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gerakin/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:gerakin/features/sync/domain/repositories/sync_repository.dart';
import 'package:gerakin/features/sync/data/datasources/local_sync_queue_data_source.dart';
import 'package:gerakin/features/sync/data/datasources/remote_firestore_data_source.dart';
import 'package:gerakin/features/sync/models/sync_item.dart';
import 'package:gerakin/features/sync/models/sync_status.dart';
import 'package:gerakin/features/sync/services/connectivity_monitor.dart';
import 'package:gerakin/features/sync/services/retry_manager.dart';
import 'package:gerakin/features/sync/services/conflict_resolver.dart';
import 'package:gerakin/features/sync/services/sync_engine.dart';

/// Mock in-memory implementation dari [LocalSyncQueueDataSource].
class MockLocalSyncQueueDataSource implements LocalSyncQueueDataSource {
  final List<SyncItem> queue = [];
  SyncStatus? status;
  int _idCounter = 1;

  @override
  Future<int> enqueue(SyncItem item) async {
    if (item.id == 0) {
      item.id = _idCounter++;
    }
    queue.add(item);
    return item.id;
  }

  @override
  Future<List<SyncItem>> getPendingItems() async {
    return List.from(queue);
  }

  @override
  Future<void> updateItem(SyncItem item) async {
    final idx = queue.indexWhere((x) => x.id == item.id);
    if (idx != -1) {
      queue[idx] = item;
    }
  }

  @override
  Future<void> deleteItem(int id) async {
    queue.removeWhere((x) => x.id == id);
  }

  @override
  Future<void> saveSyncStatus(SyncStatus status) async {
    this.status = status;
  }

  @override
  Future<SyncStatus?> getSyncStatus() async {
    return status;
  }
}

/// Mock in-memory implementation dari [RemoteFirestoreDataSource].
class MockRemoteFirestoreDataSource implements RemoteFirestoreDataSource {
  final Map<String, Map<String, dynamic>> db = {};

  @override
  Future<void> createDocument(String collection, String documentId, Map<String, dynamic> data) async {
    db['$collection/$documentId'] = Map<String, dynamic>.from(data);
  }

  @override
  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) async {
    db['$collection/$documentId']?.addAll(data);
  }

  @override
  Future<void> deleteDocument(String collection, String documentId) async {
    db.remove('$collection/$documentId');
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String collection, String documentId) async {
    return db['$collection/$documentId'];
  }
}

/// Mock kelas [Connectivity] dari connectivity_plus.
class MockConnectivity implements Connectivity {
  List<ConnectivityResult> activeResults;
  final StreamController<List<ConnectivityResult>> _controller = StreamController<List<ConnectivityResult>>.broadcast();

  MockConnectivity({required this.activeResults});

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => activeResults;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  void triggerChange(List<ConnectivityResult> results) {
    activeResults = results;
    _controller.add(results);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('Cloud Sync Engine Unit Tests', () {
    late MockLocalSyncQueueDataSource localQueue;
    late MockRemoteFirestoreDataSource remoteFirestore;
    late MockConnectivity mockConnectivity;
    late ConnectivityMonitor connectivityMonitor;
    late SyncRepository repository;
    late SyncEngine syncEngine;

    setUp(() {
      localQueue = MockLocalSyncQueueDataSource();
      remoteFirestore = MockRemoteFirestoreDataSource();
      
      // Default: Terhubung ke internet lewat WiFi
      mockConnectivity = MockConnectivity(activeResults: [ConnectivityResult.wifi]);
      connectivityMonitor = ConnectivityMonitor(connectivity: mockConnectivity);
      
      repository = SyncRepositoryImpl(localQueue, remoteFirestore);
      syncEngine = SyncEngine(repository, connectivityMonitor);
    });

    tearDown(() {
      mockConnectivity.dispose();
    });

    // ── 1. SYNC QUEUE TESTS ─────────────────────────────────────────────
    test('LocalSyncQueueDataSource queues and retrieves items in FIFO order', () async {
      await repository.queueChange(
        collection: 'workouts',
        documentId: 'doc1',
        operation: 'create',
        data: {'name': 'Squats'},
      );

      await repository.queueChange(
        collection: 'workouts',
        documentId: 'doc2',
        operation: 'create',
        data: {'name': 'Lunges'},
      );

      final items = await repository.getPendingItems();
      expect(items.length, equals(2));
      expect(items[0].documentId, equals('doc1'));
      expect(items[1].documentId, equals('doc2'));

      // Selesaikan proses item 1
      await repository.deleteItem(items[0].id);
      final remaining = await repository.getPendingItems();
      expect(remaining.length, equals(1));
      expect(remaining.first.documentId, equals('doc2'));
    });

    // ── 2. RETRY MANAGER TESTS ──────────────────────────────────────────
    test('RetryManager computes correct exponential backoff delays', () {
      final manager = RetryManager(maxRetries: 3);

      expect(manager.shouldRetry(0), isTrue);
      expect(manager.shouldRetry(2), isTrue);
      expect(manager.shouldRetry(3), isFalse); // Batas tercapai

      // delay = 1000 * 2^(retryCount - 1)
      expect(manager.calculateBackoffDelay(1), equals(1000));
      expect(manager.calculateBackoffDelay(2), equals(2000));
      expect(manager.calculateBackoffDelay(3), equals(4000));
      expect(manager.calculateBackoffDelay(4), equals(8000));
    });

    // ── 3. CONFLICT RESOLUTION TESTS ────────────────────────────────────
    test('ConflictResolver resolves conflicts using Last Write Wins', () {
      final resolver = ConflictResolver();

      final localData = {
        'id': 1,
        'displayName': 'Ahmad',
        'updatedAt': '2026-07-27T08:00:00Z',
      };

      final remoteDataNewer = {
        'id': 1,
        'displayName': 'Ahmad Cloud',
        'updatedAt': '2026-07-27T08:30:00Z',
      };

      final remoteDataOlder = {
        'id': 1,
        'displayName': 'Ahmad Cloud',
        'updatedAt': '2026-07-27T07:30:00Z',
      };

      // Kasus 1: Cloud menang (LWW remote)
      final result1 = resolver.resolveLastWriteWins(localData: localData, remoteData: remoteDataNewer);
      expect(result1.strategy, equals('last_write_wins_remote'));
      expect(result1.resolvedData['displayName'], equals('Ahmad Cloud'));

      // Kasus 2: Lokal menang (LWW lokal)
      final result2 = resolver.resolveLastWriteWins(localData: localData, remoteData: remoteDataOlder);
      expect(result2.strategy, equals('last_write_wins_local'));
      expect(result2.resolvedData['displayName'], equals('Ahmad'));
    });

    // ── 4. CONNECTIVITY MONITOR TESTS ───────────────────────────────────
    test('ConnectivityMonitor returns online state correctly', () async {
      expect(await connectivityMonitor.isConnected, isTrue);

      // Ubah koneksi ke none (offline)
      mockConnectivity.triggerChange([ConnectivityResult.none]);
      expect(await connectivityMonitor.isConnected, isFalse);
    });

    // ── 5. SYNC ENGINE TESTS ────────────────────────────────────────────
    test('SyncEngine processes queue items successfully when online', () async {
      await repository.queueChange(
        collection: 'sessions',
        documentId: 'sess1',
        operation: 'create',
        data: {
          'id': 1,
          'workoutName': 'Therapy',
          'createdAt': '2026-07-27T08:00:00Z',
        },
      );

      // Jalankan proses sinkronisasi antrean
      await syncEngine.processQueue();

      // Cek antrean lokal kosong
      final pending = await repository.getPendingItems();
      expect(pending.isEmpty, isTrue);

      // Cek data masuk ke remote database (Firestore)
      final remoteDoc = await remoteFirestore.getDocument('sessions', 'sess1');
      expect(remoteDoc, isNotNull);
      expect(remoteDoc!['workoutName'], equals('Therapy'));

      // Cek status sinkronisasi tersimpan sebagai idle (selesai)
      final status = await repository.getSyncStatus();
      expect(status.status, equals('idle'));
    });

    test('SyncEngine aborts queue processing when connection is offline', () async {
      await repository.queueChange(
        collection: 'sessions',
        documentId: 'sess2',
        operation: 'create',
        data: {'id': 2},
      );

      // Matikan internet
      mockConnectivity.triggerChange([ConnectivityResult.none]);

      await syncEngine.processQueue();

      // Cek antrean lokal tetap berisi 1 data pending
      final pending = await repository.getPendingItems();
      expect(pending.length, equals(1));
    });
  });
}
