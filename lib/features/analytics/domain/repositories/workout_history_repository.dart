import '../../models/workout_session.dart';
import '../../models/recovery_progress.dart';
import '../../models/achievement.dart';

/// Kontrak repositori untuk mengelola riwayat latihan, pemulihan, dan pencapaian.
abstract class WorkoutHistoryRepository {
  // ── Workout Sessions ─────────────────────────────────
  Future<int> saveWorkoutSession(WorkoutSession session);
  Future<List<WorkoutSession>> getAllWorkoutSessions();
  Stream<List<WorkoutSession>> watchWorkoutSessions();
  Future<void> deleteWorkoutSession(int id);

  // ── Recovery Progress ────────────────────────────────
  Future<int> saveRecoveryProgress(RecoveryProgress progress);
  Future<List<RecoveryProgress>> getAllRecoveryProgress();
  Stream<List<RecoveryProgress>> watchRecoveryProgress();

  // ── Achievements ─────────────────────────────────────
  Future<void> saveAchievement(Achievement achievement);
  Future<List<Achievement>> getAllAchievements();
  Future<Achievement?> getAchievementById(String achievementId);
  Stream<List<Achievement>> watchAchievements();
  Future<void> initDefaultAchievements(List<Achievement> defaults);
}
