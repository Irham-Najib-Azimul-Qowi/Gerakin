import 'dart:async';

/// Service timer hitung mundur periode istirahat (Rest Timer) antar set.
class RestTimer {
  RestTimer();

  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isActive = false;

  int get secondsRemaining => _secondsRemaining;
  bool get isActive => _isActive;

  void startRest(
    int durationSeconds, {
    required Function(int remaining) onTick,
    required Function() onFinished,
  }) {
    cancel();
    _secondsRemaining = durationSeconds;
    _isActive = true;

    onTick(_secondsRemaining);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        _secondsRemaining -= 1;
        onTick(_secondsRemaining);
      } else {
        _secondsRemaining = 0;
        _isActive = false;
        timer.cancel();
        onTick(0);
        onFinished();
      }
    });
  }

  void skipRest({required Function() onFinished}) {
    cancel();
    _secondsRemaining = 0;
    _isActive = false;
    onFinished();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
  }
}
