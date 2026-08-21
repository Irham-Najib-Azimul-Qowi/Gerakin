import 'exercise_type.dart';

/// Konfigurasi threshold, target, dan pengaman untuk setiap gerakan latihan.
class ExerciseConfig {
  const ExerciseConfig({
    required this.exerciseType,
    this.targetSets = 3,
    this.targetRepsPerSet = 10,
    this.restDurationSeconds = 25,
    this.minRepDurationMs = 900,
    this.minLandmarkLikelihood = 0.5,
    this.startAngleThreshold = 30.0,
    this.middleAngleThreshold = 60.0,
    this.targetAngleThreshold = 85.0,
    this.hysteresisTolerance = 12.0,
  });

  final ExerciseType exerciseType;
  final int targetSets;
  final int targetRepsPerSet;
  final int restDurationSeconds;
  final int minRepDurationMs;
  final double minLandmarkLikelihood;
  final double startAngleThreshold;
  final double middleAngleThreshold;
  final double targetAngleThreshold;
  final double hysteresisTolerance;

  factory ExerciseConfig.forType(ExerciseType type) {
    switch (type) {
      case ExerciseType.sideArmRaise:
        return ExerciseConfig(
          exerciseType: type,
          targetSets: 3,
          targetRepsPerSet: 10,
          restDurationSeconds: 25,
          startAngleThreshold: 25.0,  // Elevasi lengan dekat tubuh (< 25°)
          middleAngleThreshold: 55.0, // Terangkat sedang (30°–65°)
          targetAngleThreshold: 80.0, // Elevasi sejajar bahu (80°–105°)
          hysteresisTolerance: 10.0,
        );

      case ExerciseType.bicepCurl:
        return ExerciseConfig(
          exerciseType: type,
          targetSets: 3,
          targetRepsPerSet: 10,
          restDurationSeconds: 25,
          startAngleThreshold: 145.0, // Siku lurus ke bawah (>= 145°)
          middleAngleThreshold: 100.0, // Siku menekuk sedang (90°–130°)
          targetAngleThreshold: 65.0,  // Curl penuh (<= 65°)
          hysteresisTolerance: 12.0,
        );

      case ExerciseType.neckRotation:
        return ExerciseConfig(
          exerciseType: type,
          targetSets: 2,
          targetRepsPerSet: 8,
          restDurationSeconds: 20,
          minRepDurationMs: 1400,     // Gerakan leher lebih lambat & hati-hati
          startAngleThreshold: 5.0,   // Hidung lurus ke depan
          middleAngleThreshold: 20.0, // Putaran sedang
          targetAngleThreshold: 40.0, // Putaran samping penuh
          hysteresisTolerance: 8.0,
        );
    }
  }
}
