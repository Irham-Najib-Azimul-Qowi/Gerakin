import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Hasil transformasi rotasi matriks koordinat mentah.
class RotatedPoint {
  final double x;
  final double y;
  final double effectiveWidth;
  final double effectiveHeight;

  const RotatedPoint({
    required this.x,
    required this.y,
    required this.effectiveWidth,
    required this.effectiveHeight,
  });
}

/// Transformer Rotasi Matriks Komputer Visi Spesifikasi Resmi ML Kit Android.
class RotationTransformer {
  RotationTransformer._();

  /// Mengonversi titik mentah (rawX, rawY) pada dimensi gambar (imgW, imgH)
  /// sesuai dengan [InputImageRotation] dan status [isFrontCamera].
  ///
  /// PADA GOOGLE ML KIT FLUTTER PLUGIN:
  /// PoseDetector internal ML Kit telah memutar koordinat landmark ke dimensi gambar preview.
  /// - Jika portrait (90° / 270°): `effectiveWidth = imgH`, `effectiveHeight = imgW`.
  /// - Jika landscape (0° / 180°): `effectiveWidth = imgW`, `effectiveHeight = imgH`.
  static RotatedPoint transform({
    required double rawX,
    required double rawY,
    required Size imageSize,
    required InputImageRotation rotation,
    required bool isFrontCamera,
  }) {
    final double imgW = imageSize.width;
    final double imgH = imageSize.height;

    final bool isPortrait = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    final double effW = isPortrait ? imgH : imgW;
    final double effH = isPortrait ? imgW : imgH;

    double xRot = rawX;
    double yRot = rawY;

    if (rotation == InputImageRotation.rotation180deg) {
      xRot = effW - rawX;
      yRot = effH - rawY;
    }

    // Mirroring Horizontal Kamera Depan pada aksis X preview
    if (isFrontCamera) {
      xRot = effW - xRot;
    }

    return RotatedPoint(
      x: xRot,
      y: yRot,
      effectiveWidth: effW,
      effectiveHeight: effH,
    );
  }
}
