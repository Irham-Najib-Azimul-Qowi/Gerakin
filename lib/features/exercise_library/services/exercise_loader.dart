import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/full_exercise_definition.dart';
import 'exercise_validator.dart';

/// Service pemuat data latihan dari file asset JSON (Exercise Loader).
class ExerciseLoader {
  const ExerciseLoader({
    AssetBundle? initialAssetBundle,
    ExerciseValidator? validator,
  })  : _assetBundle = initialAssetBundle,
        _validator = validator ?? const ExerciseValidator();

  final AssetBundle? _assetBundle;
  final ExerciseValidator _validator;

  /// Memuat daftar [FullExerciseDefinition] dari path asset JSON.
  Future<List<FullExerciseDefinition>> loadExercisesFromAsset({
    String assetPath = 'assets/exercises/exercises.json',
  }) async {
    final bundle = _assetBundle ?? rootBundle;
    final jsonString = await bundle.loadString(assetPath);
    return parseExercisesFromJsonString(jsonString);
  }

  /// Memproses JSON String menjadi daftar [FullExerciseDefinition].
  List<FullExerciseDefinition> parseExercisesFromJsonString(String jsonString) {
    final List<dynamic> parsedList = jsonDecode(jsonString) as List<dynamic>;
    final result = <FullExerciseDefinition>[];

    for (final item in parsedList) {
      if (item is Map<String, dynamic> && _validator.validateJsonMap(item)) {
        final exercise = FullExerciseDefinition.fromJson(item);
        if (_validator.validateDefinition(exercise)) {
          result.add(exercise);
        }
      }
    }

    return result;
  }
}
