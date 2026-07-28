import '../../camera/models/pose_landmark_model.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Hasil validasi kalibrasi posisi & sensor kamera sebelum latihan.
class CalibrationResult {
  const CalibrationResult({
    required this.isFaceDetected,
    required this.isShoulderDetected,
    required this.isHipDetected,
    required this.isDistanceValid,
    required this.isLightingValid,
    required this.isEntireBodyVisible,
    required this.averageConfidence,
    required this.instructionMessage,
    required this.isReady,
  });

  final bool isFaceDetected;
  final bool isShoulderDetected;
  final bool isHipDetected;
  final bool isDistanceValid;
  final bool isLightingValid;
  final bool isEntireBodyVisible;
  final double averageConfidence;
  final String instructionMessage;
  final bool isReady;
}

/// Service untuk kalibrasi AI Camera sebelum latihan dimulai.
class WorkoutValidator {
  const WorkoutValidator();

  /// Menilai keberadaan tubuh pengguna di frame kamera secara komprehensif.
  static CalibrationResult validateCalibration(
    List<PoseLandmarkModel> landmarks, {
    double minLandmarkConfidence = 0.5,
  }) {
    if (landmarks.isEmpty) {
      return const CalibrationResult(
        isFaceDetected: false,
        isShoulderDetected: false,
        isHipDetected: false,
        isDistanceValid: false,
        isLightingValid: false,
        isEntireBodyVisible: false,
        averageConfidence: 0.0,
        instructionMessage: 'Posisikan tubuh Anda di depan kamera',
        isReady: false,
      );
    }

    final landmarkMap = <PoseLandmarkType, PoseLandmarkModel>{};
    double totalConfidence = 0.0;

    for (final lm in landmarks) {
      landmarkMap[lm.type] = lm;
      totalConfidence += lm.likelihood;
    }

    final double avgConfidence = totalConfidence / landmarks.length;

    // 1. Face Check (Nose, Ears, Eyes)
    final nose = landmarkMap[PoseLandmarkType.nose];
    final leftEar = landmarkMap[PoseLandmarkType.leftEar];
    final rightEar = landmarkMap[PoseLandmarkType.rightEar];
    final isFaceDetected = (nose != null && nose.isValid(minLandmarkConfidence)) ||
        (leftEar != null && leftEar.isValid(minLandmarkConfidence)) ||
        (rightEar != null && rightEar.isValid(minLandmarkConfidence));

    // 2. Shoulder Check
    final leftShoulder = landmarkMap[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarkMap[PoseLandmarkType.rightShoulder];
    final isShoulderDetected = leftShoulder != null &&
        rightShoulder != null &&
        leftShoulder.isValid(minLandmarkConfidence) &&
        rightShoulder.isValid(minLandmarkConfidence);

    // 3. Hip Check
    final leftHip = landmarkMap[PoseLandmarkType.leftHip];
    final rightHip = landmarkMap[PoseLandmarkType.rightHip];
    final isHipDetected = leftHip != null &&
        rightHip != null &&
        leftHip.isValid(minLandmarkConfidence) &&
        rightHip.isValid(minLandmarkConfidence);

    // 4. Knee / Ankle Check (Full body)
    final leftKnee = landmarkMap[PoseLandmarkType.leftKnee];
    final rightKnee = landmarkMap[PoseLandmarkType.rightKnee];
    final leftAnkle = landmarkMap[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarkMap[PoseLandmarkType.rightAnkle];

    final isLowerBodyVisible = (leftKnee != null && leftKnee.isValid(minLandmarkConfidence)) ||
        (rightKnee != null && rightKnee.isValid(minLandmarkConfidence)) ||
        (leftAnkle != null && leftAnkle.isValid(minLandmarkConfidence)) ||
        (rightAnkle != null && rightAnkle.isValid(minLandmarkConfidence));

    final isEntireBodyVisible = isFaceDetected && isShoulderDetected && isHipDetected && isLowerBodyVisible;

    // 5. Lighting Check based on average confidence
    final isLightingValid = avgConfidence >= 0.55;

    // 6. Distance Check: Cek bahu tidak terlalu dekat / terlalu jauh di frame
    bool isDistanceValid = true;
    String feedback = 'Posisi Sempurna! Bersiaplah...';

    if (isShoulderDetected) {
      final shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
      if (shoulderWidth > 380) {
        isDistanceValid = false;
        feedback = 'Mundur sedikit dari kamera';
      } else if (shoulderWidth < 60) {
        isDistanceValid = false;
        feedback = 'Maju sedikit mendekati kamera';
      }
    }

    if (!isLightingValid) {
      feedback = 'Pencahayaan kurang, pastikan ruangan terang';
    } else if (!isFaceDetected) {
      feedback = 'Posisikan wajah Anda terlihat oleh kamera';
    } else if (!isShoulderDetected) {
      feedback = 'Naikkan kamera agar bahu terlihat jelas';
    } else if (!isHipDetected) {
      feedback = 'Mundur sedikit agar pinggul terlihat';
    } else if (!isEntireBodyVisible) {
      feedback = 'Pastikan seluruh tubuh dari kepala hingga lutut terlihat';
    }

    final isReady = isFaceDetected &&
        isShoulderDetected &&
        isHipDetected &&
        isDistanceValid &&
        isLightingValid &&
        isEntireBodyVisible;

    return CalibrationResult(
      isFaceDetected: isFaceDetected,
      isShoulderDetected: isShoulderDetected,
      isHipDetected: isHipDetected,
      isDistanceValid: isDistanceValid,
      isLightingValid: isLightingValid,
      isEntireBodyVisible: isEntireBodyVisible,
      averageConfidence: avgConfidence,
      instructionMessage: feedback,
      isReady: isReady,
    );
  }
}
