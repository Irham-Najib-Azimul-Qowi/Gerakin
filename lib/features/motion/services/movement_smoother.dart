import '../models/joint_angle.dart';

/// Service penapis noise/jitter menggunakan Exponential Moving Average (EMA).
///
/// FORMULA ALGORITMA EMA:
/// $S_t = \alpha \cdot X_t + (1 - \alpha) \cdot S_{t-1}$
///
/// Dimana:
/// - $X_t$: Nilai mentah (raw angle / coordinate) pada frame saat ini
/// - $S_{t-1}$: Nilai terhaluskan dari frame sebelumnya
/// - $\alpha$ (alpha): Faktor kehalusan ($0.0 < \alpha \le 1.0$).
///   Nilai $\alpha = 0.35$ memberikan keseimbangan optimal antara menghilangkan jitter
///   kamera dan mempertahankan respon realtime.
class MovementSmoother {
  MovementSmoother({this.defaultAlpha = 0.35});

  final double defaultAlpha;
  final Map<String, double> _history = {};

  /// Memperhalus nilai double mentah berdasarkan [key] unik.
  double smoothValue(String key, double rawValue, [double? alpha]) {
    final a = (alpha ?? defaultAlpha).clamp(0.01, 1.0);

    if (!_history.containsKey(key)) {
      _history[key] = rawValue;
      return rawValue;
    }

    final previousSmoothed = _history[key]!;
    final currentSmoothed = (a * rawValue) + ((1.0 - a) * previousSmoothed);

    _history[key] = currentSmoothed;
    return currentSmoothed;
  }

  /// Memperhalus objek [JointAngle].
  JointAngle smoothJointAngle(JointAngle rawAngle, [double? alpha]) {
    final smoothedDeg = smoothValue(
      'joint_${rawAngle.type.name}',
      rawAngle.angle,
      alpha,
    );

    return rawAngle.copyWith(angle: smoothedDeg);
  }

  /// Memperhalus seluruh map [JointAngle].
  Map<JointType, JointAngle> smoothJointAngles(
    Map<JointType, JointAngle> rawAngles, [
    double? alpha,
  ]) {
    final result = <JointType, JointAngle>{};
    for (final entry in rawAngles.entries) {
      result[entry.key] = smoothJointAngle(entry.value, alpha);
    }
    return result;
  }

  /// Reset riwayat smoothing untuk satu key atau seluruhnya.
  void reset([String? key]) {
    if (key != null) {
      _history.remove(key);
    } else {
      _history.clear();
    }
  }
}
