import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';

/// Service wrapper untuk inisialisasi ObjectBox database lokal.
class ObjectBoxStore {
  late final Store store;

  ObjectBoxStore._create(this.store);

  /// Membuat instance [ObjectBoxStore] secara asynchronous.
  static Future<ObjectBoxStore> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final storeDir = p.join(docsDir.path, "obx-db-gerakin");
    final store = await openStore(directory: storeDir);
    return ObjectBoxStore._create(store);
  }
}

/// Provider Riverpod untuk instansiasi ObjectBox [Store].
/// Harus di-override di [ProviderScope] pada file `main.dart`.
final objectBoxStoreProvider = Provider<Store>((ref) {
  throw UnimplementedError('Harus meng-override objectBoxStoreProvider di main.dart');
});
