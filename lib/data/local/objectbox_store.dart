import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';

/// Service wrapper untuk inisialisasi ObjectBox database lokal.
class ObjectBoxStore {
  final Store store;

  ObjectBoxStore(this.store);

  /// Membuka [Store] secara langsung dengan perlindungan terhadap [MissingPluginException].
  static Future<Store> _openStoreDirectly({String? directory}) async {
    try {
      await loadObjectBoxLibraryAndroidCompat();
    } catch (_) {
      // Abaikan jika method channel objectbox_flutter_libs tidak ditemukan di Android 13+
    }
    return Store(
      getObjectBoxModel(),
      directory: directory,
    );
  }

  /// Membuat instance [ObjectBoxStore] secara asynchronous.
  static Future<ObjectBoxStore> create() async {
    String? storeDir;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      storeDir = p.join(docsDir.path, "obx-db-gerakin");
    } catch (_) {
      try {
        final tempDir = await getTemporaryDirectory();
        storeDir = p.join(tempDir.path, "obx-db-gerakin");
      } catch (_) {
        storeDir = null;
      }
    }

    if (storeDir != null) {
      try {
        final store = await _openStoreDirectly(directory: storeDir);
        return ObjectBoxStore(store);
      } catch (e) {
        try {
          final dir = Directory(storeDir);
          if (await dir.exists()) {
            await dir.delete(recursive: true);
          }
          final store = await _openStoreDirectly(directory: storeDir);
          return ObjectBoxStore(store);
        } catch (_) {}
      }
    }

    // Fallback utama: gunakan in-memory store
    final store = await _openStoreDirectly(directory: Store.inMemoryPrefix);
    return ObjectBoxStore(store);
  }
}

/// Provider Riverpod untuk instansiasi ObjectBox [Store].
/// Harus di-override di [ProviderScope] pada file `main.dart`.
final objectBoxStoreProvider = Provider<Store>((ref) {
  throw UnimplementedError('Harus meng-override objectBoxStoreProvider di main.dart');
});
