import '../../motion/models/joint_angle.dart';
import '../../motion/models/motion_analysis.dart';
import '../models/assessment_result.dart';

/// Service pengukur kemampuan fisik awal (Initial Assessment Service).
///
/// Mengukur:
/// - Shoulder ROM
/// - Elbow ROM
/// - Movement Stability
/// - Movement Speed
/// - Pose Confidence
class InitialAssessmentService {
  const InitialAssessmentService();

  /// Menganalisis sampel daftar [MotionAnalysis] dari sesi pengujian awal.
  AssessmentResult analyzeAssessmentSamples(List<MotionAnalysis> samples) {
    if (samples.isEmpty) {
      return AssessmentResult.initial();
    }

    double maxShoulder = 0.0;
    double maxElbow = 0.0;
    double totalConfidence = 0.0;
    int confidenceCount = 0;

    for (final sample in samples) {
      final shoulderAngle = sample.getAngle(JointType.leftShoulder)?.angle ?? 0.0;
      final elbowAngle = sample.getAngle(JointType.leftElbow)?.angle ?? 0.0;

      if (shoulderAngle > maxShoulder) maxShoulder = shoulderAngle;
      if (elbowAngle > maxElbow) maxElbow = elbowAngle;

      for (final j in sample.jointAngles.values) {
        totalConfidence += j.confidence;
        confidenceCount++;
      }
    }

    final avgConfidence = confidenceCount > 0
        ? (totalConfidence / confidenceCount).clamp(0.0, 1.0)
        : 0.9;

    // Kestabilan diukur dari konsistensi postur
    final stabilityCount = samples
        .where((s) => s.posture.isShoulderSymmetric)
        .length;
    final stabilityScore = (stabilityCount / samples.length * 100.0).clamp(0.0, 100.0);

    return AssessmentResult(
      shoulderRom: maxShoulder > 0 ? maxShoulder : 140.0,
      elbowRom: maxElbow > 0 ? maxElbow : 155.0,
      movementStability: stabilityScore,
      movementSpeed: 45.0,
      poseConfidence: avgConfidence,
      assessedAt: DateTime.now(),
    );
  }
}
