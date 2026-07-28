import '../../motion/models/motion_analysis.dart';
import '../../motion/models/motion_validation.dart';
import '../models/safety_status.dart';

/// Engine pemantau keselamatan fisik (Safety Engine).
class SafetyEngine {
  const SafetyEngine();

  /// Menganalisis status keselamatan dari [MotionAnalysis] saat ini.
  SafetyStatus evaluateSafety(MotionAnalysis motion) {
    double score = 100.0;
    final warnings = <String>[];

    if (motion.validationStatus == MotionValidationStatus.outOfRange) {
      score -= 50.0;
      warnings.add('Tubuh berada di luar jangkauan kamera!');
    }

    if (motion.validationStatus == MotionValidationStatus.tooFast) {
      score -= 30.0;
      warnings.add('Kecepatan ekstrem! Risiko cedera sendi');
    }

    if (!motion.posture.isShoulderSymmetric) {
      score -= 20.0;
      warnings.add('Ketidakseimbangan simetri bahu cukup besar');
    }

    final finalScore = score.clamp(0.0, 100.0);
    final isSafe = finalScore >= 60.0;
    final shouldStop = finalScore < 40.0;

    return SafetyStatus(
      safetyScore: finalScore,
      isSafe: isSafe,
      activeWarnings: warnings,
      shouldStopWorkout: shouldStop,
    );
  }
}
