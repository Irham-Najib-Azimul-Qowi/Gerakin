import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../domain/exercise_config.dart';
import '../domain/exercise_phase.dart';
import '../domain/exercise_result.dart';
import '../domain/exercise_type.dart';
import '../domain/movement_feedback.dart';
import '../logic/angle_calculator.dart';
import '../logic/exercise_tts_service.dart';
import '../logic/movement_quality_engine.dart';
import '../logic/repetition_counter.dart';
import '../logic/seated_posture_validator.dart';
import '../../camera/models/pose_landmark_model.dart';

/// Class abstrak Engine dasar pemrosesan pose & analisis sesi latihan.
abstract class BaseExerciseEngine extends ChangeNotifier {
  BaseExerciseEngine({
    required this.config,
    ExerciseTtsService? ttsService,
    MovementQualityEngine? qualityEngine,
  })  : _ttsService = ttsService ?? FlutterExerciseTtsService(),
        _qualityEngine = qualityEngine ?? const MovementQualityEngine(),
        _repCounter = RepetitionCounter(
          targetReps: config.targetRepsPerSet,
          minRepDurationMs: config.minRepDurationMs,
          hysteresisTolerance: config.hysteresisTolerance,
        );

  final ExerciseConfig config;
  final ExerciseTtsService _ttsService;
  final MovementQualityEngine _qualityEngine;
  final RepetitionCounter _repCounter;
  final SeatedPostureValidator _postureValidator = SeatedPostureValidator();

  final EmaSmoother angleSmoother = EmaSmoother(alpha: 0.35);

  bool _isCalibrated = false;
  bool _isPaused = false;
  bool _isCompleted = false;
  bool _isResting = false;
  int _currentSet = 1;
  int _restSecondsRemaining = 0;
  DateTime? _lastStandingAlertTime;

  double _currentPrimaryAngle = 0.0;
  double _currentAccuracy = 0.0;
  double _accumulatedAccuracySum = 0.0;
  int _accuracySampleCount = 0;
  int _totalCorrectionsCount = 0;

  DateTime? _sessionStartTime;
  DateTime? _sessionEndTime;

  MovementFeedback? _currentFeedback;
  Map<PoseLandmarkType, PoseLandmarkModel> _activeLandmarks = {};
  final List<RepResult> _completedRepResults = [];

  // Getters
  ExerciseType get exerciseType => config.exerciseType;
  bool get isCalibrated => _isCalibrated;
  bool get isPaused => _isPaused;
  bool get isCompleted => _isCompleted;
  bool get isResting => _isResting;
  int get currentSet => _currentSet;
  int get totalSets => config.targetSets;
  int get completedReps => _repCounter.completedReps;
  int get targetReps => config.targetRepsPerSet;
  int get restSecondsRemaining => _restSecondsRemaining;
  UserPostureState get postureState => _postureValidator.currentState;

  MovementPhase get currentPhase => _repCounter.currentPhase;
  double get currentPrimaryAngle => _currentPrimaryAngle;
  double get currentAccuracy => _currentAccuracy;
  double get averageAccuracy => _accuracySampleCount > 0
      ? (_accumulatedAccuracySum / _accuracySampleCount).clamp(0.0, 100.0)
      : 100.0;

  MovementFeedback? get currentFeedback => _currentFeedback;
  Map<PoseLandmarkType, PoseLandmarkModel> get activeLandmarks => _activeLandmarks;
  ExerciseTtsService get ttsService => _ttsService;

  /// Memeriksa keandalan landmark utama
  bool isLandmarkReliable(PoseLandmarkModel? landmark) {
    return landmark != null && landmark.likelihood >= config.minLandmarkLikelihood;
  }

  /// Memproses frame pose yang diterima dari stream kamera real-time
  void processFrame(List<PoseLandmarkModel> landmarks) {
    if (_isPaused || _isCompleted || _isResting) return;

    _sessionStartTime ??= DateTime.now();

    // Map landmark untuk kemudahan pencarian
    _activeLandmarks = {for (final l in landmarks) l.type: l};

    // 0. Evaluasi Postur Duduk vs. Berdiri (SeatedPostureValidator)
    final postureResult = _postureValidator.evaluate(_activeLandmarks);
    if (postureResult.state == UserPostureState.standing) {
      _currentFeedback = MovementFeedback.correction(postureResult.message);

      final now = DateTime.now();
      if (_lastStandingAlertTime == null ||
          now.difference(_lastStandingAlertTime!).inSeconds >= 5) {
        _lastStandingAlertTime = now;
        _ttsService.speak('Silakan kembali ke posisi duduk untuk melanjutkan latihan.');
      }

      notifyListeners();
      return; // Jeda analisis gerakan selama posisi tidak sesuai
    }

    // 1. Cek Reliabilitas Landmark Utama yang Dibutuhkan
    if (!checkRequiredLandmarksReliable()) {
      _currentFeedback = MovementFeedback.lowConfidence;
      _ttsService.speak(_currentFeedback!.message, feedback: _currentFeedback);
      notifyListeners();
      return;
    }

    // Posisikan terkalibrasi begitu landmark utama reliable
    if (!_isCalibrated) {
      _isCalibrated = true;
      _currentFeedback = MovementFeedback.ready;
      _ttsService.speak(_currentFeedback!.message, feedback: _currentFeedback);
    }

    // 2. Analisis Sudut Khusus Gerakan Latihan
    final analysisResult = analyzeExerciseMovement();
    final rawAngle = analysisResult.primaryAngle;
    _currentPrimaryAngle = angleSmoother.smooth(rawAngle);

    // 3. Evaluasi Akurasi / Quality Real-Time
    _currentAccuracy = _qualityEngine.calculateAccuracy(
      type: config.exerciseType,
      primaryAngle: _currentPrimaryAngle,
      targetAngle: analysisResult.targetAngle,
      secondaryAngle: analysisResult.secondaryAngle,
      symmetryDifference: analysisResult.symmetryDifference,
      torsoTilt: analysisResult.torsoTilt,
    );

    if (_currentAccuracy > 0) {
      _accumulatedAccuracySum += _currentAccuracy;
      _accuracySampleCount++;
    }

    // 4. Update Umpan Balik Koreksi / Pujian
    if (analysisResult.feedback != null) {
      _currentFeedback = analysisResult.feedback;
      if (_currentFeedback!.category == FeedbackCategory.correction) {
        _totalCorrectionsCount++;
      }
      _ttsService.speak(_currentFeedback!.message, feedback: _currentFeedback);
    } else {
      _currentFeedback = MovementFeedback(
        message: getInstructionTextForPhase(currentPhase),
        category: FeedbackCategory.instruction,
      );
    }

    // 5. Update State Machine Repetition Counter
    final isRepJustCompleted = _repCounter.processAngle(
      currentAngle: _currentPrimaryAngle,
      startThreshold: config.startAngleThreshold,
      middleThreshold: config.middleAngleThreshold,
      targetThreshold: config.targetAngleThreshold,
      isGreaterTarget: analysisResult.isGreaterTarget,
    );

    if (isRepJustCompleted) {
      _completedRepResults.add(RepResult(
        repIndex: _repCounter.completedReps,
        accuracyPercentage: _currentAccuracy,
        durationMs: 1200,
        corrections: analysisResult.feedback != null ? [analysisResult.feedback!.message] : [],
      ));

      _ttsService.speakMilestone(_repCounter.completedReps);

      // Cek apakah Target Repetisi per Set Selesai
      if (_repCounter.isSetComplete) {
        _handleSetCompleted();
      }
    }

    notifyListeners();
  }

  void _handleSetCompleted() {
    if (_currentSet >= config.targetSets) {
      // Seluruh Set Latihan Telah Selesai!
      _isCompleted = true;
      _sessionEndTime = DateTime.now();
      _ttsService.speak('Latihan selesai. Kerja bagus!');
    } else {
      // Masuk Fase Istirahat Antar-Set
      _isResting = true;
      _restSecondsRemaining = config.restDurationSeconds;
      _ttsService.speak('Set ke $_currentSet selesai. Istirahat sebentar.');
      _startRestTimer();
    }
  }

  void _startRestTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isResting) return false;

      _restSecondsRemaining--;
      notifyListeners();

      if (_restSecondsRemaining <= 0) {
        skipRest();
        return false;
      }
      return true;
    });
  }

  void skipRest() {
    _isResting = false;
    _currentSet++;
    _repCounter.resetReps();
    _ttsService.speak('Siap untuk set ke $_currentSet. Mulai!');
    notifyListeners();
  }

  void pause() {
    _isPaused = true;
    _ttsService.stop();
    notifyListeners();
  }

  void resume() {
    _isPaused = false;
    _ttsService.speak('Latihan dilanjutkan.');
    notifyListeners();
  }

  ExerciseSessionSummary generateSummary() {
    final start = _sessionStartTime ?? DateTime.now();
    final end = _sessionEndTime ?? DateTime.now();
    final duration = end.difference(start).inSeconds;

    return ExerciseSessionSummary(
      exerciseType: config.exerciseType,
      startedAt: start,
      endedAt: end,
      completedSets: _currentSet,
      totalSets: config.targetSets,
      completedReps: _completedRepResults.length,
      targetReps: config.targetSets * config.targetRepsPerSet,
      averageAccuracy: averageAccuracy,
      durationInSeconds: duration > 0 ? duration : 1,
      totalCorrectionsCount: _totalCorrectionsCount,
      repDetails: _completedRepResults,
    );
  }

  /// Metode abstrak yang wajib diimplementasikan oleh engine spesifik gerakan
  bool checkRequiredLandmarksReliable();
  AnalysisData analyzeExerciseMovement();
  String getInstructionTextForPhase(MovementPhase phase);
}

/// Data analisis sementara hasil evaluasi frame
class AnalysisData {
  const AnalysisData({
    required this.primaryAngle,
    required this.targetAngle,
    required this.secondaryAngle,
    required this.symmetryDifference,
    required this.torsoTilt,
    this.feedback,
    this.isGreaterTarget = true,
  });

  final double primaryAngle;
  final double targetAngle;
  final double secondaryAngle;
  final double symmetryDifference;
  final double torsoTilt;
  final MovementFeedback? feedback;
  final bool isGreaterTarget;
}
