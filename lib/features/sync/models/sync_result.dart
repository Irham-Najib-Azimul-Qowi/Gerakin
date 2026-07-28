/// Hasil dari proses sinkronisasi satu SyncItem.
class SyncResult {
  final bool isSuccess;
  final bool hasConflict;
  final String? errorMessage;

  SyncResult({
    required this.isSuccess,
    this.hasConflict = false,
    this.errorMessage,
  });
}
