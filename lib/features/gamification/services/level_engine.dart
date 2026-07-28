import '../domain/repositories/gamification_repository.dart';
import '../models/user_level.dart';
import 'rules/level_progression_rule.dart';
import '../../sync/domain/repositories/sync_repository.dart';

/// Engine untuk mengelola naik level (level-up) pengguna berdasarkan akumulasi XP.
class LevelEngine {
  final GamificationRepository _repository;
  final SyncRepository _syncRepository;
  final LevelProgressionRule _progressionRule = LevelProgressionRule();

  LevelEngine(this._repository, this._syncRepository);

  /// Menambahkan XP ke pengguna dan menaikkan level jika batas ambang terlewati.
  Future<UserLevel> addXP(int userId, int xpAmount) async {
    var userLvl = await _repository.getUserLevel(userId);

    int newXP = userLvl.currentXP + xpAmount;
    int currentLevel = userLvl.currentLevel;
    int nextLevelXP = userLvl.nextLevelXP;

    while (newXP >= nextLevelXP) {
      newXP -= nextLevelXP;
      currentLevel++;
      nextLevelXP = _progressionRule.evaluate(currentLevel);
    }

    final updated = userLvl.copyWith(
      currentLevel: currentLevel,
      currentXP: newXP,
      nextLevelXP: nextLevelXP,
    );

    await _repository.saveUserLevel(updated);

    // Kirim data pembaruan ke antrean Sync Engine
    await _syncRepository.queueChange(
      collection: 'users',
      documentId: 'level_$userId',
      operation: 'update',
      data: {
        'userId': userId,
        'currentLevel': currentLevel,
        'currentXP': newXP,
        'nextLevelXP': nextLevelXP,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );

    return updated;
  }
}
