import '../models/exercise_definition.dart';

/// Service pelacak transisi fase dan penghitung repetisi (Repetition Counter).
class RepetitionCounter {
  RepetitionCounter();

  int _completedReps = 0;
  int _completedSets = 0;

  int get completedReps => _completedReps;
  int get completedSets => _completedSets;

  /// Menambah jumlah repetisi yang selesai.
  void incrementRep() {
    _completedReps++;
  }

  /// Menambah jumlah set yang selesai.
  void incrementSet() {
    _completedSets++;
    _completedReps = 0; // Reset rep counter untuk set baru
  }

  /// Memeriksa apakah set saat ini telah mencapai target repetisi.
  bool isSetCompleted(ExerciseDefinition exercise) {
    return _completedReps >= exercise.repetitionTarget;
  }

  /// Memeriksa apakah seluruh set telah selesai.
  bool isWorkoutCompleted(ExerciseDefinition exercise) {
    return _completedSets >= exercise.setTarget;
  }

  /// Reset penghitung.
  void reset() {
    _completedReps = 0;
    _completedSets = 0;
  }

  void setRepsAndSets(int reps, int sets) {
    _completedReps = reps;
    _completedSets = sets;
  }
}
