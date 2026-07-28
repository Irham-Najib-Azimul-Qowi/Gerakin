/// Enum status arah gerakan biomekanik pengguna.
enum MovementState {
  /// Gerakan sedang naik (extension / concentric / ascent tergantung konteks workout).
  movingUp,

  /// Gerakan sedang turun (flexion / eccentric / descent tergantung konteks workout).
  movingDown,

  /// Pengguna dalam posisi diam/statis (isometric / hold).
  static,
}

/// Extension helper untuk [MovementState].
extension MovementStateX on MovementState {
  bool get isMovingUp => this == MovementState.movingUp;
  bool get isMovingDown => this == MovementState.movingDown;
  bool get isStatic => this == MovementState.static;

  String get label {
    switch (this) {
      case MovementState.movingUp:
        return 'Bergerak Naik';
      case MovementState.movingDown:
        return 'Bergerak Turun';
      case MovementState.static:
        return 'Diam / Statis';
    }
  }
}
