import '../../camera/models/detected_pose.dart';

/// Analyzer estimasi kualitas pencahayaan lingkungan (Lighting Score).
class LightingAnalyzer {
  const LightingAnalyzer();

  /// Menghitung skor pencahayaan (0.0 s/d 100.0%) dari rata-rata tingkat kepercayaan landmark.
  double analyzeLightingScore(DetectedPose pose) {
    if (pose.landmarks.isEmpty) return 50.0;

    double totalConfidence = 0.0;
    for (final landmark in pose.landmarks.values) {
      totalConfidence += landmark.likelihood;
    }

    final avgLikelihood = totalConfidence / pose.landmarks.length;
    final lightingScore = (avgLikelihood * 100.0).clamp(30.0, 100.0);
    return double.parse(lightingScore.toStringAsFixed(1));
  }
}
