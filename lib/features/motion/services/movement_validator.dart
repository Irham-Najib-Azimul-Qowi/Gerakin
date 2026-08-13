import '../../camera/models/detected_pose.dart';
import '../models/joint_angle.dart';
import '../models/motion_tracking_constants.dart';
import '../models/motion_validation.dart';
import '../models/movement_state.dart';

/// Service validator kualitas gerakan biomekanik.
///
/// Memeriksa keabsahan data frame pose berdasarkan:
/// - Visibilitas landmark (outOfRange)
/// - Kecepatan eksekusi (tooFast / tooSlow)
/// - Kelengkapan rentang gerak (incomplete vs valid)
class MovementValidator {
  const MovementValidator({
    this.maxAngularVelocityDegPerSec = 220.0,
    this.minAngularVelocityDegPerSec = 5.0,
  });

  /// Batas kecepatan sudut maksimal dalam derajat per detik.
  final double maxAngularVelocityDegPerSec;

  /// Batas kecepatan sudut minimal dalam derajat per detik.
  final double minAngularVelocityDegPerSec;

  /// Memvalidasi status gerakan dari frame saat ini.
  MotionValidationStatus validate({
    required DetectedPose? pose,
    required Map<JointType, JointAngle> jointAngles,
    required MovementState movementState,
    double? angularVelocityDegPerSec,
    double minConfidence = MotionTrackingConstants.kMinLandmarkConfidence,
  }) {
    // 1. Periksa ketersediaan pose & jangkauan sensor
    if (pose == null || pose.landmarks.isEmpty) {
      return MotionValidationStatus.outOfRange;
    }

    final validLandmarksCount = pose.landmarks.values
        .where((lm) => lm.isValid(minConfidence))
        .length;

    // Jika kurang dari 8 landmark utama terdeteksi
    if (validLandmarksCount < 8) {
      return MotionValidationStatus.outOfRange;
    }

    // 2. Periksa Kecepatan Gerakan (jika data kecepatan tersedia)
    if (angularVelocityDegPerSec != null && !movementState.isStatic) {
      final absVelocity = angularVelocityDegPerSec.abs();
      if (absVelocity > maxAngularVelocityDegPerSec) {
        return MotionValidationStatus.tooFast;
      }
      if (absVelocity < minAngularVelocityDegPerSec) {
        return MotionValidationStatus.tooSlow;
      }
    }

    // 3. Status Default
    return MotionValidationStatus.valid;
  }
}
