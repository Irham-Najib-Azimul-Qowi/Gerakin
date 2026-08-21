/// Fase gerakan dalam sesi latihan adaptif.
enum MovementPhase {
  /// Posisi awal / persiapan
  start,

  /// Fase transisi menuju gerakan target
  middle,

  /// Puncak gerakan target
  target,

  /// Fase kembali ke posisi awal
  returning,
}
