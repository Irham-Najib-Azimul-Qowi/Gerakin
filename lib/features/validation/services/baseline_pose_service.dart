import '../../camera/models/detected_pose.dart';
import '../../motion/models/body_posture.dart';

/// Service penangkap & verifikasi pose awal lurus (Baseline Pose Service).
class BaselinePoseService {
  BaselinePoseService();

  bool _isBaselineCaptured = false;
  BodyPosture? _capturedBaseline;

  bool get isBaselineCaptured => _isBaselineCaptured;
  BodyPosture? get capturedBaseline => _capturedBaseline;

  /// Memeriksa dan menangkap baseline posture jika posisi berdiri sudah tegak lurus & simetris.
  bool verifyAndCaptureBaseline({
    required DetectedPose pose,
    required BodyPosture posture,
  }) {
    double totalConfidence = 0.0;
    for (final landmark in pose.landmarks.values) {
      totalConfidence += landmark.likelihood;
    }
    final avgConfidence = pose.landmarks.isNotEmpty
        ? totalConfidence / pose.landmarks.length
        : 0.0;

    if (posture.isShoulderSymmetric &&
        posture.torsoOrientation == TorsoOrientation.upright &&
        avgConfidence >= 0.8) {
      _capturedBaseline = posture;
      _isBaselineCaptured = true;
      return true;
    }
    return false;
  }

  void reset() {
    _isBaselineCaptured = false;
    _capturedBaseline = null;
  }
}
