import '../domain/repositories/user_repository.dart';
import '../models/assessment_profile.dart';

/// Layanan untuk mengelola alur penaksiran fisik awal pengguna (Assessment Wizard).
class AssessmentWizardService {
  final UserRepository _repository;

  AssessmentWizardService(this._repository);

  /// Menghitung tingkat mobilitas berdasarkan skor penilaian.
  String calculateMobilityLevel({
    required int upperBodyScore,
    required int coreScore,
    required int enduranceScore,
  }) {
    final avg = (upperBodyScore + coreScore + enduranceScore) / 3.0;
    if (avg < 40.0) {
      return 'beginner';
    } else if (avg < 75.0) {
      return 'intermediate';
    } else {
      return 'advanced';
    }
  }

  /// Memvalidasi input skor penilaian (skala 0 - 100).
  bool validateScore(int score) {
    return score >= 0 && score <= 100;
  }

  /// Menyimpan hasil penaksiran fisik pengguna.
  Future<void> saveAssessmentResult({
    required int userId,
    required int upperBodyScore,
    required int coreScore,
    required int enduranceScore,
  }) async {
    final assessment = AssessmentProfile(
      userId: userId,
      upperBodyMobilityScore: upperBodyScore,
      coreStabilityScore: coreScore,
      enduranceLevel: enduranceScore,
      completedAt: DateTime.now(),
    );
    await _repository.saveAssessment(assessment);
  }
}
