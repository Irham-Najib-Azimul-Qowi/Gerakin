import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../camera/models/pose_landmark_model.dart';

/// Overlay Visualisasi Skeleton 2D High-Contrast di atas Kamera Fisik.
///
/// GAYA VISUAL:
/// - Bones (Garis Penghubung): Dual-pass (Garis Luar Hitam Pekat 10px + Garis Dalam Cerah 6px)
/// - Joints (Lingkaran Sendi): Outer Ring Hitam (8px) + Inner Circle Putih Cerah (5.5px) + Color Core (3.5px)
/// - Kontras Tinggi: Terlihat sangat jelas dan tegas di atas pakaian/background apapun.
class PoseOverlay extends StatelessWidget {
  const PoseOverlay({
    super.key,
    required this.landmarks,
    this.color = Colors.white,
    this.showHeadTriangle = true,
  });

  final Map<PoseLandmarkType, PoseLandmarkModel> landmarks;
  final Color color;
  final bool showHeadTriangle;

  @override
  Widget build(BuildContext context) {
    if (landmarks.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        painter: _PosePainter(
          landmarks: landmarks,
          color: color,
          showHeadTriangle: showHeadTriangle,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PosePainter extends CustomPainter {
  _PosePainter({
    required this.landmarks,
    required this.color,
    required this.showHeadTriangle,
  });

  final Map<PoseLandmarkType, PoseLandmarkModel> landmarks;
  final Color color;
  final bool showHeadTriangle;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Paint untuk Garis Luar Hitam Pekat (Dark High-Contrast Outline)
    final boneOutlinePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 9.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 2. Paint untuk Garis Tulang Utama (Inner High-Contrast Core Line)
    final bonePaint = Paint()
      ..color = color
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 3. Paint untuk Titik Sendi Lingkaran (Circular Joint Dots)
    final jointOutlinePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final jointWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final jointCorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Pasangan koneksi sendi tubuh utama pengguna kursi roda
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

    // Gambar Garis Skeleton Utama (Pass 1: Outline Hitam, Pass 2: Inti Cerah)
    for (final conn in connections) {
      final p1 = landmarks[conn[0]];
      final p2 = landmarks[conn[1]];

      if (p1 != null && p2 != null && p1.likelihood >= 0.40 && p2.likelihood >= 0.40) {
        final pt1 = Offset(p1.x, p1.y);
        final pt2 = Offset(p2.x, p2.y);

        canvas.drawLine(pt1, pt2, boneOutlinePaint);
        canvas.drawLine(pt1, pt2, bonePaint);
      }
    }

    // Gambar Segitiga Kepala/Leher (jika tersedia landmark hidung & bahu)
    if (showHeadTriangle) {
      final nose = landmarks[PoseLandmarkType.nose];
      final ls = landmarks[PoseLandmarkType.leftShoulder];
      final rs = landmarks[PoseLandmarkType.rightShoulder];

      if (nose != null && ls != null && rs != null &&
          nose.likelihood >= 0.40 && ls.likelihood >= 0.40 && rs.likelihood >= 0.40) {
        final nPt = Offset(nose.x, nose.y);
        final lsPt = Offset(ls.x, ls.y);
        final rsPt = Offset(rs.x, rs.y);

        canvas.drawLine(lsPt, nPt, boneOutlinePaint);
        canvas.drawLine(lsPt, nPt, bonePaint);
        canvas.drawLine(rsPt, nPt, boneOutlinePaint);
        canvas.drawLine(rsPt, nPt, bonePaint);
      }
    }

    // Gambar Titik Sendi Lingkaran Berlapis (Circular Joint Nodes)
    const targetJoints = {
      PoseLandmarkType.nose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
    };

    for (final entry in landmarks.entries) {
      if (!targetJoints.contains(entry.key)) continue;

      final model = entry.value;
      if (model.likelihood >= 0.40) {
        final pt = Offset(model.x, model.y);
        // Outer Ring Hitam (8.0px)
        canvas.drawCircle(pt, 8.0, jointOutlinePaint);
        // Inner Circle Putih (5.5px)
        canvas.drawCircle(pt, 5.5, jointWhitePaint);
        // Core Dot (3.5px)
        canvas.drawCircle(pt, 3.5, jointCorePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PosePainter oldDelegate) {
    return oldDelegate.landmarks != landmarks || oldDelegate.color != color;
  }
}
