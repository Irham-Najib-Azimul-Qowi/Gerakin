import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../domain/exercise_config.dart';
import '../domain/exercise_phase.dart';
import '../domain/exercise_type.dart';
import '../domain/movement_feedback.dart';
import '../logic/angle_calculator.dart';
import 'base_exercise_engine.dart';

/// Engine analisis gerakan 2: **Seated Bicep Curl**.
class BicepCurlEngine extends BaseExerciseEngine {
  BicepCurlEngine({
    ExerciseConfig? config,
  }) : super(config: config ?? ExerciseConfig.forType(ExerciseType.bicepCurl));

  @override
  bool checkRequiredLandmarksReliable() {
    final ls = activeLandmarks[PoseLandmarkType.leftShoulder];
    final rs = activeLandmarks[PoseLandmarkType.rightShoulder];
    final le = activeLandmarks[PoseLandmarkType.leftElbow];
    final re = activeLandmarks[PoseLandmarkType.rightElbow];
    final lw = activeLandmarks[PoseLandmarkType.leftWrist];
    final rw = activeLandmarks[PoseLandmarkType.rightWrist];

    return isLandmarkReliable(ls) &&
        isLandmarkReliable(rs) &&
        isLandmarkReliable(le) &&
        isLandmarkReliable(re) &&
        isLandmarkReliable(lw) &&
        isLandmarkReliable(rw);
  }

  @override
  AnalysisData analyzeExerciseMovement() {
    final ls = activeLandmarks[PoseLandmarkType.leftShoulder]!;
    final rs = activeLandmarks[PoseLandmarkType.rightShoulder]!;
    final le = activeLandmarks[PoseLandmarkType.leftElbow]!;
    final re = activeLandmarks[PoseLandmarkType.rightElbow]!;
    final lw = activeLandmarks[PoseLandmarkType.leftWrist]!;
    final rw = activeLandmarks[PoseLandmarkType.rightWrist]!;
    final lh = activeLandmarks[PoseLandmarkType.leftHip];
    final rh = activeLandmarks[PoseLandmarkType.rightHip];

    final leftShoulderPt = Offset(ls.x, ls.y);
    final rightShoulderPt = Offset(rs.x, rs.y);
    final leftElbowPt = Offset(le.x, le.y);
    final rightElbowPt = Offset(re.x, re.y);
    final leftWristPt = Offset(lw.x, lw.y);
    final rightWristPt = Offset(rw.x, rw.y);

    // 1. Hitung Sudut Fleksi Siku Kiri & Kanan
    final leftElbowAngle = AngleCalculator.calculateAngle(leftShoulderPt, leftElbowPt, leftWristPt);
    final rightElbowAngle = AngleCalculator.calculateAngle(rightShoulderPt, rightElbowPt, rightWristPt);
    final avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2.0;

    // 2. Hitung Pergeseran Posisi Lengan Atas (Shoulder-Elbow Alignment)
    final leftArmOffset = (leftElbowPt.dx - leftShoulderPt.dx).abs();
    final rightArmOffset = (rightElbowPt.dx - rightShoulderPt.dx).abs();
    final avgArmOffset = (leftArmOffset + rightArmOffset) / 2.0;

    // 3. Simetri Kiri-Kanan
    final symmetryDiff = (leftElbowAngle - rightElbowAngle).abs();

    // 4. Kemiringan Torso
    double torsoTilt = 0.0;
    if (lh != null && rh != null && isLandmarkReliable(lh) && isLandmarkReliable(rh)) {
      final shoulderMid = Offset((ls.x + rs.x) / 2.0, (ls.y + rs.y) / 2.0);
      final hipMid = Offset((lh.x + rh.x) / 2.0, (lh.y + rh.y) / 2.0);
      torsoTilt = AngleCalculator.calculateVerticalElevationAngle(hipMid, shoulderMid);
    }

    // 5. Umpan Balik Real-Time & Koreksi
    MovementFeedback? feedback;

    if (torsoTilt > 18.0) {
      feedback = const MovementFeedback(
        message: 'Jaga punggung tetap tegak.',
        category: FeedbackCategory.correction,
        visualIcon: '!',
        speechText: 'Jaga punggung tetap tegap pada sandaran kursi roda.',
      );
    } else if (avgArmOffset > 60.0) {
      feedback = const MovementFeedback(
        message: 'Pertahankan siku di dekat tubuh.',
        category: FeedbackCategory.correction,
        visualIcon: '↔',
        speechText: 'Pertahankan posisi siku tetap di dekat tubuh.',
      );
    } else if (symmetryDiff > 25.0) {
      feedback = const MovementFeedback(
        message: 'Gerakkan kedua tangan secara seimbang.',
        category: FeedbackCategory.correction,
        visualIcon: '↔',
        speechText: 'Gerakkan tangan kiri dan kanan secara bersamaan.',
      );
    } else if (currentPhase == MovementPhase.middle && avgElbowAngle > config.targetAngleThreshold + 15.0) {
      feedback = const MovementFeedback(
        message: 'Tekuk siku sedikit lebih jauh.',
        category: FeedbackCategory.correction,
        visualIcon: '↑',
        speechText: 'Tekuk siku lebih jauh mendekati bahu.',
      );
    }

    return AnalysisData(
      primaryAngle: avgElbowAngle,
      targetAngle: config.targetAngleThreshold,
      secondaryAngle: avgArmOffset,
      symmetryDifference: symmetryDiff,
      torsoTilt: torsoTilt,
      feedback: feedback,
      isGreaterTarget: false, // Bicep curl: makin tertekuk sudut makin KECIL
    );
  }

  @override
  String getInstructionTextForPhase(MovementPhase phase) {
    switch (phase) {
      case MovementPhase.start:
        return 'Luruskan lengan ke bawah di samping tubuh';
      case MovementPhase.middle:
      case MovementPhase.returning:
        return 'Tekuk kedua siku perlahan ke arah bahu';
      case MovementPhase.target:
        return 'Dekatkan tangan ke arah bahu!';
    }
  }
}
