import '../domain/repositories/gamification_repository.dart';
import '../models/mission.dart';
import 'xp_engine.dart';
import 'level_engine.dart';

/// Engine untuk menginisialisasi dan mengevaluasi status penyelesaian Misi Harian.
class MissionEngine {
  final GamificationRepository _repository;
  final XPEngine _xpEngine;
  final LevelEngine _levelEngine;

  MissionEngine(this._repository, this._xpEngine, this._levelEngine);

  /// Menghasilkan misi harian jika antrean kosong.
  Future<void> initializeDailyMissions() async {
    final list = await _repository.getMissions();
    if (list.isNotEmpty) return;

    final m1 = Mission(
      title: 'Latihan Harian',
      description: 'Selesaikan 1 sesi latihan adaptif.',
      xpReward: 30,
      isCompleted: false,
      type: 'daily',
      targetValue: 1.0,
      currentValue: 0.0,
      createdAt: DateTime.now(),
    );

    final m2 = Mission(
      title: 'Akurasi Hebat',
      description: 'Mencapai akurasi rata-rata di atas 80% dalam satu sesi latihan.',
      xpReward: 50,
      isCompleted: false,
      type: 'daily',
      targetValue: 80.0,
      currentValue: 0.0,
      createdAt: DateTime.now(),
    );

    await _repository.saveMission(m1);
    await _repository.saveMission(m2);
  }

  /// Memperbarui progres misi harian setelah latihan selesai dilakukan.
  Future<void> updateMissionProgress(int userId, {required double workoutCount, required double accuracy}) async {
    final missions = await _repository.getMissions();
    for (var m in missions) {
      if (m.isCompleted) continue;

      double newValue = m.currentValue;
      if (m.title == 'Latihan Harian') {
        newValue += workoutCount;
      } else if (m.title == 'Akurasi Hebat') {
        newValue = accuracy;
      }

      final completed = newValue >= m.targetValue;
      final updated = m.copyWith(
        currentValue: newValue.clamp(0, m.targetValue),
        isCompleted: completed,
      );

      await _repository.saveMission(updated);

      if (completed) {
        await _xpEngine.awardDirectXP(userId: userId, amount: m.xpReward, source: 'mission_${m.id}');
        await _levelEngine.addXP(userId, m.xpReward);
      }
    }
  }
}
