import '../../workout_engine/models/exercise_definition.dart';
import '../models/full_exercise_definition.dart';

/// Contract repository abstrak untuk Exercise Content Management System (ECMS).
abstract class ExerciseRepository {
  /// Mengambil seluruh daftar latihan dari sumber data ECMS.
  Future<List<FullExerciseDefinition>> getAllExercises();

  /// Mengambil latihan spesifik berdasarkan [id].
  Future<FullExerciseDefinition?> getExerciseById(String id);

  /// Mengambil latihan berdasarkan kategori (Warm Up, Range of Motion, Strength, Cardio, Cooldown).
  Future<List<FullExerciseDefinition>> getExercisesByCategory(String category);

  /// Mengonversi dan mengambil [ExerciseDefinition] untuk digunakan oleh Workout Engine.
  Future<ExerciseDefinition?> getWorkoutExerciseDefinition(String id);
}
