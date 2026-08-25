import 'package:flutter_riverpod/legacy.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../services/workout_session_engine.dart';
import '../models/workout_state.dart';
import '../models/movement_phase.dart';
import '../models/workout_summary.dart';
import '../models/workout_session.dart';
import '../models/live_alert.dart';
import '../repository/workout_session_repository.dart';
import '../../exercise_library/models/full_exercise_definition.dart';
import '../../camera/models/pose_landmark_model.dart';
import '../../motion/services/joint_angle_calculator.dart';
import '../../motion/models/joint_angle.dart';
import '../../gamification/services/streak_engine.dart';
import '../../gamification/services/xp_engine.dart';
import '../../gamification/services/level_engine.dart';
import '../../gamification/services/gamification_providers.dart';
import '../../user/domain/repositories/user_repository.dart';
import '../../user/data/repositories/user_repository_impl.dart';

/// State snapshot untuk UI Workout Session.
class WorkoutSessionUIState {
  const WorkoutSessionUIState({
    required this.exercise,
    this.workoutState = WorkoutState.idle,
    this.movementPhase = MovementPhase.idle,
    this.currentAngle = 0.0,
    this.targetAngle = 180.0,
    this.poseConfidence = 0.0,
    this.currentRep = 0,
    this.targetReps = 10,
    this.currentSet = 1,
    this.targetSets = 3,
    this.elapsedSeconds = 0,
    this.restSecondsRemaining = 0,
    this.holdProgress = 0.0,
    this.isDevModeEnabled = false,
    this.isMuted = false,
    this.calibrationInstruction = 'Posisikan tubuh Anda',
    this.isCalibrationReady = false,
    this.currentCoachMessage = 'Posisikan tubuh Anda di depan kamera untuk kalibrasi.',
    this.activeAlert,
    this.summary,
    this.landmarks = const [],
    this.fps = 0,
    this.lastProcessingTimeMs = 0.0,
  });

  final FullExerciseDefinition exercise;
  final WorkoutState workoutState;
  final MovementPhase movementPhase;
  final double currentAngle;
  final double targetAngle;
  final double poseConfidence;
  final int currentRep;
  final int targetReps;
  final int currentSet;
  final int targetSets;
  final int elapsedSeconds;
  final int restSecondsRemaining;
  final double holdProgress;
  final bool isDevModeEnabled;
  final bool isMuted;
  final String calibrationInstruction;
  final bool isCalibrationReady;
  final String currentCoachMessage;
  final LiveAlert? activeAlert;
  final WorkoutSummary? summary;
  final List<PoseLandmarkModel> landmarks;
  final int fps;
  final double lastProcessingTimeMs;

  WorkoutSessionUIState copyWith({
    FullExerciseDefinition? exercise,
    WorkoutState? workoutState,
    MovementPhase? movementPhase,
    double? currentAngle,
    double? targetAngle,
    double? poseConfidence,
    int? currentRep,
    int? targetReps,
    int? currentSet,
    int? targetSets,
    int? elapsedSeconds,
    int? restSecondsRemaining,
    double? holdProgress,
    bool? isDevModeEnabled,
    bool? isMuted,
    String? calibrationInstruction,
    bool? isCalibrationReady,
    String? currentCoachMessage,
    LiveAlert? activeAlert,
    bool clearAlert = false,
    WorkoutSummary? summary,
    List<PoseLandmarkModel>? landmarks,
    int? fps,
    double? lastProcessingTimeMs,
  }) {
    return WorkoutSessionUIState(
      exercise: exercise ?? this.exercise,
      workoutState: workoutState ?? this.workoutState,
      movementPhase: movementPhase ?? this.movementPhase,
      currentAngle: currentAngle ?? this.currentAngle,
      targetAngle: targetAngle ?? this.targetAngle,
      poseConfidence: poseConfidence ?? this.poseConfidence,
      currentRep: currentRep ?? this.currentRep,
      targetReps: targetReps ?? this.targetReps,
      currentSet: currentSet ?? this.currentSet,
      targetSets: targetSets ?? this.targetSets,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
      holdProgress: holdProgress ?? this.holdProgress,
      isDevModeEnabled: isDevModeEnabled ?? this.isDevModeEnabled,
      isMuted: isMuted ?? this.isMuted,
      calibrationInstruction: calibrationInstruction ?? this.calibrationInstruction,
      isCalibrationReady: isCalibrationReady ?? this.isCalibrationReady,
      currentCoachMessage: currentCoachMessage ?? this.currentCoachMessage,
      activeAlert: clearAlert ? null : (activeAlert ?? this.activeAlert),
      summary: summary ?? this.summary,
      landmarks: landmarks ?? this.landmarks,
      fps: fps ?? this.fps,
      lastProcessingTimeMs: lastProcessingTimeMs ?? this.lastProcessingTimeMs,
    );
  }
}

/// StateNotifier Controller Riverpod untuk mengelola Workout Session UI & Engine.
class WorkoutSessionController extends StateNotifier<WorkoutSessionUIState> {
  WorkoutSessionController({
    required FullExerciseDefinition initialExercise,
    required this.repository,
    this.streakEngine,
    this.xpEngine,
    this.levelEngine,
    this.userRepository,
  })  : _engine = WorkoutSessionEngine(exercise: initialExercise),
        super(WorkoutSessionUIState(
          exercise: initialExercise,
          targetAngle: initialExercise.targetAngles.targetAngle,
          targetReps: initialExercise.repetitionTarget,
          targetSets: initialExercise.setTarget,
        ));

  final WorkoutSessionEngine _engine;
  final WorkoutSessionRepository repository;
  final StreakEngine? streakEngine;
  final XPEngine? xpEngine;
  final LevelEngine? levelEngine;
  final UserRepository? userRepository;

  WorkoutSessionEngine get engine => _engine;

  void toggleDevMode() {
    state = state.copyWith(isDevModeEnabled: !state.isDevModeEnabled);
  }

  void toggleMute() {
    _engine.voiceCoach.toggleMute();
    state = state.copyWith(isMuted: _engine.voiceCoach.isMuted);
  }

  void startCalibration() {
    _engine.startCalibration();
    state = state.copyWith(workoutState: _engine.state);
  }

  void startCountdown() {
    state = state.copyWith(workoutState: WorkoutState.countdown);
  }

  void startCountdownComplete() {
    _engine.startWorkoutAfterCountdown();
    _updateUI();
  }

  void processFrame(List<PoseLandmarkModel> landmarks) {
    if (landmarks.isEmpty) return;

    final jointType = state.exercise.targetAngles.primaryJoint;
    final calculatedAngle = _calculatePrimaryAngle(landmarks, jointType);

    _engine.processCameraFrame(landmarks, calculatedAngle);
    _updateUI(landmarks: landmarks);
  }

  double _calculatePrimaryAngle(List<PoseLandmarkModel> landmarks, JointType jointType) {
    final lmMap = {for (var l in landmarks) l.type: l};
    switch (jointType) {
      case JointType.leftElbow:
        final angle = JointAngleCalculator.calculateJointAngle(
          type: JointType.leftElbow,
          firstLandmark: lmMap[PoseLandmarkType.leftShoulder],
          vertexLandmark: lmMap[PoseLandmarkType.leftElbow],
          lastLandmark: lmMap[PoseLandmarkType.leftWrist],
        );
        return angle?.angle ?? 90.0;

      case JointType.rightElbow:
        final angle = JointAngleCalculator.calculateJointAngle(
          type: JointType.rightElbow,
          firstLandmark: lmMap[PoseLandmarkType.rightShoulder],
          vertexLandmark: lmMap[PoseLandmarkType.rightElbow],
          lastLandmark: lmMap[PoseLandmarkType.rightWrist],
        );
        return angle?.angle ?? 90.0;

      case JointType.leftShoulder:
        final angle = JointAngleCalculator.calculateJointAngle(
          type: JointType.leftShoulder,
          firstLandmark: lmMap[PoseLandmarkType.leftHip],
          vertexLandmark: lmMap[PoseLandmarkType.leftShoulder],
          lastLandmark: lmMap[PoseLandmarkType.leftElbow],
        );
        return angle?.angle ?? 0.0;

      case JointType.rightShoulder:
        final angle = JointAngleCalculator.calculateJointAngle(
          type: JointType.rightShoulder,
          firstLandmark: lmMap[PoseLandmarkType.rightHip],
          vertexLandmark: lmMap[PoseLandmarkType.rightShoulder],
          lastLandmark: lmMap[PoseLandmarkType.rightElbow],
        );
        return angle?.angle ?? 0.0;

      case JointType.leftKnee:
        final angle = JointAngleCalculator.calculateJointAngle(
          type: JointType.leftKnee,
          firstLandmark: lmMap[PoseLandmarkType.leftHip],
          vertexLandmark: lmMap[PoseLandmarkType.leftKnee],
          lastLandmark: lmMap[PoseLandmarkType.leftAnkle],
        );
        return angle?.angle ?? 180.0;

      case JointType.rightKnee:
        final angle = JointAngleCalculator.calculateJointAngle(
          type: JointType.rightKnee,
          firstLandmark: lmMap[PoseLandmarkType.rightHip],
          vertexLandmark: lmMap[PoseLandmarkType.rightKnee],
          lastLandmark: lmMap[PoseLandmarkType.rightAnkle],
        );
        return angle?.angle ?? 180.0;

      case JointType.neckRotation:
      case JointType.neckFlexion:
        final angle = JointAngleCalculator.calculateNeckAngle(
          type: jointType,
          noseLandmark: lmMap[PoseLandmarkType.nose],
          leftShoulder: lmMap[PoseLandmarkType.leftShoulder],
          rightShoulder: lmMap[PoseLandmarkType.rightShoulder],
        );
        return angle?.angle ?? 0.0;

      default:
        return 90.0;
    }
  }

  void pauseWorkout() {
    _engine.pauseWorkout();
    _updateUI();
  }

  void resumeWorkout() {
    _engine.resumeWorkout();
    _updateUI();
  }

  void skipRest() {
    _engine.skipRest();
    _updateUI();
  }

  Future<void> finishWorkout() async {
    _engine.finishWorkout();
    _updateUI();

    if (_engine.summaryResult != null) {
      final summary = _engine.summaryResult!;
      final sessionData = WorkoutSessionData(
        id: summary.sessionId,
        exerciseId: state.exercise.id,
        exerciseName: state.exercise.name,
        startTime: DateTime.now().subtract(Duration(seconds: _engine.elapsedSeconds)),
        endTime: DateTime.now(),
        totalDurationSeconds: _engine.elapsedSeconds,
        sets: const [],
        summary: summary,
        recordedFrames: _engine.recordedFrames,
      );

      await repository.saveSession(sessionData);

      // Panggil gamification engine setelah sesi berhasil disimpan
      try {
        int userId = 1;
        if (userRepository != null) {
          final activeProfile = await userRepository!.getActiveProfile();
          if (activeProfile != null) {
            userId = activeProfile.id;
          }
        }

        if (streakEngine != null) {
          await streakEngine!.recordActivity(userId);
        }

        if (xpEngine != null) {
          final earnedXp = await xpEngine!.awardXPForWorkout(
            userId: userId,
            accuracy: summary.averageAccuracy,
            consistency: summary.score.consistencyScore,
            completion: 100.0,
          );

          if (levelEngine != null && earnedXp > 0) {
            await levelEngine!.addXP(userId, earnedXp);
          }
        }
      } catch (_) {}
    }
  }

  void cancelWorkout() {
    _engine.cancelWorkout();
    _updateUI();
  }

  void _updateUI({List<PoseLandmarkModel>? landmarks}) {
    final cal = _engine.calibrationResult;
    state = state.copyWith(
      workoutState: _engine.state,
      movementPhase: _engine.phase,
      currentAngle: _engine.currentAngle,
      poseConfidence: _engine.poseConfidence,
      currentRep: _engine.currentRep,
      currentSet: _engine.currentSet,
      elapsedSeconds: _engine.elapsedSeconds,
      restSecondsRemaining: _engine.restSecondsRemaining,
      holdProgress: _engine.holdProgress,
      calibrationInstruction: cal?.instructionMessage ?? 'Posisikan tubuh Anda',
      isCalibrationReady: cal?.isReady ?? false,
      currentCoachMessage: _engine.voiceCoach.lastSpokenText,
      activeAlert: _engine.activeAlert,
      summary: _engine.summaryResult,
      landmarks: landmarks ?? state.landmarks,
      fps: _engine.fps,
      lastProcessingTimeMs: _engine.lastFrameProcessingTimeMs,
    );
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}

final workoutSessionControllerProvider =
    StateNotifierProvider.family<WorkoutSessionController, WorkoutSessionUIState, FullExerciseDefinition>(
  (ref, exercise) {
    final repo = ref.watch(workoutSessionRepositoryProvider);
    final streak = ref.watch(streakEngineProvider);
    final xp = ref.watch(xpEngineProvider);
    final lvl = ref.watch(levelEngineProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    return WorkoutSessionController(
      initialExercise: exercise,
      repository: repo,
      streakEngine: streak,
      xpEngine: xp,
      levelEngine: lvl,
      userRepository: userRepo,
    );
  },
);
