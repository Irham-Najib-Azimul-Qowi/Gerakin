import '../../camera/models/detected_pose.dart';
import '../../motion/models/body_posture.dart';

/// Evaluator skor kualitas deteksi pose secara keseluruhan (Pose Quality 0–100%).
class PoseQualityEvaluator {
  const PoseQualityEvaluator();

  /// Menghitung skor kualitas pose dari confidence, kelengkapan sendi, dan kesimetrisan.
  double evaluatePoseQuality({
    required DetectedPose pose,
    required BodyPosture posture,
  }) {
    if (pose.landmarks.isEmpty) return 0.0;

    double totalConfidence = 0.0;
    for (final landmark in pose.landmarks.values) {
      totalConfidence += landmark.likelihood;
    }

    final avgConfidence = totalConfidence / pose.landmarks.length;
    final confidenceComponent = (avgConfidence * 100.0) * 0.5;
    final symmetryComponent = posture.isShoulderSymmetric ? 30.0 : 15.0;
    final countComponent = (pose.landmarks.length / 33.0 * 20.0).clamp(0.0, 20.0);

    final totalScore = (confidenceComponent + symmetryComponent + countComponent).clamp(0.0, 100.0);
    return double.parse(totalScore.toStringAsFixed(1));
  }
}
