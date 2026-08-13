import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/detected_pose.dart';
import '../services/coordinate_mapper.dart';
import 'pose_connections.dart';
import 'pose_renderer.dart';

/// CustomPainter profesional untuk merender kerangka tubuh (Skeleton Overlay)
/// gaya visual AR Fitness Modern:
/// - Garis Tulang (Bone Lines): Sleek Pure White + Dark Outline Shadow.
/// - Titik Sendi Lingkaran (Joint Nodes): Dynamic Status Color (Green / Yellow / Red) + Soft Neon Glow.
class SkeletonPainter extends CustomPainter {
  SkeletonPainter({
    required this.pose,
    required this.metrics,
    required this.renderer,
    this.minConfidence = 0.20,
    this.skeletonColor = Colors.white,
  });

  final DetectedPose pose;
  final CoordinateTransformMetrics metrics;
  final PoseRenderer renderer;
  final double minConfidence;

  /// Warna dinamis untuk titik sendi (Hijau = Valid/Sukses, Kuning/Merah = Warning/Error)
  final Color skeletonColor;

  // Garis luar/bayangan hitam pekat (Dark Outline Shadow) untuk tulang
  final Paint _boneOutlinePaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.85)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // Garis tulang utama (Pure White Sleek Line)
  final Paint _bonePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // Layer Glow Neon Halus di bawah garis tulang
  final Paint _boneGlowPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.25)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

  // Aura glow sendi dinamis
  final Paint _jointGlowPaint = Paint()
    ..style = PaintingStyle.fill;

  // Lis/pinggiran hitam titik sendi
  final Paint _jointOutlinePaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.85)
    ..style = PaintingStyle.fill;

  // Inti titik sendi (Circle Node dengan Warna Dinamis)
  final Paint _jointPaint = Paint()
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.canvasSize.isEmpty) return;

    // Map penampung titik canvas terpetakan dan confidence asli
    final mappedCanvasOffsets = <PoseLandmarkType, Offset>{};
    final landmarkLikelihoods = <PoseLandmarkType, double>{};

    // 1. Petakan seluruh landmark mentah ke koordinat Canvas dengan smoothing EMA
    for (final lm in pose.landmarks.values) {
      if (lm.isValid(minConfidence)) {
        final smoothedLm = renderer.smoothLandmark(lm);
        final offset = CoordinateMapper.mapLandmarkToCanvas(
          landmark: smoothedLm,
          metrics: metrics,
        );
        mappedCanvasOffsets[lm.type] = offset;
        landmarkLikelihoods[lm.type] = lm.likelihood;
      }
    }

    // 2. Gambar Seluruh Garis Tulang (Bones: HEAD, SHOULDERS, TORSO, ARMS, LEGS) dalam Warna Putih Bersih
    for (final conn in PoseConnections.all) {
      final startOffset = mappedCanvasOffsets[conn.start];
      final endOffset = mappedCanvasOffsets[conn.end];

      if (startOffset != null && endOffset != null) {
        // Ketebalan Anatomis (Proksimal tebal, Distal tipis)
        final double strokeWidth;
        switch (conn.category) {
          case 'torso':
            strokeWidth = 6.5;
            break;
          case 'arm':
            if (conn.start == PoseLandmarkType.leftElbow ||
                conn.start == PoseLandmarkType.rightElbow) {
              strokeWidth = 4.0;
            } else {
              strokeWidth = 5.5;
            }
            break;
          case 'leg':
            strokeWidth = 5.0;
            break;
          case 'head':
          default:
            strokeWidth = 3.5;
            break;
        }

        // 2a. Neon Glow Layer (White Glow)
        _boneGlowPaint.strokeWidth = strokeWidth + 4.0;
        canvas.drawLine(startOffset, endOffset, _boneGlowPaint);

        // 2b. Dark Outline Shadow
        _boneOutlinePaint.strokeWidth = strokeWidth + 3.0;
        canvas.drawLine(startOffset, endOffset, _boneOutlinePaint);

        // 2c. Garis Tulang Utama (Pure White)
        _bonePaint.strokeWidth = strokeWidth;
        canvas.drawLine(startOffset, endOffset, _bonePaint);
      }
    }

    // 3. Gambar Koneksi Atap Kepala (Head Roof Triangle: leftShoulder ↔ nose ↔ rightShoulder)
    final nose = mappedCanvasOffsets[PoseLandmarkType.nose];
    final leftShoulder = mappedCanvasOffsets[PoseLandmarkType.leftShoulder];
    final rightShoulder = mappedCanvasOffsets[PoseLandmarkType.rightShoulder];

    if (nose != null && leftShoulder != null && rightShoulder != null) {
      _bonePaint.strokeWidth = 3.5;
      _boneOutlinePaint.strokeWidth = 6.5;

      canvas.drawLine(leftShoulder, nose, _boneOutlinePaint);
      canvas.drawLine(leftShoulder, nose, _bonePaint);
      canvas.drawLine(rightShoulder, nose, _boneOutlinePaint);
      canvas.drawLine(rightShoulder, nose, _bonePaint);
    }

    // 4. Gambar Titik Sendi Lingkaran (Titik Sendi Dinamis: Hijau/Kuning/Merah)
    const mainBodyJointTypes = {
      PoseLandmarkType.nose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    };

    for (final entry in mappedCanvasOffsets.entries) {
      final type = entry.key;
      if (!mainBodyJointTypes.contains(type)) continue;

      final offset = entry.value;
      final likelihood = landmarkLikelihoods[type] ?? 1.0;

      // Opacity linier berdasarkan confidence landmark
      final opacity = ((likelihood.clamp(0.0, 1.0) - minConfidence) /
              (1.0 - minConfidence))
          .clamp(0.3, 1.0);

      // Aura glow titik sendi (Warna Dinamis: Hijau/Kuning/Merah)
      _jointGlowPaint.color = skeletonColor.withValues(alpha: 0.45 * opacity);
      canvas.drawCircle(offset, 12.0, _jointGlowPaint);

      // Pinggiran hitam pekat
      canvas.drawCircle(offset, 7.5, _jointOutlinePaint);

      // Inti titik sendi (Warna Dinamis: Hijau/Kuning/Merah)
      _jointPaint.color = skeletonColor.withValues(alpha: opacity);
      canvas.drawCircle(offset, 5.0, _jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.metrics.canvasSize != metrics.canvasSize ||
        oldDelegate.skeletonColor != skeletonColor;
  }
}
