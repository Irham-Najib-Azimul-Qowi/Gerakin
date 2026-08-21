import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_landmark_model.dart';

/// Service terpusat transformasi geometris Komputer Visi.
///
/// Mengubah koordinat mentah ML Kit Pose Landmark (Image Space)
/// menjadi koordinat Canvas Layar UI (Screen Space) secara presisi tanpa offset manual.
///
/// PERHITUNGAN PRESISE:
/// 1. Aspect Ratio Scaling (BoxFit.cover)
/// 2. Crop Offset Offset-X / Offset-Y
/// 3. Sensor Rotation (0°, 90°, 180°, 270°)
/// 4. Front Camera Horizontal Mirroring
class PoseCoordinateTransformer {
  final Size rawImageSize;
  final Size canvasSize;
  final InputImageRotation rotation;
  final bool isFrontCamera;
  final BoxFit fit;

  late final Size rotatedImageSize;
  late final double scale;
  late final double dx;
  late final double dy;

  PoseCoordinateTransformer({
    required this.rawImageSize,
    required this.canvasSize,
    required this.rotation,
    required this.isFrontCamera,
    this.fit = BoxFit.cover,
  }) {
    final bool isRotated90or270 = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    final double imgW = rawImageSize.width;
    final double imgH = rawImageSize.height;

    // MLKit Android/iOS Flutter plugin mentranspose dimensi pada rotasi portrait (90° / 270°)
    final double rotW = isRotated90or270 ? imgH : imgW;
    final double rotH = isRotated90or270 ? imgW : imgH;
    rotatedImageSize = Size(rotW, rotH);

    if (rotW > 0 && rotH > 0 && !canvasSize.isEmpty) {
      final double scaleX = canvasSize.width / rotW;
      final double scaleY = canvasSize.height / rotH;

      // Penskalaan BoxFit.cover vs BoxFit.contain
      scale = fit == BoxFit.cover
          ? math.max(scaleX, scaleY)
          : math.min(scaleX, scaleY);

      final double renderedW = rotW * scale;
      final double renderedH = rotH * scale;

      // Crop Offset untuk full-screen camera preview
      dx = (renderedW - canvasSize.width) / 2.0;
      dy = (renderedH - canvasSize.height) / 2.0;
    } else {
      scale = 1.0;
      dx = 0.0;
      dy = 0.0;
    }
  }

  /// Memetakan koordinat mentah [PoseLandmarkModel] ke [Offset] pada Canvas UI Layar.
  Offset transformLandmark(PoseLandmarkModel landmark) {
    return transformRawPoint(landmark.x, landmark.y);
  }

  /// Memetakan koordinat (rawX, rawY) ke [Offset] Canvas UI Layar.
  Offset transformRawPoint(double rawX, double rawY) {
    if (rotatedImageSize.width == 0 || rotatedImageSize.height == 0) {
      return Offset.zero;
    }

    double x = rawX;
    double y = rawY;

    // Mirroring Horizontal Kamera Depan pada aksis X preview
    if (isFrontCamera) {
      x = rotatedImageSize.width - x;
    }

    // Penskalaan dan pergeseran crop offset
    final double screenX = (x * scale) - dx;
    final double screenY = (y * scale) - dy;

    return Offset(screenX, screenY);
  }

  /// Memetakan [Offset] relatif ke Canvas Layar
  Offset transformOffset(Offset point) {
    return transformRawPoint(point.dx, point.dy);
  }
}
