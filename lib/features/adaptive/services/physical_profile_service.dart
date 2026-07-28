import '../models/assessment_result.dart';
import '../models/physical_profile.dart';
import 'adaptive_difficulty_engine.dart';

/// Service pengelola profil fisik adaptif pengguna.
class PhysicalProfileService {
  PhysicalProfileService({
    AdaptiveDifficultyEngine? difficultyEngine,
  }) : _difficultyEngine = difficultyEngine ?? const AdaptiveDifficultyEngine();

  final AdaptiveDifficultyEngine _difficultyEngine;
  PhysicalProfile _currentProfile = PhysicalProfile.defaultProfile();

  PhysicalProfile get currentProfile => _currentProfile;

  /// Memperbarui profil fisik pengguna dari hasil [AssessmentResult].
  PhysicalProfile updateProfileFromAssessment(AssessmentResult assessment) {
    final level = _difficultyEngine.calculateDifficultyLevel(
      shoulderRom: assessment.shoulderRom,
      elbowRom: assessment.elbowRom,
      stabilityScore: assessment.movementStability,
    );

    final rating = _difficultyEngine.getRatingForLevel(level);

    _currentProfile = PhysicalProfile(
      shoulderRom: assessment.shoulderRom,
      elbowRom: assessment.elbowRom,
      stabilityScore: assessment.movementStability,
      difficultyLevel: level,
      fitnessRating: rating,
      lastUpdated: DateTime.now(),
    );

    return _currentProfile;
  }
}
