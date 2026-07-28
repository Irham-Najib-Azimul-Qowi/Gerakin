import '../../models/sync_item.dart';
import '../../models/sync_status.dart';
import '../../models/sync_result.dart';

/// Kontrak repositori untuk melacak antrean sinkronisasi (Sync Queue) data offline.
abstract class SyncRepository {
  /// Memasukkan data perubahan baru ke dalam antrean sinkronisasi lokal.
  Future<void> queueChange({
    required String collection,
    required String documentId,
    required String operation,
    required Map<String, dynamic> data,
  });

  /// Mengambil semua item sinkronisasi tertunda dari antrean lokal.
  Future<List<SyncItem>> getPendingItems();

  /// Memperbarui informasi item di antrean lokal (misal: jumlah percobaan ulang).
  Future<void> updateItem(SyncItem item);

  /// Menghapus item dari antrean lokal setelah berhasil disinkronkan.
  Future<void> deleteItem(int id);

  /// Sinkronisasi item tertentu ke database cloud (remote).
  Future<SyncResult> syncItemToRemote(SyncItem item);

  /// Menyimpan status sinkronisasi terakhir secara lokal.
  Future<void> saveSyncStatus(SyncStatus status);

  /// Mendapatkan status sinkronisasi saat ini.
  Future<SyncStatus> getSyncStatus();
}
