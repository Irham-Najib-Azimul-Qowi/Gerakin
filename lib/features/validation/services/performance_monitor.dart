/// Service pemantau performa real-time (Performance Monitor).
///
/// Memantau:
/// - FPS Stream Kamera
/// - Processing Time (ms)
/// - Total Latency (ms)
class PerformanceMonitor {
  PerformanceMonitor();

  int _frameCount = 0;
  DateTime? _lastFpsCheckTime;
  double _currentFps = 30.0;
  double _lastProcessingTimeMs = 16.0;

  double get currentFps => _currentFps;
  double get lastProcessingTimeMs => _lastProcessingTimeMs;
  double get totalLatencyMs => _lastProcessingTimeMs + 15.0;

  /// Mencatat 1 frame yang baru saja diproses dalam durasi [processingTimeMs].
  void recordFrameProcessing(double processingTimeMs) {
    _frameCount++;
    _lastProcessingTimeMs = processingTimeMs;

    final now = DateTime.now();
    _lastFpsCheckTime ??= now;

    final elapsedMs = now.difference(_lastFpsCheckTime!).inMilliseconds;
    if (elapsedMs >= 1000) {
      _currentFps = (_frameCount * 1000.0 / elapsedMs).clamp(1.0, 120.0);
      _frameCount = 0;
      _lastFpsCheckTime = now;
    }
  }

  void reset() {
    _frameCount = 0;
    _lastFpsCheckTime = null;
    _currentFps = 30.0;
    _lastProcessingTimeMs = 16.0;
  }
}
