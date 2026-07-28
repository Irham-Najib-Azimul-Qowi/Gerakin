import '../domain/repositories/gamification_repository.dart';
import '../models/goal.dart';

/// Layanan pelacakan target/sasaran latihan pengguna secara terstruktur.
class GoalTrackingService {
  final GamificationRepository _repository;

  GoalTrackingService(this._repository);

  /// Menambahkan target baru ke pelacak sasaran.
  Future<void> addGoal(Goal goal) async {
    await _repository.saveGoal(goal);
  }

  /// Mendapatkan seluruh daftar target aktif pengguna.
  Future<List<Goal>> getGoals(int userId) async {
    return _repository.getGoals(userId);
  }

  /// Memperbarui progres sasaran setelah penyelesaian aktivitas latihan.
  Future<void> updateGoalProgress(int userId, String targetType, double increment) async {
    final goals = await _repository.getGoals(userId);
    for (var g in goals) {
      if (g.targetType == targetType) {
        final newValue = g.currentValue + increment;
        final updated = g.copyWith(
          currentValue: newValue.clamp(0, g.targetValue),
        );
        await _repository.saveGoal(updated);
      }
    }
  }

  /// Menghapus target tertentu.
  Future<void> deleteGoal(int id) async {
    await _repository.deleteGoal(id);
  }
}
