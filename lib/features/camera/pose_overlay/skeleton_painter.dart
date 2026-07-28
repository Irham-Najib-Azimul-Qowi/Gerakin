import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/detected_pose.dart';
import '../services/coordinate_mapper.dart';
import 'pose_connections.dart';
import 'pose_renderer.dart';

/// CustomPainter profesional untuk merender kerangka tubuh (Skeleton Overlay)
/// persis sesuai gaya visual AR Fitness / Rehabilitasi (Pure White Lines + Dark Outline Shadow).
class SkeletonPainter extends CustomPainter {
  SkeletonPainter({
    required this.pose,
    required this.metrics,
    required this.renderer,
    this.minConfidence = 0.20,
  });

  final DetectedPose pose;
  final CoordinateTransformMetrics metrics;
  final PoseRenderer renderer;
  final double minConfidence;

  // Garis luar/bayangan hitam pekat (Dark Outline Shadow)
  final Paint _boneOutlinePaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.85)
    ..strokeWidth = 8.5
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // Garis tulang utama (Pure White)
  final Paint _bonePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 5.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // Aura glow sendi
  final Paint _jointGlowPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.25)
    ..style = PaintingStyle.fill;

  // Lis/pinggiran hitam titik sendi
  final Paint _jointOutlinePaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.85)
    ..style = PaintingStyle.fill;

  // Titik inti sendi (Pure White Circle Node)
  final Paint _jointPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.canvasSize.isEmpty) return;

    // Map penampung titik canvas terpetakan
    final mappedCanvasOffsets = <PoseLandmarkType, Offset>{};

    // 1. Petakan seluruh landmark mentah ke koordinat Canvas dengan smoothing EMA
    for (final lm in pose.landmarks.values) {
      if (lm.isValid(minConfidence)) {
        final smoothedLm = renderer.smoothLandmark(lm);
        final offset = CoordinateMapper.mapLandmarkToCanvas(
          landmark: smoothedLm,
          metrics: metrics,
        );
        mappedCanvasOffsets[lm.type] = offset;
      }
    }

    // 2. Gambar Seluruh Garis Tulang (Bones: HEAD, SHOULDERS, TORSO, ARMS, LEGS)
    for (final conn in PoseConnections.all) {
      final startOffset = mappedCanvasOffsets[conn.start];
      final endOffset = mappedCanvasOffsets[conn.end];

      if (startOffset != null && endOffset != null) {
        // Dark outline shadow
        canvas.drawLine(startOffset, endOffset, _boneOutlinePaint);
        // Garis putih di atasnya
        canvas.drawLine(startOffset, endOffset, _bonePaint);
      }
    }

    // 3. Gambar Koneksi Geometris Atap Kepala (Head Roof Trap/Triangle: leftShoulder ↔ nose ↔ rightShoulder)
    final nose = mappedCanvasOffsets[PoseLandmarkType.nose];
    final leftShoulder = mappedCanvasOffsets[PoseLandmarkType.leftShoulder];
    final rightShoulder = mappedCanvasOffsets[PoseLandmarkType.rightShoulder];

    if (nose != null && leftShoulder != null && rightShoulder != null) {
      canvas.drawLine(leftShoulder, nose, _boneOutlinePaint);
      canvas.drawLine(leftShoulder, nose, _bonePaint);
      canvas.drawLine(rightShoulder, nose, _boneOutlinePaint);
      canvas.drawLine(rightShoulder, nose, _bonePaint);
    }

    // 4. Gambar Titik Sendi (Joint Circle Nodes)
    for (final entry in mappedCanvasOffsets.entries) {
      final offset = entry.value;

      // Aura glow halus
      canvas.drawCircle(offset, 12.0, _jointGlowPaint);
      // Pinggiran hitam
      canvas.drawCircle(offset, 8.0, _jointOutlinePaint);
      // Inti putih bersih
      canvas.drawCircle(offset, 5.5, _jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) {
    return oldDelegate.pose != pose || oldDelegate.metrics.canvasSize != metrics.canvasSize;
  }
}
