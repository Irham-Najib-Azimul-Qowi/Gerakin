import '../models/calibration_status.dart';
import 'baseline_pose_service.dart';
import 'distance_estimator.dart';
import 'lighting_analyzer.dart';

import '../../camera/models/detected_pose.dart';
import '../../motion/models/body_posture.dart';

/// Service pengelola alur kalibrasi pra-latihan (Calibration Service).
class CalibrationService {
  CalibrationService({
    LightingAnalyzer? lightingAnalyzer,
    DistanceEstimator? distanceEstimator,
    BaselinePoseService? baselineService,
  })  : _lightingAnalyzer = lightingAnalyzer ?? const LightingAnalyzer(),
        _distanceEstimator = distanceEstimator ?? const DistanceEstimator(),
        _baselineService = baselineService ?? BaselinePoseService();

  final LightingAnalyzer _lightingAnalyzer;
  final DistanceEstimator _distanceEstimator;
  final BaselinePoseService _baselineService;

  CalibrationStatus _currentStatus = CalibrationStatus.initial();

  CalibrationStatus get currentStatus => _currentStatus;

  /// Menjalankan langkah kalibrasi berikutnya berdasarkan pose saat ini.
  CalibrationStatus processCalibrationFrame({
    required DetectedPose pose,
    required BodyPosture posture,
  }) {
    // 1. Cek Pencahayaan
    final lighting = _lightingAnalyzer.analyzeLightingScore(pose);
    if (lighting < 50.0) {
      _currentStatus = const CalibrationStatus(
        step: CalibrationStep.checkingEnvironment,
        progressPercentage: 25.0,
        statusMessage: 'Pencahayaan kurang. Pindahlah ke area yang lebih terang.',
      );
      return _currentStatus;
    }

    // 2. Cek Jarak Kamera
    final distance = _distanceEstimator.estimateDistanceMeters(pose);
    if (distance < 1.2 || distance > 3.5) {
      _currentStatus = CalibrationStatus(
        step: CalibrationStep.checkingDistance,
        progressPercentage: 50.0,
        statusMessage: 'Sesuaikan jarak ke kamera (Jarak ideal 1.5 - 2.5m). Jarak saat ini: ${distance}m',
      );
      return _currentStatus;
    }

    // 3. Cek Pose Baseline
    final isBaselineOk = _baselineService.verifyAndCaptureBaseline(
      pose: pose,
      posture: posture,
    );

    if (!isBaselineOk) {
      _currentStatus = const CalibrationStatus(
        step: CalibrationStep.checkingBaseline,
        progressPercentage: 75.0,
        statusMessage:
            'Posisikan tubuh Anda tegak lurus menghadap kamera dari kursi roda untuk mengambil sampel baseline.',
      );
      return _currentStatus;
    }

    // 4. Selesai
    _currentStatus = const CalibrationStatus(
      step: CalibrationStep.completed,
      progressPercentage: 100.0,
      statusMessage: 'Kalibrasi Berhasil! Siap memulai latihan.',
    );

    return _currentStatus;
  }

  void reset() {
    _baselineService.reset();
    _currentStatus = CalibrationStatus.initial();
  }
}
