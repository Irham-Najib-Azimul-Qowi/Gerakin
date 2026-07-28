import 'body_posture.dart';
import 'joint_angle.dart';
import 'motion_validation.dart';
import 'movement_state.dart';

/// Output utama Motion Engine pada setiap frame.
///
/// Menyediakan informasi biomekanik lengkap yang akan dikonsumsi oleh
/// Workout Engine pada tahap selanjutnya (repetition counting, form feedback, dll).
class MotionAnalysis {
  const MotionAnalysis({
    required this.jointAngles,
    required this.posture,
    required this.movementState,
    required this.validationStatus,
    required this.timestamp,
  });

  /// Map seluruh sudut sendi terhitung (misal: leftElbow, rightKnee, dll).
  final Map<JointType, JointAngle> jointAngles;

  /// Analisis postur tubuh.
  final BodyPosture posture;

  /// Arah gerakan saat ini (movingUp, movingDown, static).
  final MovementState movementState;

  /// Status validasi kualitas gerakan.
  final MotionValidationStatus validationStatus;

  /// Timestamp tepat saat analisis dieksekusi.
  final DateTime timestamp;

  /// Mendapatkan sudut sendi spesifik jika ada.
  JointAngle? getAngle(JointType type) => jointAngles[type];

  @override
  String toString() =>
      'MotionAnalysis(state: ${movementState.name}, status: ${validationStatus.name}, timestamp: $timestamp)';
}
