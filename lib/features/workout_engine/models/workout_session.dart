import 'exercise_definition.dart';
import 'workout_metrics.dart';
import 'workout_state.dart';

/// Model data yang merepresentasikan status sesi latihan aktif.
class WorkoutSession {
  const WorkoutSession({
    required this.exercise,
    required this.currentState,
    required this.metrics,
    this.isResting = false,
    this.isPaused = false,
    this.startTime,
    required this.lastStateChangeTime,
  });

  /// Definisi latihan yang sedang dijalankan.
  final ExerciseDefinition exercise;

  /// Status State Machine saat ini.
  final WorkoutState currentState;

  /// Metrik latihan realtime.
  final WorkoutMetrics metrics;

  /// Apakah saat ini sedang fase istirahat antar set.
  final bool isResting;

  /// Apakah sesi latihan sedang di-pause.
  final bool isPaused;

  /// Waktu awal mulai latihan.
  final DateTime? startTime;

  /// Waktu perubahan state terakhir.
  final DateTime lastStateChangeTime;

  factory WorkoutSession.initial(ExerciseDefinition exercise) {
    final now = DateTime.now();
    return WorkoutSession(
      exercise: exercise,
      currentState: WorkoutState.idle,
      metrics: WorkoutMetrics.initial(
        repTarget: exercise.repetitionTarget,
        setTarget: exercise.setTarget,
      ),
      lastStateChangeTime: now,
    );
  }

  WorkoutSession copyWith({
    ExerciseDefinition? exercise,
    WorkoutState? currentState,
    WorkoutMetrics? metrics,
    bool? isResting,
    bool? isPaused,
    DateTime? startTime,
    DateTime? lastStateChangeTime,
  }) {
    return WorkoutSession(
      exercise: exercise ?? this.exercise,
      currentState: currentState ?? this.currentState,
      metrics: metrics ?? this.metrics,
      isResting: isResting ?? this.isResting,
      isPaused: isPaused ?? this.isPaused,
      startTime: startTime ?? this.startTime,
      lastStateChangeTime: lastStateChangeTime ?? this.lastStateChangeTime,
    );
  }
}
