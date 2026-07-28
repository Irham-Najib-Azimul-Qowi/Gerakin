import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout_session.dart';
import '../../analytics/models/workout_session.dart' as obx;
import '../../../data/local/objectbox_store.dart';
import '../../../objectbox.g.dart';
import '../../../../core/services/logger_service.dart';

abstract class WorkoutSessionRepository {
  Future<void> saveSession(WorkoutSessionData session);
  Future<WorkoutSessionData?> getSessionById(String id);
  Future<List<WorkoutSessionData>> getAllSessions();
}

class ObjectBoxWorkoutSessionRepository implements WorkoutSessionRepository {
  ObjectBoxWorkoutSessionRepository(this._store, this._logger);

  final Store? _store;
  final LoggerService _logger;

  final Map<String, WorkoutSessionData> _memoryFallbackStore = {};

  @override
  Future<void> saveSession(WorkoutSessionData session) async {
    _memoryFallbackStore[session.id] = session;
    try {
      if (_store != null) {
        final box = _store.box<obx.WorkoutSession>();
        final entity = obx.WorkoutSession(
          workoutId: session.exerciseId,
          workoutName: session.exerciseName,
          startTime: session.startTime,
          durationInSeconds: session.totalDurationSeconds,
          caloriesBurned: session.summary.caloriesBurned,
          completedReps: session.summary.totalRepsCompleted,
          targetReps: session.summary.totalRepsCompleted,
          accuracy: session.summary.averageAccuracy,
          averageRom: session.summary.averageROM,
          isCompleted: true,
          recoveryScore: session.summary.score.totalScore.round(),
        );
        box.put(entity);
        _logger.info('Berhasil menyimpan sesi ${session.id} ke ObjectBox', category: 'WORKOUT_REPO');
      }
    } catch (e) {
      _logger.warning('ObjectBox save fallback: $e', category: 'WORKOUT_REPO');
    }
  }

  @override
  Future<WorkoutSessionData?> getSessionById(String id) async {
    return _memoryFallbackStore[id];
  }

  @override
  Future<List<WorkoutSessionData>> getAllSessions() async {
    return _memoryFallbackStore.values.toList();
  }
}

final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>((ref) {
  Store? store;
  try {
    store = ref.watch(objectBoxStoreProvider);
  } catch (_) {}
  return ObjectBoxWorkoutSessionRepository(store, LoggerService());
});
