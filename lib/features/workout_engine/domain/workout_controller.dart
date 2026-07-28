import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/models/motion_analysis.dart';

import '../data/exercise_library.dart';
import '../models/exercise_definition.dart';
import '../models/workout_metrics.dart';
import '../models/workout_result.dart';
import '../models/workout_session.dart';
import '../models/workout_state.dart';
import '../services/hold_timer.dart';
import '../services/repetition_counter.dart';
import '../services/rest_timer.dart';
import '../services/workout_metrics_calculator.dart';
import '../services/workout_scoring.dart';

/// Riverpod Provider untuk [WorkoutController].
final workoutControllerProvider =
    NotifierProvider<WorkoutController, WorkoutSession>(
  WorkoutController.new,
);

/// Single entry point Controller (Riverpod Notifier) untuk mengelola seluruh sesi latihan.
///
/// TANGGUNG JAWAB:
/// - Menerima data [MotionAnalysis] murni dari Motion Engine (decoupled dari ML Kit).
/// - Menjalankan State Machine (`idle` -> `ready` -> `moving` -> `hold` -> `returning` -> `completed`).
/// - Mengatur penambahan repetisi & set, timer hold, timer rest, skor akurasi, dan metrik realtime.
class WorkoutController extends Notifier<WorkoutSession> {
  WorkoutController({
    RepetitionCounter? repCounter,
    HoldTimer? holdTimer,
    RestTimer? restTimer,
    WorkoutScoring? scoring,
    WorkoutMetricsCalculator? metricsCalculator,
  })  : _repCounter = repCounter ?? RepetitionCounter(),
        _holdTimer = holdTimer ?? HoldTimer(),
        _restTimer = restTimer ?? RestTimer(),
        _scoring = scoring ?? WorkoutScoring(),
        _metricsCalculator = metricsCalculator ?? WorkoutMetricsCalculator();

  final RepetitionCounter _repCounter;
  final HoldTimer _holdTimer;
  final RestTimer _restTimer;
  final WorkoutScoring _scoring;
  final WorkoutMetricsCalculator _metricsCalculator;

  DateTime? _sessionStartTime;
  DateTime? _lastTickTime;

  @override
  WorkoutSession build() {
    return WorkoutSession.initial(ExerciseLibrary.armRaise);
  }

  /// Getter publik untuk membaca status sesi saat ini.
  WorkoutSession get currentSession => state;

  /// Memulai sesi latihan baru dengan [exercise].
  void startWorkout(ExerciseDefinition exercise) {
    _repCounter.reset();
    _holdTimer.reset();
    _restTimer.reset();
    _scoring.reset();

    final now = DateTime.now();
    _sessionStartTime = now;
    _lastTickTime = now;

    state = WorkoutSession(
      exercise: exercise,
      currentState: WorkoutState.ready,
      metrics: WorkoutMetrics.initial(
        repTarget: exercise.repetitionTarget,
        setTarget: exercise.setTarget,
      ).copyWith(
        exerciseStatus: 'Ambil posisi awal di depan kamera',
      ),
      startTime: now,
      lastStateChangeTime: now,
    );
  }

  /// Entry point utama feed frame: menerima [MotionAnalysis] real-time.
  void processMotion(MotionAnalysis analysis) {
    if (state.currentState.isIdle ||
        state.currentState.isCompleted ||
        state.isPaused) {
      return;
    }

    final now = DateTime.now();
    final deltaMs = _lastTickTime != null
        ? now.difference(_lastTickTime!).inMilliseconds
        : 33;
    _lastTickTime = now;

    final durationSeconds = _sessionStartTime != null
        ? now.difference(_sessionStartTime!).inSeconds
        : 0;

    // 1. Update Skor real-time
    final currentScore = _scoring.processFrameScore(analysis);

    // 2. Cek jika sedang fase istirahat (Rest Phase)
    if (state.isResting) {
      final isRestDone = _restTimer.update(deltaMs);
      if (isRestDone) {
        _restTimer.reset();
        state = state.copyWith(
          isResting: false,
          currentState: WorkoutState.ready,
          lastStateChangeTime: now,
        );
      } else {
        final updatedMetrics = _metricsCalculator.computeMetrics(
          exercise: state.exercise,
          currentRep: _repCounter.completedReps,
          currentSet: _repCounter.completedSets + 1,
          durationSeconds: durationSeconds,
          holdSeconds: 0,
          restSeconds: _restTimer.remainingSeconds,
          score: currentScore,
          statusText: 'Istirahat! Set berikutnya dalam ${_restTimer.remainingSeconds}s',
        );
        state = state.copyWith(metrics: updatedMetrics);
        return;
      }
    }

    // 3. Ambil Sudut Sendi Utama
    final primaryJointAngle = analysis.getAngle(state.exercise.primaryJoint);
    final currentAngle = primaryJointAngle?.angle ?? 0.0;

    // 4. State Machine Transition Logic
    WorkoutState newState = state.currentState;
    String statusMessage = state.metrics.exerciseStatus;

    switch (state.currentState) {
      case WorkoutState.idle:
        break;

      case WorkoutState.ready:
        if (state.exercise.isAtStartAngle(currentAngle)) {
          newState = WorkoutState.moving;
          statusMessage = 'Bagus! Lakukan gerakan menuju target';
        } else {
          statusMessage = 'Sesuaikan sudut awal (${state.exercise.startAngle.toInt()}°)';
        }
        break;

      case WorkoutState.moving:
        if (state.exercise.isAtTargetAngle(currentAngle)) {
          if (state.exercise.holdDuration > 0) {
            newState = WorkoutState.hold;
            _holdTimer.start(state.exercise.holdDuration);
            statusMessage = 'Tahan posisi ${_holdTimer.remainingSeconds}s!';
          } else {
            newState = WorkoutState.returning;
            statusMessage = 'Kembali ke posisi awal';
          }
        } else {
          statusMessage = 'Gerakkan lengan ke sudut target (${state.exercise.targetAngle.toInt()}°)';
        }
        break;

      case WorkoutState.hold:
        final isHoldDone = _holdTimer.update(deltaMs);
        if (isHoldDone) {
          _holdTimer.reset();
          newState = WorkoutState.returning;
          statusMessage = 'Kembali ke posisi awal';
        } else {
          statusMessage = 'Tahan posisi! ${_holdTimer.remainingSeconds}s';
        }
        break;

      case WorkoutState.returning:
        if (state.exercise.isAtStartAngle(currentAngle)) {
          _repCounter.incrementRep();

          if (_repCounter.isSetCompleted(state.exercise)) {
            _repCounter.incrementSet();

            if (_repCounter.isWorkoutCompleted(state.exercise)) {
              newState = WorkoutState.completed;
              statusMessage = 'Selamat! Latihan Selesai!';
            } else {
              // Mulai Istirahat Antar Set
              _restTimer.start(state.exercise.restDuration);
              state = state.copyWith(isResting: true);
              statusMessage = 'Set Selesai! Istirahat ${_restTimer.remainingSeconds}s';
            }
          } else {
            newState = WorkoutState.moving;
            statusMessage = 'Repetisi ${_repCounter.completedReps} Selesai!';
          }
        } else {
          statusMessage = 'Kembali penuh ke posisi awal';
        }
        break;

      case WorkoutState.completed:
        statusMessage = 'Latihan Selesai!';
        break;
    }

    // 5. Update Sesi & Metrik
    final updatedMetrics = _metricsCalculator.computeMetrics(
      exercise: state.exercise,
      currentRep: _repCounter.completedReps,
      currentSet: _repCounter.completedSets + 1 > state.exercise.setTarget
          ? state.exercise.setTarget
          : _repCounter.completedSets + 1,
      durationSeconds: durationSeconds,
      holdSeconds: _holdTimer.remainingSeconds,
      restSeconds: _restTimer.remainingSeconds,
      score: currentScore,
      statusText: statusMessage,
    );

    state = state.copyWith(
      currentState: newState,
      metrics: updatedMetrics,
      lastStateChangeTime: newState != state.currentState ? now : state.lastStateChangeTime,
    );
  }

  /// Pause sesi latihan.
  void pauseWorkout() {
    if (state.currentState.isCompleted || state.currentState.isIdle) return;
    state = state.copyWith(isPaused: true);
  }

  /// Resume sesi latihan.
  void resumeWorkout() {
    if (!state.isPaused) return;
    _lastTickTime = DateTime.now();
    state = state.copyWith(isPaused: false);
  }

  /// Menghentikan latihan dan mengembalikan [WorkoutResult].
  WorkoutResult finishWorkout() {
    final now = DateTime.now();
    final durationSeconds = _sessionStartTime != null
        ? now.difference(_sessionStartTime!).inSeconds
        : 0;

    final int totalReps = (_repCounter.completedSets * state.exercise.repetitionTarget) +
        _repCounter.completedReps;
    final int totalTargetReps = state.exercise.setTarget * state.exercise.repetitionTarget;
    final double calories = _metricsCalculator.calculateCaloriesBurned(durationSeconds);
    final double accuracy = totalTargetReps > 0
        ? ((totalReps / totalTargetReps) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    final result = WorkoutResult(
      exerciseId: state.exercise.id,
      exerciseName: state.exercise.name,
      totalCompletedReps: totalReps,
      totalTargetReps: totalTargetReps,
      totalCompletedSets: _repCounter.completedSets,
      totalDurationSeconds: durationSeconds,
      caloriesBurned: calories,
      finalScore: state.metrics.workoutScore,
      accuracyPercentage: accuracy,
      completedAt: now,
    );

    state = state.copyWith(
      currentState: WorkoutState.completed,
      lastStateChangeTime: now,
    );

    return result;
  }
}
