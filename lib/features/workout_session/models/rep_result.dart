import 'workout_rep.dart';

/// Hasil evaluasi setelah satu repetisi selesai.
class RepResult {
  const RepResult({
    required this.isSuccess,
    required this.rep,
    required this.message,
    required this.shouldTriggerVoice,
  });

  final bool isSuccess;
  final WorkoutRep rep;
  final String message;
  final bool shouldTriggerVoice;
}
