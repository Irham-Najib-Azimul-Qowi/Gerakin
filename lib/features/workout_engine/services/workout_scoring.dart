import '../../motion/models/motion_analysis.dart';
import '../../motion/models/motion_validation.dart';

/// Service penghitung skor akurasi dan kualitas gerakan realtime (Workout Scoring).
class WorkoutScoring {
  WorkoutScoring();

  double _totalAccumulatedScore = 0.0;
  int _frameCount = 0;
  double _currentScore = 100.0;

  /// Skor rata-rata kumulatif (0.0 s/d 100.0).
  double get currentScore => _currentScore;

  /// Menghitung skor untuk frame [analysis] saat ini dan memperbarui rata-rata kumulatif.
  double processFrameScore(MotionAnalysis analysis) {
    double frameScore = 100.0;

    // 1. Penalti berdasarkan validasi gerakan
    switch (analysis.validationStatus) {
      case MotionValidationStatus.valid:
        break;
      case MotionValidationStatus.tooFast:
        frameScore -= 15.0;
        break;
      case MotionValidationStatus.tooSlow:
        frameScore -= 10.0;
        break;
      case MotionValidationStatus.incomplete:
        frameScore -= 10.0;
        break;
      case MotionValidationStatus.outOfRange:
        frameScore -= 25.0;
        break;
    }

    // 2. Penalti postur (misal: simetri bahu miring)
    if (!analysis.posture.isShoulderSymmetric) {
      frameScore -= 10.0;
    }

    final clampedFrameScore = frameScore.clamp(0.0, 100.0);

    _frameCount++;
    _totalAccumulatedScore += clampedFrameScore;
    _currentScore = _totalAccumulatedScore / _frameCount;

    return _currentScore;
  }

  /// Reset skor.
  void reset() {
    _totalAccumulatedScore = 0.0;
    _frameCount = 0;
    _currentScore = 100.0;
  }
}
