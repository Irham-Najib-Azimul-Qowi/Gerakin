import '../domain/repositories/gamification_repository.dart';
import '../models/challenge.dart';
import 'xp_engine.dart';
import 'level_engine.dart';

/// Engine untuk menginisialisasi dan memperbarui tantangan mingguan (Weekly Challenges).
class ChallengeEngine {
  final GamificationRepository _repository;
  final XPEngine _xpEngine;
  final LevelEngine _levelEngine;

  ChallengeEngine(this._repository, this._xpEngine, this._levelEngine);

  /// Menginisialisasi tantangan mingguan standar jika belum terdaftar.
  Future<void> initializeWeeklyChallenges() async {
    final list = await _repository.getChallenges();
    if (list.isNotEmpty) return;

    final c1 = Challenge(
      title: 'Konsistensi Mingguan',
      description: 'Selesaikan 3 sesi latihan adaptif dalam kurun waktu satu minggu.',
      xpReward: 150,
      isCompleted: false,
      type: 'weekly',
      targetValue: 3.0,
      currentValue: 0.0,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
    );

    await _repository.saveChallenge(c1);
  }

  /// Memperbarui progres tantangan mingguan berdasarkan jumlah latihan.
  Future<void> updateChallengeProgress(int userId, {required double workoutCount}) async {
    final challenges = await _repository.getChallenges();
    for (var c in challenges) {
      if (c.isCompleted) continue;

      double newValue = c.currentValue + workoutCount;
      final completed = newValue >= c.targetValue;

      final updated = c.copyWith(
        currentValue: newValue.clamp(0, c.targetValue),
        isCompleted: completed,
      );

      await _repository.saveChallenge(updated);

      if (completed) {
        await _xpEngine.awardDirectXP(userId: userId, amount: c.xpReward, source: 'challenge_${c.id}');
        await _levelEngine.addXP(userId, c.xpReward);
      }
    }
  }
}
