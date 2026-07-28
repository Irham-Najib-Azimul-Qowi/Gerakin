import '../models/conflict_result.dart';

/// Penyelesai konflik data sinkronisasi.
class ConflictResolver {
  /// Menyelesaikan konflik data menggunakan strategi Last Write Wins (LWW).
  ConflictResult resolveLastWriteWins({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) {
    final localTimeStr = localData['updatedAt'] ?? localData['createdAt'];
    final remoteTimeStr = remoteData['updatedAt'] ?? remoteData['createdAt'];

    if (localTimeStr == null) {
      return ConflictResult(resolvedData: remoteData, strategy: 'last_write_wins_remote');
    }
    if (remoteTimeStr == null) {
      return ConflictResult(resolvedData: localData, strategy: 'last_write_wins_local');
    }

    final localTime = DateTime.parse(localTimeStr);
    final remoteTime = DateTime.parse(remoteTimeStr);

    if (localTime.isAfter(remoteTime)) {
      return ConflictResult(resolvedData: localData, strategy: 'last_write_wins_local');
    } else {
      return ConflictResult(resolvedData: remoteData, strategy: 'last_write_wins_remote');
    }
  }
}
