/// Model data metrik real-time latihan fisik.
class WorkoutMetrics {
  const WorkoutMetrics({
    required this.currentRep,
    required this.currentSet,
    required this.remainingRep,
    required this.remainingSet,
    required this.workoutDurationSeconds,
    required this.holdDurationSeconds,
    required this.restDurationSeconds,
    required this.caloriesEstimate,
    required this.workoutScore,
    required this.exerciseStatus,
  });

  /// Indeks repetisi saat ini (1-indexed).
  final int currentRep;

  /// Indeks set saat ini (1-indexed).
  final int currentSet;

  /// Sisa repetisi pada set ini.
  final int remainingRep;

  /// Sisa set pada latihan ini.
  final int remainingSet;

  /// Total durasi latihan yang telah berjalan dalam detik.
  final int workoutDurationSeconds;

  /// Sisa/durasi penahanan posisi puncak (hold phase) dalam detik.
  final int holdDurationSeconds;

  /// Sisa durasi istirahat (rest phase) dalam detik.
  final int restDurationSeconds;

  /// Estimasi kalori yang terbakar (kcal).
  final double caloriesEstimate;

  /// Skor akurasi dan kualitas gerakan (0.0 s/d 100.0).
  final double workoutScore;

  /// Teks status deskriptif real-time (misal: "Bagus, tahan 3 detik lagi!").
  final String exerciseStatus;

  factory WorkoutMetrics.initial({
    int repTarget = 10,
    int setTarget = 3,
  }) {
    return WorkoutMetrics(
      currentRep: 0,
      currentSet: 1,
      remainingRep: repTarget,
      remainingSet: setTarget,
      workoutDurationSeconds: 0,
      holdDurationSeconds: 0,
      restDurationSeconds: 0,
      caloriesEstimate: 0.0,
      workoutScore: 100.0,
      exerciseStatus: 'Bersiap di depan kamera',
    );
  }

  WorkoutMetrics copyWith({
    int? currentRep,
    int? currentSet,
    int? remainingRep,
    int? remainingSet,
    int? workoutDurationSeconds,
    int? holdDurationSeconds,
    int? restDurationSeconds,
    double? caloriesEstimate,
    double? workoutScore,
    String? exerciseStatus,
  }) {
    return WorkoutMetrics(
      currentRep: currentRep ?? this.currentRep,
      currentSet: currentSet ?? this.currentSet,
      remainingRep: remainingRep ?? this.remainingRep,
      remainingSet: remainingSet ?? this.remainingSet,
      workoutDurationSeconds:
          workoutDurationSeconds ?? this.workoutDurationSeconds,
      holdDurationSeconds: holdDurationSeconds ?? this.holdDurationSeconds,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      caloriesEstimate: caloriesEstimate ?? this.caloriesEstimate,
      workoutScore: workoutScore ?? this.workoutScore,
      exerciseStatus: exerciseStatus ?? this.exerciseStatus,
    );
  }
}
