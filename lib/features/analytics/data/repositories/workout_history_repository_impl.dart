import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/objectbox_store.dart';
import '../../../../objectbox.g.dart';
import '../../domain/repositories/workout_history_repository.dart';
import '../../models/workout_session.dart';
import '../../models/recovery_progress.dart';
import '../../models/achievement.dart';

/// Implementasi [WorkoutHistoryRepository] menggunakan database lokal ObjectBox.
class WorkoutHistoryRepositoryImpl implements WorkoutHistoryRepository {
  final Box<WorkoutSession> _sessionBox;
  final Box<RecoveryProgress> _recoveryBox;
  final Box<Achievement> _achievementBox;

  WorkoutHistoryRepositoryImpl(Store store)
      : _sessionBox = store.box<WorkoutSession>(),
        _recoveryBox = store.box<RecoveryProgress>(),
        _achievementBox = store.box<Achievement>();

  @override
  Future<int> saveWorkoutSession(WorkoutSession session) async {
    return _sessionBox.put(session);
  }

  @override
  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    // Return sorted by date descending by default
    final query = (_sessionBox.query()..order(WorkoutSession_.startTime, flags: Order.descending)).build();
    final result = query.find();
    query.close();
    return result;
  }

  @override
  Stream<List<WorkoutSession>> watchWorkoutSessions() {
    return _sessionBox
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  Future<void> deleteWorkoutSession(int id) async {
    _sessionBox.remove(id);
  }

  @override
  Future<int> saveRecoveryProgress(RecoveryProgress progress) async {
    return _recoveryBox.put(progress);
  }

  @override
  Future<List<RecoveryProgress>> getAllRecoveryProgress() async {
    final query = (_recoveryBox.query()..order(RecoveryProgress_.date, flags: Order.descending)).build();
    final result = query.find();
    query.close();
    return result;
  }

  @override
  Stream<List<RecoveryProgress>> watchRecoveryProgress() {
    return _recoveryBox
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  Future<void> saveAchievement(Achievement achievement) async {
    final existing = await getAchievementById(achievement.achievementId);
    if (existing != null) {
      achievement.id = existing.id;
    }
    _achievementBox.put(achievement);
  }

  @override
  Future<List<Achievement>> getAllAchievements() async {
    return _achievementBox.getAll();
  }

  @override
  Future<Achievement?> getAchievementById(String achievementId) async {
    final query = _achievementBox
        .query(Achievement_.achievementId.equals(achievementId))
        .build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  @override
  Stream<List<Achievement>> watchAchievements() {
    return _achievementBox
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  Future<void> initDefaultAchievements(List<Achievement> defaults) async {
    for (final def in defaults) {
      final existing = await getAchievementById(def.achievementId);
      if (existing == null) {
        _achievementBox.put(def);
      }
    }
  }
}

/// Provider Riverpod untuk instansiasi [WorkoutHistoryRepository].
final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>((ref) {
  final store = ref.watch(objectBoxStoreProvider);
  return WorkoutHistoryRepositoryImpl(store);
});
