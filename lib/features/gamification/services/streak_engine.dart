import '../domain/repositories/gamification_repository.dart';
import '../models/streak.dart';
import 'rules/streak_rule.dart';
import '../../sync/domain/repositories/sync_repository.dart';

/// Engine untuk menghitung hari latihan berturut-turut (Streak) pengguna.
class StreakEngine {
  final GamificationRepository _repository;
  final SyncRepository _syncRepository;
  final StreakRule _streakRule = StreakRule();

  StreakEngine(this._repository, this._syncRepository);

  /// Memperbarui jumlah streak harian setelah latihan diselesaikan.
  Future<Streak> recordActivity(int userId) async {
    final streak = await _repository.getStreak(userId);
    final now = DateTime.now();

    // Cek jika latihan pertama kali
    if (streak.lastActiveDate.millisecondsSinceEpoch == 0) {
      final updated = streak.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastActiveDate: now,
      );
      await _repository.saveStreak(updated);
      await _syncStreak(updated);
      return updated;
    }

    final newStreakVal = _streakRule.evaluate(StreakInput(
      lastActiveDate: streak.lastActiveDate,
      currentActiveDate: now,
      currentStreak: streak.currentStreak,
    ));

    final longest = newStreakVal > streak.longestStreak ? newStreakVal : streak.longestStreak;

    final updated = streak.copyWith(
      currentStreak: newStreakVal,
      longestStreak: longest,
      lastActiveDate: now,
    );

    await _repository.saveStreak(updated);
    await _syncStreak(updated);
    return updated;
  }

  Future<void> _syncStreak(Streak streak) async {
    await _syncRepository.queueChange(
      collection: 'users',
      documentId: 'streak_${streak.userId}',
      operation: 'update',
      data: {
        'userId': streak.userId,
        'currentStreak': streak.currentStreak,
        'longestStreak': streak.longestStreak,
        'lastActiveDate': streak.lastActiveDate.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}
