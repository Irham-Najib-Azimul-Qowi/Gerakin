import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:gerakin/features/camera/models/detected_pose.dart';
import 'package:gerakin/features/camera/models/pose_landmark_model.dart';
import 'package:gerakin/features/motion/models/body_posture.dart';
import 'package:gerakin/features/validation/models/calibration_status.dart';
import 'package:gerakin/features/validation/services/calibration_service.dart';

void main() {
  group('Calibration Service Tests', () {
    late CalibrationService calibrationService;

    setUp(() {
      calibrationService = CalibrationService();
    });

    test('Alur kalibrasi selesai 100% saat pose baseline valid dan pencahayaan ideal', () {
      final pose = _createHighQualityPose();
      const posture = BodyPosture(
        shoulderSymmetryDiff: 2,
        isShoulderSymmetric: true,
        torsoOrientation: TorsoOrientation.upright,
        armPosition: ArmPosition.lowered,
        leaningDirection: LeaningDirection.neutral,
      );

      final status = calibrationService.processCalibrationFrame(
        pose: pose,
        posture: posture,
      );

      expect(status.step, equals(CalibrationStep.completed));
      expect(status.progressPercentage, equals(100.0));
      expect(status.isCompleted, isTrue);
    });
  });
}

DetectedPose _createHighQualityPose() {
  final landmarks = <PoseLandmarkType, PoseLandmarkModel>{};

  landmarks[PoseLandmarkType.leftShoulder] = const PoseLandmarkModel(
    type: PoseLandmarkType.leftShoulder,
    x: 100,
    y: 100,
    z: 0,
    likelihood: 0.95,
  );
  landmarks[PoseLandmarkType.rightShoulder] = const PoseLandmarkModel(
    type: PoseLandmarkType.rightShoulder,
    x: 300,
    y: 100,
    z: 0,
    likelihood: 0.95,
  );

  return DetectedPose(
    landmarks: landmarks,
    imageSize: const Size(720, 1280),
    rotation: InputImageRotation.rotation0deg,
    isFrontCamera: true,
  );
}
