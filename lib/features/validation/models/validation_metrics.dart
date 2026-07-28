/// Model data 9 metrik utama AI Validation Dashboard.
class ValidationMetrics {
  const ValidationMetrics({
    required this.fps,
    required this.processingTimeMs,
    required this.poseConfidence,
    required this.trackingStability,
    required this.cameraDistanceMeters,
    required this.lightingScore,
    required this.poseQualityScore,
    required this.latencyMs,
    required this.currentRom,
  });

  /// 1. Frame Rate Stream Kamera (FPS)
  final double fps;

  /// 2. Waktu Pemrosesan Frame (ms)
  final double processingTimeMs;

  /// 3. Tingkat Kepercayaan Deteksi Pose (0.0 s/d 100.0%)
  final double poseConfidence;

  /// 4. Kestabilan Tracking Landmark (0.0 s/d 100.0%)
  final double trackingStability;

  /// 5. Jarak Pengguna ke Kamera (Meter)
  final double cameraDistanceMeters;

  /// 6. Skor Kualitas Pencahayaan Lingkungan (0.0 s/d 100.0%)
  final double lightingScore;

  /// 7. Skor Kualitas Pose Keseluruhan (0.0 s/d 100.0%)
  final double poseQualityScore;

  /// 8. Latensi Total Pipeline (ms)
  final double latencyMs;

  /// 9. Current ROM Bahu/Sendi Utama (Derajat °)
  final double currentRom;

  factory ValidationMetrics.initial() {
    return const ValidationMetrics(
      fps: 30.0,
      processingTimeMs: 16.0,
      poseConfidence: 90.0,
      trackingStability: 85.0,
      cameraDistanceMeters: 2.0,
      lightingScore: 80.0,
      poseQualityScore: 88.0,
      latencyMs: 33.0,
      currentRom: 140.0,
    );
  }
}
