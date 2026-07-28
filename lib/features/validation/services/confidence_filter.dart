import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../camera/models/detected_pose.dart';
import '../../camera/models/pose_landmark_model.dart';

/// Service penyaring landmark berbasis tingkat kepercayaan (Confidence Filter).
class ConfidenceFilter {
  const ConfidenceFilter({this.minConfidenceThreshold = 0.5});

  final double minConfidenceThreshold;

  /// Menyaring [DetectedPose] dan mengembalikan pose baru yang hanya berisi landmark valid.
  DetectedPose filterPose(DetectedPose pose) {
    final filteredLandmarks = <PoseLandmarkType, PoseLandmarkModel>{};

    for (final entry in pose.landmarks.entries) {
      if (entry.value.likelihood >= minConfidenceThreshold) {
        filteredLandmarks[entry.key] = entry.value;
      }
    }

    return DetectedPose(
      landmarks: filteredLandmarks,
      imageSize: pose.imageSize,
      rotation: pose.rotation,
      isFrontCamera: pose.isFrontCamera,
    );
  }

  /// Menghitung rasio landmark valid dalam pose.
  double computeValidRatio(DetectedPose pose) {
    if (pose.landmarks.isEmpty) return 0.0;

    final validCount = pose.landmarks.values
        .where((l) => l.likelihood >= minConfidenceThreshold)
        .length;

    return validCount / pose.landmarks.length;
  }
}
