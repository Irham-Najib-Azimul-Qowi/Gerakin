import '../models/full_exercise_definition.dart';
import 'exercise_repository.dart';

/// Repository pemberi rekomendasi latihan adaptif terstruktur.
class ExerciseRecommendationRepository {
  const ExerciseRecommendationRepository({
    required this.repository,
  });

  final ExerciseRepository repository;

  /// Merekomendasikan paket latihan berdasarkan level kesulitan (1-5) dan kategori pilihan.
  Future<List<FullExerciseDefinition>> getRecommendedPack({
    required int difficultyLevel,
    String? category,
  }) async {
    final all = await repository.getAllExercises();

    return all.where((e) {
      if (category != null && category.isNotEmpty && category != 'All') {
        if (e.category.toLowerCase() != category.toLowerCase()) return false;
      }
      return (e.difficulty - difficultyLevel).abs() <= 1;
    }).toList();
  }
}
