import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_landmark_model.dart';
import 'rotation_transformer.dart';

/// Metrik Transformasi Koordinat 5-Tahap untuk rendering dan inspeksi diagnostik overlay.
class CoordinateTransformMetrics {
  final Size rawImageSize;
  final Size effectivePreviewSize;
  final Size canvasSize;
  final InputImageRotation rotation;
  final double scaleX;
  final double scaleY;
  final double scale;
  final double offsetX;
  final double offsetY;
  final bool isFrontCamera;

  const CoordinateTransformMetrics({
    required this.rawImageSize,
    required this.effectivePreviewSize,
    required this.canvasSize,
    required this.rotation,
    required this.scaleX,
    required this.scaleY,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    required this.isFrontCamera,
  });
}

/// Pipeline Transformasi Koordinat Komputer Visi 5-Tahap:
///
/// 1. Raw Image Coordinate (Sensor Space)
/// 2. Rotated Image Coordinate (Rotation Matrix Transformation)
/// 3. Normalized Coordinate (0.0 .. 1.0)
/// 4. Preview Coordinate (Camera Aspect Ratio Space)
/// 5. Canvas Coordinate (Widget Display Space with BoxFit Cover/Contain)
class CoordinateMapper {
  CoordinateMapper._();

  /// Menghitung seluruh metrik transformasi berdasarkan ukuran gambar mentah, ukuran canvas UI, dan rotasi.
  static CoordinateTransformMetrics computeMetrics({
    required Size rawImageSize,
    required Size canvasSize,
    required InputImageRotation rotation,
    required bool isFrontCamera,
    BoxFit fit = BoxFit.cover,
  }) {
    if (rawImageSize.width == 0 || rawImageSize.height == 0 || canvasSize.isEmpty) {
      return CoordinateTransformMetrics(
        rawImageSize: rawImageSize,
        effectivePreviewSize: Size.zero,
        canvasSize: canvasSize,
        rotation: rotation,
        scaleX: 1.0,
        scaleY: 1.0,
        scale: 1.0,
        offsetX: 0.0,
        offsetY: 0.0,
        isFrontCamera: isFrontCamera,
      );
    }

    // Gunakan RotationTransformer untuk mendapatkan dimensi efektif (portrait vs landscape)
    final dummyRotated = RotationTransformer.transform(
      rawX: 0,
      rawY: 0,
      imageSize: rawImageSize,
      rotation: rotation,
      isFrontCamera: isFrontCamera,
    );

    final double previewWidth = dummyRotated.effectiveWidth;
    final double previewHeight = dummyRotated.effectiveHeight;
    final effectivePreviewSize = Size(previewWidth, previewHeight);

    final double scaleX = canvasSize.width / previewWidth;
    final double scaleY = canvasSize.height / previewHeight;

    final double scale = fit == BoxFit.cover
        ? (scaleX > scaleY ? scaleX : scaleY)
        : (scaleX < scaleY ? scaleX : scaleY);

    final double offsetX = (canvasSize.width - (previewWidth * scale)) / 2.0;
    final double offsetY = (canvasSize.height - (previewHeight * scale)) / 2.0;

    return CoordinateTransformMetrics(
      rawImageSize: rawImageSize,
      effectivePreviewSize: effectivePreviewSize,
      canvasSize: canvasSize,
      rotation: rotation,
      scaleX: scaleX,
      scaleY: scaleY,
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
      isFrontCamera: isFrontCamera,
    );
  }

  /// Memetakan landmark [PoseLandmarkModel] ke [Offset] pada Canvas layar.
  static Offset mapLandmarkToCanvas({
    required PoseLandmarkModel landmark,
    required CoordinateTransformMetrics metrics,
  }) {
    if (metrics.rawImageSize.width == 0 || metrics.rawImageSize.height == 0) {
      return Offset.zero;
    }

    // TAHAP 1 & 2: Transformasi Matriks Rotasi ML Kit & Mirroring Kamera Depan
    final rotatedPoint = RotationTransformer.transform(
      rawX: landmark.x,
      rawY: landmark.y,
      imageSize: metrics.rawImageSize,
      rotation: metrics.rotation,
      isFrontCamera: metrics.isFrontCamera,
    );

    // TAHAP 3: Normalisasi Koordinat (0.0 .. 1.0)
    final double normX = (rotatedPoint.x / rotatedPoint.effectiveWidth).clamp(0.0, 1.0);
    final double normY = (rotatedPoint.y / rotatedPoint.effectiveHeight).clamp(0.0, 1.0);

    // TAHAP 4: Penskalaan ke Ruang Preview Kamera
    final double previewX = normX * metrics.effectivePreviewSize.width;
    final double previewY = normY * metrics.effectivePreviewSize.height;

    // TAHAP 5: Penskalaan & Offset ke Canvas UI Layar (BoxFit Cover/Contain)
    final double canvasX = (previewX * metrics.scale) + metrics.offsetX;
    final double canvasY = (previewY * metrics.scale) + metrics.offsetY;

    return Offset(canvasX, canvasY);
  }
}
