import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../camera/models/detected_pose.dart';
import '../../../camera/models/pose_landmark_model.dart';
import '../../../camera/services/pose_coordinate_transformer.dart';
import '../../logic/seated_posture_validator.dart';

/// Overlay Visualisasi Skeleton 2D High-Contrast dengan Transformasi Geometris Presisi.
///
/// PERBAIKAN UTAMA:
/// 1. Menggunakan [PoseCoordinateTransformer] untuk konversi geometris presisi (Scale, Crop, Mirror).
/// 2. Skeleton Full-Body Lengkap (Kepala, Neck Virtual Node, Torso, Spine, Arm, Legs).
/// 3. Memastikan pemetaan anatomis kiri/kanan konsisten tanpa manual offset hack.
/// 4. Mendukung Mode Debug dengan label anatomis & crosshair titik sendi.
class PoseOverlay extends StatelessWidget {
  const PoseOverlay({
    super.key,
    required this.pose,
    this.color = Colors.white,
    this.postureState = UserPostureState.sitting,
    this.showDebugHUD = false,
  });

  final DetectedPose? pose;
  final Color color;
  final UserPostureState postureState;
  final bool showDebugHUD;

  @override
  Widget build(BuildContext context) {
    if (pose == null || pose!.landmarks.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        final transformer = PoseCoordinateTransformer(
          rawImageSize: pose!.imageSize,
          canvasSize: canvasSize,
          rotation: pose!.rotation,
          isFrontCamera: pose!.isFrontCamera,
          fit: BoxFit.cover,
        );

        return IgnorePointer(
          child: CustomPaint(
            painter: _FullBodyPosePainter(
              landmarks: pose!.landmarks,
              transformer: transformer,
              color: postureState == UserPostureState.standing
                  ? Colors.orangeAccent
                  : color,
              showDebugHUD: showDebugHUD,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _FullBodyPosePainter extends CustomPainter {
  _FullBodyPosePainter({
    required this.landmarks,
    required this.transformer,
    required this.color,
    required this.showDebugHUD,
  });

  final Map<PoseLandmarkType, PoseLandmarkModel> landmarks;
  final PoseCoordinateTransformer transformer;
  final Color color;
  final bool showDebugHUD;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Catat seluruh koordinat Canvas yang telah di-transform presisi
    final screenPoints = <PoseLandmarkType, Offset>{};

    for (final entry in landmarks.entries) {
      final model = entry.value;
      if (model.likelihood >= 0.38) {
        screenPoints[entry.key] = transformer.transformLandmark(model);
      }
    }

    // 2. Paint untuk Garis Luar Hitam Pekat (Dark High-Contrast Outline)
    final boneOutlinePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 3. Paint untuk Garis Tulang Utama (Inner High-Contrast Core Line)
    final bonePaint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 4. Paint untuk Spine Center Line (Garis Tulang Belakang Halus)
    final spinePaint = Paint()
      ..color = color.withValues(alpha: 0.65)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 5. Paint untuk Titik Sendi Lingkaran (Circular Joint Nodes)
    final jointOutlinePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final jointWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final jointCorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // ── GANDER BONES KEPALA & VIRTUAL NECK NODE ─────────────────────
    final nose = screenPoints[PoseLandmarkType.nose];
    final ls = screenPoints[PoseLandmarkType.leftShoulder];
    final rs = screenPoints[PoseLandmarkType.rightShoulder];

    if (nose != null && ls != null && rs != null) {
      final shoulderCenter = Offset((ls.dx + rs.dx) / 2.0, (ls.dy + rs.dy) / 2.0);
      final neck = Offset.lerp(shoulderCenter, nose, 0.35)!;

      // Nose -> Neck -> Left/Right Shoulder
      _drawBone(canvas, nose, neck, boneOutlinePaint, bonePaint);
      _drawBone(canvas, neck, ls, boneOutlinePaint, bonePaint);
      _drawBone(canvas, neck, rs, boneOutlinePaint, bonePaint);
    }

    // ── KONEKSI FULL-BODY SKELETON (TORSO, ARMS, LEGS) ──────────────
    final connections = [
      // Torso & Pelvis
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],

      // Upper Limbs (Left & Right Arms)
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],

      // Lower Limbs (Left & Right Legs)
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],

      // Feet (Jika reliable)
      [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel],
      [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel],
    ];

    for (final conn in connections) {
      final p1 = screenPoints[conn[0]];
      final p2 = screenPoints[conn[1]];

      if (p1 != null && p2 != null) {
        _drawBone(canvas, p1, p2, boneOutlinePaint, bonePaint);
      }
    }

    // Garis Tulang Belakang (Center Spine: Shoulder Center ↔ Hip Center)
    final lh = screenPoints[PoseLandmarkType.leftHip];
    final rh = screenPoints[PoseLandmarkType.rightHip];

    if (ls != null && rs != null && lh != null && rh != null) {
      final shoulderCenter = Offset((ls.dx + rs.dx) / 2.0, (ls.dy + rs.dy) / 2.0);
      final hipCenter = Offset((lh.dx + rh.dx) / 2.0, (lh.dy + rh.dy) / 2.0);
      canvas.drawLine(shoulderCenter, hipCenter, spinePaint);
    }

    // ── GAMBAR TITIK SENDI LINGKARAN BERLAPIS (JOINT NODES) ─────────
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
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    };

    for (final entry in screenPoints.entries) {
      if (!targetJoints.contains(entry.key)) continue;

      final pt = entry.value;
      // Outer Ring Hitam (8.5px)
      canvas.drawCircle(pt, 8.5, jointOutlinePaint);
      // Inner Circle Putih (6.0px)
      canvas.drawCircle(pt, 6.0, jointWhitePaint);
      // Core Dot Warna (3.5px)
      canvas.drawCircle(pt, 3.5, jointCorePaint);
    }

    // ── DEBUG HUD OVERLAY (LABEL ANATOMIS & CROSSHAIR DETEKSI) ──────
    if (showDebugHUD) {
      _drawDebugLabels(canvas, screenPoints);
    }
  }

  void _drawBone(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint outlinePaint,
    Paint mainPaint,
  ) {
    canvas.drawLine(p1, p2, outlinePaint);
    canvas.drawLine(p1, p2, mainPaint);
  }

  void _drawDebugLabels(Canvas canvas, Map<PoseLandmarkType, Offset> points) {
    final textStyle = const TextStyle(
      color: Colors.yellowAccent,
      fontSize: 10,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.black54,
    );

    const labels = {
      PoseLandmarkType.leftShoulder: 'LS',
      PoseLandmarkType.rightShoulder: 'RS',
      PoseLandmarkType.leftElbow: 'LE',
      PoseLandmarkType.rightElbow: 'RE',
      PoseLandmarkType.leftWrist: 'LW',
      PoseLandmarkType.rightWrist: 'RW',
      PoseLandmarkType.leftHip: 'LH',
      PoseLandmarkType.rightHip: 'RH',
      PoseLandmarkType.leftKnee: 'LK',
      PoseLandmarkType.rightKnee: 'RK',
      PoseLandmarkType.leftAnkle: 'LA',
      PoseLandmarkType.rightAnkle: 'RA',
    };

    for (final entry in labels.entries) {
      final pt = points[entry.key];
      if (pt != null) {
        // Red debug dot
        canvas.drawCircle(pt, 3.0, Paint()..color = Colors.red);

        final textSpan = TextSpan(text: ' ${entry.value} ', style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(pt.dx + 6, pt.dy - 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FullBodyPosePainter oldDelegate) {
    return oldDelegate.landmarks != landmarks || oldDelegate.color != color;
  }
}
