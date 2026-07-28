/// Model hasil pengujian kemampuan fisik awal (Initial Assessment Result).
class AssessmentResult {
  const AssessmentResult({
    required this.shoulderRom,
    required this.elbowRom,
    required this.movementStability,
    required this.movementSpeed,
    required this.poseConfidence,
    required this.assessedAt,
  });

  /// Rentang gerak bahu (Shoulder Range of Motion) dalam derajat.
  final double shoulderRom;

  /// Rentang gerak siku (Elbow Range of Motion) dalam derajat.
  final double elbowRom;

  /// Skor kestabilan gerak (Movement Stability) 0.0 s/d 100.0.
  final double movementStability;

  /// Kecepatan gerak rata-rata (Movement Speed) dalam derajat per detik.
  final double movementSpeed;

  /// Rata-rata tingkat kepercayaan deteksi pose (Pose Confidence) 0.0 s/d 1.0.
  final double poseConfidence;

  /// Waktu pelaksanaan penilaian.
  final DateTime assessedAt;

  factory AssessmentResult.initial() {
    return AssessmentResult(
      shoulderRom: 140.0,
      elbowRom: 155.0,
      movementStability: 85.0,
      movementSpeed: 45.0,
      poseConfidence: 0.9,
      assessedAt: DateTime.now(),
    );
  }
}
