import '../../workout_engine/models/exercise_definition.dart';
import '../models/full_exercise_definition.dart';
import '../repository/exercise_repository.dart';
import '../services/exercise_loader.dart';

/// Implementasi [ExerciseRepository] yang memuat data secara terdesentralisasi dari file JSON Asset (`assets/exercises/exercises.json`).
class AssetExerciseRepositoryImpl implements ExerciseRepository {
  AssetExerciseRepositoryImpl({
    ExerciseLoader? loader,
  }) : _loader = loader ?? const ExerciseLoader();

  final ExerciseLoader _loader;
  List<FullExerciseDefinition>? _cachedExercises;

  @override
  Future<List<FullExerciseDefinition>> getAllExercises() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    _cachedExercises = await _loader.loadExercisesFromAsset();
    return _cachedExercises!;
  }

  @override
  Future<FullExerciseDefinition?> getExerciseById(String id) async {
    final list = await getAllExercises();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FullExerciseDefinition>> getExercisesByCategory(String category) async {
    final list = await getAllExercises();
    return list
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<ExerciseDefinition?> getWorkoutExerciseDefinition(String id) async {
    final full = await getExerciseById(id);
    return full?.toWorkoutExerciseDefinition();
  }
}
