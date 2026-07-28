/// Hasil penyelesaian konflik data antara lokal dan cloud.
class ConflictResult {
  final Map<String, dynamic> resolvedData;
  final String strategy; // e.g., 'last_write_wins'

  ConflictResult({
    required this.resolvedData,
    required this.strategy,
  });
}
