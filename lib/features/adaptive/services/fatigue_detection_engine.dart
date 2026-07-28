import '../../motion/models/motion_analysis.dart';
import '../../motion/models/motion_validation.dart';
import '../models/fatigue_status.dart';

/// Engine pendeteksi kelelahan otot (Fatigue Detection Engine).
class FatigueDetectionEngine {
  FatigueDetectionEngine();

  int _totalFrames = 0;
  int _slowVelocityFrames = 0;
  int _postureFaultFrames = 0;

  /// Memproses kelelahan dari sampel frame [analysis] dan kecepatan sudut.
  FatigueStatus processFrame({
    required MotionAnalysis analysis,
    double? angularVelocityDegPerSec,
  }) {
    _totalFrames++;

    if (analysis.validationStatus == MotionValidationStatus.tooSlow) {
      _slowVelocityFrames++;
    }

    if (!analysis.posture.isShoulderSymmetric) {
      _postureFaultFrames++;
    }

    if (_totalFrames == 0) {
      return FatigueStatus.fresh();
    }

    final slowRatio = _slowVelocityFrames / _totalFrames;
    final faultRatio = _postureFaultFrames / _totalFrames;

    final degradationPercentage = ((slowRatio * 0.6 + faultRatio * 0.4) * 100.0).clamp(0.0, 100.0);
    final fatigueScore = degradationPercentage;

    FatigueLevel level = FatigueLevel.none;
    bool recommendRest = false;

    if (fatigueScore >= 75.0) {
      level = FatigueLevel.severe;
      recommendRest = true;
    } else if (fatigueScore >= 50.0) {
      level = FatigueLevel.moderate;
      recommendRest = true;
    } else if (fatigueScore >= 25.0) {
      level = FatigueLevel.mild;
      recommendRest = false;
    } else {
      level = FatigueLevel.none;
      recommendRest = false;
    }

    return FatigueStatus(
      level: level,
      fatigueScore: fatigueScore,
      degradationPercentage: degradationPercentage,
      recommendRest: recommendRest,
    );
  }

  /// Reset counter kelelahan.
  void reset() {
    _totalFrames = 0;
    _slowVelocityFrames = 0;
    _postureFaultFrames = 0;
  }
}
