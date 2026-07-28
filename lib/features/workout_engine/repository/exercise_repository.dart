import '../models/exercise_definition.dart';

/// Contract repository untuk mengakses daftar latihan fisik.
abstract class ExerciseRepository {
  /// Mendapatkan seluruh daftar latihan fisik yang tersedia.
  List<ExerciseDefinition> getAllExercises();

  /// Mendapatkan latihan fisik spesifik berdasarkan [id].
  ExerciseDefinition? getExerciseById(String id);
}
