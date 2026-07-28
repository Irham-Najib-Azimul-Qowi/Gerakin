/// Service pengelola durasi istirahat antar set (Rest Timer).
class RestTimer {
  RestTimer();

  int _targetSeconds = 0;
  int _elapsedMilliseconds = 0;
  bool _isActive = false;

  int get targetSeconds => _targetSeconds;
  int get remainingSeconds {
    final remainingMs = (_targetSeconds * 1000) - _elapsedMilliseconds;
    return (remainingMs / 1000).ceil().clamp(0, _targetSeconds);
  }

  bool get isActive => _isActive;
  bool get isCompleted => _isActive && _elapsedMilliseconds >= (_targetSeconds * 1000);

  /// Memulai countdown istirahat untuk [seconds] detik.
  void start(int seconds) {
    _targetSeconds = seconds;
    _elapsedMilliseconds = 0;
    _isActive = seconds > 0;
  }

  /// Update delta waktu berlalu dalam milidetik.
  bool update(int deltaMilliseconds) {
    if (!_isActive || isCompleted) return false;

    _elapsedMilliseconds += deltaMilliseconds;
    if (_elapsedMilliseconds >= (_targetSeconds * 1000)) {
      _elapsedMilliseconds = _targetSeconds * 1000;
      return true;
    }

    return false;
  }

  /// Reset timer.
  void reset() {
    _targetSeconds = 0;
    _elapsedMilliseconds = 0;
    _isActive = false;
  }
}
