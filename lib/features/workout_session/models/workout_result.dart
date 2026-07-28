import 'workout_summary.dart';

/// Hasil akhir keseluruhan sesi latihan.
class WorkoutResult {
  const WorkoutResult({
    required this.isSuccess,
    required this.summary,
    this.errorMessage,
  });

  final bool isSuccess;
  final WorkoutSummary summary;
  final String? errorMessage;
}
