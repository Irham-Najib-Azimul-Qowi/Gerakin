import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Helper perhitungan matematika vektor & sudut sendi tubuh.
class AngleCalculator {
  const AngleCalculator._();

  /// Menghitung sudut dalam derajat antara 3 titik [a], [b], dan [c] dengan [b] sebagai Vertex.
  ///
  /// Menggunakan formula Dot-Product Vector dengan pencengkeraman (clamping) nilai kosinus
  /// pada rentang [-1.0, 1.0] untuk mencegah kesalahan NaN (Not a Number).
  static double calculateAngle(Offset a, Offset b, Offset c) {
    final double abX = a.dx - b.dx;
    final double abY = a.dy - b.dy;
    final double cbX = c.dx - b.dx;
    final double cbY = c.dy - b.dy;

    final double dotProduct = (abX * cbX) + (abY * cbY);
    final double magAB = math.sqrt((abX * abX) + (abY * abY));
    final double magCB = math.sqrt((cbX * cbX) + (cbY * cbY));

    if (magAB == 0.0 || magCB == 0.0) {
      return 0.0;
    }

    final double cosTheta = (dotProduct / (magAB * magCB)).clamp(-1.0, 1.0);
    final double angleInRadians = math.acos(cosTheta);

    return angleInRadians * (180.0 / math.pi);
  }

  /// Menghitung sudut kemiringan vertikal (elevasi) garis AB terhadap sumbu vertikal Y.
  static double calculateVerticalElevationAngle(Offset a, Offset b) {
    final double dx = b.dx - a.dx;
    final double dy = b.dy - a.dy;

    final double mag = math.sqrt(dx * dx + dy * dy);
    if (mag == 0) return 0.0;

    // dy positif ke bawah pada koordinat layar
    final double cosTheta = (-dy / mag).clamp(-1.0, 1.0);
    final double angleInRadians = math.acos(cosTheta);

    return angleInRadians * (180.0 / math.pi);
  }

  /// Menghitung sudut rotasi horizontal antara 2 mata/telinga terhadap garis bahu.
  static double calculateHorizontalDisplacement(Offset left, Offset right) {
    return (left.dx - right.dx).abs();
  }
}

/// Exponential Moving Average (EMA) Smoother untuk mengurangi jitter data landmark.
class EmaSmoother {
  EmaSmoother({this.alpha = 0.35});

  final double alpha;
  double? _previousValue;

  double smooth(double currentValue) {
    if (_previousValue == null) {
      _previousValue = currentValue;
      return currentValue;
    }

    final smoothed = (alpha * currentValue) + ((1.0 - alpha) * _previousValue!);
    _previousValue = smoothed;
    return smoothed;
  }

  void reset() {
    _previousValue = null;
  }
}
