import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:gerakin/features/camera/models/detected_pose.dart';
import 'package:gerakin/features/camera/models/pose_landmark_model.dart';
import 'package:gerakin/features/motion/models/body_posture.dart';
import 'package:gerakin/features/motion/services/body_analyzer.dart';

void main() {
  group('BodyAnalyzer Tests', () {
    const analyzer = BodyAnalyzer();

    // Pose dengan kemiringan bahu ~10 derajat
    final poseWithTiltedShoulders = DetectedPose(
      imageSize: const Size(480, 640),
      rotation: InputImageRotation.rotation0deg,
      isFrontCamera: true,
      landmarks: {
        PoseLandmarkType.leftShoulder: const PoseLandmarkModel(
          type: PoseLandmarkType.leftShoulder,
          x: 100.0,
          y: 200.0,
          z: 0.0,
          likelihood: 0.9,
        ),
        PoseLandmarkType.rightShoulder: const PoseLandmarkModel(
          type: PoseLandmarkType.rightShoulder,
          x: 200.0,
          y: 217.6, // dy = 17.6, dx = 100 => atan2(17.6, 100) ~ 10 derajat
          z: 0.0,
          likelihood: 0.9,
        ),
      },
    );

    test('Tanpa baseline: Bahu miring 10° diklasifikasikan tidak simetris (isShoulderSymmetric = false)', () {
      final result = analyzer.analyzePosture(
        pose: poseWithTiltedShoulders,
        jointAngles: const {},
        baseline: null,
      );

      expect(result.shoulderSymmetryDiff, greaterThan(8.0));
      expect(result.isShoulderSymmetric, isFalse);
    });

    test('Dengan baseline personal (10° tilt): Pose yang sama diklasifikasikan simetris relatif terhadap baseline', () {
      const baselinePosture = BodyPosture(
        shoulderSymmetryDiff: 10.0,
        isShoulderSymmetric: false,
        torsoOrientation: TorsoOrientation.upright,
        armPosition: ArmPosition.lowered,
        leaningDirection: LeaningDirection.neutral,
      );

      final result = analyzer.analyzePosture(
        pose: poseWithTiltedShoulders,
        jointAngles: const {},
        baseline: baselinePosture,
      );

      // Deviasi relatif = |10.0° - 10.0°| = 0° <= 8° => true
      expect(result.isShoulderSymmetric, isTrue);
    });
  });
}
