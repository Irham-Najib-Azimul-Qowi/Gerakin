import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:gerakin/features/camera/models/detected_pose.dart';
import 'package:gerakin/features/camera/models/pose_landmark_model.dart';
import 'package:gerakin/features/motion/models/body_posture.dart';
import 'package:gerakin/features/validation/services/pose_quality_evaluator.dart';

void main() {
  group('Pose Quality Evaluator Tests', () {
    late PoseQualityEvaluator evaluator;

    setUp(() {
      evaluator = const PoseQualityEvaluator();
    });

    test('Menghitung skor kualitas pose tinggi untuk pose percaya diri dan simetris', () {
      final landmarks = <PoseLandmarkType, PoseLandmarkModel>{};
      for (int i = 0; i < 33; i++) {
        final type = PoseLandmarkType.values[i];
        landmarks[type] = PoseLandmarkModel(
          type: type,
          x: 100,
          y: 100,
          z: 0,
          likelihood: 0.9,
        );
      }

      final pose = DetectedPose(
        landmarks: landmarks,
        imageSize: const Size(720, 1280),
        rotation: InputImageRotation.rotation0deg,
        isFrontCamera: true,
      );

      const posture = BodyPosture(
        shoulderSymmetryDiff: 0,
        isShoulderSymmetric: true,
        torsoOrientation: TorsoOrientation.upright,
        armPosition: ArmPosition.lowered,
        leaningDirection: LeaningDirection.neutral,
      );

      final score = evaluator.evaluatePoseQuality(pose: pose, posture: posture);

      expect(score, greaterThan(80.0));
    });
  });
}
