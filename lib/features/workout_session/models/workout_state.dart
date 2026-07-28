/// State Machine utama untuk seluruh alur/session rehabilitasi.
enum WorkoutState {
  /// Sesi belum dimulai
  idle,

  /// Persiapan awal sebelum kamera aktif
  preparing,

  /// AI melakukan kalibrasi posisi & pencahayaan kamera
  calibrating,

  /// Kalibrasi berhasil, pengguna dalam posisi siap
  ready,

  /// Hitung mundur (3, 2, 1, Mulai!)
  countdown,

  /// Sesi latihan aktif, AI merekam & menghitung repetisi
  workout,

  /// Jeda antar set (Rest timer)
  rest,

  /// Latihan di-pause oleh pengguna
  paused,

  /// Seluruh set & repetisi telah selesai
  completed,

  /// Latihan dibatalkan pengguna atau karena darurat
  cancelled,

  /// Terjadi kesalahan (misal kamera terputus)
  error,
}

extension WorkoutStateExtension on WorkoutState {
  bool get isIdle => this == WorkoutState.idle;
  bool get isPreparing => this == WorkoutState.preparing;
  bool get isCalibrating => this == WorkoutState.calibrating;
  bool get isReady => this == WorkoutState.ready;
  bool get isCountdown => this == WorkoutState.countdown;
  bool get isWorkout => this == WorkoutState.workout;
  bool get isRest => this == WorkoutState.rest;
  bool get isPaused => this == WorkoutState.paused;
  bool get isCompleted => this == WorkoutState.completed;
  bool get isCancelled => this == WorkoutState.cancelled;
  bool get isError => this == WorkoutState.error;

  /// Pesan status dalam Bahasa Indonesia untuk UI.
  String get displayName {
    switch (this) {
      case WorkoutState.idle:
        return 'Belum Dimulai';
      case WorkoutState.preparing:
        return 'Mempersiapkan...';
      case WorkoutState.calibrating:
        return 'Kalibrasi Kamera';
      case WorkoutState.ready:
        return 'Siap Dimulai';
      case WorkoutState.countdown:
        return 'Hitung Mundur';
      case WorkoutState.workout:
        return 'Latihan Berlangsung';
      case WorkoutState.rest:
        return 'Istirahat Set';
      case WorkoutState.paused:
        return 'Di-pause';
      case WorkoutState.completed:
        return 'Selesai!';
      case WorkoutState.cancelled:
        return 'Dibatalkan';
      case WorkoutState.error:
        return 'Kesalahan Sensor';
    }
  }
}
