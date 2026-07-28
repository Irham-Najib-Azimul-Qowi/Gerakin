/// Enum State Machine utama untuk Workout Engine.
enum WorkoutState {
  /// Sesi belum dimulai atau di-pause.
  idle,

  /// Pengguna bersiap di depan kamera, menunggu posisi awal (starting posture).
  ready,

  /// Pengguna sedang melakukan gerakan menuju sudut target (puncak).
  moving,

  /// Pengguna menahan posisi puncak (isometric hold).
  hold,

  /// Pengguna sedang kembali ke posisi awal (eccentric / return path).
  returning,

  /// Latihan / set telah selesai secara penuh.
  completed,
}

/// Extension helper untuk [WorkoutState].
extension WorkoutStateX on WorkoutState {
  bool get isIdle => this == WorkoutState.idle;
  bool get isReady => this == WorkoutState.ready;
  bool get isMoving => this == WorkoutState.moving;
  bool get isHold => this == WorkoutState.hold;
  bool get isReturning => this == WorkoutState.returning;
  bool get isCompleted => this == WorkoutState.completed;

  /// Status teks yang ramah pengguna.
  String get statusText {
    switch (this) {
      case WorkoutState.idle:
        return 'Siap Dimulai';
      case WorkoutState.ready:
        return 'Ambil Posisi Awal';
      case WorkoutState.moving:
        return 'Lakukan Gerakan';
      case WorkoutState.hold:
        return 'Tahan Posisi';
      case WorkoutState.returning:
        return 'Kembali ke Posisi Awal';
      case WorkoutState.completed:
        return 'Latihan Selesai!';
    }
  }
}
