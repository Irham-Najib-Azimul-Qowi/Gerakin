/// Konstanta bersama untuk modul Pelacakan Sendi & Gerakan (Motion Tracking Engine).
///
/// Menyediakan nilai ambang tunggal (Single Source of Truth) untuk digunakan
/// di seluruh pipeline: kalkulasi sudut, penapisan jitter, dan validasi gerakan.
abstract class MotionTrackingConstants {
  /// Ambang confidence minimum landmark yang dipakai secara KONSISTEN
  /// di seluruh pipeline motion tracking.
  static const double kMinLandmarkConfidence = 0.5;
}
