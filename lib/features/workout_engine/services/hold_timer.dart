/// Service pengelola durasi penahanan posisi puncak (Isometric Hold Timer).
class HoldTimer {
  HoldTimer();

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

  /// Memulai timer hold untuk durasi [seconds].
  void start(int seconds) {
    _targetSeconds = seconds;
    _elapsedMilliseconds = 0;
    _isActive = seconds > 0;
  }

  /// Menambah delta waktu yang berlalu dalam milidetik.
  ///
  /// Mengembalikan `true` tepat saat timer baru saja selesai.
  bool update(int deltaMilliseconds) {
    if (!_isActive || isCompleted) return false;

    _elapsedMilliseconds += deltaMilliseconds;
    if (_elapsedMilliseconds >= (_targetSeconds * 1000)) {
      _elapsedMilliseconds = _targetSeconds * 1000;
      return true;
    }

    return false;
  }

  /// Hentikan atau reset timer.
  void reset() {
    _targetSeconds = 0;
    _elapsedMilliseconds = 0;
    _isActive = false;
  }
}
