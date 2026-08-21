import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_landmark_model.dart';
import 'pose_coordinate_transformer.dart';

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

/// Pipeline Transformasi Koordinat Komputer Visi 5-Tahap Terpusat.
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
    final transformer = PoseCoordinateTransformer(
      rawImageSize: rawImageSize,
      canvasSize: canvasSize,
      rotation: rotation,
      isFrontCamera: isFrontCamera,
      fit: fit,
    );

    return CoordinateTransformMetrics(
      rawImageSize: rawImageSize,
      effectivePreviewSize: transformer.rotatedImageSize,
      canvasSize: canvasSize,
      rotation: rotation,
      scaleX: transformer.scale,
      scaleY: transformer.scale,
      scale: transformer.scale,
      offsetX: transformer.dx,
      offsetY: transformer.dy,
      isFrontCamera: isFrontCamera,
    );
  }

  /// Memetakan landmark [PoseLandmarkModel] ke [Offset] pada Canvas layar.
  static Offset mapLandmarkToCanvas({
    required PoseLandmarkModel landmark,
    required CoordinateTransformMetrics metrics,
  }) {
    final transformer = PoseCoordinateTransformer(
      rawImageSize: metrics.rawImageSize,
      canvasSize: metrics.canvasSize,
      rotation: metrics.rotation,
      isFrontCamera: metrics.isFrontCamera,
      fit: BoxFit.cover,
    );

    return transformer.transformLandmark(landmark);
  }
}
