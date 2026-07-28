import '../models/movement_phase.dart';

/// State Machine pengatur fase per gerakan rehabilitasi.
class MovementStateMachine {
  MovementStateMachine({
    required this.startAngle,
    required this.targetAngle,
    this.tolerance = 15.0,
    this.requiredHoldSeconds = 2.0,
  });

  final double startAngle;
  final double targetAngle;
  final double tolerance;
  final double requiredHoldSeconds;

  MovementPhase _currentPhase = MovementPhase.idle;
  DateTime? _holdStartTime;
  double _peakAngle = 0.0;
  double _minAngle = 999.0;
  double _accumulatedHoldSeconds = 0.0;

  MovementPhase get currentPhase => _currentPhase;
  double get peakAngle => _peakAngle;
  double get minAngle => _minAngle;
  double get holdProgress => requiredHoldSeconds > 0
      ? (_accumulatedHoldSeconds / requiredHoldSeconds).clamp(0.0, 1.0)
      : 1.0;

  void reset() {
    _currentPhase = MovementPhase.idle;
    _holdStartTime = null;
    _peakAngle = 0.0;
    _minAngle = 999.0;
    _accumulatedHoldSeconds = 0.0;
  }

  /// Memproses sudut baru per frame dan mengembalikan pergeseran [MovementPhase].
  MovementPhase processFrame(double currentAngle, DateTime now) {
    if (currentAngle > _peakAngle) _peakAngle = currentAngle;
    if (currentAngle < _minAngle) _minAngle = currentAngle;

    final isTargetReached = (currentAngle - targetAngle).abs() <= tolerance ||
        (targetAngle > startAngle && currentAngle >= targetAngle - tolerance) ||
        (targetAngle < startAngle && currentAngle <= targetAngle + tolerance);

    final isNearStart = (currentAngle - startAngle).abs() <= tolerance * 1.5;

    switch (_currentPhase) {
      case MovementPhase.idle:
        if (!isNearStart) {
          _currentPhase = MovementPhase.start;
        }
        break;

      case MovementPhase.start:
        if (isTargetReached) {
          _currentPhase = MovementPhase.hold;
          _holdStartTime = now;
        } else {
          _currentPhase = MovementPhase.movingUp;
        }
        break;

      case MovementPhase.movingUp:
        if (isTargetReached) {
          _currentPhase = MovementPhase.hold;
          _holdStartTime = now;
        }
        break;

      case MovementPhase.hold:
        if (_holdStartTime != null) {
          _accumulatedHoldSeconds = now.difference(_holdStartTime!).inMilliseconds / 1000.0;
        }
        if (_accumulatedHoldSeconds >= requiredHoldSeconds) {
          _currentPhase = MovementPhase.movingDown;
        } else if (!isTargetReached && _accumulatedHoldSeconds < requiredHoldSeconds * 0.5) {
          // Jika keluar dari target zone sebelum 50% hold, kembalikan ke movingUp
          _currentPhase = MovementPhase.movingUp;
          _holdStartTime = null;
        }
        break;

      case MovementPhase.movingDown:
        if (isNearStart) {
          _currentPhase = MovementPhase.completed;
        }
        break;

      case MovementPhase.completed:
        // Siap untuk dipanen oleh RepCounter lalu di-reset
        break;
    }

    return _currentPhase;
  }
}
