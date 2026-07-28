import '../models/joint_angle.dart';
import '../models/movement_state.dart';

/// Service penentu arah gerakan biomekanik (movingUp, movingDown, static).
///
/// Mengacak jejak perubahan sudut sendi utama terhadap waktu ($\Delta \theta$).
class MovementAnalyzer {
  MovementAnalyzer({
    this.deltaThresholdDegrees = 1.8,
    this.windowSize = 3,
  });

  /// Ambang batas minimal delta derajat untuk menganggap gerakan aktif (bukan noise).
  final double deltaThresholdDegrees;

  /// Jumlah frame history yang digunakan untuk smoothing trend arah.
  final int windowSize;

  final Map<JointType, List<double>> _angleHistory = {};

  /// Menganalisis [MovementState] berdasarkan perubahan sudut [targetJoint] saat ini.
  MovementState analyzeDirection({
    required JointType targetJoint,
    required double currentAngle,
  }) {
    final history = _angleHistory.putIfAbsent(targetJoint, () => []);
    history.add(currentAngle);

    if (history.length > windowSize) {
      history.removeAt(0);
    }

    if (history.length < 2) {
      return MovementState.static;
    }

    // Hitung rata-rata perubahan per frame
    final double delta = history.last - history.first;

    if (delta > deltaThresholdDegrees) {
      return MovementState.movingUp;
    } else if (delta < -deltaThresholdDegrees) {
      return MovementState.movingDown;
    } else {
      return MovementState.static;
    }
  }

  /// Reset riwayat pergerakan.
  void reset([JointType? targetJoint]) {
    if (targetJoint != null) {
      _angleHistory.remove(targetJoint);
    } else {
      _angleHistory.clear();
    }
  }
}
