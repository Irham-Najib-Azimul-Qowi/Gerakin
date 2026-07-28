import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../camera/models/detected_pose.dart';
import '../models/body_posture.dart';
import '../models/joint_angle.dart';
import '../models/motion_analysis.dart';
import '../models/motion_validation.dart';
import '../models/movement_state.dart';
import '../services/body_analyzer.dart';
import '../services/joint_angle_calculator.dart';
import '../services/movement_analyzer.dart';
import '../services/movement_smoother.dart';
import '../services/movement_validator.dart';

/// Facade/Orchestrator utama Motion Engine.
///
/// Menerima [DetectedPose] mentah dari Camera Engine, mengeksekusi pipeline:
/// 1. Perhitungan Sudut Vektor 2D/3D ([JointAngleCalculator])
/// 2. Penapisan Jitter/Noise EMA ([MovementSmoother])
/// 3. Analisis Postur Biomekanik ([BodyAnalyzer])
/// 4. Analisis Arah Gerakan ([MovementAnalyzer])
/// 5. Validasi Kualitas Gerakan ([MovementValidator])
///
/// Menghasilkan objek [MotionAnalysis] murni sebagai kontrak untuk Workout Engine.
class MotionProcessor {
  MotionProcessor({
    MovementSmoother? smoother,
    BodyAnalyzer? bodyAnalyzer,
    MovementAnalyzer? movementAnalyzer,
    MovementValidator? validator,
  })  : _smoother = smoother ?? MovementSmoother(),
        _bodyAnalyzer = bodyAnalyzer ?? const BodyAnalyzer(),
        _movementAnalyzer = movementAnalyzer ?? MovementAnalyzer(),
        _validator = validator ?? const MovementValidator();

  final MovementSmoother _smoother;
  final BodyAnalyzer _bodyAnalyzer;
  final MovementAnalyzer _movementAnalyzer;
  final MovementValidator _validator;

  /// Memproses [DetectedPose] dan mengembalikan [MotionAnalysis].
  MotionAnalysis processPose(
    DetectedPose? pose, {
    JointType primaryJoint = JointType.leftElbow,
  }) {
    final now = DateTime.now();

    if (pose == null || pose.landmarks.isEmpty) {
      return MotionAnalysis(
        jointAngles: const {},
        posture: const BodyPosture(
          shoulderSymmetryDiff: 0,
          isShoulderSymmetric: true,
          torsoOrientation: TorsoOrientation.upright,
          armPosition: ArmPosition.lowered,
          leaningDirection: LeaningDirection.neutral,
        ),
        movementState: MovementState.static,
        validationStatus: MotionValidationStatus.outOfRange,
        timestamp: now,
      );
    }

    // 1. Perhitungan Sudut Sendi Mentah (Raw)
    final rawAngles = _calculateAllJointAngles(pose);

    // 2. EMA Smoothing untuk Penapisan Jitter Kamera
    final smoothedAngles = _smoother.smoothJointAngles(rawAngles);

    // 3. Analisis Postur Tubuh Biomekanik
    final posture = _bodyAnalyzer.analyzePosture(
      pose: pose,
      jointAngles: smoothedAngles,
    );

    // 4. Analisis Arah Gerakan (movingUp, movingDown, static)
    final primaryAngle = smoothedAngles[primaryJoint]?.angle ?? 0.0;
    final movementState = _movementAnalyzer.analyzeDirection(
      targetJoint: primaryJoint,
      currentAngle: primaryAngle,
    );

    // 5. Validasi Kualitas Gerakan
    final validationStatus = _validator.validate(
      pose: pose,
      jointAngles: smoothedAngles,
      movementState: movementState,
    );

    return MotionAnalysis(
      jointAngles: smoothedAngles,
      posture: posture,
      movementState: movementState,
      validationStatus: validationStatus,
      timestamp: now,
    );
  }

  /// Menghitung seluruh sudut sendi utama dari [DetectedPose].
  Map<JointType, JointAngle> _calculateAllJointAngles(DetectedPose pose) {
    final angles = <JointType, JointAngle>{};

    void calc(
      JointType type,
      PoseLandmarkType pA,
      PoseLandmarkType pB,
      PoseLandmarkType pC,
    ) {
      final angle = JointAngleCalculator.calculateJointAngle(
        type: type,
        firstLandmark: pose.getLandmark(pA, 0.4),
        vertexLandmark: pose.getLandmark(pB, 0.4),
        lastLandmark: pose.getLandmark(pC, 0.4),
      );
      if (angle != null) {
        angles[type] = angle;
      }
    }

    // Left Arm
    calc(
      JointType.leftElbow,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
    );
    calc(
      JointType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
    );

    // Right Arm
    calc(
      JointType.rightElbow,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
    );
    calc(
      JointType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
    );

    // Left Leg
    calc(
      JointType.leftKnee,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
    );
    calc(
      JointType.leftHip,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
    );

    // Right Leg
    calc(
      JointType.rightKnee,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
    );
    calc(
      JointType.rightHip,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
    );

    return angles;
  }

  /// Reset state internal processor (history smoothing & direction tracker).
  void reset() {
    _smoother.reset();
    _movementAnalyzer.reset();
  }
}
