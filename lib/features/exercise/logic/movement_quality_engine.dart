import '../domain/exercise_type.dart';

/// Engine pengukur kualitas & akurasi gerakan real-time (0–100%).
class MovementQualityEngine {
  const MovementQualityEngine();

  /// Menghitung skor akurasi real-time berdasarkan faktor biomekanik latihan.
  double calculateAccuracy({
    required ExerciseType type,
    required double primaryAngle,
    required double targetAngle,
    required double secondaryAngle,
    required double symmetryDifference,
    required double torsoTilt,
  }) {
    switch (type) {
      case ExerciseType.sideArmRaise:
        // 40% pencapaian sudut target, 25% bentuk siku, 20% simetri, 15% stabilitas torso
        final angleScore = (1.0 - ((primaryAngle - targetAngle).abs() / targetAngle)).clamp(0.0, 1.0) * 40.0;
        final elbowScore = (secondaryAngle > 140.0 ? 1.0 : (secondaryAngle / 140.0)).clamp(0.0, 1.0) * 25.0;
        final symmetryScore = (1.0 - (symmetryDifference / 30.0)).clamp(0.0, 1.0) * 20.0;
        final torsoScore = (1.0 - (torsoTilt / 20.0)).clamp(0.0, 1.0) * 15.0;

        return (angleScore + elbowScore + symmetryScore + torsoScore).clamp(0.0, 100.0);

      case ExerciseType.bicepCurl:
        // 45% fleksi siku ROM, 25% stabilitas letak siku, 15% simetri, 15% stabilitas torso
        final flexScore = (1.0 - ((primaryAngle - targetAngle).abs() / 90.0)).clamp(0.0, 1.0) * 45.0;
        final positionScore = (1.0 - (secondaryAngle / 35.0)).clamp(0.0, 1.0) * 25.0;
        final symmetryScore = (1.0 - (symmetryDifference / 25.0)).clamp(0.0, 1.0) * 15.0;
        final torsoScore = (1.0 - (torsoTilt / 20.0)).clamp(0.0, 1.0) * 15.0;

        return (flexScore + positionScore + symmetryScore + torsoScore).clamp(0.0, 100.0);

      case ExerciseType.neckRotation:
        // 50% rotasi leher, 30% stabilitas bahu/torso, 20% kontrol kemiringan kepala
        final rotationScore = (primaryAngle / targetAngle).clamp(0.0, 1.0) * 50.0;
        final shoulderScore = (1.0 - (symmetryDifference / 20.0)).clamp(0.0, 1.0) * 30.0;
        final tiltScore = (1.0 - (torsoTilt / 15.0)).clamp(0.0, 1.0) * 20.0;

        return (rotationScore + shoulderScore + tiltScore).clamp(0.0, 100.0);
    }
  }
}
