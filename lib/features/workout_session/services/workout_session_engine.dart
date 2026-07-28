import 'dart:async';
import '../models/workout_state.dart';
import '../models/movement_phase.dart';
import '../models/workout_rep.dart';
import '../models/workout_summary.dart';
import '../models/recorded_frame.dart';
import 'voice_coach.dart';
import 'workout_validator.dart';
import 'movement_state_machine.dart';
import 'rep_counter.dart';
import 'set_manager.dart';
import 'rest_timer.dart';
import 'workout_summary_engine.dart';
import 'workout_recorder.dart';
import '../../camera/models/pose_landmark_model.dart';
import '../../exercise_library/models/full_exercise_definition.dart';
import '../../../../core/services/logger_service.dart';

/// Orchestrator utama untuk Sesi Latihan Rehabilitasi Terintegrasi.
class WorkoutSessionEngine {
  WorkoutSessionEngine({
    required this.exercise,
    VoiceCoach? voiceCoach,
    LoggerService? logger,
  })  : _voiceCoach = voiceCoach ?? VoiceCoach(),
        _logger = logger ?? LoggerService(),
        _recorder = WorkoutRecorder(),
        _restTimer = RestTimer() {
    _initEngine();
  }

  final FullExerciseDefinition exercise;
  final VoiceCoach _voiceCoach;
  final LoggerService _logger;
  final WorkoutRecorder _recorder;
  final RestTimer _restTimer;

  late final MovementStateMachine _stateMachine;
  late final RepCounter _repCounter;
  late final SetManager _setManager;

  WorkoutState _state = WorkoutState.idle;
  CalibrationResult? _lastCalibrationResult;
  double _currentAngle = 0.0;
  double _currentConfidence = 0.0;
  int _workoutElapsedSeconds = 0;
  Timer? _sessionDurationTimer;
  DateTime? _sessionStartTime;
  WorkoutSummary? _summaryResult;

  // Developer & Debug Telemetry
  double _lastFrameProcessingTimeMs = 0.0;
  int _landmarkCount = 0;
  int _fps = 0;
  DateTime _lastFpsTime = DateTime.now();
  int _frameCount = 0;

  // Getters
  WorkoutState get state => _state;
  MovementPhase get phase => _repCounter.stateMachine.currentPhase;
  CalibrationResult? get calibrationResult => _lastCalibrationResult;
  double get currentAngle => _currentAngle;
  double get targetAngle => exercise.targetAngles.targetAngle;
  double get startAngle => exercise.targetAngles.startAngle;
  double get poseConfidence => _currentConfidence;
  int get currentRep => _repCounter.completedReps;
  int get targetReps => exercise.repetitionTarget;
  int get currentSet => _setManager.currentSetIndex;
  int get targetSets => exercise.setTarget;
  int get elapsedSeconds => _workoutElapsedSeconds;
  int get restSecondsRemaining => _restTimer.secondsRemaining;
  double get holdProgress => _repCounter.stateMachine.holdProgress;
  VoiceCoach get voiceCoach => _voiceCoach;
  WorkoutSummary? get summaryResult => _summaryResult;
  List<RecordedFrame> get recordedFrames => _recorder.recordedFrames;

  // Developer getters
  double get lastFrameProcessingTimeMs => _lastFrameProcessingTimeMs;
  int get landmarkCount => _landmarkCount;
  int get fps => _fps;

  void _initEngine() {
    _stateMachine = MovementStateMachine(
      startAngle: exercise.targetAngles.startAngle,
      targetAngle: exercise.targetAngles.targetAngle,
      tolerance: exercise.tolerance,
      requiredHoldSeconds: exercise.holdDuration.toDouble(),
    );

    _repCounter = RepCounter(
      stateMachine: _stateMachine,
      targetAngle: exercise.targetAngles.targetAngle,
      startAngle: exercise.targetAngles.startAngle,
    );

    _setManager = SetManager(
      totalSetsTarget: exercise.setTarget,
      targetRepsPerSet: exercise.repetitionTarget,
      restSecondsBetweenSets: exercise.restDuration,
    );
  }

  void startCalibration() {
    _state = WorkoutState.calibrating;
    _voiceCoach.speak('Posisikan tubuh Anda di depan kamera untuk kalibrasi.', priority: CoachPriority.high);
  }

  /// Memproses frame pose yang diterima dari sensor kamera ML Kit.
  void processCameraFrame(List<PoseLandmarkModel> landmarks, double calculatedAngle) {
    final startTime = DateTime.now();

    // FPS Calculation
    _frameCount++;
    final fpsElapsed = startTime.difference(_lastFpsTime).inMilliseconds;
    if (fpsElapsed >= 1000) {
      _fps = ((_frameCount * 1000) / fpsElapsed).round();
      _frameCount = 0;
      _lastFpsTime = startTime;
    }

    _landmarkCount = landmarks.length;
    _currentAngle = calculatedAngle;

    if (landmarks.isNotEmpty) {
      _currentConfidence = landmarks.fold(0.0, (sum, l) => sum + l.likelihood) / landmarks.length;
    } else {
      _currentConfidence = 0.0;
    }

    switch (_state) {
      case WorkoutState.calibrating:
        _lastCalibrationResult = WorkoutValidator.validateCalibration(landmarks);
        if (_lastCalibrationResult!.isReady) {
          _state = WorkoutState.ready;
          _voiceCoach.speak('Kalibrasi Sempurna. Bersiaplah!', priority: CoachPriority.high);
        } else {
          _voiceCoach.speak(_lastCalibrationResult!.instructionMessage, priority: CoachPriority.low);
        }
        break;

      case WorkoutState.workout:
        final now = DateTime.now();

        // 1. Process Rep State Machine
        final WorkoutRep? completedRep = _repCounter.processAngle(calculatedAngle, now);

        // 2. Record telemetry frame
        _recorder.recordFrame(
          currentAngle: calculatedAngle,
          targetAngle: exercise.targetAngles.targetAngle,
          phase: phase,
          state: _state,
          confidence: _currentConfidence,
          repIndex: _repCounter.completedReps,
          setIndex: _setManager.currentSetIndex,
          landmarks: landmarks,
        );

        // 3. Evaluate Realtime Feedback
        _provideRealtimeCoachFeedback(calculatedAngle, phase);

        // 4. Handle Rep Completion
        if (completedRep != null) {
          _voiceCoach.speak(
            'Repetisi ${_repCounter.completedReps} bagus!',
            priority: CoachPriority.high,
            force: true,
          );

          final setResult = _setManager.onRepCompleted(completedRep);
          if (setResult != null && setResult.isCompleted) {
            _handleSetCompleted(setResult.hasNextSet);
          }
        }
        break;

      default:
        break;
    }

    _lastFrameProcessingTimeMs = DateTime.now().difference(startTime).inMicroseconds / 1000.0;
  }

  void _provideRealtimeCoachFeedback(double angle, MovementPhase phase) {
    switch (phase) {
      case MovementPhase.movingUp:
        if (angle < exercise.targetAngles.targetAngle - 30) {
          _voiceCoach.speak('Naikkan sedikit lagi', priority: CoachPriority.medium);
        }
        break;
      case MovementPhase.hold:
        _voiceCoach.speak('Tahan posisi puncak', priority: CoachPriority.medium);
        break;
      case MovementPhase.movingDown:
        _voiceCoach.speak('Turunkan perlahan', priority: CoachPriority.medium);
        break;
      default:
        break;
    }
  }

  void _handleSetCompleted(bool hasNextSet) {
    if (hasNextSet) {
      _state = WorkoutState.rest;
      _voiceCoach.speak(
        'Set ${_setManager.currentSetIndex - 1} selesai! Istirahat ${exercise.restDuration} detik.',
        priority: CoachPriority.high,
        force: true,
      );

      _restTimer.startRest(
        exercise.restDuration,
        onTick: (_) {},
        onFinished: () {
          _resumeNextSet();
        },
      );
    } else {
      finishWorkout();
    }
  }

  void skipRest() {
    _restTimer.skipRest(onFinished: () {
      _resumeNextSet();
    });
  }

  void _resumeNextSet() {
    _state = WorkoutState.workout;
    _repCounter.reset();
    _voiceCoach.speak('Mulai set ${_setManager.currentSetIndex}!', priority: CoachPriority.high, force: true);
  }

  void startWorkoutAfterCountdown() {
    _state = WorkoutState.workout;
    _sessionStartTime = DateTime.now();
    _logger.info('Sesi latihan dimulai pada $_sessionStartTime', category: 'SESSION_ENGINE');
    _recorder.startRecording();
    _startSessionTimer();
    _voiceCoach.speak('Mulai latihan!', priority: CoachPriority.high, force: true);
  }

  void _startSessionTimer() {
    _sessionDurationTimer?.cancel();
    _sessionDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state == WorkoutState.workout) {
        _workoutElapsedSeconds += 1;
      }
    });
  }

  void pauseWorkout() {
    if (_state == WorkoutState.workout) {
      _state = WorkoutState.paused;
      _voiceCoach.speak('Latihan di-pause', priority: CoachPriority.high);
    }
  }

  void resumeWorkout() {
    if (_state == WorkoutState.paused) {
      _state = WorkoutState.workout;
      _voiceCoach.speak('Melanjutkan latihan', priority: CoachPriority.high);
    }
  }

  void finishWorkout() {
    _state = WorkoutState.completed;
    _sessionDurationTimer?.cancel();
    _recorder.stopRecording();

    _summaryResult = WorkoutSummaryEngine.generateSummary(
      sessionId: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      totalDurationSeconds: _workoutElapsedSeconds,
      estimatedCaloriesPerMin: exercise.estimatedCalories > 0 ? exercise.estimatedCalories : 4.5,
      completedSets: _setManager.completedSets,
      frames: _recorder.recordedFrames,
      targetROM: (exercise.targetAngles.targetAngle - exercise.targetAngles.startAngle).abs(),
    );

    _voiceCoach.speak(
      'Latihan selesai! Skor Anda ${_summaryResult!.score.totalScore.round()}. Kerja bagus!',
      priority: CoachPriority.emergency,
      force: true,
    );
  }

  void cancelWorkout() {
    _state = WorkoutState.cancelled;
    _sessionDurationTimer?.cancel();
    _restTimer.cancel();
    _recorder.stopRecording();
    _voiceCoach.speak('Latihan dibatalkan', priority: CoachPriority.high);
  }

  void dispose() {
    _sessionDurationTimer?.cancel();
    _restTimer.cancel();
    _voiceCoach.stop();
  }
}
