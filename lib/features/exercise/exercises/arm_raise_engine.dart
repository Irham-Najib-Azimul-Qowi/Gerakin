import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../domain/exercise_config.dart';
import '../domain/exercise_phase.dart';
import '../domain/exercise_type.dart';
import '../domain/movement_feedback.dart';
import '../logic/angle_calculator.dart';
import 'base_exercise_engine.dart';

/// Engine analisis gerakan 1: **Seated Side Arm Raise**.
class ArmRaiseEngine extends BaseExerciseEngine {
  ArmRaiseEngine({
    ExerciseConfig? config,
  }) : super(config: config ?? ExerciseConfig.forType(ExerciseType.sideArmRaise));

  @override
  bool checkRequiredLandmarksReliable() {
    final ls = activeLandmarks[PoseLandmarkType.leftShoulder];
    final rs = activeLandmarks[PoseLandmarkType.rightShoulder];
    final le = activeLandmarks[PoseLandmarkType.leftElbow];
    final re = activeLandmarks[PoseLandmarkType.rightElbow];

    return isLandmarkReliable(ls) &&
        isLandmarkReliable(rs) &&
        isLandmarkReliable(le) &&
        isLandmarkReliable(re);
  }

  @override
  AnalysisData analyzeExerciseMovement() {
    final ls = activeLandmarks[PoseLandmarkType.leftShoulder]!;
    final rs = activeLandmarks[PoseLandmarkType.rightShoulder]!;
    final le = activeLandmarks[PoseLandmarkType.leftElbow]!;
    final re = activeLandmarks[PoseLandmarkType.rightElbow]!;
    final lw = activeLandmarks[PoseLandmarkType.leftWrist];
    final rw = activeLandmarks[PoseLandmarkType.rightWrist];
    final lh = activeLandmarks[PoseLandmarkType.leftHip];
    final rh = activeLandmarks[PoseLandmarkType.rightHip];

    final leftShoulderPt = Offset(ls.x, ls.y);
    final rightShoulderPt = Offset(rs.x, rs.y);
    final leftElbowPt = Offset(le.x, le.y);
    final rightElbowPt = Offset(re.x, re.y);

    // 1. Hitung Elevasi Lengan Kiri & Kanan terhadap sumbu vertikal
    final leftElevation = AngleCalculator.calculateVerticalElevationAngle(leftShoulderPt, leftElbowPt);
    final rightElevation = AngleCalculator.calculateVerticalElevationAngle(rightShoulderPt, rightElbowPt);
    final avgElevation = (leftElevation + rightElevation) / 2.0;

    // 2. Hitung Siku (Kemiringan Tekukan Siku)
    double leftElbowAngle = 180.0;
    double rightElbowAngle = 180.0;
    if (lw != null && isLandmarkReliable(lw)) {
      leftElbowAngle = AngleCalculator.calculateAngle(leftShoulderPt, leftElbowPt, Offset(lw.x, lw.y));
    }
    if (rw != null && isLandmarkReliable(rw)) {
      rightElbowAngle = AngleCalculator.calculateAngle(rightShoulderPt, rightElbowPt, Offset(rw.x, rw.y));
    }
    final minElbowAngle = leftElbowAngle < rightElbowAngle ? leftElbowAngle : rightElbowAngle;

    // 3. Hitung Perbedaan Simetri Kiri-Kanan
    final symmetryDiff = (leftElevation - rightElevation).abs();

    // 4. Hitung Kemiringan Torso/Badan
    double torsoTilt = 0.0;
    if (lh != null && rh != null && isLandmarkReliable(lh) && isLandmarkReliable(rh)) {
      final shoulderMid = Offset((ls.x + rs.x) / 2.0, (ls.y + rs.y) / 2.0);
      final hipMid = Offset((lh.x + rh.x) / 2.0, (lh.y + rh.y) / 2.0);
      torsoTilt = AngleCalculator.calculateVerticalElevationAngle(hipMid, shoulderMid);
    }

    // 5. Evaluasi Umpan Balik Real-Time & Koreksi Gerakan
    MovementFeedback? feedback;

    if (torsoTilt > 18.0) {
      feedback = const MovementFeedback(
        message: 'Jaga tubuh tetap tegak.',
        category: FeedbackCategory.correction,
        visualIcon: '!',
        speechText: 'Jaga tubuh tetap tegak pada sandaran kursi roda.',
      );
    } else if (symmetryDiff > 20.0 && avgElevation > 35.0) {
      feedback = const MovementFeedback(
        message: 'Seimbangkan tinggi kedua tangan.',
        category: FeedbackCategory.correction,
        visualIcon: '↔',
        speechText: 'Seimbangkan tinggi tangan kiri dan kanan.',
      );
    } else if (minElbowAngle < 130.0 && avgElevation > 35.0) {
      feedback = const MovementFeedback(
        message: 'Luruskan siku sedikit.',
        category: FeedbackCategory.correction,
        visualIcon: '↑',
        speechText: 'Luruskan siku sedikit agar lengan terangkat sempurna.',
      );
    } else if (currentPhase == MovementPhase.middle && avgElevation < config.targetAngleThreshold - 15.0) {
      feedback = const MovementFeedback(
        message: 'Angkat tangan sedikit lebih tinggi.',
        category: FeedbackCategory.correction,
        visualIcon: '↑',
        speechText: 'Angkat tangan lebih tinggi hingga sejajar bahu.',
      );
    }

    return AnalysisData(
      primaryAngle: avgElevation,
      targetAngle: config.targetAngleThreshold,
      secondaryAngle: minElbowAngle,
      symmetryDifference: symmetryDiff,
      torsoTilt: torsoTilt,
      feedback: feedback,
      isGreaterTarget: true,
    );
  }

  @override
  String getInstructionTextForPhase(MovementPhase phase) {
    switch (phase) {
      case MovementPhase.start:
        return 'Posisikan kedua tangan di samping tubuh';
      case MovementPhase.middle:
      case MovementPhase.returning:
        return 'Angkat kedua tangan ke samping secara perlahan';
      case MovementPhase.target:
        return 'Capai tinggi sejajar bahu!';
    }
  }
}
