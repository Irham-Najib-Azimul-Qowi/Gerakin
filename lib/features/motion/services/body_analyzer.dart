import 'dart:math' as math;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../camera/models/detected_pose.dart';
import '../models/body_posture.dart';
import '../models/joint_angle.dart';

/// Service analisis biomekanik postur tubuh pengguna.
///
/// Menganalisis:
/// 1. Simetri bahu (Shoulder Symmetry)
/// 2. Orientasi torso (Torso Orientation)
/// 3. Posisi lengan (Arm Position)
/// 4. Arah kemiringan (Leaning Direction)
class BodyAnalyzer {
  const BodyAnalyzer();

  /// Menganalisis postur tubuh dari [DetectedPose] dan daftar [jointAngles].
  ///
  /// Jika [baseline] diberikan (hasil kalibrasi per pengguna), evaluasi simetri
  /// dan toleransi postur dihitung secara RELATIF terhadap baseline pengguna tersebut,
  /// bukan asumsi "tegak sempurna" universal.
  BodyPosture analyzePosture({
    required DetectedPose pose,
    required Map<JointType, JointAngle> jointAngles,
    BodyPosture? baseline,
  }) {
    final leftShoulder = pose.getLandmark(PoseLandmarkType.leftShoulder);
    final rightShoulder = pose.getLandmark(PoseLandmarkType.rightShoulder);
    final leftHip = pose.getLandmark(PoseLandmarkType.leftHip);
    final rightHip = pose.getLandmark(PoseLandmarkType.rightHip);
    final leftWrist = pose.getLandmark(PoseLandmarkType.leftWrist);
    final rightWrist = pose.getLandmark(PoseLandmarkType.rightWrist);

    // 1. Analisis Simetri Bahu
    double shoulderSymmetryDiff = 0.0;
    bool isSymmetric = true;

    if (leftShoulder != null && rightShoulder != null) {
      final dy = (leftShoulder.y - rightShoulder.y).abs();
      final dx = (leftShoulder.x - rightShoulder.x).abs();
      if (dx > 0) {
        final radians = math.atan2(dy, dx);
        shoulderSymmetryDiff = radians * (180.0 / math.pi);
      }

      // Jika baseline tersedia, toleransi 8° dihitung relatif terhadap baseline pengguna
      final baseDiff = baseline?.shoulderSymmetryDiff ?? 0.0;
      final relativeDiff = (shoulderSymmetryDiff - baseDiff).abs();
      isSymmetric = relativeDiff <= 8.0;
    }

    // 2. Analisis Orientasi Torso & Leaning Direction
    TorsoOrientation orientation = TorsoOrientation.upright;
    LeaningDirection leaning = LeaningDirection.neutral;

    if (leftShoulder != null &&
        rightShoulder != null &&
        leftHip != null &&
        rightHip != null) {
      final midShoulderX = (leftShoulder.x + rightShoulder.x) / 2.0;
      final midShoulderY = (leftShoulder.y + rightShoulder.y) / 2.0;
      final midHipX = (leftHip.x + rightHip.x) / 2.0;
      final midHipY = (leftHip.y + rightHip.y) / 2.0;

      final dx = midShoulderX - midHipX;
      final dy = midShoulderY - midHipY; // Kamera Y tumbuh ke bawah

      final tiltAngle = math.atan2(dx.abs(), dy.abs()) * (180.0 / math.pi);

      if (tiltAngle < 12.0) {
        orientation = TorsoOrientation.upright;
        leaning = LeaningDirection.neutral;
      } else if (dx < -15.0) {
        orientation = TorsoOrientation.tiltedSide;
        leaning = LeaningDirection.left;
      } else if (dx > 15.0) {
        orientation = TorsoOrientation.tiltedSide;
        leaning = LeaningDirection.right;
      } else {
        orientation = TorsoOrientation.leaningForward;
        leaning = LeaningDirection.forward;
      }
    }

    // 3. Analisis Posisi Lengan
    ArmPosition armPos = ArmPosition.lowered;
    final leftElbowAngle = jointAngles[JointType.leftElbow]?.angle ?? 180.0;
    final rightElbowAngle = jointAngles[JointType.rightElbow]?.angle ?? 180.0;
    final avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2.0;

    if (leftShoulder != null &&
        rightShoulder != null &&
        leftWrist != null &&
        rightWrist != null) {
      final avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2.0;
      final avgWristY = (leftWrist.y + rightWrist.y) / 2.0;

      if (avgWristY < avgShoulderY - 30) {
        armPos = ArmPosition.raised;
      } else if (avgElbowAngle < 120.0) {
        armPos = ArmPosition.bent;
      } else if (avgElbowAngle >= 150.0) {
        armPos = ArmPosition.extended;
      } else {
        armPos = ArmPosition.lowered;
      }
    }

    return BodyPosture(
      shoulderSymmetryDiff: shoulderSymmetryDiff,
      isShoulderSymmetric: isSymmetric,
      torsoOrientation: orientation,
      armPosition: armPos,
      leaningDirection: leaning,
    );
  }
}
