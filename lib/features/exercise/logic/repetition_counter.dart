import '../domain/exercise_phase.dart';

enum RepetitionState {
  waitingStart,
  movingUp,
  reachedTarget,
  returning,
}

/// State Machine pengatur hitungan repetisi (Repetition Counter) dengan Hysteresis & Debounce.
class RepetitionCounter {
  RepetitionCounter({
    required this.targetReps,
    this.minRepDurationMs = 900,
    this.hysteresisTolerance = 10.0,
  });

  final int targetReps;
  final int minRepDurationMs;
  final double hysteresisTolerance;

  RepetitionState _state = RepetitionState.waitingStart;
  MovementPhase _currentPhase = MovementPhase.start;

  int _completedReps = 0;
  DateTime? _repStartTime;
  DateTime? _lastCompletedTime;

  // Getters
  RepetitionState get state => _state;
  MovementPhase get currentPhase => _currentPhase;
  int get completedReps => _completedReps;
  bool get isSetComplete => _completedReps >= targetReps;

  void resetReps() {
    _completedReps = 0;
    _state = RepetitionState.waitingStart;
    _currentPhase = MovementPhase.start;
    _repStartTime = null;
    _lastCompletedTime = null;
  }

  /// Memproses sudut saat ini dan memperbarui state repetisi.
  ///
  /// Mengembalikan `true` jika repetisi baru saja berhasil dihitung.
  bool processAngle({
    required double currentAngle,
    required double startThreshold,
    required double middleThreshold,
    required double targetThreshold,
    bool isGreaterTarget = true,
  }) {
    final now = DateTime.now();

    // Tentukan apakah target tercapai dengan toleransi hysteresis
    final bool isAtStart = isGreaterTarget
        ? currentAngle <= startThreshold + hysteresisTolerance
        : currentAngle >= startThreshold - hysteresisTolerance;

    final bool isAtMiddle = isGreaterTarget
        ? (currentAngle >= middleThreshold - hysteresisTolerance &&
            currentAngle < targetThreshold - hysteresisTolerance)
        : (currentAngle <= middleThreshold + hysteresisTolerance &&
            currentAngle > targetThreshold + hysteresisTolerance);

    final bool isAtTarget = isGreaterTarget
        ? currentAngle >= targetThreshold - hysteresisTolerance
        : currentAngle <= targetThreshold + hysteresisTolerance;

    // Update MovementPhase untuk pengontrol tampilan gambar panduan
    if (isAtTarget) {
      _currentPhase = MovementPhase.target;
    } else if (isAtMiddle || _state == RepetitionState.movingUp || _state == RepetitionState.returning) {
      _currentPhase = MovementPhase.middle;
    } else {
      _currentPhase = MovementPhase.start;
    }

    // State Machine Evaluasi Repetisi
    switch (_state) {
      case RepetitionState.waitingStart:
        if (isAtStart) {
          _repStartTime = now;
        } else if (!isAtStart && _repStartTime != null) {
          _state = RepetitionState.movingUp;
        }
        break;

      case RepetitionState.movingUp:
        if (isAtTarget) {
          _state = RepetitionState.reachedTarget;
        } else if (isAtStart) {
          // Pengguna kembali ke awal tanpa mencapai target -> reset tanpa hitung
          _state = RepetitionState.waitingStart;
          _repStartTime = null;
        }
        break;

      case RepetitionState.reachedTarget:
        if (!isAtTarget) {
          _state = RepetitionState.returning;
        }
        break;

      case RepetitionState.returning:
        if (isAtStart) {
          // Debounce check: minimal durasi 1 repetisi (mencegah false rep)
          final durationMs = _repStartTime != null
              ? now.difference(_repStartTime!).inMilliseconds
              : 0;

          final timeSinceLastRep = _lastCompletedTime != null
              ? now.difference(_lastCompletedTime!).inMilliseconds
              : 9999;

          if (durationMs >= minRepDurationMs && timeSinceLastRep >= minRepDurationMs) {
            _completedReps++;
            _lastCompletedTime = now;
            _state = RepetitionState.waitingStart;
            _repStartTime = null;
            return true; // Repetisi valid berhasil dihitung!
          } else {
            _state = RepetitionState.waitingStart;
            _repStartTime = null;
          }
        }
        break;
    }

    return false;
  }
}
