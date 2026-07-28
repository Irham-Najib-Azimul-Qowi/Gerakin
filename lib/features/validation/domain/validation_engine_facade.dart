import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../camera/models/detected_pose.dart';
import '../../motion/models/body_posture.dart';

import '../models/calibration_status.dart';
import '../models/recorded_session.dart';
import '../models/validation_metrics.dart';
import '../services/baseline_pose_service.dart';
import '../services/calibration_service.dart';
import '../services/camera_quality_service.dart';
import '../services/confidence_filter.dart';
import '../services/distance_estimator.dart';
import '../services/error_logger.dart';
import '../services/landmark_stability_analyzer.dart';
import '../services/lighting_analyzer.dart';
import '../services/performance_monitor.dart';
import '../services/pose_quality_evaluator.dart';
import '../services/session_recorder.dart';
import '../services/session_replay.dart';

/// Class pembungkus State Validasi untuk UI & Validation Dashboard.
class ValidationState {
  const ValidationState({
    required this.calibrationStatus,
    required this.metrics,
    required this.isRecording,
    required this.isReplaying,
    this.recordedSession,
  });

  final CalibrationStatus calibrationStatus;
  final ValidationMetrics metrics;
  final bool isRecording;
  final bool isReplaying;
  final RecordedSession? recordedSession;

  factory ValidationState.initial() {
    return ValidationState(
      calibrationStatus: CalibrationStatus.initial(),
      metrics: ValidationMetrics.initial(),
      isRecording: false,
      isReplaying: false,
    );
  }
}

/// Riverpod Provider untuk [ValidationEngineFacade].
final validationEngineProvider =
    NotifierProvider<ValidationEngineFacade, ValidationState>(
  ValidationEngineFacade.new,
);

/// Facade Controller utama pengelola AI Validation & Calibration System.
class ValidationEngineFacade extends Notifier<ValidationState> {
  ValidationEngineFacade({
    ConfidenceFilter? confidenceFilter,
    LandmarkStabilityAnalyzer? stabilityAnalyzer,
    DistanceEstimator? distanceEstimator,
    LightingAnalyzer? lightingAnalyzer,
    CameraQualityService? cameraQualityService,
    PoseQualityEvaluator? poseQualityEvaluator,
    BaselinePoseService? baselinePoseService,
    CalibrationService? calibrationService,
    SessionRecorder? sessionRecorder,
    SessionReplay? sessionReplay,
    PerformanceMonitor? performanceMonitor,
    ErrorLogger? errorLogger,
  })  : _confidenceFilter = confidenceFilter ?? const ConfidenceFilter(),
        _stabilityAnalyzer = stabilityAnalyzer ?? LandmarkStabilityAnalyzer(),
        _distanceEstimator = distanceEstimator ?? const DistanceEstimator(),
        _lightingAnalyzer = lightingAnalyzer ?? const LightingAnalyzer(),
        _cameraQualityService = cameraQualityService ?? const CameraQualityService(),
        _poseQualityEvaluator = poseQualityEvaluator ?? const PoseQualityEvaluator(),
        _baselinePoseService = baselinePoseService ?? BaselinePoseService(),
        _calibrationService = calibrationService ?? CalibrationService(),
        _sessionRecorder = sessionRecorder ?? SessionRecorder(),
        _sessionReplay = sessionReplay ?? SessionReplay(),
        _performanceMonitor = performanceMonitor ?? PerformanceMonitor(),
        _errorLogger = errorLogger ?? ErrorLogger();

  final ConfidenceFilter _confidenceFilter;
  final LandmarkStabilityAnalyzer _stabilityAnalyzer;
  final DistanceEstimator _distanceEstimator;
  final LightingAnalyzer _lightingAnalyzer;
  final CameraQualityService _cameraQualityService;
  final PoseQualityEvaluator _poseQualityEvaluator;
  final BaselinePoseService _baselinePoseService;
  final CalibrationService _calibrationService;
  final SessionRecorder _sessionRecorder;
  final SessionReplay _sessionReplay;
  final PerformanceMonitor _performanceMonitor;
  final ErrorLogger _errorLogger;

  CameraQualityService get cameraQualityService => _cameraQualityService;
  BaselinePoseService get baselinePoseService => _baselinePoseService;
  ErrorLogger get errorLogger => _errorLogger;

  @override
  ValidationState build() {
    return ValidationState.initial();
  }

  /// Memproses frame real-time dan memperbarui seluruh 9 metrik AI Validation Dashboard.
  void processFrame({
    required DetectedPose pose,
    required BodyPosture posture,
    required double currentShoulderAngle,
    required double currentElbowAngle,
    double frameProcessingTimeMs = 16.0,
  }) {
    _performanceMonitor.recordFrameProcessing(frameProcessingTimeMs);

    final filteredPose = _confidenceFilter.filterPose(pose);
    final stability = _stabilityAnalyzer.addPoseAndComputeStability(filteredPose);
    final distance = _distanceEstimator.estimateDistanceMeters(filteredPose);
    final lighting = _lightingAnalyzer.analyzeLightingScore(filteredPose);
    final poseQuality = _poseQualityEvaluator.evaluatePoseQuality(
      pose: filteredPose,
      posture: posture,
    );

    // Update Kalibrasi
    final calibStatus = _calibrationService.processCalibrationFrame(
      pose: filteredPose,
      posture: posture,
    );

    // Hitung rata-rata confidence pose
    double totalConfidence = 0.0;
    for (final l in pose.landmarks.values) {
      totalConfidence += l.likelihood;
    }
    final avgConfidence = pose.landmarks.isNotEmpty
        ? totalConfidence / pose.landmarks.length
        : 0.9;

    // Rekam jika sedang merekam
    if (_sessionRecorder.isRecording) {
      _sessionRecorder.recordFrame(
        shoulderAngle: currentShoulderAngle,
        elbowAngle: currentElbowAngle,
        confidence: avgConfidence,
        validationStatus: calibStatus.step.name,
      );
    }

    final newMetrics = ValidationMetrics(
      fps: double.parse(_performanceMonitor.currentFps.toStringAsFixed(1)),
      processingTimeMs: double.parse(_performanceMonitor.lastProcessingTimeMs.toStringAsFixed(1)),
      poseConfidence: double.parse((avgConfidence * 100.0).toStringAsFixed(1)),
      trackingStability: double.parse(stability.toStringAsFixed(1)),
      cameraDistanceMeters: distance,
      lightingScore: lighting,
      poseQualityScore: poseQuality,
      latencyMs: double.parse(_performanceMonitor.totalLatencyMs.toStringAsFixed(1)),
      currentRom: currentShoulderAngle,
    );

    state = ValidationState(
      calibrationStatus: calibStatus,
      metrics: newMetrics,
      isRecording: _sessionRecorder.isRecording,
      isReplaying: _sessionReplay.isPlaying,
      recordedSession: state.recordedSession,
    );
  }

  /// Mulai merekam sesi latihan.
  void startRecording(String exerciseId) {
    _sessionRecorder.startRecording(exerciseId);
    state = ValidationState(
      calibrationStatus: state.calibrationStatus,
      metrics: state.metrics,
      isRecording: true,
      isReplaying: false,
      recordedSession: state.recordedSession,
    );
  }

  /// Selesai merekam sesi latihan.
  RecordedSession? stopRecording() {
    final recorded = _sessionRecorder.stopRecording();
    state = ValidationState(
      calibrationStatus: state.calibrationStatus,
      metrics: state.metrics,
      isRecording: false,
      isReplaying: false,
      recordedSession: recorded,
    );
    return recorded;
  }

  /// Memulai replay tanpa kamera dari rekaman [session].
  void startReplay(RecordedSession session) {
    _sessionReplay.loadSession(session);
    _sessionReplay.startReplay();
    state = ValidationState(
      calibrationStatus: state.calibrationStatus,
      metrics: state.metrics,
      isRecording: false,
      isReplaying: true,
      recordedSession: session,
    );
  }
}
