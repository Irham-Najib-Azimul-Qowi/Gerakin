import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/detected_pose.dart';
import '../models/pose_landmark_model.dart';

/// Pengelola Bounding Box Tubuh & Landmark Stabilization (EMA Smoother).
class PoseRenderer {
  PoseRenderer({this.alpha = 0.45});

  /// Faktor penghalusan Exponential Moving Average (EMA). Default: 0.45 (Responsif)
  final double alpha;

  final Map<PoseLandmarkType, Offset> _smoothedLandmarks = {};

  /// Menghitung Bounding Box tubuh berdasarkan landmark utama (Shoulders, Hips, Knees).
  Rect? computeBodyBoundingBox(DetectedPose pose, double minConfidence) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    final targetTypes = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
    ];

    int validCount = 0;
    for (final type in targetTypes) {
      final lm = pose.getLandmark(type, minConfidence);
      if (lm != null) {
        validCount++;
        if (lm.x < minX) minX = lm.x;
        if (lm.y < minY) minY = lm.y;
        if (lm.x > maxX) maxX = lm.x;
        if (lm.y > maxY) maxY = lm.y;
      }
    }

    if (validCount < 2) return null;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Menghaluskan koordinat landmark mentah menggunakan EMA Filter (\alpha = 0.25).
  PoseLandmarkModel smoothLandmark(PoseLandmarkModel rawLandmark) {
    final type = rawLandmark.type;
    final currentOffset = Offset(rawLandmark.x, rawLandmark.y);

    if (!_smoothedLandmarks.containsKey(type)) {
      _smoothedLandmarks[type] = currentOffset;
      return rawLandmark;
    }

    final prevOffset = _smoothedLandmarks[type]!;
    final smoothedX = alpha * rawLandmark.x + (1.0 - alpha) * prevOffset.dx;
    final smoothedY = alpha * rawLandmark.y + (1.0 - alpha) * prevOffset.dy;

    final newOffset = Offset(smoothedX, smoothedY);
    _smoothedLandmarks[type] = newOffset;

    return PoseLandmarkModel(
      type: rawLandmark.type,
      x: smoothedX,
      y: smoothedY,
      z: rawLandmark.z,
      likelihood: rawLandmark.likelihood,
    );
  }

  /// Membersihkan riwayat smoothing jika pose di-reset.
  void reset() {
    _smoothedLandmarks.clear();
  }
}
