import '../models/full_exercise_definition.dart';

/// Service penyaringan latihan (Exercise Filter).
class ExerciseFilter {
  const ExerciseFilter();

  /// Menyaring daftar latihan berdasarkan Kategori, Difficulty (1-5), dan Tag.
  List<FullExerciseDefinition> filter({
    required List<FullExerciseDefinition> exercises,
    String? category,
    int? difficultyLevel,
    String? tag,
  }) {
    return exercises.where((e) {
      if (category != null && category.isNotEmpty && category != 'All') {
        if (e.category.toLowerCase() != category.toLowerCase()) return false;
      }

      if (difficultyLevel != null && difficultyLevel > 0) {
        if (e.difficulty != difficultyLevel) return false;
      }

      if (tag != null && tag.isNotEmpty) {
        if (!e.tags.map((t) => t.toLowerCase()).contains(tag.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
