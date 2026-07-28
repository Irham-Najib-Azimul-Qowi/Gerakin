import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:gerakin/features/camera/models/detected_pose.dart';
import 'package:gerakin/features/camera/models/pose_landmark_model.dart';
import 'package:gerakin/features/validation/services/confidence_filter.dart';

void main() {
  group('Confidence Filter Tests', () {
    late ConfidenceFilter filter;

    setUp(() {
      filter = const ConfidenceFilter(minConfidenceThreshold: 0.5);
    });

    test('Menyaring landmark dengan confidence di bawah 0.5', () {
      final landmarks = {
        PoseLandmarkType.leftShoulder: const PoseLandmarkModel(
          type: PoseLandmarkType.leftShoulder,
          x: 100,
          y: 100,
          z: 0,
          likelihood: 0.9, // High
        ),
        PoseLandmarkType.rightShoulder: const PoseLandmarkModel(
          type: PoseLandmarkType.rightShoulder,
          x: 200,
          y: 100,
          z: 0,
          likelihood: 0.2, // Low -> Filtered out!
        ),
      };

      final pose = DetectedPose(
        landmarks: landmarks,
        imageSize: const Size(720, 1280),
        rotation: InputImageRotation.rotation0deg,
        isFrontCamera: true,
      );

      final filtered = filter.filterPose(pose);

      expect(filtered.landmarks.containsKey(PoseLandmarkType.leftShoulder), isTrue);
      expect(filtered.landmarks.containsKey(PoseLandmarkType.rightShoulder), isFalse);
      expect(filtered.landmarks.length, equals(1));
    });
  });
}
