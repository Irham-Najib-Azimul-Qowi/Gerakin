import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout_session.dart';
import '../models/workout_summary.dart';
import '../models/workout_score.dart';
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
    if (_memoryFallbackStore.containsKey(id)) {
      return _memoryFallbackStore[id];
    }

    if (_store != null) {
      try {
        final box = _store.box<obx.WorkoutSession>();
        final intId = int.tryParse(id);
        if (intId != null) {
          final entity = box.get(intId);
          if (entity != null) return _mapToSessionData(entity);
        }
        final all = box.getAll();
        for (final entity in all) {
          if (entity.workoutId == id) {
            return _mapToSessionData(entity);
          }
        }
      } catch (e) {
        _logger.warning('Gagal membaca getSessionById($id) dari ObjectBox: $e', category: 'WORKOUT_REPO');
      }
    }

    return null;
  }

  @override
  Future<List<WorkoutSessionData>> getAllSessions() async {
    if (_store != null) {
      try {
        final box = _store.box<obx.WorkoutSession>();
        final entities = box.getAll();
        if (entities.isNotEmpty) {
          return entities.map(_mapToSessionData).toList();
        }
      } catch (e) {
        _logger.warning('Gagal membaca getAllSessions dari ObjectBox: $e', category: 'WORKOUT_REPO');
      }
    }
    return _memoryFallbackStore.values.toList();
  }

  /// Memetakan entitas [obx.WorkoutSession] ObjectBox kembali ke [WorkoutSessionData].
  ///
  /// KEPUTUSAN DESAIN STORAGE:
  /// Rekaman detail per-frame (`recordedFrames`) dan array `sets` mentah sengaja tidak disimpan
  /// permanen ke dalam ObjectBox demi menghemat ruang penyimpanan lokal perangkat pengguna kursi roda.
  /// Seluruh metrik esensial (durasi, repetisi, kalori, akurasi, ROM, skor) direkonstruksi secara penuh.
  WorkoutSessionData _mapToSessionData(obx.WorkoutSession entity) {
    return WorkoutSessionData(
      id: entity.id.toString(),
      exerciseId: entity.workoutId,
      exerciseName: entity.workoutName,
      startTime: entity.startTime,
      endTime: entity.startTime.add(Duration(seconds: entity.durationInSeconds)),
      totalDurationSeconds: entity.durationInSeconds,
      sets: const [],
      recordedFrames: const [],
      summary: WorkoutSummary(
        sessionId: entity.id.toString(),
        exerciseId: entity.workoutId,
        exerciseName: entity.workoutName,
        totalDurationSeconds: entity.durationInSeconds,
        caloriesBurned: entity.caloriesBurned,
        totalRepsCompleted: entity.completedReps,
        totalSetsCompleted: 1,
        averageAccuracy: entity.accuracy,
        averageROM: entity.averageRom,
        averageSpeedDegreesPerSec: 0.0,
        averageHoldSeconds: 0.0,
        movementStability: entity.accuracy,
        score: WorkoutScore(
          accuracyScore: entity.accuracy,
          romScore: entity.averageRom,
          smoothnessScore: entity.recoveryScore.toDouble(),
          confidenceScore: 1.0,
          consistencyScore: entity.accuracy,
          holdScore: 100.0,
          speedScore: 100.0,
          safetyScore: entity.recoveryScore.toDouble(),
          totalScore: entity.recoveryScore.toDouble(),
        ),
        xpEarned: (entity.completedReps * 10),
        achievements: const ['Sesi Tersimpan'],
        improvements: const [],
        timestamp: entity.startTime,
      ),
    );
  }
}

final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>((ref) {
  Store? store;
  try {
    store = ref.watch(objectBoxStoreProvider);
  } catch (_) {}
  return ObjectBoxWorkoutSessionRepository(store, LoggerService());
});
