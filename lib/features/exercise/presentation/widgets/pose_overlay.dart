import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../camera/models/pose_landmark_model.dart';

/// Overlay Visualisasi Skeleton 2D di atas Kamera Fisik.
class PoseOverlay extends StatelessWidget {
  const PoseOverlay({
    super.key,
    required this.landmarks,
    this.color = const Color(0xFF00BFA5),
  });

  final Map<PoseLandmarkType, PoseLandmarkModel> landmarks;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (landmarks.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        painter: _PosePainter(landmarks: landmarks, color: color),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PosePainter extends CustomPainter {
  _PosePainter({
    required this.landmarks,
    required this.color,
  });

  final Map<PoseLandmarkType, PoseLandmarkModel> landmarks;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Pasangan koneksi sendi tubuh utama
    final connections = [
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    ];

    // Gambar Garis Skeleton
    for (final conn in connections) {
      final p1 = landmarks[conn[0]];
      final p2 = landmarks[conn[1]];

      if (p1 != null && p2 != null && p1.likelihood >= 0.45 && p2.likelihood >= 0.45) {
        canvas.drawLine(
          Offset(p1.x, p1.y),
          Offset(p2.x, p2.y),
          linePaint,
        );
      }
    }

    // Gambar Titik Landmark Sendi
    for (final model in landmarks.values) {
      if (model.likelihood >= 0.45) {
        final pt = Offset(model.x, model.y);
        canvas.drawCircle(pt, 5.5, dotPaint);
        canvas.drawCircle(pt, 5.5, dotBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PosePainter oldDelegate) => true;
}
