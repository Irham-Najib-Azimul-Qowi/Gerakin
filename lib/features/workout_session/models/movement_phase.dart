/// Fase gerakan per repetisi dalam State Machine Rep Counting.
enum MovementPhase {
  /// Posisi netral/diam sebelum memulai gerakan
  idle,

  /// Inisiasi gerakan (subjek bergerak meninggalkan posisi idle)
  start,

  /// Fase konsentrik / bergerak menuju puncak (Flexion/Extension)
  movingUp,

  /// Tahan posisi puncak (Isometric hold)
  hold,

  /// Fase eksentrik / kembali perlahan ke posisi awal
  movingDown,

  /// Repetisi berhasil diselesaikan penuh
  completed,
}

extension MovementPhaseExtension on MovementPhase {
  bool get isIdle => this == MovementPhase.idle;
  bool get isStart => this == MovementPhase.start;
  bool get isMovingUp => this == MovementPhase.movingUp;
  bool get isHold => this == MovementPhase.hold;
  bool get isMovingDown => this == MovementPhase.movingDown;
  bool get isCompleted => this == MovementPhase.completed;

  String get displayName {
    switch (this) {
      case MovementPhase.idle:
        return 'Posisi Awal';
      case MovementPhase.start:
        return 'Mulai Gerakan';
      case MovementPhase.movingUp:
        return 'Naikkan Sendi';
      case MovementPhase.hold:
        return 'Tahan Posisi';
      case MovementPhase.movingDown:
        return 'Turunkan Perlahan';
      case MovementPhase.completed:
        return 'Repetisi Selesai!';
    }
  }
}
