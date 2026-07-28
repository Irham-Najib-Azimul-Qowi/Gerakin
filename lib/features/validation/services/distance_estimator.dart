import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../camera/models/detected_pose.dart';

/// Service pengestimasi jarak posisi pengguna ke kamera dalam meter.
class DistanceEstimator {
  const DistanceEstimator();

  /// Mengestimasi jarak pengguna ke kamera (Meter) berdasarkan rasio lebar bahu.
  double estimateDistanceMeters(DetectedPose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (leftShoulder == null || rightShoulder == null) {
      return 2.0; // Default estimate 2.0 meter
    }

    final dx = leftShoulder.x - rightShoulder.x;
    final dy = leftShoulder.y - rightShoulder.y;
    final shoulderWidthPx = sqrt(dx * dx + dy * dy);

    if (shoulderWidthPx <= 0) return 2.0;

    // Model inversif sederhana: semakin besar pixel bahu -> semakin dekat pengguna
    final distanceMeters = (450.0 / shoulderWidthPx).clamp(0.8, 5.0);
    return double.parse(distanceMeters.toStringAsFixed(1));
  }
}
