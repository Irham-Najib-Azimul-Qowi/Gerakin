import 'workout_set.dart';

/// Hasil evaluasi setelah satu set selesai.
class SetResult {
  const SetResult({
    required this.isCompleted,
    required this.set,
    required this.restSecondsRemaining,
    required this.hasNextSet,
  });

  final bool isCompleted;
  final WorkoutSet set;
  final int restSecondsRemaining;
  final bool hasNextSet;
}
