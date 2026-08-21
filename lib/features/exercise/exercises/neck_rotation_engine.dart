import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../domain/exercise_config.dart';
import '../domain/exercise_phase.dart';
import '../domain/exercise_type.dart';
import '../domain/movement_feedback.dart';
import '../logic/angle_calculator.dart';
import 'base_exercise_engine.dart';

enum NeckSubPhase {
  center,
  turningRight,
  reachedRight,
  centerAfterRight,
  turningLeft,
  reachedLeft,
}

/// Engine analisis gerakan 3: **Seated Neck Rotation**.
///
/// Mengatur siklus repetisi leher: **CENTER → RIGHT → CENTER → LEFT → CENTER = 1 Rep**.
class NeckRotationEngine extends BaseExerciseEngine {
  NeckRotationEngine({
    ExerciseConfig? config,
  }) : super(config: config ?? ExerciseConfig.forType(ExerciseType.neckRotation));

  NeckSubPhase _subPhase = NeckSubPhase.center;

  @override
  bool checkRequiredLandmarksReliable() {
    final nose = activeLandmarks[PoseLandmarkType.nose];
    final ls = activeLandmarks[PoseLandmarkType.leftShoulder];
    final rs = activeLandmarks[PoseLandmarkType.rightShoulder];

    return isLandmarkReliable(nose) && isLandmarkReliable(ls) && isLandmarkReliable(rs);
  }

  @override
  AnalysisData analyzeExerciseMovement() {
    final nose = activeLandmarks[PoseLandmarkType.nose]!;
    final ls = activeLandmarks[PoseLandmarkType.leftShoulder]!;
    final rs = activeLandmarks[PoseLandmarkType.rightShoulder]!;
    final le = activeLandmarks[PoseLandmarkType.leftEar];
    final re = activeLandmarks[PoseLandmarkType.rightEar];

    final nosePt = Offset(nose.x, nose.y);
    final leftShoulderPt = Offset(ls.x, ls.y);
    final rightShoulderPt = Offset(rs.x, rs.y);

    final shoulderMid = Offset((ls.x + rs.x) / 2.0, (ls.y + rs.y) / 2.0);
    final shoulderWidth = (leftShoulderPt.dx - rightShoulderPt.dx).abs();

    // 1. Hitung Pergeseran Horizontal Hidung terhadap Tengah Bahu (Derajat Rotasi relatif)
    final horizontalOffset = (nosePt.dx - shoulderMid.dx) / (shoulderWidth > 0 ? shoulderWidth : 1.0);
    final rotationAngle = (horizontalOffset * 180.0).abs(); // Estimasi sudut rotasi leher

    // 2. Rotasi Bahu (Apakah bahu ikut berputar?)
    final shoulderTilt = AngleCalculator.calculateVerticalElevationAngle(leftShoulderPt, rightShoulderPt);
    final shoulderRotationDiff = (shoulderTilt - 90.0).abs();

    // 3. Kemiringan Kepala Kesamping (Head Lateral Tilt)
    double headTilt = 0.0;
    if (le != null && re != null && isLandmarkReliable(le) && isLandmarkReliable(re)) {
      headTilt = AngleCalculator.calculateVerticalElevationAngle(Offset(le.x, le.y), Offset(re.x, re.y));
      headTilt = (headTilt - 90.0).abs();
    }

    // 4. Update Sub-Phase Rotasi Leher (Center -> Right -> Center -> Left -> Center)
    final isCenter = rotationAngle < config.startAngleThreshold;
    final isTurnedRight = nosePt.dx > shoulderMid.dx + (shoulderWidth * 0.12);
    final isTurnedLeft = nosePt.dx < shoulderMid.dx - (shoulderWidth * 0.12);

    switch (_subPhase) {
      case NeckSubPhase.center:
        if (isTurnedRight) {
          _subPhase = NeckSubPhase.reachedRight;
        } else if (isTurnedLeft) {
          _subPhase = NeckSubPhase.reachedLeft;
        }
        break;

      case NeckSubPhase.reachedRight:
        if (isCenter) {
          _subPhase = NeckSubPhase.centerAfterRight;
        }
        break;

      case NeckSubPhase.centerAfterRight:
        if (isTurnedLeft) {
          _subPhase = NeckSubPhase.reachedLeft;
        }
        break;

      case NeckSubPhase.reachedLeft:
        if (isCenter) {
          _subPhase = NeckSubPhase.center;
        }
        break;

      default:
        break;
    }

    // 5. Umpan Balik Real-Time & Koreksi
    MovementFeedback? feedback;

    if (shoulderRotationDiff > 14.0) {
      feedback = const MovementFeedback(
        message: 'Pertahankan bahu tetap menghadap depan.',
        category: FeedbackCategory.correction,
        visualIcon: '↔',
        speechText: 'Pertahankan posisi bahu tetap diam dan menghadap ke depan.',
      );
    } else if (headTilt > 15.0) {
      feedback = const MovementFeedback(
        message: 'Jaga kepala tetap tegak.',
        category: FeedbackCategory.correction,
        visualIcon: '!',
        speechText: 'Jaga posisi kepala tetap tegap saat memutar leher.',
      );
    } else if (currentPhase == MovementPhase.middle && rotationAngle < config.targetAngleThreshold - 10.0) {
      feedback = const MovementFeedback(
        message: 'Putar kepala sedikit lebih jauh.',
        category: FeedbackCategory.correction,
        visualIcon: '↔',
        speechText: 'Putar kepala sedikit lebih jauh secara lembut.',
      );
    }

    return AnalysisData(
      primaryAngle: rotationAngle,
      targetAngle: config.targetAngleThreshold,
      secondaryAngle: shoulderRotationDiff,
      symmetryDifference: shoulderRotationDiff,
      torsoTilt: headTilt,
      feedback: feedback,
      isGreaterTarget: true,
    );
  }

  @override
  String getInstructionTextForPhase(MovementPhase phase) {
    switch (_subPhase) {
      case NeckSubPhase.center:
        return 'Hadap lurus ke depan';
      case NeckSubPhase.turningRight:
      case NeckSubPhase.reachedRight:
        return 'Putar kepala perlahan ke kanan';
      case NeckSubPhase.centerAfterRight:
        return 'Kembali ke tengah, lalu putar ke kiri';
      case NeckSubPhase.turningLeft:
      case NeckSubPhase.reachedLeft:
        return 'Putar kepala perlahan ke kiri';
    }
  }
}
