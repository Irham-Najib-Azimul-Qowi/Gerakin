import 'dart:math';
import '../../camera/models/detected_pose.dart';

/// Analyzer kestabilan landmark dan pembaca jitter posisi tubuh.
class LandmarkStabilityAnalyzer {
  LandmarkStabilityAnalyzer({this.historySize = 10});

  final int historySize;
  final List<DetectedPose> _poseHistory = [];

  /// Menambahkan pose baru dan mengembalikan skor kestabilan (0.0 s/d 100.0%).
  double addPoseAndComputeStability(DetectedPose pose) {
    _poseHistory.add(pose);
    if (_poseHistory.length > historySize) {
      _poseHistory.removeAt(0);
    }

    if (_poseHistory.length < 3) {
      return 100.0;
    }

    double totalVariance = 0.0;
    int count = 0;

    for (int i = 1; i < _poseHistory.length; i++) {
      final prev = _poseHistory[i - 1];
      final curr = _poseHistory[i];

      for (final key in curr.landmarks.keys) {
        final p1 = prev.landmarks[key];
        final p2 = curr.landmarks[key];
        if (p1 != null && p2 != null) {
          final dx = p2.x - p1.x;
          final dy = p2.y - p1.y;
          totalVariance += sqrt(dx * dx + dy * dy);
          count++;
        }
      }
    }

    if (count == 0) return 100.0;

    final avgJitter = totalVariance / count;
    final stability = (100.0 - (avgJitter * 2.0)).clamp(0.0, 100.0);
    return stability;
  }

  void reset() {
    _poseHistory.clear();
  }
}
