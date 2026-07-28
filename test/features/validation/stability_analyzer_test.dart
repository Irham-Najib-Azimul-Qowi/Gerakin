import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:gerakin/features/camera/models/detected_pose.dart';
import 'package:gerakin/features/camera/models/pose_landmark_model.dart';
import 'package:gerakin/features/validation/services/landmark_stability_analyzer.dart';

void main() {
  group('Landmark Stability Analyzer Tests', () {
    late LandmarkStabilityAnalyzer stabilityAnalyzer;

    setUp(() {
      stabilityAnalyzer = LandmarkStabilityAnalyzer();
    });

    test('Menghitung kestabilan 100% untuk pose konstan tanpa jitter', () {
      final pose1 = _createPoseAt(100.0, 100.0);
      final pose2 = _createPoseAt(100.0, 100.0);
      final pose3 = _createPoseAt(100.0, 100.0);

      stabilityAnalyzer.addPoseAndComputeStability(pose1);
      stabilityAnalyzer.addPoseAndComputeStability(pose2);
      final stability = stabilityAnalyzer.addPoseAndComputeStability(pose3);

      expect(stability, equals(100.0));
    });
  });
}

DetectedPose _createPoseAt(double x, double y) {
  final landmarks = {
    PoseLandmarkType.leftShoulder: PoseLandmarkModel(
      type: PoseLandmarkType.leftShoulder,
      x: x,
      y: y,
      z: 0,
      likelihood: 0.9,
    ),
  };
  return DetectedPose(
    landmarks: landmarks,
    imageSize: const Size(720, 1280),
    rotation: InputImageRotation.rotation0deg,
    isFrontCamera: true,
  );
}
