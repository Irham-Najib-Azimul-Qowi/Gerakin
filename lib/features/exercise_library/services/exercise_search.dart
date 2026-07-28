import '../models/full_exercise_definition.dart';

/// Service pencarian teks penuh (Exercise Search).
class ExerciseSearch {
  const ExerciseSearch();

  /// Mencari latihan berdasarkan query teks pada nama, deskripsi, tag, dan otot target.
  List<FullExerciseDefinition> search({
    required List<FullExerciseDefinition> exercises,
    required String query,
  }) {
    if (query.trim().isEmpty) return exercises;

    final q = query.toLowerCase().trim();

    return exercises.where((e) {
      final nameMatch = e.name.toLowerCase().contains(q);
      final descMatch = e.description.toLowerCase().contains(q);
      final tagMatch = e.tags.any((t) => t.toLowerCase().contains(q));
      final muscleMatch = e.targetMuscles.any((m) => m.toLowerCase().contains(q));

      return nameMatch || descMatch || tagMatch || muscleMatch;
    }).toList();
  }
}
