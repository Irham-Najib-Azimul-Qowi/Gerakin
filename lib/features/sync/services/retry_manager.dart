import 'dart:math';

/// Manajer untuk mengelola penundaan dan batas maksimal percobaan ulang (Exponential Backoff).
class RetryManager {
  final int maxRetries;

  RetryManager({this.maxRetries = 5});

  /// Menghitung penundaan (delay) dalam milidetik menggunakan rumus eksponensial backoff.
  int calculateBackoffDelay(
    int retryCount, {
    int initialDelayMs = 1000,
    double multiplier = 2.0,
    int maxDelayMs = 60000,
  }) {
    if (retryCount <= 0) return 0;
    final delay = initialDelayMs * pow(multiplier, retryCount - 1);
    return delay.round().clamp(0, maxDelayMs);
  }

  /// Memvalidasi apakah item masih bisa dicoba kembali.
  bool shouldRetry(int currentRetryCount) {
    return currentRetryCount < maxRetries;
  }
}
