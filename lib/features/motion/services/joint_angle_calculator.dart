import 'dart:math' as math;

import '../../camera/models/pose_landmark_model.dart';
import '../models/joint_angle.dart';
import '../models/motion_tracking_constants.dart';

/// Service perhitungan matematika vektor 2D/3D untuk menghitung sudut sendi.
///
/// PERHITUNGAN VEKTOR AKURAT:
/// Diberikan 3 titik $A$, $B$ (vertex/sendi), dan $C$:
/// - Vektor $BA = A - B$
/// - Vektor $BC = C - B$
/// - Sudut $\theta = |\arctan2(y_A - y_B, x_A - x_B) - \arctan2(y_C - y_B, x_C - x_B)|$
/// - Dinormalisasi ke rentang $0^\circ \le \theta \le 180^\circ$.
class JointAngleCalculator {
  const JointAngleCalculator();

  /// Menghitung sudut dalam derajat ($0^\circ \le \theta \le 180^\circ$) antara 3 titik koordinat 2D.
  ///
  /// [firstPoint] ($A$): Titik pertama (misal: Bahu)
  /// [vertexPoint] ($B$): Titik sendi pusat/puncak (misal: Siku)
  /// [lastPoint] ($C$): Titik ketiga (misal: Pergelangan tangan)
  static double calculateAngle2D(
    math.Point<double> firstPoint,
    math.Point<double> vertexPoint,
    math.Point<double> lastPoint,
  ) {
    final double radians = math.atan2(
          lastPoint.y - vertexPoint.y,
          lastPoint.x - vertexPoint.x,
        ) -
        math.atan2(
          firstPoint.y - vertexPoint.y,
          firstPoint.x - vertexPoint.x,
        );

    double degrees = radians.abs() * (180.0 / math.pi);

    if (degrees > 180.0) {
      degrees = 360.0 - degrees;
    }

    return degrees;
  }

  /// Menghitung [JointAngle] dari 3 landmark [PoseLandmarkModel].
  static JointAngle? calculateJointAngle({
    required JointType type,
    required PoseLandmarkModel? firstLandmark,
    required PoseLandmarkModel? vertexLandmark,
    required PoseLandmarkModel? lastLandmark,
    double minConfidence = MotionTrackingConstants.kMinLandmarkConfidence,
  }) {
    if (firstLandmark == null || vertexLandmark == null || lastLandmark == null) {
      return null;
    }

    if (!firstLandmark.isValid(minConfidence) ||
        !vertexLandmark.isValid(minConfidence) ||
        !lastLandmark.isValid(minConfidence)) {
      return null;
    }

    final pA = math.Point<double>(firstLandmark.x, firstLandmark.y);
    final pB = math.Point<double>(vertexLandmark.x, vertexLandmark.y);
    final pC = math.Point<double>(lastLandmark.x, lastLandmark.y);

    final angle = calculateAngle2D(pA, pB, pC);
    final confidence = (firstLandmark.likelihood +
            vertexLandmark.likelihood +
            lastLandmark.likelihood) /
        3.0;

    return JointAngle(
      type: type,
      angle: angle,
      confidence: confidence,
    );
  }

  /// Menghitung [JointAngle] khusus leher (fleksi atau rotasi) berdasarkan
  /// posisi [noseLandmark], [leftShoulder], dan [rightShoulder].
  ///
  /// Menghitung kemiringan vektor hidung-ke-tengah-bahu relatif terhadap sumbu vertikal.
  static JointAngle? calculateNeckAngle({
    required JointType type,
    required PoseLandmarkModel? noseLandmark,
    required PoseLandmarkModel? leftShoulder,
    required PoseLandmarkModel? rightShoulder,
    double minConfidence = MotionTrackingConstants.kMinLandmarkConfidence,
  }) {
    if (noseLandmark == null || leftShoulder == null || rightShoulder == null) {
      return null;
    }

    if (!noseLandmark.isValid(minConfidence) ||
        !leftShoulder.isValid(minConfidence) ||
        !rightShoulder.isValid(minConfidence)) {
      return null;
    }

    final midShoulderX = (leftShoulder.x + rightShoulder.x) / 2.0;
    final midShoulderY = (leftShoulder.y + rightShoulder.y) / 2.0;

    final dx = noseLandmark.x - midShoulderX;
    final dy = noseLandmark.y - midShoulderY;

    // Sudut relatif terhadap garis vertikal (0 derajat = tegak lurus)
    final radians = math.atan2(dx.abs(), dy.abs());
    final degrees = radians * (180.0 / math.pi);
    final confidence = (noseLandmark.likelihood +
            leftShoulder.likelihood +
            rightShoulder.likelihood) /
        3.0;

    return JointAngle(
      type: type,
      angle: degrees,
      confidence: confidence,
    );
  }
}
